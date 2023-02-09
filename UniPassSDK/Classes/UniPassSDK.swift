//
//  UnipassSDK.swift
//  UnipassWallet
//
//

import AuthenticationServices
import SafariServices
import UIKit

public class UniPassSDK: NSObject {
    var option: UniPassSDKOption = UniPassSDKOption()

    private var walletUrl: String = ""
    private var supportLoginType: ConnectType = ConnectType.both
    private var authSession: ASWebAuthenticationSession!

    public init(sdkOption: UniPassSDKOption) {
        super.init()
        option = sdkOption
        if sdkOption.walletUrl.count == 0 {
            walletUrl = sdkOption.environment == .Mainnet ? "https://wallet.unipass.id" : "https://testnet.wallet.unipass.id"
        } else {
            walletUrl = sdkOption.walletUrl
        }

        if option.appSetting == nil {
            option.appSetting = UniPassSDKAppSetting()
        }
    }

    public func logIn(loginSuccessBlock: @escaping (UniPassUserInfo) -> Void, loginErrorBlock: @escaping (UniPassError) -> Void) {
        logIn(loginSuccessBlock: loginSuccessBlock, loginErrorBlock: loginErrorBlock, loginOption: nil)
    }

    /// Login Unipass Wallet
    /// - Parameters:
    ///   - loginSuccessBlock: success callback for login function, user info will be returned and cached
    ///   - loginErrorBlock: error callback for login function, error code and message be returned
    ///   - loginOption: the login optoins, inlcuding connect type, return email, authorize etc.
    public func logIn(loginSuccessBlock: @escaping (UniPassUserInfo) -> Void, loginErrorBlock: @escaping (UniPassError) -> Void, loginOption: UniPassSDKLoginOption?) {
        supportLoginType = loginOption?.connectType == nil ? ConnectType.both : loginOption!.connectType!

        do {
            var dict = [String: AnyObject]()
            dict["authorize"] = (loginOption?.authorize == true) as AnyObject
            dict["returnEmail"] = (loginOption?.returnEmail == true) as AnyObject

            try jumpToUrl(.Login, pathType: .Login, paraDict: dict) { error, callBackUrl in
                if error != nil {
                    loginErrorBlock(error!)
                } else {
                    let callbackData = Data.fromBase64URL(callBackUrl!.fragment!)
                    let response = try? JSONDecoder().decode(ResponseMessage.self, from: callbackData!)
                    if response?.type == UniPassFunType.Login && response?.errorCode == nil {
                        let userInfo = response?.userInfo
                        if userInfo != nil {
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = .prettyPrinted
                            let data = try? encoder.encode(userInfo)
                            UserDefaults.standard.set(String(data: data!, encoding: .utf8)!, forKey: "UniPassSDK")

                            loginSuccessBlock(userInfo!)
                        } else {
                            loginErrorBlock(UniPassError.unknownError)
                        }
                    } else {
                        loginErrorBlock(UniPassError.userCancelled(msg: response?.errorMsg))
                    }
                }
            }
        } catch let error as UniPassError {
            loginErrorBlock(error)
        } catch let error {
            loginErrorBlock(UniPassError.unknownError)
        }
    }

    /// Logout UniPass Wallet
    /// - Parameters:
    ///   - logOutSuccessBlock: success callback for logout function
    ///   - logoutErrorBlock: error callback for logout function, error code and message will be returned
    ///   - deep: indicate whether logout user from UniPass web pages, if set to false, will only clear cached user info
    public func logOut(logOutSuccessBlock: @escaping () -> Void, logoutErrorBlock: @escaping (UniPassError) -> Void, deep: Bool = true) {
        do {
            if deep {
                try jumpToUrl(.LogOut, pathType: .LogOut, paraDict: nil) { error, callBackUrl in
                    if error != nil {
                        logoutErrorBlock(UniPassError.appCancelled)
                    } else {
                        do {
                            let callbackData = Data.fromBase64URL(callBackUrl!.fragment!)
                            let response = try? JSONDecoder().decode(ResponseMessage.self, from: callbackData!)
                            if response?.type == UniPassFunType.LogOut && response?.errorCode == nil {
                                UserDefaults.standard.set("", forKey: "UniPassSDK")
                                logOutSuccessBlock()
                            } else {
                                logoutErrorBlock(UniPassError.runtimeError(msg: response?.errorMsg ?? ""))
                            }

                        } catch let error {
                            logoutErrorBlock(UniPassError.decodingError)
                        }
                    }
                }
            } else {
                UserDefaults.standard.set("", forKey: "UniPassSDK")
                logOutSuccessBlock()
            }

        } catch let error as UniPassError {
            logoutErrorBlock(error)
        } catch let error {
            logoutErrorBlock(UniPassError.unknownError)
        }
    }

