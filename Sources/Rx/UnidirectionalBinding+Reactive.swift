import RxSwift
import RxCocoa

// MARK: - BindingTargetProvider

public protocol BindingTargetProvider {
    associatedtype Value

    var bindingTarget: BindingTarget<Value> { get }
}

public struct BindingTarget<Value>: BindingTargetProvider {
    public let lifetime: Lifetime
    public let action: (Value) -> Void

    public var bindingTarget: BindingTarget<Value> {
        return self
    }

    public init(lifetime: Lifetime, action: @escaping (Value) -> Void) {
        self.lifetime = lifetime
        self.action = action
    }
}

extension BindingTarget {
    public init<Object: AnyObject>(object: Object, action: @escaping (Value) -> Void) {
        self.init(lifetime: .of(object), action: action)
    }

    public init<Object: AnyObject>(object: Object, keyPath: WritableKeyPath<Object, Value>) {
        self.init(object: object) { [weak object = object] value in
            object?[keyPath: keyPath] = value
        }
    }
}

// MARK: - Operator

precedencegroup BindingPrecedence {
    associativity: none

    // Binds tighter than assignment but looser than everything else
    higherThan: AssignmentPrecedence
}

infix operator => : BindingPrecedence

extension BindingTargetProvider {
    @discardableResult
    public static func =>
        <Source: ObservableType>(source: Source, provider: Self) -> Disposable
        where Value == Source.Element {
        let bindingTarget = provider.bindingTarget
        return source.asObservable()
            .takeDuring(bindingTarget.lifetime)
            .bind(onNext: bindingTarget.action)
    }

    @discardableResult
    public static func =>
        <Source: ObservableType>(source: Source, provider: Self) -> Disposable
        where Value == Source.Element? {
        return source.map(Optional.init) => provider
    }
}

extension BindingTargetProvider where Value == Void {
    @discardableResult
    public static func =>
        <Source: ObservableType>(source: Source, provider: Self) -> Disposable {
        let bindingTarget = provider.bindingTarget
        return source.asObservable()
            .map({ _ in })
            .takeDuring(bindingTarget.lifetime)
            .bind(onNext: bindingTarget.action)
    }
}

// MARK: - Reactive Extensions

extension Reactive where Base: AnyObject {
    private func makeBindingTarget<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
        return .init(object: base, keyPath: keyPath)
    }

    public subscript<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
        return .init(object: base, keyPath: keyPath)
    }

    public subscript<Value>(action: @escaping (Base) -> (Value) -> Void) -> BindingTarget<Value> {
        return .init(object: base, action: action(base))
    }

    public func makeBindingTarget<Value>(action: ((Base, Value) -> Void)?) -> BindingTarget<Value> {
        return .init(object: base) { [weak base = base] value in
            if let base = base {
                action?(base, value)
            }
        }
    }

    public subscript<Value>(action: ((Base, Value) -> Void)?) -> BindingTarget<Value> {
        return makeBindingTarget(action: action)
    }

    public subscript<Value>(action: @escaping (Base, Value) -> Void) -> BindingTarget<Value> {
        return makeBindingTarget(action: action)
    }

    public subscript(action: @escaping (Base) -> () -> Void) -> BindingTarget<Void> {
        return .init(object: base, action: action(base))
    }

    public subscript(action: ((Base) -> Void)?) -> BindingTarget<Void> {
        return makeBindingTarget { base, _ in
            action?(base)
        }
    }

    public subscript(action: @escaping (Base) -> Void) -> BindingTarget<Void> {
        return self[Optional(action)]
    }

    public subscript<A, B>(action: @escaping (Base) -> (A, B) -> Void) -> BindingTarget<(A, B)> {
        return .init(object: base, action: action(base))
    }

    public subscript<A, B>(action: ((Base, A, B) -> Void)?) -> BindingTarget<(A, B)> {
        return makeBindingTarget { base, args in
            let (a, b) = args
            action?(base, a, b)
        }
    }

    public subscript<A, B>(action: @escaping (Base, A, B) -> Void) -> BindingTarget<(A, B)> {
        return self[Optional(action)]
    }

    public subscript<A, B, C>(action: @escaping (Base) -> (A, B, C) -> Void) -> BindingTarget<(A, B, C)> {
        return .init(object: base, action: action(base))
    }

    public subscript<A, B, C>(action: ((Base, A, B, C) -> Void)?) -> BindingTarget<(A, B, C)> {
        return makeBindingTarget { base, args in
            let (a, b, c) = args
            action?(base, a, b, c)
        }
    }

    public subscript<A, B, C>(action: @escaping (Base, A, B, C) -> Void) -> BindingTarget<(A, B, C)> {
        return self[Optional(action)]
    }
}

// MARK: - RxRelay

import RxRelay

extension ObserverType where Self: AnyObject & BindingTargetProvider {
    public var bindingTarget: BindingTarget<Element> {
        return .init(object: self, action: onNext)
    }
}
extension ReplaySubject: BindingTargetProvider {}
extension BehaviorSubject: BindingTargetProvider {}
extension PublishSubject: BindingTargetProvider {}

public protocol RxRelayObject: ObservableType {
    func accept(_ event: Element)
}
extension RxRelayObject where Self: AnyObject & BindingTargetProvider {
    public var bindingTarget: BindingTarget<Element> {
        return .init(object: self, action: accept)
    }
}
extension PublishRelay: RxRelayObject, BindingTargetProvider {}
extension BehaviorRelay: RxRelayObject, BindingTargetProvider {}
