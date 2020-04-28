import RxSwift
import RxCocoa

// MARK: - Binding

extension ObservableType {
    public func bind<Target>(
        to target: Target,
        action: @escaping (Target, Element) -> Void
    ) -> Disposable {
        bind { element in
            action(target, element)
        }
    }

    /// Bind Observable to Closure.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        action: @escaping (Target, Element) -> Void
    ) -> Disposable {
        bind(to: Binder(target, binding: action))
    }

    /// Bind Observable to Optional Closure.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        action: ((Target, Element) -> Void)?
    ) -> Disposable {
        if let action = action {
            return bind(to: target, action: action)
        }
        return Disposables.create()
    }

    /// Bind Observable to Closure that take no event element.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        action: @escaping (Target) -> Void
    ) -> Disposable {
        takeUntil(target.rx.deallocated).bind(
            to: Binder(target) { target, _ in
                action(target)
            }
        )
    }

    /// Bind Observable to Optional Closure that take no event element.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        action: ((Target) -> Void)?
    ) -> Disposable {
        if let action = action {
            return bind(to: target, action: action)
        }
        return Disposables.create()
    }

    /// Bind Observable to Closure that take event element as two arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B>(
        to target: Target,
        action: @escaping (Target, A, B) -> Void
    ) -> Disposable where (A, B) == Element {
        takeUntil(target.rx.deallocated).bind(
            to: Binder(target) { target, args in
                action(target, args.0, args.1)
            }
        )
    }

    /// Bind Observable to Optional Closure that take event element as two arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B>(
        to target: Target,
        action: ((Target, A, B) -> Void)?
    ) -> Disposable where (A, B) == Element {
        takeUntil(target.rx.deallocated).bind(
            to: Binder<Element>(target) { target, args in
                action?(target, args.0, args.1)
            }
        )
    }

    /// Bind Observable to Closure that take event element as three arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(
        to target: Target,
        action: @escaping (Target, A, B, C) -> Void
    ) -> Disposable where (A, B, C) == Element {
        takeUntil(target.rx.deallocated).bind(
            to: Binder<Element>(target) { target, args in
                action(target, args.0, args.1, args.2)
            }
        )
    }

    /// Bind Observable to Optional Closure that take event element as three arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(
        to target: Target,
        action: ((Target, A, B, C) -> Void)?
    ) -> Disposable where (A, B, C) == Element {
        takeUntil(target.rx.deallocated).bind(
            to: Binder<Element>(target) { target, args in
                action?(target, args.0, args.1, args.2)
            }
        )
    }

    /// Bind Observable to Method.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        action: @escaping (Target) -> (Element) -> Void
    ) -> Disposable {
        takeUntil(target.rx.deallocated).bind(
            to: Binder(target) { target, value in
                action(target)(value)
            }
        )
    }

    /// Bind Observable to Method that take no event element.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        action: @escaping (Target) -> () -> Void
    ) -> Disposable {
        takeUntil(target.rx.deallocated).bind(
            to: Binder(target) { target, _ in
                action(target)()
            }
        )
    }

    /// Bind Observable to Method that take event element as two arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B>(
        to target: Target,
        action: @escaping (Target) -> (A, B) -> Void
    ) -> Disposable where (A, B) == Element {
        takeUntil(target.rx.deallocated).bind(
            to: Binder<Element>(target) { target, args in
                action(target)(args.0, args.1)
            }
        )
    }

    /// Bind Observable to Method that take event element as three arguments.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(
        to target: Target,
        action: @escaping (Target) -> (A, B, C) -> Void
    ) -> Disposable where (A, B, C) == Element {
        takeUntil(target.rx.deallocated).bind(
            to: Binder(target) { target, args in
                action(target)(args.0, args.1, args.2)
            }
        )
    }

    /// Bind Observable to KeyPath.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        keyPath: ReferenceWritableKeyPath<Target, Element>
    ) -> Disposable {
        takeUntil(target.rx.deallocated).bind(to: target.rx[keyPath])
    }

    /// Bind Observable to Optional KeyPath.
    @discardableResult
    public func bind<Target: AnyObject & ReactiveCompatible>(
        to target: Target,
        keyPath: ReferenceWritableKeyPath<Target, Element?>
    ) -> Disposable {
        map(Optional.init).takeUntil(target.rx.deallocated).bind(to: target.rx[keyPath])
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
    public func bind<Observer: AnyObject & ReactiveCompatible & ObserverType>(
        to observer: Observer
    ) -> Disposable where Observer.Element == Element {
        takeUntil(observer.rx.deallocated).subscribe { [weak observer] e in
            observer?.on(e)
        }
    }

    @discardableResult
    public func bind<Observer: AnyObject & ReactiveCompatible & ObserverType>(
        to observer: Observer
    ) -> Disposable where Observer.Element == Element? {
        map(Optional.init).bind(to: observer)
    }

    @discardableResult
    public func bind(to relay: PublishRelay<Element>) -> Disposable {
        takeUntil(relay.rx.deallocated).subscribe { [weak relay] e in
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
        map(Optional.init).bind(to: relay)
    }

    @discardableResult
    public func bind(to relay: BehaviorRelay<Element>) -> Disposable {
        takeUntil(relay.rx.deallocated).subscribe { [weak relay] e in
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
        map(Optional.init).bind(to: relay)
    }
}

private func rxFatalErrorInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
    fatalError(lastMessage(), file: file, line: line)
    #else
    print("\(file):\(line): \(lastMessage())")
    #endif
}