    /// Sign Message with UniPass Wallet
    /// - Parameters:
    ///   - signInput: input to be signed
    ///   - SuccessBlock: success callback for sign message, signature will be returned when succeed
    ///   - ErrorBlock: error callback for sign message, error code and message when failed
    public func signMessage(_ signInput: UniPassSignInput, SuccessBlock: @escaping (String) -> Void, ErrorBlock: @escaping (UniPassError) -> Void) {
        do {
            try assertSameUser(address: signInput.from)

            var dict = [String: AnyObject]()
            dict["from"] = signInput.from as AnyObject
            dict["type"] = signInput.type.rawValue as AnyObject
            dict["msg"] = signInput.msg as AnyObject

            try jumpToUrl(.SignMessage, pathType: .SignMessage, paraDict: dict) { error, callBackUrl in
                if error != nil {
                    ErrorBlock(error!)
                } else {
                    do {
                        let callbackData = Data.fromBase64URL(callBackUrl!.fragment!)
                        print("callbackData", String(data: callbackData!, encoding: .utf8)!)
                        let response = try? JSONDecoder().decode(ResponseMessage.self, from: callbackData!)
                        print("response", response)
                        if response?.type == UniPassFunType.SignMessage && response?.errorCode == nil {
                            let signature = response?.signature
                            if signature != nil {
                                SuccessBlock(signature!)
                            } else {
                                ErrorBlock(UniPassError.runtimeError(msg: "signature is nil"))
                            }
                        } else {
                            ErrorBlock(UniPassError.userCancelled(msg: response?.errorMsg))
                        }
                    } catch let error { ErrorBlock(UniPassError.decodingError) }
                }
            }

        } catch let error as UniPassError {
            ErrorBlock(error)
        } catch let error {
            ErrorBlock(UniPassError.unknownError)
        }
    }

    /// Send Transaction with UniPass Wallet
    /// - Parameters:
    ///   - transaction: ethereum transaction body, including to, value, data
    ///   - SuccessBlock: success callback for send transaction, if transaction comitted success on blockchain, transaction hash will be returned
    ///   - ErrorBlock: error callback for send transaction, if transaction failed, error code and message will be returned
    public func sendTransaction(_ transaction: UniPassTransaction, SuccessBlock: @escaping (String) -> Void, ErrorBlock: @escaping (UniPassError) -> Void) {
        do {
            try assertSameUser(address: transaction.from)

            var dict = [String: AnyObject]()
            dict["from"] = transaction.from as AnyObject
            dict["to"] = transaction.to as AnyObject
            dict["value"] = transaction.value as AnyObject
            dict["data"] = transaction.data as AnyObject

            try jumpToUrl(.Transaction, pathType: .Transaction, paraDict: dict) { error, callBackUrl in
                do {
                    if error != nil {
                        ErrorBlock(error!)
                    } else {
                        let callbackData = Data.fromBase64URL(callBackUrl!.fragment!)
                        print("callbackData", String(data: callbackData!, encoding: .utf8)!)
                        let response = try? JSONDecoder().decode(ResponseMessage.self, from: callbackData!)
                        if response?.type == UniPassFunType.Transaction && response?.errorCode == nil {
                            let transactionHash = response?.transactionHash
                            if transactionHash != nil {
                                SuccessBlock(transactionHash!)
                            } else {
                                ErrorBlock(UniPassError.runtimeError(msg: "transactionHash is nil"))
                            }
                        } else {
                            ErrorBlock(UniPassError.userCancelled(msg: response?.errorMsg))
                        }
                    }
                } catch let error {
                    ErrorBlock(UniPassError.decodingError)
                }
            }
        } catch let error as UniPassError {
            ErrorBlock(error)
        } catch let error {
            ErrorBlock(UniPassError.unknownError)
        }
    }

    public func getUserInfo() -> UniPassUserInfo? {
        do {
            let userInfoStr = UserDefaults.standard.object(forKey: "UniPassSDK") as? String ?? ""

            return try JSONDecoder().decode(UniPassUserInfo.self, from: userInfoStr.data(using: .utf8)!)

        } catch {
            return nil
        }
    }

    public func isLogin() -> Bool {
        return getUserInfo() != nil
    }

