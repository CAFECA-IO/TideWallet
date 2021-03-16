import 'package:tidewallet3/helpers/cryptor.dart';
import 'package:convert/convert.dart';

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

  static encodeData(String primaryType, data, types, bool useV4) {
    final encodedTypes = ['bytes32'];
    final encodedValues = [hashType(primaryType, types)];

    if (useV4) {
      encodeField(String name, String type, List value) {
        if (type.lastIndexOf(']') == type.length - 1) {
          final parsedType = type.substring(0, type.lastIndexOf('['));
          final typeValuePairs =
              value.map((e) => encodeField(name, parsedType, e)).toList();

          // TODO:
          // return ['bytes32', sha3(ethAbi.rawEncode(typeValuePairs.map( (_a) {
          //                   var t = _a[0];
          //                   return t;
          //               }), typeValuePairs.map( (_a) {
          //                   var v = _a[1];
          //                   return v;
          //               })))];
        }
        return [type, value];
      }

      for (var i = 0, a = types[primaryType]; i < a.length; i++) {
        final field = a[i];
        var _b = encodeField(field.name, field.type, data[field.name]),
            type = _b[0],
            value = _b[1];
        encodedTypes.add(type);
        encodedValues.add(value);
      }
    } else {}
  }

  static sha3(String msg) {
    final buffer = hex.decode(msg);

    Cryptor.keccak256round(buffer, round: 1);
  }

  static hashType(primaryType, types) {
    return sha3(encodeType(primaryType, types));
  }

  static String encodeType(String primaryType, Map types) {
    String result = '';
    var deps = findTypeDependencies(primaryType, types);
    deps.removeWhere((dep) {
      return dep != primaryType;
    });
    // TODO:
    // deps = [primaryType] + deps.sort();
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
            var name = _a.name, t = _a.type;
            return t + " " + name;
          }).join(',') +
          ")";
    }
    return result;
  }

  static List findTypeDependencies(String primaryType, types, {List results}) {
    if (results == null) {
      results = [];
    }
    // TODO:
    // primaryType = primaryType.match(/^\w*/u)[0];
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
}
