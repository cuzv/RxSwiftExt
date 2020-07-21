import Foundation
import RxSwift

// MARK: - Materialize

func materialize<In, Out>(of function: @escaping (In) -> Observable<Out>) -> (In) -> Observable<Event<Out>> {
    return {
        function($0).materialize()
    }
}

// MARK: - Result

func result<In, Out>(of function: @escaping (In) -> Observable<Out>) -> (In) -> Observable<Result<Out, Error>> {
    return {
        function($0).mapToResult()
    }
}
