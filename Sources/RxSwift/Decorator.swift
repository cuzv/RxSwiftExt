import Foundation
import RxSwift

public enum RxOperators {
    public static func materialize<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Event<Out>> {
        return {
            transform($0).materialize()
        }
    }

    public static func withMaterialize<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Event<(In, Out)>> {
        return {
            transform($0).with($0).reverse().materialize()
        }
    }

    public static func formResult<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Result<Out, Error>> {
        return {
            transform($0).formResult()
        }
    }

    public static func withFormResult<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Result<(In, Out), Error>> {
        return {
            transform($0).with($0).reverse().formResult()
        }
    }
}