    public func setChain(chain: ChainType) {
        option.appSetting?.chain = chain
    }

    public func setTheme(theme: UniPassTheme) {
        option.appSetting?.theme = theme
    }

    private func jumpToUrl(_ funType: UniPassFunType, pathType: UniPassPathType, paraDict: [String: AnyObject]?, callBackBlock: @escaping ((UniPassError?, URL?) -> Void)) throws {
        var isActive = false
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
            if scene != nil {
                isActive = true
            }
        }

        print("UIWindowScene foregroundActive = ", isActive)

        if isActive == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self._jumpToUrl(funType, pathType: pathType, paraDict: paraDict, callBackBlock: callBackBlock)
            }
        } else {
            _jumpToUrl(funType, pathType: pathType, paraDict: paraDict, callBackBlock: callBackBlock)
        }
    }

    private func _jumpToUrl(_ funType: UniPassFunType, pathType: UniPassPathType, paraDict: [String: AnyObject]?, callBackBlock: @escaping ((UniPassError?, URL?) -> Void)) {
        do {
            guard
                let bundleId = Bundle.main.bundleIdentifier,
                let redirectURL = URL(string: "\(bundleId)://\(pathType.rawValue)")
            else {
                throw UniPassError.noBundleIdentifierFound
            }

            let urlStr = try generateJumpUrl(funType, pathType: pathType, redirectUrlStr: redirectURL.absoluteString, paraDict: paraDict)

            if #available(iOS 12.0, *) {
                if let unipassUrl = URL(string: urlStr) {
                    // open ASWebAuthenticationSession
                    self.authSession = ASWebAuthenticationSession(url: unipassUrl, callbackURLScheme: redirectURL.scheme) { callbackURL, authError in

                        print("authError", authError)
                        print("callbackURL", callbackURL)
                        if authError == nil {
                            callBackBlock(nil, callbackURL)
                        } else {
                            callBackBlock(UniPassError.appCancelled, nil)
                        }
                    }

                    if #available(iOS 13.0, *) {
                        self.authSession.presentationContextProvider = self
                    }
                    if !(self.authSession.start()) {
                        callBackBlock(UniPassError.unknownError, nil)
                    }
                }

            } else {
                callBackBlock(UniPassError.runtimeError(msg: "iOS version is less than 12"), nil)
            }
        } catch let error as UniPassError {
            callBackBlock(error, nil)
        } catch let error {
            callBackBlock(UniPassError.unknownError, nil)
        }
    }

    private func generateJumpUrl(_ funType: UniPassFunType, pathType: UniPassPathType, redirectUrlStr: String, paraDict: [String: AnyObject]?) throws -> String {
        var urlStr = walletUrl + "/" + pathType.rawValue + "?redirectUrl=" + redirectUrlStr.uni_urlEncoded()
        if funType == UniPassFunType.Login {
            urlStr = urlStr + "&connectType=" + supportLoginType.rawValue
        }
        let hash = try buildHashStr(funType, paraDict: paraDict)
        urlStr = urlStr + "#" + hash

        guard
            var components = URLComponents(string: urlStr)
        else { throw UniPassError.encodingError }

        return urlStr
    }

    private func buildHashStr(_ funType: UniPassFunType, paraDict: [String: AnyObject]?) throws -> String {
        do {
            var hasStr = ""
            var dict = [String: AnyObject]()
            dict["type"] = funType.rawValue as AnyObject
            if let setting = option.appSetting {
                dict["appSetting"] = setting.getAppSettingDict() as AnyObject
            }
            if let para = paraDict {
                dict["payload"] = para as AnyObject
            }
//            hasStr = try uni_convertDictionaryToString(dict: dict).uni_toBase64().uni_urlEncoded()
            hasStr = try uni_convertDictionaryToString(dict: dict).data(using: .utf8)?.toBase64URL() ?? ""
            return hasStr
        } catch let error {
            throw UniPassError.encodingError
        }
    }

    private func uni_convertDictionaryToString(dict: [String: AnyObject]) throws -> String {
        var result: String = ""
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))

        if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
            result = JSONString
        }

        return result
    }

    private func assertSameUser(address: String) throws {
        try assertLogin()

        let userInfo = getUserInfo()
        if userInfo!.address != nil && userInfo!.address.lowercased() != address.lowercased() {
            throw UniPassError.invalidFromAddress
        }
    }

    private func assertLogin() throws {
        if !isLogin() { throw UniPassError.userNotLogin }
    }
}

extension UniPassSDK: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 12.0, *)
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}
