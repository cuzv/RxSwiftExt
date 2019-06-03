import RxSwift

extension ObservableType {
    public func void() -> Observable<Void> {
        return map({ _ in })
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
}

extension ObservableType where Element == String {
    public func ignoreEmpty() -> Observable<String> {
        return map { e -> String? in e.isEmpty ? nil : e }.ignoreNil()
    }
}
