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
            .lazy
            .flatMap({ self.model(forSectionAt: $0).items })
            .filter(isIncluded)
    }

    public func indexPath(of model: Item) -> IndexPath? {
        return (0 ..< numberOfSections())
            .lazy
            .compactMap { section -> IndexPath? in
                self.model(forSectionAt: section)
                    .items
                    .lazy
                    .firstIndex(where: { $0.identity == model.identity })
                    .flatMap({ IndexPath(item: $0, section: section) })
            }
            .first
    }
}
