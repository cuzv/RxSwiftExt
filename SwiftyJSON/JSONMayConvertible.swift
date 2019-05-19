import Foundation
import SwiftyJSON

public protocol JSONMayConvertible {
    init?(failable json: JSON)
}

extension JSON {
    public func resolved<U: JSONMayConvertible>() -> U? {
        return map(U.init(failable:))
    }
}

extension String: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.string {
            self = value
        } else {
            return nil
        }
    }
}

extension Bool: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.bool {
            self = value
        } else {
            return nil
        }
    }
}

extension Int: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.int {
            self = value
        } else {
            return nil
        }
    }
}

extension Double: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.double {
            self = value
        } else {
            return nil
        }
    }
}

extension Float: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.float {
            self = value
        } else {
            return nil
        }
    }
}

extension Int8: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.int8 {
            self = value
        } else {
            return nil
        }
    }
}

extension Int16: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.int16 {
            self = value
        } else {
            return nil
        }
    }
}

extension Int32: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.int32 {
            self = value
        } else {
            return nil
        }
    }
}

extension Int64: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.int64 {
            self = value
        } else {
            return nil
        }
    }
}

extension CGPoint: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.number?.cgPointValue {
            self = value
        } else {
            return nil
        }
    }
}

extension CGVector: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.number?.cgVectorValue {
            self = value
        } else {
            return nil
        }
    }
}

extension CGSize: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.number?.cgSizeValue {
            self = value
        } else {
            return nil
        }
    }
}

extension CGRect: JSONMayConvertible {
    public init?(failable json: JSON) {
        if let value = json.number?.cgRectValue {
            self = value
        } else {
            return nil
        }
    }
}

extension CGFloat: JSONMayConvertible {
    public init?(failable json: JSON) {
        #if (arch(i386) || arch(arm))
        if let value = json.float {
            self = CGFloat(value)
        } else{
            return nil
        }
        #else
        if let value = json.double {
            self = CGFloat(value)
        } else{
            return nil
        }
        #endif
    }
}

