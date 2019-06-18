import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UICollectionView {
    public func nearBottom(padding constant: CGFloat = 60) -> Observable<Bool> {
        return contentOffset
            .map(\.y)
            .map { [unowned base] offsetY -> Bool in
                let bottom = base.contentSize.height - offsetY - base.bounds.height
                let isNearBottom = 0 < bottom && bottom < 60
                return isNearBottom
        }
    }
}

