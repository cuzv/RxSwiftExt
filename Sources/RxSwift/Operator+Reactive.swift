import RxSwift

public extension ObservableType {
  func optional() -> Observable<Element?> {
    map(Optional.init)
  }

  func eraseType() -> Observable<Void> {
    map { _ in () }
  }

  func with<Inserted>(
    _ inserted: Inserted
  ) -> Observable<(Element, Inserted)> {
    map { ($0, inserted) }
  }

  func withDeferred<Inserted>(
    _ inserted: @escaping @autoclosure () -> Inserted
  ) -> Observable<(Element, Inserted)> {
    map { ($0, inserted()) }
  }

  func succeeding<Successor>(
    _ successor: Successor
  ) -> Observable<Successor> {
    map { _ in successor }
  }

  func succeedingDeferred<Successor>(
    _ successor: @escaping @autoclosure () -> Successor
  ) -> Observable<Successor> {
    map { _ in successor() }
  }

  func unwrap<Wrapped>() -> Observable<Wrapped> where Element == Wrapped? {
    flatMap(Observable.from(optional:))
  }

  func map<Result>(
    _ keyPath: KeyPath<Element, Result>
  ) -> Observable<Result> {
    map { $0[keyPath: keyPath] }
  }

  func compactMap<Result>(
    _ keyPath: KeyPath<Element, Result?>
  ) -> Observable<Result> {
    compactMap { $0[keyPath: keyPath] }
  }

  func `as`<Transformed>(
    _ transformedType: Transformed.Type
  ) -> Observable<Transformed?> {
    map { $0 as? Transformed }
  }

  func of<Transformed>(
    _ transformedType: Transformed.Type
  ) -> Observable<Transformed> {
    compactMap { $0 as? Transformed }
  }

  func reverse<A, B>() -> Observable<(B, A)> where Element == (A, B) {
    map { ($0.1, $0.0) }
  }

  func reverse<A, B, C>() -> Observable<(C, B, A)> where Element == (A, B, C) {
    map { ($0.2, $0.1, $0.0) }
  }

  func squeeze<A, B, C>() -> Observable<(A, B, C)> where Element == ((A, B), C) {
    map { ($0.0, $0.1, $1) }
  }

  func filter(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
    filter { $0[keyPath: keyPath] }
  }

  func ignore(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
    filter { !$0[keyPath: keyPath] }
  }

  func ignore(_ predicate: @escaping (Element) throws -> Bool) -> Observable<Element> {
    filter { try !predicate($0) }
  }

  func catchErrorJustComplete() -> Observable<Element> {
    `catch` { _ in .empty() }
  }

  func map<A, B>(
    _ transformA: @escaping (Element) -> A,
    _ transformB: @escaping (Element) -> B
  ) -> Observable<(A, B)> {
    map { e in
      (transformA(e), transformB(e))
    }
  }

  func map<A, B, C>(
    _ transformA: @escaping (Element) -> A,
    _ transformB: @escaping (Element) -> B,
    _ transformC: @escaping (Element) -> C
  ) -> Observable<(A, B, C)> {
    map { e in
      (transformA(e), transformB(e), transformC(e))
    }
  }

  func mutate(
    _ mutation: @escaping (inout Element) -> Void
  ) -> Observable<Element> {
    map { output in
      var result = output
      mutation(&result)
      return result
    }
  }

  func formResult<E: ErrorRepresentable>() -> Observable<Swift.Result<Element, E>> {
    materialize().compactMap { event in
      switch event {
      case let .next(element):
        .success(element)
      case let .error(error):
        .failure(E(error))
      case .completed:
        nil
      }
    }
  }

  func withFlatMapLatest<Source: ObservableConvertibleType>(
    _ selector: @escaping (Element) throws -> Source
  ) -> Observable<(Element, Source.Element)> {
    flatMapLatest { element in
      try (selector(element)).asObservable().with(element).reverse()
    }
  }

  func withFlatMap<Source: ObservableConvertibleType>(
    _ selector: @escaping (Element) throws -> Source
  ) -> Observable<(Element, Source.Element)> {
    flatMap { element in
      try (selector(element)).asObservable().with(element).reverse()
    }
  }
}

public extension ObservableType where Element: Equatable {
  func filter(_ valueToFilter: @escaping @autoclosure () -> Element) -> Observable<Element> {
    filter { valueToFilter() == $0 }
  }

  func filter(_ valuesToFilter: Element...) -> Observable<Element> {
    filter { valuesToFilter.contains($0) }
  }

  func filter<Sequence: Swift.Sequence>(_ valuesToFilter: @escaping @autoclosure () -> Sequence) -> Observable<Element> where Sequence.Element == Element {
    filter { valuesToFilter().contains($0) }
  }

  func ignore(_ valueToFilter: @escaping @autoclosure () -> Element) -> Observable<Element> {
    filter { valueToFilter() != $0 }
  }

  func ignore(_ valuesToIgnore: Element...) -> Observable<Element> {
    filter { !valuesToIgnore.contains($0) }
  }

  func ignore<Sequence: Swift.Sequence>(_ valuesToIgnore: Sequence) -> Observable<Element> where Sequence.Element == Element {
    filter { !valuesToIgnore.contains($0) }
  }

  func ignore<Sequence: Swift.Sequence>(_ valuesToIgnore: @escaping @autoclosure () -> Sequence) -> Observable<Element> where Sequence.Element == Element {
    filter { !valuesToIgnore().contains($0) }
  }
}

public extension ObservableType where Element == String? {
  func ignoreEmpty() -> Observable<String> {
    unwrap().ignoreEmpty()
  }
}

public extension ObservableType where Element == Bool {
  func toggle() -> Observable<Bool> {
    map(!)
  }
}

public extension ObservableType where Element: Collection {
  func ignoreEmpty() -> Observable<Element> {
    ignore(\.isEmpty)
  }

  func tryMapMany<Result>(_ transform: @escaping (Element.Element) throws -> Result) -> Observable<[Result]> {
    map { try $0.map(transform) }
  }

  func mapMany<Result>(_ transform: @escaping (Element.Element) -> Result) -> Observable<[Result]> {
    map { $0.map(transform) }
  }
}

public extension ObservableType where Element: EventConvertible {
  func elements() -> Observable<Element.Element> {
    compactMap(\.event.element)
  }

  func errors() -> Observable<Swift.Error> {
    compactMap(\.event.error)
  }

  func terminal() -> Observable<Bool> {
    map(\.event.isStopEvent)
  }
}

import ResultConvertible

public extension ObservableType where Element: ResultConvertible {
  func elements() -> Observable<Element.Success> {
    compactMap(\.result.success)
  }

  func errors() -> Observable<Element.Failure> {
    compactMap(\.result.failure)
  }

  func unwrap() -> Observable<Element.Success> {
    .create { observer in
      self.subscribe { event in
        switch event {
        case let .next(element):
          switch element.result {
          case let .success(value):
            observer.onNext(value)
          case let .failure(error):
            observer.onError(error)
          }
        case let .error(error):
          observer.onError(error)
        case .completed:
          observer.onCompleted()
        }
      }
    }
  }
}

public extension Observable {
  func merge(_ others: Observable<Element>...) -> Observable<Element> {
    Observable.merge([self] + others)
  }
}
