import RxSwift
import RxCocoa

extension Reactive where Base: AnyObject {
    public func makeBinder(_ action: @escaping (Base) -> () -> Void) -> Binder<Void> {
        return Binder(base) { target, _ in
            action(target)()
        }
    }
    
    public subscript(_ action: @escaping (Base) -> () -> Void) -> Binder<Void> {
        return makeBinder(action)
    }
    
    public func makeBinder<Value>(_ action: @escaping (Base) -> (Value) -> Void) -> Binder<Value> {
        return Binder(base) { target, value in
            action(target)(value)
        }
    }
    
    public subscript<Value>(_ action: @escaping (Base) -> (Value) -> Void) -> Binder<Value> {
        return makeBinder(action)
    }
    
    public func makeBinder<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> Void) -> Binder<(V1, V2)> {
        return Binder(base) { target, value in
            action(target)(value.0, value.1)
        }
    }
    
    public subscript<V1, V2>(_ action: @escaping (Base) -> (V1, V2) -> Void) -> Binder<(V1, V2)> {
        return makeBinder(action)
    }
    
    public func makeBinder<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> Void) -> Binder<(V1, V2, V3)> {
        return Binder(base) { target, value in
            action(target)(value.0, value.1, value.2)
        }
    }
    
    public subscript<V1, V2, V3>(_ action: @escaping (Base) -> (V1, V2, V3) -> Void) -> Binder<(V1, V2, V3)> {
        return makeBinder(action)
    }
}

