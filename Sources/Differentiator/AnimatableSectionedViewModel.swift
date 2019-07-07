import Foundation
import Differentiator

public protocol AnimatableSectionedViewModel {
    associatedtype Section: IdentifiableType & Equatable
    associatedtype Item: IdentifiableType & Equatable
    typealias ModelOfAnimatableSection = AnimatableSectionModel<Section, Item>

    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    func model(forSectionAt section: Int) -> ModelOfAnimatableSection
}

extension AnimatableSectionedViewModel {
    public func model(forItemAt indexPath: IndexPath) -> Item {
        return model(forSectionAt: indexPath.section).items[indexPath.item]
    }

    public func allModels(_ isIncluded: (Item) -> Bool) -> [Item] {
        return (0 ..< numberOfSections())
            .map({ model(forSectionAt: $0) })
            .flatMap({ $0.items })
            .filter(isIncluded)
    }

    public func indexPath(of model: Item) -> IndexPath? {
        for section in 0 ..< numberOfSections() {
            if let item = self.model(forSectionAt: section).items.firstIndex(where: { $0 == model }) {
                return IndexPath(item: item, section: section)
            }
        }
        return nil
    }
}
