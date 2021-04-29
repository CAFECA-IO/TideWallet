# Getting Started
1. Set [develop env](#Develop) (vscode)
2. Set [database config](#DB)



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
            "program": "lib/main_dev.dart", 
            "args": [    
                "--flavor",   
                "dev"     
            ]
        },  
        {  
            "name": "Production",  
            "request": "launch", 
            "type": "dart", 
            "program": "lib/main_prod.dart",  
            "args": [       
                "--flavor",   
                "prod"  
            ]     
        }  
    ]
}
```

## Firebase

**Android:**

`Add google-services.json to:`

1. android/app/src/debug
2. android/app/src/release


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