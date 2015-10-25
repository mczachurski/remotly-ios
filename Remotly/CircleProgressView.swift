//
//  CircleProgressView.swift
//  Test
//
//  Created by Admin on 4/4/15.
//  Copyright (c) 2015 Sutan. All rights reserved.
//

import UIKit

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0))
}

func sizeForText(text:String, font:UIFont) -> CGSize{
    let label:UILabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, CGFloat.max))
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.size
}

@IBDesignable class CircleProgressView: UIView {
    
    internal struct Constants {
        let circleDegress = 360.0
        let minimumValue = 0.000001
        let maximumValue = 0.999999
        let ninetyDegrees = 90.0
        let twoSeventyDegrees = 270.0
        var contentView:UIView = UIView()
        var contentContainer:UIView = UIView()
        var progressLabel:UILabel = UILabel()
        var percentageLabel:UILabel = UILabel()
    }
    
    let constants = Constants()
    
    @IBInspectable var progress: Double = 0.000001 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var clockwise: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackWidth: CGFloat = 10 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackImage: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackBackgroundColor: UIColor = UIColorFromRGB(0xD8D8D8) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackFillColor: UIColor = UIColorFromRGB(0xD4AF37) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackBorderColor:UIColor = UIColor.clearColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackBorderWidth: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var centerFillColor: UIColor = UIColor.whiteColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var contentView: UIView {
        return self.constants.contentView
    }
    
    @IBInspectable var progressLabel: UILabel {
        return self.constants.progressLabel
    }
    
    @IBInspectable var percentageLabel: UILabel {
        return self.constants.percentageLabel
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeLayout()
    }
    
    func makeLayout() {
        self.backgroundColor = UIColor.clearColor()
        self.addSubview(contentView)
        progressLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(progressLabel)
        percentageLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(percentageLabel)
    }
    
    override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        let width:CGFloat = rect.size.width
        let hegith:CGFloat = rect.size.height
        let diameter:CGFloat = min(width, hegith)
        var circleRect:CGRect
        
        trackWidth = diameter > 50 ? diameter / 8 : diameter * 0.16
        
        if width != hegith {
            let space:CGFloat = (max(width, hegith) - diameter) / 2
            if width > hegith {
                circleRect = CGRectMake(space, 0, diameter, diameter)
            }
            else {
                circleRect = CGRectMake(0, space, diameter, diameter)
            }
        }
        else {
            circleRect = rect;
        }
        
        let innerRect = CGRectInset(circleRect, trackBorderWidth, trackBorderWidth)
        let percentage:Int = Int(progress * 100)
        progress = (progress/1.0) == 0.0 ? constants.minimumValue : progress
        progress = (progress/1.0) >= 1.0 ? constants.maximumValue : progress
        
        progress = clockwise ? (-constants.twoSeventyDegrees + ((1.0 - progress) * constants.circleDegress)) : (constants.ninetyDegrees - ((1.0 - progress) * constants.circleDegress))
        
        let context = UIGraphicsGetCurrentContext()
        
        // background Drawing
        trackBackgroundColor.setFill()
        let circlePath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect)))
        circlePath.fill();
        
        if trackBorderWidth > 0 {
            circlePath.lineWidth = trackBorderWidth
            trackBorderColor.setStroke()
            circlePath.stroke()
        }
        
        let progressRect: CGRect = CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect))
        let center = CGPointMake(progressRect.midX, progressRect.midY)
        let radius = progressRect.width / 2.0
        let startAngle:CGFloat = clockwise ? CGFloat(-progress * M_PI / 180.0) : CGFloat(constants.twoSeventyDegrees * M_PI / 180)
        let endAngle:CGFloat = clockwise ? CGFloat(constants.twoSeventyDegrees * M_PI / 180) : CGFloat(-progress * M_PI / 180.0)
        if percentage > 0 {
            // progress Drawing
            let progressPath = UIBezierPath()
            
            progressPath.addArcWithCenter(center, radius:radius, startAngle:startAngle, endAngle:endAngle, clockwise:!clockwise)
            progressPath.addLineToPoint(CGPointMake(progressRect.midX, progressRect.midY))
            progressPath.closePath()
            
            CGContextSaveGState(context)
            
            progressPath.addClip()
            
            if trackImage != nil {
                trackImage!.drawInRect(innerRect)
            } else {
                trackFillColor.setFill()
                circlePath.fill()
            }
            
            CGContextRestoreGState(context)
        }
        
        // center Drawing
        let centerPath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX + trackWidth, innerRect.minY + trackWidth, CGRectGetWidth(innerRect) - (2 * trackWidth), CGRectGetHeight(innerRect) - (2 * trackWidth)))
        centerFillColor.setFill()
        centerPath.fill()
        
        let layer = CAShapeLayer()
        layer.path = centerPath.CGPath
        contentView.layer.mask = layer
        
        // text
        let fontSize:CGFloat = diameter * 3 / 10
        let progressFont:UIFont = UIFont(name: "Helvetica Neue", size: fontSize)!
        let percentageFont:UIFont = UIFont(name: "Helvetica Neue", size: fontSize / 2)!
        
        progressLabel.font = progressFont
        progressLabel.textColor = trackFillColor
        progressLabel.text = String(format: "%d", percentage)
        
        if ( diameter > 50 ) {
            progressLabel.frame = circleRect
            
            percentageLabel.font = percentageFont
            percentageLabel.textColor = trackFillColor
            percentageLabel.text = "%"
            
            let progressSize:CGSize = sizeForText(progressLabel.text!, font: progressFont)
            let percentageSize:CGSize = sizeForText(percentageLabel.text!, font: percentageFont)
            
            progressLabel.frame = CGRectMake(
                center.x - progressSize.width / 2 - trackWidth / 4,
                center.y - progressSize.height / 2,
                progressSize.width,
                progressSize.height)
            percentageLabel.frame = CGRectMake(
                progressLabel.frame.origin.x + progressLabel.frame.size.width,
                progressLabel.frame.origin.y + percentageSize.height / 4,
                percentageSize.width,
                percentageSize.height)
        }
        else {
            progressLabel.frame = circleRect
            percentageLabel.text = ""
        }
    }
    
}