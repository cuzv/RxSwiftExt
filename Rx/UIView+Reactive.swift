import UIKit
import RxSwift
import RxCocoa
import RxGesture

extension Reactive where Base: UIView {
    public var knock: Observable<UITapGestureRecognizer> {
        return base.rx.tapGesture().when(.recognized)
    }
}
