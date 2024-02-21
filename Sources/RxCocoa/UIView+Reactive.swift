import RxCocoa
import RxSwift
import UIKit

#if canImport(RxGesture)
import RxGesture

public extension Reactive where Base: UIView {
  var click: Observable<UITapGestureRecognizer> {
    base.rx.tapGesture().when(.recognized)
  }
}

#endif
