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
    
    public func subscribeOn(_ scheduler: RxScheduler) -> Observable<Self.E> {
        return subscribeOn(scheduler.toImmediateScheduler())
    }
}

// MARK: - Operator

extension ObservableType {
    public func void() -> Observable<Void> {
        return map({ _ in })
    }
    
    public func ignoreNil<R>() -> Observable<R> where E == R? {
        return flatMap(Observable.from(optional:))
    }
    
    public func ignoreErrorAndNil<R>() -> Observable<R> where E == R? {
        return catchErrorJustReturn(nil).flatMap(Observable.from(optional:))
    }
    
    public func map<R>(_ keyPath: KeyPath<E, R>) -> Observable<R> {
        return map { $0[keyPath: keyPath] }
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

extension ObservableType {
    public func bind<Target>(to target: Target, action: @escaping (Target, E) -> Void) -> Disposable {
        return observeOn(MainScheduler.instance).bind { e in
            action(target, e)
        }
    }
    
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: @escaping (Target, E) -> Void) -> Disposable {
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: Binder(target, binding: action))
    }
    
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, E>) -> Disposable {
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: target.rx[keyPath])
    }
    
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, E?>) -> Disposable {
        return map(Optional.init).observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: target.rx[keyPath])
    }
}

extension ReplaySubject: ReactiveCompatible {}
extension BehaviorSubject: ReactiveCompatible {}
extension PublishSubject: ReactiveCompatible {}
extension BehaviorRelay: ReactiveCompatible {}
extension PublishRelay: ReactiveCompatible {}

extension ObservableType {
    @discardableResult
    public func bind<O: AnyObject & ReactiveCompatible & ObserverType>(to observer: O) -> Disposable where O.E == E {
        return observeOn(MainScheduler.instance).takeUntil(observer.rx.deallocated).subscribe { [weak observer] e in
            observer?.on(e)
        }
    }
    
    @discardableResult
    public func bind<O: AnyObject & ReactiveCompatible & ObserverType>(to observer: O) -> Disposable where O.E == E? {
        return map(Optional.init).bind(to: observer)
    }
    
    @discardableResult
    public func bind(to relay: PublishRelay<E>) -> Disposable {
        return observeOn(MainScheduler.instance).takeUntil(relay.rx.deallocated).subscribe { [weak relay] e in
            switch e {
            case let .next(element):
                relay?.accept(element)
            case let .error(error):
                rxFatalErrorInDebug("Binding error to publish relay: \(error)")
            case .completed:
                break
            }
        }
    }
    
    @discardableResult
    public func bind(to relay: PublishRelay<E?>) -> Disposable {
        return map(Optional.init).bind(to: relay)
    }
    
    @discardableResult
    public func bind(to relay: BehaviorRelay<E>) -> Disposable {
        return observeOn(MainScheduler.instance).takeUntil(relay.rx.deallocated).subscribe { [weak relay] e in
            switch e {
            case let .next(element):
                relay?.accept(element)
            case let .error(error):
                rxFatalErrorInDebug("Binding error to behavior relay: \(error)")
                break
            case .completed:
                break
            }
        }
    }
    
    @discardableResult
    public func bind(to relay: BehaviorRelay<E?>) -> Disposable {
        return map(Optional.init).bind(to: relay)
    }
}

private func rxFatalErrorInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
    fatalError(lastMessage(), file: file, line: line)
    #else
    print("\(file):\(line): \(lastMessage())")
    #endif
}
