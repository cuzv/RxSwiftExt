import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    public var knock: Observable<UITapGestureRecognizer> {
        return base.rx.tapGesture().when(.recognized)
    }
}

