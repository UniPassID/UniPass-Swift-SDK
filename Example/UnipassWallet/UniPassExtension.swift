//
//  Extension.swift
//  UnipassWallet
//
//

import Foundation
import UIKit
extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(utf8).base64EncodedString()
    }

    func urlEncoded() -> String {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
        return addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? self
    }

    // 将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return removingPercentEncoding ?? ""
    }

    func convertStringToDictionary() -> [String: AnyObject]? {
        if let data = data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions(rawValue: 0)]) as? [String: AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

extension UIView {
    // MARK: 坐标尺寸

    var origin: CGPoint {
        get {
            return frame.origin
        }
        set(newValue) {
            var rect = frame
            rect.origin = newValue
            frame = rect
        }
    }

    var size: CGSize {
        get {
            return frame.size
        }
        set(newValue) {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }

    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set(newValue) {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }

    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set(newValue) {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }

    var right: CGFloat {
        get {
            return (frame.origin.x + frame.size.width)
        }
        set(newValue) {
            var rect = frame
            rect.origin.x = (newValue - frame.size.width)
            frame = rect
        }
    }

    var bottom: CGFloat {
        get {
            return (frame.origin.y + frame.size.height)
        }
        set(newValue) {
            var rect = frame
            rect.origin.y = (newValue - frame.size.height)
            frame = rect
        }
    }

    // MARK: - size

    func width() -> CGFloat {
        return frame.size.width
    }

    func height() -> CGFloat {
        return frame.size.height
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return "0x" + self.map { String(format: format, $0) }.joined()
    }
}
