import Foundation
import RxSwift

public enum RxOperators {
    // MARK: - Materialize
    @available(*, deprecated, renamed: "wrapsEvent(_:)")
    public static func materialize<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Event<Out>> {
        wrapsEvent(transform)
    }

    public static func wrapsEvent<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Event<Out>> {
        return {
            transform($0).materialize()
        }
    }

    public static func withWrapsEvent<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Event<(In, Out)>> {
        return {
            transform($0).with($0).reverse().materialize()
        }
    }

    // MARK: - Result

    @available(*, deprecated, renamed: "wrapsResult(_:)")
    public static func mapToResult<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Result<Out, Error>> {
        wrapsResult(transform)
    }

    public static func wrapsResult<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Result<Out, Error>> {
        return {
            transform($0).wrapsResult()
        }
    }

    public static func withWrapsResult<In, Out>(
        _ transform: @escaping (In) -> Observable<Out>
    ) -> (In) -> Observable<Result<(In, Out), Error>> {
        return {
            transform($0).with($0).reverse().wrapsResult()
        }
    }
}
