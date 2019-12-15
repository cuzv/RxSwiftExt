import Foundation
import CoreGraphics
import SwiftyJSON

public protocol JSONInitializable {
    init(json: JSON)
}

extension JSON: JSONInitializable {
    public init(json: JSON) {
        self = json
    }
}

extension JSON {
    public func map<U>(_ transform: (JSON) -> U) -> U {
        return transform(self)
    }

    public func resolved<U: JSONInitializable>() -> U {
        return map(U.init(json:))
    }
}

extension Array: JSONInitializable where Element: JSONInitializable {
    public init(json: JSON) {
        self = json.arrayValue.map(Element.init(json:))
    }
}

extension Dictionary: JSONInitializable where Value: JSONInitializable, Key == String {
    public init(json: JSON) {
        self = json.dictionaryValue.mapValues(Value.init(json:))
    }
}

public struct VoidBox {
    public func unwrap() {
        return ()
    }
}

extension VoidBox: JSONInitializable {
    public init(json: JSON) {
        self = VoidBox()
    }
}

extension String: JSONInitializable {
    public init(json: JSON) {
        self = json.stringValue
    }
}

extension Bool: JSONInitializable {
    public init(json: JSON) {
        self = json.boolValue
    }
}

extension Int: JSONInitializable {
    public init(json: JSON) {
        self = json.intValue
    }
}

extension Double: JSONInitializable {
    public init(json: JSON) {
        self = json.doubleValue
    }
}

extension Float: JSONInitializable {
    public init(json: JSON) {
        self = json.floatValue
    }
}

extension Int8: JSONInitializable {
    public init(json: JSON) {
        self = json.int8Value
    }
}

extension Int16: JSONInitializable {
    public init(json: JSON) {
        self = json.int16Value
    }
}

extension Int32: JSONInitializable {
    public init(json: JSON) {
        self = json.int32Value
    }
}

extension Int64: JSONInitializable {
    public init(json: JSON) {
        self = json.int64Value
    }
}

extension CGPoint: JSONInitializable {
    public init(json: JSON) {
        self = .init(x: CGFloat(json: json["x"]), y: CGFloat(json: json["y"]))
    }
}

extension CGVector: JSONInitializable {
    public init(json: JSON) {
        self = .init(dx: CGFloat(json: json["dx"]), dy: CGFloat(json: json["dy"]))
    }
}

extension CGSize: JSONInitializable {
    public init(json: JSON) {
        self = .init(width: CGFloat(json: json["width"]), height: CGFloat(json: json["height"]))
    }
}

extension CGFloat: JSONInitializable {
    public init(json: JSON) {
        #if (arch(i386) || arch(arm))
        self = CGFloat(json.floatValue)
        #else
        self = CGFloat(json.doubleValue)
        #endif
    }
}
