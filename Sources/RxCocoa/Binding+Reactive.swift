import RxCocoa
import RxSwift

// MARK: - Binding

public extension ObservableType {
  func bind<Target>(
    to target: Target,
    action: @escaping (Target, Element) -> Void
  ) -> Disposable {
    bind { element in
      action(target, element)
    }
  }

  /// Bind Observable to Closure.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    action: @escaping (Target, Element) -> Void
  ) -> Disposable {
    bind(to: Binder(target, binding: action))
  }

  /// Bind Observable to Optional Closure.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    action: ((Target, Element) -> Void)?
  ) -> Disposable {
    if let action {
      return bind(to: target, action: action)
    }
    return Disposables.create()
  }

  /// Bind Observable to Closure that take no event element.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    action: @escaping (Target) -> Void
  ) -> Disposable {
    take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, _ in
        action(target)
      }
    )
  }

  /// Bind Observable to Optional Closure that take no event element.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    action: ((Target) -> Void)?
  ) -> Disposable {
    if let action {
      return bind(to: target, action: action)
    }
    return Disposables.create()
  }

  /// Bind Observable to Closure that take event element as two arguments.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible, A, B>(
    to target: Target,
    action: @escaping (Target, A, B) -> Void
  ) -> Disposable where (A, B) == Element {
    take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, args in
        action(target, args.0, args.1)
      }
    )
  }

  /// Bind Observable to Optional Closure that take event element as two arguments.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible, A, B>(
    to target: Target,
    action: ((Target, A, B) -> Void)?
  ) -> Disposable where (A, B) == Element {
    take(until: target.rx.deallocated).bind(
      to: Binder<Element>(target) { target, args in
        action?(target, args.0, args.1)
      }
    )
  }

  /// Bind Observable to Closure that take event element as three arguments.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(
    to target: Target,
    action: @escaping (Target, A, B, C) -> Void
  ) -> Disposable where (A, B, C) == Element {
    take(until: target.rx.deallocated).bind(
      to: Binder<Element>(target) { target, args in
        action(target, args.0, args.1, args.2)
      }
    )
  }

  /// Bind Observable to Optional Closure that take event element as three arguments.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(
    to target: Target,
    action: ((Target, A, B, C) -> Void)?
  ) -> Disposable where (A, B, C) == Element {
    take(until: target.rx.deallocated).bind(
      to: Binder<Element>(target) { target, args in
        action?(target, args.0, args.1, args.2)
      }
    )
  }

  /// Bind Observable to Method.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    action: @escaping (Target) -> (Element) -> Void
  ) -> Disposable {
    take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, value in
        action(target)(value)
      }
    )
  }

  /// Bind Observable to Method that take no event element.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    action: @escaping (Target) -> () -> Void
  ) -> Disposable {
    take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, _ in
        action(target)()
      }
    )
  }

  /// Bind Observable to Method that take event element as two arguments.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible, A, B>(
    to target: Target,
    action: @escaping (Target) -> (A, B) -> Void
  ) -> Disposable where (A, B) == Element {
    take(until: target.rx.deallocated).bind(
      to: Binder<Element>(target) { target, args in
        action(target)(args.0, args.1)
      }
    )
  }

  /// Bind Observable to Method that take event element as three arguments.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible, A, B, C>(
    to target: Target,
    action: @escaping (Target) -> (A, B, C) -> Void
  ) -> Disposable where (A, B, C) == Element {
    take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, args in
        action(target)(args.0, args.1, args.2)
      }
    )
  }

  /// Bind Observable to KeyPath.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    keyPath: ReferenceWritableKeyPath<Target, Element>
  ) -> Disposable {
    take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, value in
        target[keyPath: keyPath] = value
      }
    )
  }

  /// Bind Observable to Optional KeyPath.
  @discardableResult
  func bind<Target: AnyObject & ReactiveCompatible>(
    to target: Target,
    keyPath: ReferenceWritableKeyPath<Target, Element?>
  ) -> Disposable {
    map(Optional.init).take(until: target.rx.deallocated).bind(
      to: Binder(target) { target, value in
        target[keyPath: keyPath] = value
      }
    )
  }
}

// MARK: - Relay

import RxRelay

extension ReplaySubject: ReactiveCompatible {}
extension BehaviorSubject: ReactiveCompatible {}
extension PublishSubject: ReactiveCompatible {}
extension BehaviorRelay: ReactiveCompatible {}
extension PublishRelay: ReactiveCompatible {}

public extension ObservableType {
  @discardableResult
  func bind<Observer: AnyObject & ReactiveCompatible & ObserverType>(
    to observer: Observer
  ) -> Disposable where Observer.Element == Element {
    take(until: observer.rx.deallocated).subscribe { [weak observer] e in
      observer?.on(e)
    }
  }

  @discardableResult
  func bind<Observer: AnyObject & ReactiveCompatible & ObserverType>(
    to observer: Observer
  ) -> Disposable where Observer.Element == Element? {
    map(Optional.init).bind(to: observer)
  }

  @discardableResult
  func bind(to relay: PublishRelay<Element>) -> Disposable {
    take(until: relay.rx.deallocated).subscribe { [weak relay] e in
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
  func bind(to relay: PublishRelay<Element?>) -> Disposable {
    map(Optional.init).bind(to: relay)
  }

  @discardableResult
  func bind(to relay: BehaviorRelay<Element>) -> Disposable {
    take(until: relay.rx.deallocated).subscribe { [weak relay] e in
      switch e {
      case let .next(element):
        relay?.accept(element)
      case let .error(error):
        rxFatalErrorInDebug("Binding error to behavior relay: \(error)")
      case .completed:
        break
      }
    }
  }

  @discardableResult
  func bind(to relay: BehaviorRelay<Element?>) -> Disposable {
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
