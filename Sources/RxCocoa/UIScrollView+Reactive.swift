#if os(iOS) || os(tvOS)
import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIScrollView {
  func nearBottom(padding constant: CGFloat = 60) -> Observable<Bool> {
    contentOffset
      .map(\.y)
      .map { [unowned base] offsetY -> Bool in
        guard base.contentSize.height > 0 else { return false }
        let visibleHeight = base.frame.height - base.contentInset.top - base.contentInset.bottom
        let threshold = offsetY + visibleHeight + constant
        let hit = threshold > base.contentSize.height
        return hit
      }
      .distinctUntilChanged()
  }
}
#endif
