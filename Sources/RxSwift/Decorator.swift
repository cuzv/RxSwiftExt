import Foundation
import RxSwift

// MARK: - Materialize

func materialize<Out>(of function: @escaping () -> Observable<Out>) -> () -> Observable<Event<Out>> {
    return {
        function().materialize()
    }
}

func materialize<In, Out>(of function: @escaping (In) -> Observable<Out>) -> (In) -> Observable<Event<Out>> {
    return {
        function($0).materialize()
    }
}

func materialize<X, Y, Out>(of function: @escaping (X, Y) -> Observable<Out>) -> (X, Y) -> Observable<Event<Out>> {
    return {
        function($0, $1).materialize()
    }
}

func materialize<X, Y, Z, Out>(of function: @escaping (X, Y, Z) -> Observable<Out>) -> (X, Y, Z) -> Observable<Event<Out>> {
    return {
        function($0, $1, $2).materialize()
    }
}

// MARK: - Result

func materialize<Out>(of function: @escaping () -> Observable<Out>) -> () -> Observable<Result<Out, Error>> {
    return {
        function().mapToResult()
    }
}

func materialize<In, Out>(of function: @escaping (In) -> Observable<Out>) -> (In) -> Observable<Result<Out, Error>> {
    return {
        function($0).mapToResult()
    }
}

func materialize<X, Y, Out>(of function: @escaping (X, Y) -> Observable<Out>) -> (X, Y) -> Observable<Result<Out, Error>> {
    return {
        function($0, $1).mapToResult()
    }
}

func materialize<X, Y, Z, Out>(of function: @escaping (X, Y, Z) -> Observable<Out>) -> (X, Y, Z) -> Observable<Result<Out, Error>> {
    return {
        function($0, $1, $2).mapToResult()
    }
}
