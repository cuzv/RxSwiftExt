import Foundation
import RxSwift

public enum Rx {
  public static func materialize<In, Out>(
    _ transform: @escaping (In) -> Observable<Out>
  ) -> (In) -> Observable<Event<Out>> {
    {
      transform($0).materialize()
    }
  }

  public static func withMaterialize<In, Out>(
    _ transform: @escaping (In) -> Observable<Out>
  ) -> (In) -> Observable<Event<(In, Out)>> {
    {
      transform($0).with($0).reverse().materialize()
    }
  }

  public static func formResult<In, Out, E: ErrorRepresentable>(
    _ transform: @escaping (In) -> Observable<Out>
  ) -> (In) -> Observable<Result<Out, E>> {
    {
      transform($0).formResult()
    }
  }

  public static func withFormResult<In, Out, E: ErrorRepresentable>(
    _ transform: @escaping (In) -> Observable<Out>
  ) -> (In) -> Observable<Result<(In, Out), E>> {
    {
      transform($0).with($0).reverse().formResult()
    }
  }
}
