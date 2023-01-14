# UniPassSDK

[![CI Status](https://img.shields.io/travis/UniPassSDK/UniPassSDK.svg?style=flat)](https://travis-ci.org/UniPassSDK/UniPassSDK)
[![Version](https://img.shields.io/cocoapods/v/UniPassSDK.svg?style=flat)](https://cocoapods.org/pods/UniPassSDK)
[![License](https://img.shields.io/cocoapods/l/UniPassSDK.svg?style=flat)](https://cocoapods.org/pods/UniPassSDK)
[![Platform](https://img.shields.io/cocoapods/p/UniPassSDK.svg?style=flat)](https://cocoapods.org/pods/UniPassSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

UniPassSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UniPassSDK'
```

## How to Use

### Initialization

`UniPassSDK` should be initialized at the beginning, here is the code sample for initialization.

```swift
   // init app setting
   let setting = UniPassSDKAppSetting()
   setting.appName = "testWallect"
   setting.chain = .polygon
   setting.theme = .dark
   
   // init sdk option
   let option = UniPassSDKOption()
   option.environment = .Testnet
   option.appSetting = setting
   option.context = self
   
   // init UniPassSDK
   let unipassSdk = UniPassSDK(sdkOption: option)
```

### Login

After the initialization is complete, invoke the `login` method to get information about the UniPass Account `UniPassUserInfo`.

UniPass currently supports customizing specific connect type for `login`. Currently, the login connect type provided are: `google` `email` `both`

Sample code for `login`
```swift 
    func loginBtnClicked(loginType: ConnectType) {
        unipassSdk?.logIn(loginType: loginType, loginSuccessBlock: { userinfo in
            print("unipassSdk: Login successfully ✅")
            self.userIdLabel?.text = userinfo.address
        }, loginErrorBlock: { error in
            print("unipassSdk: Login failed ❎", error)
        })
    }

```

### SignMessage

Use UniPass Wallet to sign the specified message, which can be done by calling `signMessage`. There are two message signature methods, `PersonalSign` and `SignTypedData`

```swift
    func signMessageBtnClicked() {
        if let userInfo = unipassSdk?.getUserInfo() {
            let signInput = UniPassSignInput()
            signInput.from = userInfo.address
            signInput.type = UniPassSignType.PersonalSign
            signInput.msg = signTextField?.text ?? "Test Sign Message"
                
            unipassSdk?.signMessage(signInput, SuccessBlock: { signature in
                print("unipassSdk: sign message successfully ✅", signature)
                self.signatureLabel?.text = signature
            }, ErrorBlock: { error in
                print("unipassSdk: sign message failed ❎", error)
            })
        } else {
            print("unipassSdk: user not login ❎")
        }
    }
```

### SendTransaction

```swift

    func transctionBtnBtnClicked() {
        if let userInfo = unipassSdk?.getUserInfo() {
            let tx = UniPassTransaction()
            tx.from = userInfo.address
            tx.to = "0x635b8f68aa1407712a3158782A7E21833bB392CC"
            tx.value = "0x38d7ea4c68000"

                unipassSdk?.sendTransaction(tx, SuccessBlock: { transactionHash in
                    print("unipassSdk: send transaction success ✅", transactionHash)
                    self.transactionHashLabel?.text = transactionHash
                }, ErrorBlock: { error in
                    print("unipassSdk: send transaction failed ❎", error)
                })
        } else {
            print("unipassSdk: user not login ❎")
        }
    }

```

### Logout

Log out UniPass Wallet

```swift
    func logoutBtnClicked() {
        unipassSdk?.logOut(logOutSuccessBlock: {
            print("unipassSdk: Logout successfully ✅")
            self.refreshUI()
        }, logoutErrorBlock: { error in
            print("unipassSdk: Logout failed ❎", error)
        })
    }
```

### Error Definitions

```swift
    public enum UniPassError: Error {
        case noBundleIdentifierFound
        case userNotLogin
        case userCancelled(msg: String?)
        case appCancelled
        case invalidFromAddress
        case invalidTransaction
        case unknownError
        case runtimeError(msg: String)
        case decodingError
        case encodingError
    }
```

## Author

UnipassSDK, johnz@lay2.dev

## License

UnipassSDK is available under the MIT license. See the LICENSE file for more info.
