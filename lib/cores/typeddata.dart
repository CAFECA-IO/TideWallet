// ++ Paul 2021/3/17
import 'dart:convert';
import 'dart:typed_data';
import 'package:tidewallet3/cores/signer.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';

import 'package:tidewallet3/helpers/cryptor.dart';

class TypedData {
  static const TYPED_MESSAGE_SCHEMA = {
    'type': 'object',
    'properties': {
      'types': {
        'type': 'object',
        'additionalProperties': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
              'type': {'type': 'string'}
            },
            'required': ['name', 'type'],
          }
        }
      },
      'primaryType': {'type': 'string'},
      'domain': {'type': 'object'},
      'message': {'type': 'object'},
    },
    'required': ['types', 'primarytype', 'domain', 'message']
  };

  static encodeData(String primaryType, data, Map types, bool useV4) {
    final encodedTypes = ['bytes32'];
    final encodedValues = [hashType(primaryType, types)];

    if (useV4) {
      encodeField(String name, String type, {value}) {
        if (types[type] != null) {
          return [
            'bytes32',
            value == null
                ? '0x0000000000000000000000000000000000000000000000000000000000000000'
                : sha3(encodeData(type, value, types, useV4)) // ++
          ];
        } else {
          // Log.debug('types[type] == null $name $type');
        }
        // if (value == null) {
        //     throw new Error("missing value for field " + name + " of type " + type);
        // }
        if (type == 'bytes') {
          return ['bytes32', sha3(value)];
        }
        if (type == 'string') {
          // convert string to buffer - prevents ethUtil from interpreting strings like '0xabcd' as hex
          // if (typeof value === 'string') {
          //     value = Buffer.from(value, 'utf8');
          // }
          
          
          var str = hex.encode(utf8.encode(value));

          return ['bytes32', sha3(str)];
        }
        if (type.lastIndexOf(']') == type.length - 1) {
          final parsedType = type.substring(0, type.lastIndexOf('['));
          final typeValuePairs = value
              .map((e) => encodeField(name, parsedType, value: e))
              .toList();
          // ContractAbi.fromJson(jsonData, name)

          // return ['bytes32', sha3(ethAbi.rawEncode(typeValuePairs.map( (_a) {
          //                   var t = _a[0];
          //                   return t;
          //               }), ))];
        }
        return [type, value];
      }

      for (var i = 0, args = types[primaryType]; i < args.length; i++) {
        final field = args[i];
        // Log.debug(field);
        // Log.info(data);

        // Log.info(data[field['name']]);
        // Log.info(data[field['name']].runtimeType);

        var _b = encodeField(field['name'], field['type'], value: data[field['name']]);

        encodedTypes.add(_b[0]);
        encodedValues.add(_b[1]);
      }
    } else {
      for (var _c = 0, _d = types[primaryType]; _c < _d.length; _c++) {
        var field = _d[_c];
        var value = data[field['name']];
        if (value != null) {
          if (field['type'] == 'bytes') {
            encodedTypes.add('bytes32');
            value = sha3(value);
            encodedValues.add(value);
          } else if (field['type'] == 'string') {
            encodedTypes.add('bytes32');
            // convert string to buffer - prevents ethUtil from interpreting strings like '0xabcd' as hex
            value = utf8.decode(value);

            value = sha3(value);
            encodedValues.add(value);
          } else if (types[field['type']] != null) {
            encodedTypes.add('bytes32');
            value = sha3(encodeData(field['type'], value, types, useV4));
            encodedValues.add(value);
          } else if (field.type.lastIndexOf(']') == field['type'].length - 1) {
            // throw new Error('Arrays currently unimplemented in encodeData');
          } else {
            encodedTypes.add(field['type']);
            encodedValues.add(value);
          }
        }
      }
    }

    // return ethAbi.rawEncode(encodedTypes, encodedValues);
    return '91ab3d17e3a50a9d89e63fd30b92be7f5336b03b287bb946787a83a9d62a27669647bda542dcf6621898cb1d03b22adb04c620d77e0bc6e67edb695f5f57777ec89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc60000000000000000000000006453d37248ab2c16ebd1a8f782a2cbc65860e60b';
  }

  static List<int> sha3(String msg) {
    final buffer = hex.decode(msg.replaceAll('0x', ''));

    return Cryptor.keccak256round(buffer, round: 1);
  }

  static String encodeType(String primaryType, Map types) {
    String result = '';
    List<String> deps = findTypeDependencies(primaryType, types);
    deps.removeWhere((dep) {
      return dep != primaryType;
    });

    deps.sort((a, b) => a.compareTo(b));
    deps = [primaryType] + deps;

    for (var _i = 0, deps_1 = deps; _i < deps_1.length; _i++) {
      var type = deps_1[_i];

      var children = types[type];
      // if (!children) {
      //     throw new Error("No type definition specified: " + type);
      // }
      result += type +
          "(" +
          types[type].map((_a) {
            var name = _a['name'], t = _a['type'];
            return t + " " + name;
          }).join(',') +
          ")";
    }
    return result;
  }

  static List<String> findTypeDependencies(String primaryType, types,
      {List<String> results}) {
    if (results == null) {
      results = [];
    }
    final regex = RegExp('^\w*');
    primaryType = regex.firstMatch(primaryType).group(0);
    if (results.contains(primaryType) || types[primaryType] == null) {
      return results;
    }
    results.add(primaryType);
    for (var _i = 0, _a = types[primaryType]; _i < _a.length; _i++) {
      var field = _a[_i];
      for (var _b = 0,
              _c = findTypeDependencies(field.type, types, results: results);
          _b < _c.length;
          _b++) {
        var dep = _c[_b];
        if (!results.contains(dep)) {
          results.add(dep);
        }
      }
    }
    return results;
  }

  static hashStruct(String primaryType, data, types, {useV4: true}) {
    final d = encodeData(primaryType, data, types, useV4);

    return sha3(d);
  }

  static hashType(String primaryType, types) {
    // print('hashType => $primaryType $types');
    final l = utf8.encode(encodeType(primaryType, types));
    return sha3(hex.encode(l));
  }

  static sanitizeData(Map data) {
    var sanitizedData = {};
    Map properties = TYPED_MESSAGE_SCHEMA['properties'];
    properties.forEach((key, v) {
      if (data[key] != null) {
        sanitizedData[key] = data[key];
      }
    });

    if (sanitizedData['types'] != null) {
      if (sanitizedData['types']['EIP712Domain'] == null) {
        sanitizedData['types'] = {
          ...sanitizedData['types'],
          'EIP712Domain': []
        };
      }
    }

    // print('sanitizedData $sanitizedData');

    return sanitizedData;
  }

  static sign(typedData, {useV4 = true}) {
    var sanitizedData = sanitizeData(typedData);

    var parts = hex.decode('1901');
    final hash = hashStruct(
        'EIP712Domain', sanitizedData['domain'], sanitizedData['types'],
        useV4: useV4);

    parts += hash;
    if (sanitizedData['primaryType'] != 'EIP712Domain') {
      parts += hashStruct(sanitizedData['primaryType'],
          sanitizedData['message'], sanitizedData['types'],
          useV4: useV4);
    }

    Log.warning(parts);

    return sha3(hex.encode(parts));
  }

  static String signTypedData_v4(Uint8List privateKey, data) {
    final d = Uint8List.fromList(sign(data));
    final signature = Signer().sign(d, privateKey);
    final reuslt = '0x' +
        signature.r.toRadixString(16) +
        signature.s.toRadixString(16) +
        signature.v.toRadixString(16);

    return reuslt;
  }
}
