//
//  UnipassSDKOption.swift
//  UnipassWallet
//
//

public enum UniPassEnvironment {
    case Mainnet
    case Testnet
}

public enum ChainType: String {
    case eth
    case polygon
    case bsc
    case rangers
    case scroll
}

public enum ConnectType: String {
    case google
    case email
    case both
}

public enum UniPassTheme: String {
    case light
    case dark
    case cassava
}

public enum UniPassFunType: String, Codable {
    case Login = "UP_LOGIN"
    case LogOut = "UP_LOGOUT"
    case SignMessage = "UP_SIGN_MESSAGE"
    case Transaction = "UP_TRANSACTION"
}

public enum UniPassPathType: String {
    case Login = "connect"
    case LogOut = "logout"
    case SignMessage = "sign-message"
    case Transaction = "send-transaction"
}

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


public class UniPassSDKAppSetting: NSObject {
    public var chain: ChainType = .polygon
    public var appName: String?
    public var appIcon: String?
    public var theme: UniPassTheme = .dark

    public func getAppSettingDict() -> [String: String] {
        var appSettingDict = [String: String]()
        appSettingDict["chain"] = chain.rawValue
        if let name = appName {
            appSettingDict["appName"] = name
        }
        if let icon = appIcon {
            appSettingDict["appIcon"] = icon
        }
        appSettingDict["theme"] = theme.rawValue
        return appSettingDict
    }
}

public class UniPassSDKOption: NSObject {
    public var context: UIViewController?
    public var environment: UniPassEnvironment = .Mainnet
    public var walletUrl: String = ""
    public var appSetting: UniPassSDKAppSetting?
}

public struct UniPassSDKLoginOption {
    public var connectType: ConnectType? = ConnectType.both
    public var authorize: Bool? = false
    public var returnEmail: Bool? = false
    
    public init(connectType: ConnectType?, authorize: Bool?, returnEmail: Bool?) {
        self.connectType = connectType
        self.authorize = authorize
        self.returnEmail = returnEmail
    }
}

public enum UniPassSignType: String {
    case PersonalSign
    case SignTypedData
}

public class UniPassSignInput: NSObject {
    public var from: String = ""
    public var type: UniPassSignType = .PersonalSign
    public var msg: String = ""
}

public class UniPassTransaction: NSObject {
    public var from: String = ""
    public var to: String = ""
    public var value: String = "0x"
    public var data: String = "0x"
}

public struct UniPassUserInfo: Codable {
    public let address: String
    public let email: String?
    public let newborn: Bool?
    public let message: String?
    public let signature: String?

    public init(address: String, email: String?, newborn: Bool?, message: String?, signature: String?) {
        self.address = address
        self.email = email
        self.newborn = newborn
        self.message = message
        self.signature = signature
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        newborn = try container.decodeIfPresent(Bool.self, forKey: .newborn)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
    }
}

public struct ResponseMessage: Codable{
    public let type: UniPassFunType
    public let errorCode: Int?
    public let errorMsg: String?
    
    public let userInfo: UniPassUserInfo?
    public let signature: String?
    public let transactionHash: String?

    public init(type: String, errorCode: Int?, errorMsg: String?, userInfo: UniPassUserInfo?, signature: String?, transactionHash: String?) {
        self.type = UniPassFunType.init(rawValue: type)!
        self.errorCode = errorCode
        self.errorMsg = errorMsg
        self.userInfo = userInfo
        self.signature = signature
        self.transactionHash = transactionHash
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = UniPassFunType.init(rawValue: try container.decode(String.self, forKey: .type)) ?? UniPassFunType.Transaction
        errorCode = try container.decodeIfPresent(Int.self, forKey: .errorCode)
        errorMsg = try container.decodeIfPresent(String.self, forKey: .errorMsg)
        userInfo = try container.decodeIfPresent(UniPassUserInfo.self, forKey: .userInfo)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
        transactionHash = try container.decodeIfPresent(String.self, forKey: .transactionHash)
    }
}

