@testable import RxRelay
@testable import RxSwift
@testable import RxSwiftExt
import XCTest

final class SpmTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.

    let relay = BehaviorRelay<Bool>(value: true)
    XCTAssertEqual(relay.value, true)

    relay.accept(false)
    XCTAssertEqual(relay.value, false)
  }

  func request(in: String) -> Observable<Int> {
    .just(1)
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
