import Foundation
import RxSwift
import RxCocoa

// MARK: - Schedluer

public enum RxScheduler {
    case main
    case serial(DispatchQoS)
    case concurrent(DispatchQoS)
    case operation(OperationQueue)
    
    func toImmediateScheduler() -> ImmediateSchedulerType {
        switch self {
        case .main: return MainScheduler.instance
        case let .serial(qos): return SerialDispatchQueueScheduler(qos: qos)
        case let .concurrent(qos): return ConcurrentDispatchQueueScheduler(qos: qos)
        case let .operation(queue): return OperationQueueScheduler(operationQueue: queue)
        }
    }
}

public extension ObservableType {
    public func observeOn(scheduler: RxScheduler) -> Observable<Self.E> {
        return observeOn(scheduler.toImmediateScheduler())
    }
    
    public func subscribeOn(_ scheduler: RxScheduler) -> RxSwift.Observable<Self.E> {
        return subscribeOn(scheduler.toImmediateScheduler())
    }
}

// MARK: - Operator

public extension ObservableType {
    public func void() -> Observable<Void> {
        return asObservable().map({ _ in })
    }
    
    public func ignoreNil<R>() -> Observable<R> where E == R? {
        return self.asObservable().flatMap { $0.map(Observable.just) ?? .empty() }
    }
}

// MARK: - Binder

public extension Reactive where Base: AnyObject {
    public func makeBinder(_ action: @escaping (Base) -> () -> ()) -> Binder<Void> {
        return Binder(base) { (base, _) in
            action(base)()
        }
    }
    
    public func makeBinder<Value>(_ action: @escaping (Base) -> (Value) -> ()) -> Binder<Value> {
        return Binder(base) { (base, value) in
            action(base)(value)
        }
    }
    
    public func makeBinder<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> ()) -> Binder<(V1, V2)> {
        return Binder(base) { (base, value) in
            action(base)(value.0, value.1)
        }
    }
    
    public func makeBinder<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> ()) -> Binder<(V1, V2, V3)> {
        return Binder(base) { (base, value) in
            action(base)(value.0, value.1, value.2)
        }
    }
}

