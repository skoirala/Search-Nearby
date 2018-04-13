import UIKit

internal class ProgressView: UIView {

    private let shapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    private let lineWidth: CGFloat = 10

    private func createViews() {
        layer.addSublayer(shapeLayer)

        let startColor = UIColor.black
        let endColor = startColor.withAlphaComponent(0.1)

        gradientLayer.colors = [startColor.cgColor,
                                endColor.cgColor]
        gradientLayer.locations = [0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5,
                                           y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5,
                                         y: 1)

        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = lineWidth
        shapeLayer.mask = gradientLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        shapeLayer.frame = bounds

        let arcCenter = CGPoint(x: bounds.midX,
                                   y: bounds.midY)
        let radius = (bounds.width - lineWidth) * 0.5
        let startAngle = 0.35 * CGFloat.pi
        let endAngle = 0.65 * CGFloat.pi

        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false)
        shapeLayer.path = path.cgPath
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        createViews()
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationDidBecomeActive,
                                                  object: nil)
    }

    @objc func applicationDidBecomeActive() {
        animate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func animate() {
        shapeLayer.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        animation.repeatCount = Float(Int.max)
        animation.duration = 1.0
        shapeLayer.add(animation, forKey: nil)
    }
}
