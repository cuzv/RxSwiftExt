import RxSwift
import RxCocoa

// MARK: - Binding

extension ObservableType {
    public func bind<Target>(to target: Target, action: @escaping (Target, Element) -> Void) -> Disposable {
        return observeOn(MainScheduler.instance).bind { e in
            action(target, e)
        }
    }

    /// Bind Observable to Closure.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: @escaping (Target, Element) -> Void) -> Disposable {
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: Binder(target, binding: action))
    }

    /// Bind Observable to Optional Closure.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: ((Target, Element) -> Void)?) -> Disposable {
        if let action = action {
            return bind(to: target, action: action)
        }
        return Disposables.create()
    }

    /// Bind Observable to Closure that take no event element.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: @escaping (Target) -> Void) -> Disposable {
        let binder = Binder<Element>(target) { target, _ in
            action(target)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Optional Closure that take no event element.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: ((Target) -> Void)?) -> Disposable {
        if let action = action {
            return bind(to: target, action: action)
        }
        return Disposables.create()
    }

    /// Bind Observable to Closure that take event element as two arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B>(to target: Target, action: @escaping (Target, A, B) -> Void) -> Disposable where (A, B) == Element {
        let binder = Binder<Element>(target) { target, args in
            let (a, b) = args
            action(target, a, b)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Optional Closure that take event element as two arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B>(to target: Target, action: ((Target, A, B) -> Void)?) -> Disposable where (A, B) == Element {
        let binder = Binder<Element>(target) { target, args in
            let (a, b) = args
            action?(target, a, b)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Closure that take event element as three arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(to target: Target, action: @escaping (Target, A, B, C) -> Void) -> Disposable where (A, B, C) == Element {
        let binder = Binder<Element>(target) { target, args in
            let (a, b, c) = args
            action(target, a, b, c)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Optional Closure that take event element as three arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(to target: Target, action: ((Target, A, B, C) -> Void)?) -> Disposable where (A, B, C) == Element {
        let binder = Binder<Element>(target) { target, args in
            let (a, b, c) = args
            action?(target, a, b, c)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Method.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: @escaping (Target) -> (Element) -> Void) -> Disposable {
        let binder = Binder(target) { target, value in
            action(target)(value)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Method that take no event element.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, action: @escaping (Target) -> () -> Void) -> Disposable {
        let binder = Binder<Element>(target) { target, _ in
            action(target)()
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Method that take event element as two arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B>(to target: Target, action: @escaping (Target) -> (A, B) -> Void) -> Disposable where (A, B) == Element {
        let binder = Binder<Element>(target) { target, args in
            let (a, b) = args
            action(target)(a, b)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to Method that take event element as three arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(to target: Target, action: @escaping (Target) -> (A, B, C) -> Void) -> Disposable where (A, B, C) == Element {
        let binder = Binder<Element>(target) { target, args in
            let (a, b, c) = args
            action(target)(a, b, c)
        }
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: binder)
    }

    /// Bind Observable to KeyPath.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, Element>) -> Disposable {
        return observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: target.rx[keyPath])
    }

    /// Bind Observable to Optional KeyPath.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, Element?>) -> Disposable {
        return map(Optional.init).observeOn(MainScheduler.instance).takeUntil(target.rx.deallocated).bind(to: target.rx[keyPath])
    }
}

// MARK: - Relay

import RxRelay

extension ReplaySubject: ReactiveCompatible {}
extension BehaviorSubject: ReactiveCompatible {}
extension PublishSubject: ReactiveCompatible {}
extension BehaviorRelay: ReactiveCompatible {}
extension PublishRelay: ReactiveCompatible {}

extension ObservableType {
    @discardableResult
    public func bind<Observer: AnyObject & ReactiveCompatible & ObserverType>(to observer: Observer) -> Disposable where Observer.Element == Element {
        return observeOn(MainScheduler.instance).takeUntil(observer.rx.deallocated).subscribe { [weak observer] e in
            observer?.on(e)
        }
    }

    @discardableResult
    public func bind<Observer: AnyObject & ReactiveCompatible & ObserverType>(to observer: Observer) -> Disposable where Observer.Element == Element? {
        return map(Optional.init).bind(to: observer)
    }

    @discardableResult
    public func bind(to relay: PublishRelay<Element>) -> Disposable {
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
    public func bind(to relay: PublishRelay<Element?>) -> Disposable {
        return map(Optional.init).bind(to: relay)
    }

    @discardableResult
    public func bind(to relay: BehaviorRelay<Element>) -> Disposable {
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
    public func bind(to relay: BehaviorRelay<Element?>) -> Disposable {
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
