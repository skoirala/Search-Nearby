import UIKit

class CustomButton: UIButton {

    var highlightedColor: UIColor?
    var unhighlightedColor: UIColor?

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted && highlightedColor != nil {
                highlightAnimated()
            }

            if !isHighlighted && unhighlightedColor != nil {
                unhighlightAnimated()
            }
        }
    }

    private func highlightAnimated() {
        UIView.transition(with: self,
                          duration: 0.33,
                          options: [.curveEaseIn, .transitionCrossDissolve],
                          animations: {
                            self.backgroundColor = self.highlightedColor
        })
    }

    private func unhighlightAnimated() {
        UIView.transition(with: self,
                          duration: 0.33,
                          options: [.curveEaseIn, .transitionCrossDissolve],
                          animations: {
                            self.backgroundColor = self.unhighlightedColor

        })
    }

    override var intrinsicContentSize: CGSize {
        let hPadding: CGFloat = 10.0
        var size = super.intrinsicContentSize
        size.width += hPadding * 2.0
        return size
    }
}
