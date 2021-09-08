import Foundation
import RxSwift

public final class Lifetime {
  fileprivate let subject = ReplaySubject<Void>.create(bufferSize: 1)

  private init() {
  }

  deinit {
    subject.onNext(())
    subject.onCompleted()
  }
}

extension Lifetime {
  private struct AssociatedObjectKeys {
    static var lifetime: Void?
  }

  public static func of(_ object: AnyObject) -> Lifetime {
    objc_sync_enter(self)
    defer {
      objc_sync_exit(self)
    }

    if let result = objc_getAssociatedObject(object, &AssociatedObjectKeys.lifetime) as? Lifetime {
      return result
    }

    let result = Lifetime()
    objc_setAssociatedObject(object, &AssociatedObjectKeys.lifetime, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return result
  }
}

extension ObservableType {
  public func takeDuring(_ lifetime: Lifetime) -> Observable<Element> {
    take(until: lifetime.subject)
  }
}
