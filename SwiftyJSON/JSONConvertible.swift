import Foundation
import SwiftyJSON

public protocol JSONConvertible {
    init(json: JSON)
}

extension JSON: JSONConvertible {
    public init(json: JSON) {
        self = json
    }
}

extension Array: JSONConvertible where Element: JSONConvertible {
    public init(json: JSON) {
        self = json.arrayValue.map(Element.init(json:))
    }
}

extension Dictionary: JSONConvertible where Value: JSONConvertible, Key == String {
    public init(json: JSON) {
        self = json.dictionaryValue.mapValues(Value.init(json:))
    }
}

public struct VoidBox {
    public func unwrap() -> Void {
        return ()
    }
}

extension VoidBox: JSONConvertible {
    public init(json: JSON) {
        self = VoidBox()
    }
}

extension String: JSONConvertible {
    public init(json: JSON) {
        self = json.stringValue
    }
}

extension Int: JSONConvertible {
    public init(json: JSON) {
        self = json.intValue
    }
}

extension Double: JSONConvertible {
    public init(json: JSON) {
        self = json.doubleValue
    }
}

extension Float: JSONConvertible {
    public init(json: JSON) {
        self = json.floatValue
    }
}

extension Int8: JSONConvertible {
    public init(json: JSON) {
        self = json.int8Value
    }
}

extension Int16: JSONConvertible {
    public init(json: JSON) {
        self = json.int16Value
    }
}

extension Int32: JSONConvertible {
    public init(json: JSON) {
        self = json.int32Value
    }
}

extension Int64: JSONConvertible {
    public init(json: JSON) {
        self = json.int64Value
    }
}
