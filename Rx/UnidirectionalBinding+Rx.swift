import RxSwift
import RxCocoa

// MARK: - BindingTargetProvider

public protocol BindingTargetProvider {
    associatedtype Value
    
    var bindingTarget: BindingTarget<Value> { get }
}

public struct BindingTarget<Value>: BindingTargetProvider {
    public let deallocated: Observable<Void>
    public let action: (Value) -> Void
    
    public var bindingTarget: BindingTarget<Value> {
        return self
    }
    
    public init(deallocated: Observable<Void>, action: @escaping (Value) -> Void) {
        self.deallocated = deallocated
        self.action = action
    }
}

extension BindingTarget {
    public init<Object: AnyObject>(deallocated: Observable<Void>, object: Object, keyPath: WritableKeyPath<Object, Value>) {
        self.init(deallocated: deallocated) { [weak object = object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    public init<Object: AnyObject & ReactiveCompatible>(object: Object, action: @escaping (Value) -> Void) {
        self.init(deallocated: object.rx.deallocated, action: action)
    }
    
    public init<Object: AnyObject & ReactiveCompatible>(object: Object, keyPath: WritableKeyPath<Object, Value>) {
        self.init(deallocated: object.rx.deallocated, object: object, keyPath: keyPath)
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
        where Value == Source.Element
    {
        let bindingTarget = provider.bindingTarget
        return source.asObservable()
            .takeUntil(bindingTarget.deallocated)
            .bind(onNext: bindingTarget.action)
    }
    
    @discardableResult
    public static func =>
        <Source: ObservableType>(source: Source, provider: Self) -> Disposable
        where Value == Source.Element?
    {
        return source.map(Optional.init) => provider
    }
}

extension BindingTargetProvider where Value == Void {
    @discardableResult
    public static func =>
        <Source: ObservableType>(source: Source, provider: Self) -> Disposable
    {
        let bindingTarget = provider.bindingTarget
        return source.asObservable()
            .map({ _ in })
            .takeUntil(bindingTarget.deallocated)
            .bind(onNext: bindingTarget.action)
    }
}

// MARK: - Reactive Extensions

extension Reactive where Base: AnyObject & ReactiveCompatible {
    private func makeBindingTarget<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
        return BindingTarget(deallocated: base.rx.deallocated, object: base, keyPath: keyPath)
    }
    
    public subscript<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
        return makeBindingTarget(keyPath: keyPath)
    }
    
    /// action as an closure that take one extra arguments.
    public func makeBindingTarget<Value>(action: @escaping (Base, Value) -> Void) -> BindingTarget<Value> {
        return BindingTarget(deallocated: base.rx.deallocated) { [weak base = base] value in
            if let base = base {
                action(base, value)
            }
        }
    }
    
    /// action as an  optional closure that take one extra arguments.
    public func makeBindingTarget<Value>(action: ((Base, Value) -> Void)?) -> BindingTarget<Value> {
        return BindingTarget(deallocated: base.rx.deallocated) { [weak base = base] value in
            if let base = base {
                action?(base, value)
            }
        }
    }
    
    /// action as an closure that take one extra arguments.
    public subscript<Value>(action: @escaping (Base, Value) -> Void) -> BindingTarget<Value> {
        return makeBindingTarget(action: action)
    }
    
    /// action as an optional closure that take one extra arguments.
    public subscript<Value>(action: ((Base, Value) -> Void)?) -> BindingTarget<Value> {
        return makeBindingTarget(action: action)
    }
    
    /// action as an closure that take no extra arguments.
    public subscript(action: @escaping (Base) -> Void) -> BindingTarget<Void> {
        return makeBindingTarget { base, _ in
            action(base)
        }
    }
    
    /// action as an optional closure that take no extra arguments.
    public subscript(action: ((Base) -> Void)?) -> BindingTarget<Void> {
        return makeBindingTarget { base, _ in
            action?(base)
        }
    }
    
    /// action as an closure that take two extra arguments.
    public subscript<A, B>(action: @escaping (Base, A, B) -> Void) -> BindingTarget<(A, B)> {
        return makeBindingTarget { base, args in
            let (a, b) = args
            action(base, a, b)
        }
    }
    
    /// action as an optional closure that take two extra arguments.
    public subscript<A, B>(action: ((Base, A, B) -> Void)?) -> BindingTarget<(A, B)> {
        return makeBindingTarget { base, args in
            let (a, b) = args
            action?(base, a, b)
        }
    }
    
    /// action as a method that take one arguments.
    public func makeBindingTarget<Value>(action: @escaping (Base) -> (Value) -> Void) -> BindingTarget<Value> {
        return BindingTarget(deallocated: base.rx.deallocated, action: action(base))
    }

    /// action as a method that take one arguments.
    public subscript<Value>(action: @escaping (Base) -> (Value) -> Void) -> BindingTarget<Value> {
        return makeBindingTarget(action: action)
    }
    
    /// action as a method that take no arguments.
    public subscript(action: @escaping (Base) -> () -> Void) -> BindingTarget<Void> {
        return makeBindingTarget { base, _ in
            action(base)()
        }
    }
    
    /// action as a method that take two arguments.
    public subscript<A, B>(action: @escaping (Base) -> (A, B) -> Void) -> BindingTarget<(A, B)> {
        return makeBindingTarget { (base, args) in
            let (a, b) = args
            action(base)(a, b)
        }
    }
}

// MARK: - RxRelay

import RxRelay

extension ObserverType where Self: AnyObject & ReactiveCompatible & BindingTargetProvider {
    public var bindingTarget: BindingTarget<Element> {
        return .init(object: self, action: onNext)
    }
}

extension ReplaySubject: ReactiveCompatible {}
extension ReplaySubject: BindingTargetProvider {}

extension BehaviorSubject: ReactiveCompatible {}
extension BehaviorSubject: BindingTargetProvider {}

extension PublishSubject: ReactiveCompatible {}
extension PublishSubject: BindingTargetProvider {}

public protocol RxRelayObject: ObservableType {
    func accept(_ event: Element)
}

extension RxRelayObject where Self: AnyObject & ReactiveCompatible & BindingTargetProvider {
    public var bindingTarget: BindingTarget<Element> {
        return .init(object: self, action: accept)
    }
}

extension PublishRelay: ReactiveCompatible {}
extension PublishRelay: RxRelayObject, BindingTargetProvider {}

extension BehaviorRelay: ReactiveCompatible {}
extension BehaviorRelay: RxRelayObject, BindingTargetProvider {}
