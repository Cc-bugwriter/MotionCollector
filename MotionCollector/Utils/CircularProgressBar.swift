// Copyright © 2019 Brad Howes. All rights reserved.

import UIKit

private extension CGRect {
    var center: CGPoint { CGPoint(x: self.midX, y: self.midY) }
}
/**
 Bare minimum CoreGraphics representation of a circular progress bar. The start/end part of the cirle is "north".
 Progress is represented between 0.0 and 1.0, and changes to it are through the `setProgress` method.
 */
public final class CircularProgressBar: UIView {

    /// The color of the progress bar
    public var progressTintColor: UIColor? = .orange

    /// The color of the 'channel' or untinted area, or the remaining part of the circle that is not covered by the
    /// `progressTintColor`
    public var progressChannelColor: UIColor? = UIColor.lightGray.withAlphaComponent(0.5)

    /// The width of the line used to draw the circle
    public var progressLineWidth: CGFloat = 5.0

    /// The layer that shows the progress amount
    private let foregroundLayer = CAShapeLayer()

    /// The layer that shows the remaining amount
    private let backgroundLayer = CAShapeLayer()

    /// The radius of the paths based on the available height/width of the view's frame
    private var radius: CGFloat { return (self.bounds.width - progressLineWidth) / 2.0 }

    /// Obtain a new UIBezierPath which will render as a circle.
    private var path: CGPath { UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath }

    private func wedge(_ progress: Float) {
        let path = UIBezierPath()
        path.move(to: bounds.center)
        path.addArc(withCenter: bounds.center, radius: radius, startAngle: 0.0,
                    endAngle: CGFloat(progress * 2.0 * .pi), clockwise: true)
        path.addLine(to: bounds.center)
        path.close()
        foregroundLayer.path = path.cgPath
    }

    /**
     Set up the view after being restored from an IB definition.
     */
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    /**
     Set the new progress value for the indicator.

     - parameter progress: the new value between 0.0 and 1.0
     - parameter animated: if true, animate the drawing state changes
     */
    public func setProgress(_ progress: Float, animated: Bool) {
        wedge(progress)
    }

    private func makeBackgroundLayer(){
        backgroundLayer.path = path
        backgroundLayer.lineWidth = progressLineWidth
        backgroundLayer.strokeColor = progressChannelColor?.cgColor
        backgroundLayer.strokeEnd = 1.0
        backgroundLayer.fillColor = nil
        layer.addSublayer(backgroundLayer)
    }

    private func makeForegroundLayer(){
        foregroundLayer.path = nil
        foregroundLayer.lineWidth = 1.0
        foregroundLayer.strokeColor = progressTintColor?.cgColor
        foregroundLayer.strokeEnd = 0.0
        foregroundLayer.fillColor = foregroundLayer.strokeColor
        self.layer.addSublayer(foregroundLayer)
    }

    private func setupView() {
        if self.layer.sublayers?.isEmpty ?? true {
            makeBackgroundLayer()
            makeForegroundLayer()
        }
    }

    override public func layoutSublayers(of layer: CALayer) {
        setupView()
    }
}
