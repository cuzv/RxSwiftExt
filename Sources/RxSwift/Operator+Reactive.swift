import RxSwift

extension ObservableType {
    public func void() -> Observable<Void> {
        return replaceWith(())
    }

    public func replaceWith<NewElement>(_ element: @escaping @autoclosure () -> NewElement) -> Observable<NewElement> {
        return map { _ in element() }
    }

    public func unwrap<Wrapped>() -> Observable<Wrapped> where Element == Wrapped? {
        return flatMap(Observable.from(optional:))
    }

    public func map<Result>(_ keyPath: KeyPath<Element, Result>) -> Observable<Result> {
        return map { $0[keyPath: keyPath] }
    }

    public func compactMap<Result>(_ keyPath: KeyPath<Element, Result?>) -> Observable<Result> {
        return compactMap { $0[keyPath: keyPath] }
    }

    public func `as`<Transformed>(_ transformedType: Transformed.Type) -> Observable<Transformed?> {
        return map { $0 as? Transformed }
    }

    public func of<Transformed>(_ transformedType: Transformed.Type) -> Observable<Transformed> {
        return compactMap { $0 as? Transformed }
    }

    public func filter(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        return filter { $0[keyPath: keyPath] }
    }

    public func ignore(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        return filter { !$0[keyPath: keyPath] }
    }

    public func ignore(_ predicate: @escaping (Element) throws -> Bool) -> Observable<Element> {
        return filter { try !predicate($0) }
    }

    public func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in .empty() }
    }
}

extension ObservableType where Element: Equatable {
    public func filter(_ valuesToFilter: Element...) -> Observable<Element> {
        return filter { valuesToFilter.contains($0) }
    }

    public func filter<Sequence: Swift.Sequence>(_ valuesToFilter: Sequence) -> Observable<Element> where Sequence.Element == Element {
        return filter { valuesToFilter.contains($0) }
    }

    public func ignore(_ valuesToIgnore: Element...) -> Observable<Element> {
        return filter { !valuesToIgnore.contains($0) }
    }

    public func ignore<Sequence: Swift.Sequence>(_ valuesToIgnore: Sequence) -> Observable<Element> where Sequence.Element == Element {
        return filter { !valuesToIgnore.contains($0) }
    }
}

extension ObservableType where Element == String? {
    public func ignoreEmpty() -> Observable<String> {
        return unwrap().ignoreEmpty()
    }
}

extension ObservableType where Element == Bool {
    public func not() -> Observable<Bool> {
        return map(!)
    }
}

extension ObservableType where Element: Collection {
    public func ignoreEmpty() -> Observable<Element> {
        return ignore(\.isEmpty)
    }

    public func mapElements<Transformed>(_ transform: @escaping (Element.Element) throws -> Transformed) -> Observable<[Transformed]> {
        return map { try $0.map(transform) }
    }
}

extension ObservableType where Element: EventConvertible {
    public func elements() -> Observable<Element.Element> {
        return compactMap(\.event.element)
    }

    public func errors() -> Observable<Swift.Error> {
        return compactMap(\.event.error)
    }
}

import ResultConvertible

extension ObservableType where Element: ResultConvertible {
    public func elements() -> Observable<Element.Success> {
        return compactMap(\.result.success)
    }

    public func errors() -> Observable<Element.Failure> {
        return compactMap(\.result.failure)
    }
}

extension Observable {
    public func merge(_ others: Observable<Element>...) -> Observable<Element> {
        return Observable.merge([self] + others)
    }
}
