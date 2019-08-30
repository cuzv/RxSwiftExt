import Foundation
import Differentiator

public protocol SectionedViewModel {
    associatedtype Section
    associatedtype Item
    typealias ModelOfSection = SectionModel<Section, Item>

    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    func model(forSectionAt section: Int) -> ModelOfSection
}

extension SectionedViewModel {
    public func model(forItemAt indexPath: IndexPath) -> Item {
        return model(forSectionAt: indexPath.section).items[indexPath.item]
    }

    public func allModels(_ isIncluded: (Item) -> Bool) -> [Item] {
        return (0 ..< numberOfSections())
            .lazy
            .flatMap({ self.model(forSectionAt: $0).items })
            .filter(isIncluded)
    }
}

extension SectionedViewModel where Item: Equatable {
    public func indexPath(of model: ModelOfSection.Item) -> IndexPath? {
        return (0 ..< numberOfSections())
            .lazy
            .compactMap { section -> IndexPath? in
                self.model(forSectionAt: section)
                    .items
                    .lazy
                    .firstIndex(where: { $0 == model })
                    .flatMap({ IndexPath(item: $0, section: section) })
            }
            .first
    }
}
