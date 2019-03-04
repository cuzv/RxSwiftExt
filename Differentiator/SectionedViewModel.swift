import Foundation
import Differentiator

public protocol SectionedViewModel {
    associatedtype Section
    associatedtype Item
    typealias ModelOfSection = SectionModel<Section, Item>
    
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    func model(inSection section: Int) -> ModelOfSection
}

public extension SectionedViewModel {
    public func model(atIndexPath indexPath: IndexPath) -> Item {
        return model(inSection: indexPath.section).items[indexPath.item]
    }
    
    public func allModels(_ isIncluded: (Item) -> Bool) -> [Item] {
        return (0 ..< numberOfSections())
            .map({ model(inSection: $0) })
            .flatMap({ $0.items })
            .filter(isIncluded)
    }
}

public extension SectionedViewModel where Item: Equatable {
    public func indexPath(of model: ModelOfSection.Item) -> IndexPath? {
        for section in 0 ..< numberOfSections() {
            if let item = self.model(inSection: section).items.firstIndex(where: { $0 == model }) {
                return IndexPath(item: item, section: section)
            }
        }
        return nil
    }
}