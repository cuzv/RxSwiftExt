#if os(iOS) || os(tvOS)
import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIScrollView {
  func nearBottom(padding constant: CGFloat = 60) -> Observable<Bool> {
    contentOffset
      .map(\.y)
      .map { [unowned base] offsetY -> Bool in
        let bottom = base.contentSize.height - offsetY - base.bounds.height
        let isNearBottom = bottom > 0 && bottom < 60
        return isNearBottom
      }
  }
}
#endif
