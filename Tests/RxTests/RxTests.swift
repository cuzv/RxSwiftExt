import XCTest
@testable import RxSwift
@testable import RxRelay
@testable import RxSwiftExt

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
    return .just(1)
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
