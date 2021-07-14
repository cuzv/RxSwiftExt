import Foundation
import RxSwift

public enum RxOperators {
    // MARK: - Materialize

    public static func materialize<In, Out>(_ function: @escaping (In) -> Observable<Out>) -> (In) -> Observable<Event<Out>> {
        return {
            function($0).materialize()
        }
    }

    // MARK: - Result

    public static func mapToResult<In, Out>(_ function: @escaping (In) -> Observable<Out>) -> (In) -> Observable<Result<Out, Error>> {
        return {
            function($0).mapToResult()
        }
    }
}
