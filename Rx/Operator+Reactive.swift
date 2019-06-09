import RxSwift

extension ObservableType {
    public func void() -> Observable<Void> {
        return replaceWith(())
    }
    
    public func ignoreNil<Revision>() -> Observable<Revision> where Element == Revision? {
        return flatMap(Observable.from(optional:))
    }
    
    public func ignoreErrorAndNil<Revision>() -> Observable<Revision> where Element == Revision? {
        return catchErrorJustReturn(nil).flatMap(Observable.from(optional:))
    }
    
    public func map<Revision>(_ keyPath: KeyPath<Element, Revision>) -> Observable<Revision> {
        return map { $0[keyPath: keyPath] }
    }
    
    public func filter(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        return filter { $0[keyPath: keyPath] }
    }
    
    public func filterReversed(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        return filter { !$0[keyPath: keyPath] }
    }
    
    public func replaceWith<NewElement>(_ element: NewElement) -> Observable<NewElement> {
        return map({ _ in element })
    }
}

extension ObservableType where Element == String {
    public func ignoreEmpty() -> Observable<String> {
        return map(Optional.init).ignoreEmpty()
    }
}

extension ObservableType where Element == String? {
    public func ignoreEmpty() -> Observable<String> {
        return ignoreNil().filterReversed(\.isEmpty)
    }
}

extension ObservableType where Element == Bool {
    public func reversed() -> Observable<Bool> {
        return map({ !$0 })
    }
    
    public func ignoreTrue() -> Observable<Bool> {
        return filter({ !$0 })
    }
    
    public func ignoreFalse() -> Observable<Bool> {
        return filter({ $0 })
    }
}
