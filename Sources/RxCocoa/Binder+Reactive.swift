import RxSwift
import RxCocoa

extension Reactive where Base: AnyObject {
  public subscript(_ action: @escaping (Base) -> () -> Void) -> Binder<Void> {
    Binder(base) { target, _ in
      action(target)()
    }
  }

  public subscript<Value>(_ action: @escaping (Base) -> (Value) -> Void) -> Binder<Value> {
    Binder(base) { target, value in
      action(target)(value)
    }
  }

  public subscript<A, B>(_ action: @escaping (Base) -> (A, B) -> Void) -> Binder<(A, B)> {
    Binder(base) { target, args in
      action(target)(args.0, args.1)
    }
  }

  public subscript<A, B, C>(_ action: @escaping (Base) -> (A, B, C) -> Void) -> Binder<(A, B, C)> {
    Binder(base) { target, args in
      action(target)(args.0, args.1, args.2)
    }
  }

  public subscript<A, B, C, D>(_ action: @escaping (Base) -> (A, B, C, D) -> Void) -> Binder<(A, B, C, D)> {
    Binder(base) { target, args in
      action(target)(args.0, args.1, args.2, args.3)
    }
  }

  public subscript<A, B, C, D, E>(_ action: @escaping (Base) -> (A, B, C, D, E) -> Void) -> Binder<(A, B, C, D, E)> {
    Binder(base) { target, args in
      action(target)(args.0, args.1, args.2, args.3, args.4)
    }
  }
}
