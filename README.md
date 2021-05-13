# Getting Started
1. Set [develop env](#Develop) (vscode)
2. Set [database config](#DB)
3. [Release](#Release)



## Flutter
- version: 2.0.3


## Upgrade
```
flutter upgrade
flutter clean
flutter pub get

cd ios
rm -rf Pods
rm -rf Flutter/Flutter.framework
pod install

```

## Develop
`.vscode/launch.json`
```
{
    "version": "0.2.0",
    "configurations": [
        {   
            "name": "Development",  
            "request": "launch", 
            "type": "dart",       
            "program": "lib/main.dart", 
            "args": [    
                "--flavor",   
                "development"     
            ]
        },  
        {  
            "name": "Production",  
            "request": "launch", 
            "type": "dart", 
            "program": "lib/main.dart",  
            "args": [       
                "--flavor",   
                "production"  
            ]     
        }  
    ]
}
```

## Release
- Android
    ```sh
    flutter build apk --falvor production
    // or flutter build appbundle --falvor production
    ```

- iOS
    1. XCode select Production scheme
    2. Make sure Archive `Build Configureation` using `Release-Production`
## Firebase

**Android:**

`Add google-services.json to:`

1. android/app/src/debug
    - /development
    - /production
2. android/app/src/release
    - /development
    - /production

**iOS:**

`Add google-services.json to:`

1. ios/Runner/Firebase/Development
2. ios/Runner/Firebase/Production
  


### FCM
```
//
```
### Google Sign In

`Add sha1, sha256 to Firebase Console`

        ```
        // find your sha key
        keytool -list -v \ -alias androiddebugkey -keystore ~/.android/debug.keystore
        ```


### DB
* If is using first time or changing ./lib/database run:

```
flutter packages pub run build_runner build // or flutter packages pub run build_runner build  watch
```  


### DB Schema
> ./doc/TideWallet_DBSchema_Diagram.drawio
![](./doc/TideWallet_DBSchema_Diagram.png)

### Class Definition
> ./doc/TideWallet_ClassDefinition_Diagram.drawio
![](./doc/TideWallet_ClassDefinition_Diagram.png)

### Interaction Diagram
> ./doc/TideWallet_Interaction_Diagram_1_CreateWallet.drawio
![](./doc/TideWallet_Interaction_Diagram_1_CreateWallet.png)

> ./doc/TideWallet_Interaction_Diagram_2_RestoreWallet.drawio
![](./doc/TideWallet_Interaction_Diagram_2_RestoreWallet.png)

> ./doc/TideWallet_Interaction_Diagram_3_ServiceStart.drawio
![](./doc/TideWallet_Interaction_Diagram_3_ServiceStart.png)

> ./doc/TideWallet_Interaction_Diagram_4_CreateToken.drawio
![](./doc/TideWallet_Interaction_Diagram_4_CreateToken.png)

> ./doc/TideWallet_Interaction_Diagram_ReadTransaction.drawio
![](./doc/TideWallet_Interaction_Diagram_ReadTransaction.png)

> ./doc/TideWallet_Interaction_Diagram_CreateTransaction.drawio
![](./doc/TideWallet_Interaction_Diagram_CreateTransaction.png)

> ./doc/TideWallet_Interaction_Diagram_ReceivePayment.drawio
![](./doc/TideWallet_Interaction_Diagram_ReceivePayment.png)

> ./doc/TideWallet_Interaction_Diagram_BackupWallet.drawio
![](./doc/TideWallet_Interaction_Diagram_BackupWallet.png)

### UI Logic
> ./doc/LandingScreen.drawio
![](./doc/LandingScreen.png)

> ./doc/WelcomeScreen.drawio
![](./doc/WelcomeScreen.png)

> ./doc/RestoreWalletScreen.drawio
![](./doc/RestoreWalletScreen.png)

> ./doc/AccountScreen.drawio
![](./doc/AccountScreen.png)

> ./doc/CurrencyScreen.drawio
![](./doc/CurrencyScreen.png)

this is another version
