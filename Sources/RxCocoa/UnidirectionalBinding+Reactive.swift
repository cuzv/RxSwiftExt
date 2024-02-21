import RxCocoa
import RxSwift

// MARK: - BindingTargetProvider

public protocol BindingTargetProvider {
  associatedtype Value

  var bindingTarget: BindingTarget<Value> { get }
}

public struct BindingTarget<Value>: BindingTargetProvider {
  public let lifetime: Lifetime
  public let action: (Value) -> Void

  public var bindingTarget: BindingTarget<Value> {
    self
  }

  public init(lifetime: Lifetime, action: @escaping (Value) -> Void) {
    self.lifetime = lifetime
    self.action = action
  }
}

public extension BindingTarget {
  init(object: some AnyObject, action: @escaping (Value) -> Void) {
    self.init(lifetime: .of(object), action: action)
  }

  init<Object: AnyObject>(object: Object, keyPath: WritableKeyPath<Object, Value>) {
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

infix operator =>: BindingPrecedence

public extension BindingTargetProvider {
  @discardableResult
  static func =>
  <Source: ObservableType>(source: Source, provider: Self) -> Disposable
    where Value == Source.Element
  {
    let bindingTarget = provider.bindingTarget
    return source.asObservable()
      .takeDuring(bindingTarget.lifetime)
      .bind(onNext: bindingTarget.action)
  }

  @discardableResult
  static func =>
  <Source: ObservableType>(source: Source, provider: Self) -> Disposable
    where Value == Source.Element?
  {
    source.map(Optional.init) => provider
  }
}

public extension BindingTargetProvider where Value == Void {
  @discardableResult
  static func =>
  (source: some ObservableType, provider: Self) -> Disposable {
    let bindingTarget = provider.bindingTarget
    return source.asObservable()
      .map { _ in }
      .takeDuring(bindingTarget.lifetime)
      .bind(onNext: bindingTarget.action)
  }
}

// MARK: - Reactive Extensions

public extension Reactive where Base: AnyObject {
  private func makeBindingTarget<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
    .init(object: base, keyPath: keyPath)
  }

  subscript<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
    .init(object: base, keyPath: keyPath)
  }

  subscript<Value>(action: @escaping (Base) -> (Value) -> Void) -> BindingTarget<Value> {
    .init(object: base) { [weak base = base] value in
      if let base {
        action(base)(value)
      }
    }
  }

  func makeBindingTarget<Value>(action: ((Base, Value) -> Void)?) -> BindingTarget<Value> {
    .init(object: base) { [weak base = base] value in
      if let base {
        action?(base, value)
      }
    }
  }

  subscript<Value>(action: ((Base, Value) -> Void)?) -> BindingTarget<Value> {
    makeBindingTarget(action: action)
  }

  subscript<Value>(action: @escaping (Base, Value) -> Void) -> BindingTarget<Value> {
    makeBindingTarget(action: action)
  }

  subscript(action: @escaping (Base) -> () -> Void) -> BindingTarget<Void> {
    .init(object: base) { [weak base = base] _ in
      if let base {
        action(base)()
      }
    }
  }

  subscript(action: ((Base) -> Void)?) -> BindingTarget<Void> {
    makeBindingTarget { base, _ in
      action?(base)
    }
  }

  subscript(action: @escaping (Base) -> Void) -> BindingTarget<Void> {
    self[Optional(action)]
  }

  subscript<A, B>(action: @escaping (Base) -> (A, B) -> Void) -> BindingTarget<(A, B)> {
    .init(object: base) { [weak base = base] a, b in
      if let base {
        action(base)(a, b)
      }
    }
  }

  subscript<A, B>(action: ((Base, A, B) -> Void)?) -> BindingTarget<(A, B)> {
    makeBindingTarget { base, args in
      let (a, b) = args
      action?(base, a, b)
    }
  }

  subscript<A, B>(action: @escaping (Base, A, B) -> Void) -> BindingTarget<(A, B)> {
    self[Optional(action)]
  }

  subscript<A, B, C>(action: @escaping (Base) -> (A, B, C) -> Void) -> BindingTarget<(A, B, C)> {
    .init(object: base) { [weak base = base] a, b, c in
      if let base {
        action(base)(a, b, c)
      }
    }
  }

  subscript<A, B, C>(action: ((Base, A, B, C) -> Void)?) -> BindingTarget<(A, B, C)> {
    makeBindingTarget { base, args in
      let (a, b, c) = args
      action?(base, a, b, c)
    }
  }

  subscript<A, B, C>(action: @escaping (Base, A, B, C) -> Void) -> BindingTarget<(A, B, C)> {
    self[Optional(action)]
  }
}

// MARK: - RxRelay

import RxRelay

public extension ObserverType where Self: AnyObject & BindingTargetProvider {
  var bindingTarget: BindingTarget<Element> {
    .init(object: self, action: onNext)
  }
}

extension ReplaySubject: BindingTargetProvider {}
extension BehaviorSubject: BindingTargetProvider {}
extension PublishSubject: BindingTargetProvider {}

public protocol RxRelayObject: ObservableType {
  func accept(_ event: Element)
}

public extension RxRelayObject where Self: AnyObject & BindingTargetProvider {
  var bindingTarget: BindingTarget<Element> {
    .init(object: self, action: accept)
  }
}

extension PublishRelay: RxRelayObject, BindingTargetProvider {}
extension BehaviorRelay: RxRelayObject, BindingTargetProvider {}
