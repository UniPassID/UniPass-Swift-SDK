//
//  Extension.swift
//  UnipassWallet
//
//

import Foundation
import UIKit
extension String {
    func uni_fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func uni_toBase64() -> String {
        return Data(utf8).base64EncodedString()
    }

    func uni_urlEncoded() -> String {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
        return addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? self
    }

    // 将编码后的url转换回原始的url
    func uni_urlDecoded() -> String {
        return removingPercentEncoding ?? ""
    }

    func uni_convertStringToDictionary() throws -> [String: AnyObject]? {
        do {
            if let data = data(using: String.Encoding.utf8) {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions(rawValue: 0)]) as? [String: AnyObject]
            }
        } catch {
            throw UniPassError.decodingError
        }
        throw UniPassError.decodingError
    }
}

extension Data {
    
    static func fromBase64URL(_ str: String) -> Data? {
        var base64 = str
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        return data
    }
    
    func toBase64URL() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}
