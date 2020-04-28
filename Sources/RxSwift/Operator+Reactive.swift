import RxSwift

extension ObservableType {
    public func void() -> Observable<Void> {
        replaceWith(())
    }

    public func replaceWith<NewElement>(_ element: @escaping @autoclosure () -> NewElement) -> Observable<NewElement> {
        map { _ in element() }
    }

    public func unwrap<Wrapped>() -> Observable<Wrapped> where Element == Wrapped? {
        flatMap(Observable.from(optional:))
    }

    public func map<Result>(_ keyPath: KeyPath<Element, Result>) -> Observable<Result> {
        map { $0[keyPath: keyPath] }
    }

    public func compactMap<Result>(_ keyPath: KeyPath<Element, Result?>) -> Observable<Result> {
        compactMap { $0[keyPath: keyPath] }
    }

    public func `as`<Transformed>(_ transformedType: Transformed.Type) -> Observable<Transformed?> {
        map { $0 as? Transformed }
    }

    public func of<Transformed>(_ transformedType: Transformed.Type) -> Observable<Transformed> {
        compactMap { $0 as? Transformed }
    }

    public func filter(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        filter { $0[keyPath: keyPath] }
    }

    public func ignore(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        filter { !$0[keyPath: keyPath] }
    }

    public func ignore(_ predicate: @escaping (Element) throws -> Bool) -> Observable<Element> {
        filter { try !predicate($0) }
    }

    public func catchErrorJustComplete() -> Observable<Element> {
        catchError { _ in .empty() }
    }

    public func mapToResult() -> Observable<Swift.Result<Element, Error>> {
        materialize().compactMap(Swift.Result.init(event:))
    }
}

extension Swift.Result {
    init?(event: Event<Success>) {
        switch event {
        case let .next(element):
            self = .success(element)
        case let .error(error) where error is Failure:
            self = .failure(error as! Failure)
        case .error:
            return nil
        case .completed:
            return nil
        }
    }
}

extension ObservableType where Element: Equatable {
    public func filter(_ valuesToFilter: Element...) -> Observable<Element> {
        filter { valuesToFilter.contains($0) }
    }

    public func filter<Sequence: Swift.Sequence>(_ valuesToFilter: Sequence) -> Observable<Element> where Sequence.Element == Element {
        filter { valuesToFilter.contains($0) }
    }

    public func ignore(_ valuesToIgnore: Element...) -> Observable<Element> {
        filter { !valuesToIgnore.contains($0) }
    }

    public func ignore<Sequence: Swift.Sequence>(_ valuesToIgnore: Sequence) -> Observable<Element> where Sequence.Element == Element {
        filter { !valuesToIgnore.contains($0) }
    }
}

extension ObservableType where Element == String? {
    public func ignoreEmpty() -> Observable<String> {
        unwrap().ignoreEmpty()
    }
}

extension ObservableType where Element == Bool {
    public func not() -> Observable<Bool> {
        map(!)
    }
}

extension ObservableType where Element: Collection {
    public func ignoreEmpty() -> Observable<Element> {
        ignore(\.isEmpty)
    }

    public func mapElements<Transformed>(_ transform: @escaping (Element.Element) throws -> Transformed) -> Observable<[Transformed]> {
        map { try $0.map(transform) }
    }
}

extension ObservableType where Element: EventConvertible {
    public func elements() -> Observable<Element.Element> {
        compactMap(\.event.element)
    }

    public func errors() -> Observable<Swift.Error> {
        compactMap(\.event.error)
    }
}

import ResultConvertible

extension ObservableType where Element: ResultConvertible {
    public func elements() -> Observable<Element.Success> {
        compactMap(\.result.success)
    }

    public func errors() -> Observable<Element.Failure> {
        compactMap(\.result.failure)
    }

    public func unwrap() -> Observable<Element.Success> {
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

extension Observable {
    public func merge(_ others: Observable<Element>...) -> Observable<Element> {
        Observable.merge([self] + others)
    }
}
