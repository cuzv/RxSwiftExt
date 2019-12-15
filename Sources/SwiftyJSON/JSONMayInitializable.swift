import Foundation
import CoreGraphics
import SwiftyJSON

public protocol JSONMayInitializable {
    init?(failable json: JSON)
}

extension JSON {
    public func resolved<U: JSONMayInitializable>() -> U? {
        return map(U.init(failable:))
    }
}

extension String: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.string {
            self = value
        } else {
            return nil
        }
    }
}

extension Bool: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.bool {
            self = value
        } else {
            return nil
        }
    }
}

extension Int: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.int {
            self = value
        } else {
            return nil
        }
    }
}

extension Double: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.double {
            self = value
        } else {
            return nil
        }
    }
}

extension Float: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.float {
            self = value
        } else {
            return nil
        }
    }
}

extension Int8: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.int8 {
            self = value
        } else {
            return nil
        }
    }
}

extension Int16: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.int16 {
            self = value
        } else {
            return nil
        }
    }
}

extension Int32: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.int32 {
            self = value
        } else {
            return nil
        }
    }
}

extension Int64: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let value = json.int64 {
            self = value
        } else {
            return nil
        }
    }
}

extension CGPoint: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let x = CGFloat(failable: json["x"]), let y = CGFloat(failable: json["y"]) {
            self = .init(x: x, y: y)
        } else {
            return nil
        }
    }
}

extension CGVector: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let dx = CGFloat(failable: json["dx"]), let dy = CGFloat(failable: json["dy"]) {
            self = .init(dx: dx, dy: dy)
        } else {
            return nil
        }
    }
}

extension CGSize: JSONMayInitializable {
    public init?(failable json: JSON) {
        if let width = CGFloat(failable: json["width"]), let height = CGFloat(failable: json["height"]) {
            self = .init(width: width, height: height)
        } else {
            return nil
        }
    }
}

extension CGFloat: JSONMayInitializable {
    public init?(failable json: JSON) {
        #if (arch(i386) || arch(arm))
        if let value = json.float {
            self = CGFloat(value)
        } else {
            return nil
        }
        #else
        if let value = json.double {
            self = CGFloat(value)
        } else {
            return nil
        }
        #endif
    }
}
