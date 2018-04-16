import UIKit

class DownloadProgressView: UIView {

    let backgroundLayer = CAShapeLayer()
    let foregroundLayer = CAShapeLayer()

    var progresss: CGFloat = 0 {
        didSet {
            foregroundLayer.strokeEnd = progresss
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        backgroundLayer.strokeColor = UIColor.darkGray.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = nil

        foregroundLayer.strokeColor = UIColor.white.cgColor
        foregroundLayer.lineWidth = 10
        foregroundLayer.fillColor = nil
        backgroundLayer.strokeEnd = 1
        foregroundLayer.strokeEnd = 0
        foregroundLayer.lineCap = kCALineCapRound

        layer.addSublayer(backgroundLayer)
        layer.addSublayer(foregroundLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        let dimension = min(bounds.width, bounds.height)

        let frame = CGRect(x: bounds.midX - dimension * 0.5,
                           y: bounds.midY - dimension * 0.5,
                           width: dimension,
                           height: dimension)
        backgroundLayer.frame = frame
        foregroundLayer.frame = frame

        let shapePath = UIBezierPath(ovalIn: backgroundLayer.bounds)
        backgroundLayer.path = shapePath.cgPath
        foregroundLayer.path = shapePath.cgPath
        foregroundLayer.setAffineTransform(CGAffineTransform(rotationAngle: -CGFloat.pi * 0.5))
    }
}
