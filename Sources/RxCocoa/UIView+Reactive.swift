import UIKit
import RxSwift
import RxCocoa

#if canImport(RxGesture)
import RxGesture

extension Reactive where Base: UIView {
    public var click: Observable<UITapGestureRecognizer> {
        return base.rx.tapGesture().when(.recognized)
    }
}

#endif
