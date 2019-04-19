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
        return asObservable().flatMap { $0.map(Observable.just) ?? .empty() }
    }
    
    public func ignoreErrorAndNil<R>() -> Observable<R> where E == R? {
        return asObservable().catchErrorJustReturn(nil).flatMap { $0.map(Observable.just) ?? .empty() }
    }
}

// MARK: - Binding

extension Reactive where Base: AnyObject {
    public func makeBinder(_ action: @escaping (Base) -> () -> ()) -> Binder<Void> {
        return Binder(base) { (base, _) in
            action(base)()
        }
    }
    
    public subscript(_ action: @escaping (Base) -> () -> ()) -> Binder<Void> {
        return makeBinder(action)
    }
    
    public func makeBinder<Value>(_ action: @escaping (Base) -> (Value) -> ()) -> Binder<Value> {
        return Binder(base) { (base, value) in
            action(base)(value)
        }
    }
    
    public subscript<Value>(_ action: @escaping (Base) -> (Value) -> ()) -> Binder<Value> {
        return makeBinder(action)
    }
    
    public func makeBinder<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> ()) -> Binder<(V1, V2)> {
        return Binder(base) { (base, value) in
            action(base)(value.0, value.1)
        }
    }
    
    public subscript<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> ()) -> Binder<(V1, V2)> {
        return makeBinder(action)
    }
    
    public func makeBinder<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> ()) -> Binder<(V1, V2, V3)> {
        return Binder(base) { (base, value) in
            action(base)(value.0, value.1, value.2)
        }
    }
    
    public subscript<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> ()) -> Binder<(V1, V2, V3)> {
        return makeBinder(action)
    }
}

extension Reactive where Base: AnyObject {
    public func bind<T>(_ observable: Observable<T>, action: @escaping (Base, T) -> Void) {
        _ = observable.takeUntil(deallocated).subscribeNext(to: base) { (base, t) in
            action(base, t)
        }
    }
}

extension ObservableType {
    public func subscribeNext<A: AnyObject>(to target: A, action: @escaping (A, E) -> Void) -> Disposable {
        return asObservable().subscribe(onNext: { [weak weakTarget = target] (e) in
            if let target = weakTarget {
                action(target, e)
            }
        })
    }
    
    public func subscribeWeakify<A: AnyObject>(_ target: A, on: @escaping (A, Event<E>) -> Void) -> Disposable {
        return asObservable().subscribe { [weak weakTarget = target] event in
            if let target = weakTarget {
                on(target, event)
            }
        }
    }
    
    public func subscribeWeakify<A: AnyObject>(
        target: A,
        onNext: ((A, E) -> Void)? = nil,
        onError: ((A,Swift.Error) -> Void)? = nil,
        onCompleted: ((A) -> Void)? = nil,
        onDisposed: ((A) -> Void)? = nil) -> Disposable{
        return asObservable().subscribe(onNext: { [weak weakTarget = target] e in
            if let target = weakTarget {
                onNext?(target, e)
            }
            }, onError: { [weak weakTarget = target] e in
                if let target = weakTarget {
                    onError?(target, e)
                }
            }, onCompleted: { [weak weakTarget = target] in
                if let target = weakTarget {
                    onCompleted?(target)
                }
            }, onDisposed: { [weak weakTarget = target] in
                if let target = weakTarget {
                    onDisposed?(target)
                }
        })
    }
    
    public func subscribeNext<A: AnyObject>(to target: A, action: @escaping (A) -> (E) -> Void) -> Disposable {
        let disposable = Disposables.create()
        
        let observer = AnyObserver { [weak weakTarget = target] (e: RxSwift.Event<E>) in
            if let target = weakTarget {
                switch e {
                case let .next(value): action(target)(value)
                default: disposable.dispose()
                }
            }
        }
        
        return Disposables.create(asObservable().subscribe(observer), disposable)
    }
}
