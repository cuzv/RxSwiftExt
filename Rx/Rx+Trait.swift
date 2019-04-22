import Foundation
import RxSwift
import RxCocoa

// MARK: - Schedluer

public enum RxScheduler {
    case main
    case serial(DispatchQoS)
    case concurrent(DispatchQoS)
    case operation(OperationQueue)
    
    public func toImmediateScheduler() -> ImmediateSchedulerType {
        switch self {
        case .main: return MainScheduler.instance
        case let .serial(qos): return SerialDispatchQueueScheduler(qos: qos)
        case let .concurrent(qos): return ConcurrentDispatchQueueScheduler(qos: qos)
        case let .operation(queue): return OperationQueueScheduler(operationQueue: queue)
        }
    }
}

extension ObservableType {
    public func observeOn(scheduler: RxScheduler) -> Observable<Self.E> {
        return observeOn(scheduler.toImmediateScheduler())
    }
    
    public func subscribeOn(_ scheduler: RxScheduler) -> RxSwift.Observable<Self.E> {
        return subscribeOn(scheduler.toImmediateScheduler())
    }
}

// MARK: - Operator

extension ObservableType {
    public func void() -> Observable<Void> {
        return asObservable().map({ _ in })
    }
    
    public func ignoreNil<R>() -> Observable<R> where E == R? {
        return asObservable().flatMap(Observable.from(optional:))
    }
    
    func ignoreErrors() -> Observable<E> {
        return asObservable().catchError { _ in .empty() }
    }
    
    public func ignoreErrorsAndNil<R>() -> Observable<R> where E == R? {
        return asObservable().ignoreErrors().ignoreNil()
    }
}

// MARK: - Binding

extension Reactive where Base: AnyObject {
    public func makeBinder(_ action: @escaping (Base) -> () -> ()) -> Binder<Void> {
        return Binder(base) { target, _ in
            action(target)()
        }
    }
    
    public subscript(_ action: @escaping (Base) -> () -> ()) -> Binder<Void> {
        return makeBinder(action)
    }
    
    public func makeBinder<Value>(_ action: @escaping (Base) -> (Value) -> ()) -> Binder<Value> {
        return Binder(base) { target, value in
            action(target)(value)
        }
    }
    
    public subscript<Value>(_ action: @escaping (Base) -> (Value) -> ()) -> Binder<Value> {
        return makeBinder(action)
    }
    
    public func makeBinder<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> ()) -> Binder<(V1, V2)> {
        return Binder(base) { target, value in
            action(target)(value.0, value.1)
        }
    }
    
    public subscript<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> ()) -> Binder<(V1, V2)> {
        return makeBinder(action)
    }
    
    public func makeBinder<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> ()) -> Binder<(V1, V2, V3)> {
        return Binder(base) { target, value in
            action(target)(value.0, value.1, value.2)
        }
    }
    
    public subscript<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> ()) -> Binder<(V1, V2, V3)> {
        return makeBinder(action)
    }
}

extension Reactive where Base: AnyObject {
    @discardableResult
    public func bind<E>(_ observable: Observable<E>, action: @escaping (Base, E) -> Void) -> Disposable {
        return observable
            .takeUntil(deallocated)
            .bind(to: base) { target, e in
                action(target, e)
        }
    }
}

public protocol Deallocatable: AnyObject, ReactiveCompatible {}
extension NSObject: Deallocatable {}

extension ObservableType {
    public func bind<Target>(to target: Target, action: @escaping (Target, E) -> Void) -> Disposable {
        return asObservable()
            .observeOn(MainScheduler.instance)
            .bind { e in
                action(target, e)
        }
    }
    
    public func bind<Target: AnyObject>(to target: Target, action: @escaping (Target, E) -> Void) -> Disposable {
        return asObservable()
            .bind(to: Binder<E>(target) { target, e in
                action(target, e)
            })
    }
    
    @discardableResult
    public func bind<Target: Deallocatable>(to target: Target, action: @escaping (Target, E) -> Void) -> Disposable {
        return asObservable()
            .takeUntil(target.rx.deallocated)
            .bind(to: Binder<E>(target) { target, e in
                action(target, e)
            })
    }
    
    public func bind<Target: AnyObject>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, E>) -> Disposable {
        return asObservable()
            .bind(to: Binder<E>(target) { target, e in
                target[keyPath: keyPath] = e
            })
    }
    
    @discardableResult
    public func bind<Target: Deallocatable>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, E>) -> Disposable {
        return asObservable()
            .takeUntil(target.rx.deallocated)
            .bind(to: Binder<E>(target) { target, e in
                target[keyPath: keyPath] = e
            })
    }
    
    public func bind<Target: AnyObject>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, E?>) -> Disposable {
        return map(Optional.init).bind(to: target, keyPath: keyPath)
    }
    
    @discardableResult
    public func bind<Target: Deallocatable>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, E?>) -> Disposable {
        return map(Optional.init).bind(to: target, keyPath: keyPath)
    }
}
