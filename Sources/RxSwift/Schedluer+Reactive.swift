import Foundation
import RxSwift

public enum RxScheduler {
  case main
  case serial(DispatchQoS)
  case concurrent(DispatchQoS)
  case operation(OperationQueue)

  public func toImmediateScheduler() -> ImmediateSchedulerType {
    switch self {
    case .main: MainScheduler.instance
    case let .serial(qos): SerialDispatchQueueScheduler(qos: qos)
    case let .concurrent(qos): ConcurrentDispatchQueueScheduler(qos: qos)
    case let .operation(queue): OperationQueueScheduler(operationQueue: queue)
    }
  }
}

public extension ObservableType {
  func observeOn(scheduler: RxScheduler) -> Observable<Element> {
    observe(on: scheduler.toImmediateScheduler())
  }

  func subscribeOn(_ scheduler: RxScheduler) -> Observable<Element> {
    subscribe(on: scheduler.toImmediateScheduler())
  }
}
