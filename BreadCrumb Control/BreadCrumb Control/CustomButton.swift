//
//  CustomButton.swift
//  BreadCrumb-Swift
//
//  Created by Philippe K on 14/11/2015. All rights reserved.
//  Copyright © 2015
//

import Foundation
import UIKit


enum StyleButton {
    case simpleButton
    case extendButton
}


class MyCustomButton: UIButton {

    required init?(coder aDecoder: (NSCoder!)) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    @IBInspectable var styleButton: StyleButton = .extendButton {
        didSet{
            drawRect( self.frame)
        }
    }
    
    @IBInspectable var arrowColor: UIColor = UIColor.whiteColor() {
        didSet{
            drawRect( self.frame)
        }
    }
    
    @IBInspectable var backgroundCustomColor: UIColor = UIColor.grayColor() {
        didSet{
            drawRect( self.frame)
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(frame: CGRect)
    {
        if (styleButton == .extendButton) {
            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(CGPointMake(frame.maxX - 10, frame.minY))
            bezierPath.addLineToPoint(CGPointMake(frame.maxX, frame.minY + 0.50000 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.maxX - 10, frame.maxY))
            bezierPath.addLineToPoint(CGPointMake(frame.minX, frame.maxY))
            bezierPath.addLineToPoint(CGPointMake(frame.minX, frame.minY))
            bezierPath.addLineToPoint(CGPointMake(frame.maxX - 10, frame.minY))
            bezierPath.closePath()
            //UIColor.lightGrayColor().setFill()
            self.backgroundCustomColor.setFill()
            bezierPath.fill()
        } else {
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath(rect: CGRectMake(frame.minX, frame.minY, frame.maxX, frame.maxY))
            self.backgroundCustomColor.setFill()
            rectanglePath.fill()

            //// Bezier 2 Drawing
            let bezier2Path = UIBezierPath()
            //bezier2Path.moveToPoint(CGPointMake(frame.minX + 0.95000 * frame.width, frame.minY + 5))
            //bezier2Path.addLineToPoint(CGPointMake(frame.maxX-2, frame.minY + 0.50000 * frame.height))
            //bezier2Path.addLineToPoint(CGPointMake(frame.minX + 0.95000 * frame.width, frame.maxY - 5))
            bezier2Path.moveToPoint(CGPointMake(frame.maxX - 11 , frame.minY + 8))
            bezier2Path.addLineToPoint(CGPointMake(frame.maxX - 2, frame.minY + 0.50000 * frame.height))
            bezier2Path.addLineToPoint(CGPointMake(frame.maxX - 11, frame.maxY - 8))
            bezier2Path.lineCapStyle = .Round;
            
            self.arrowColor.setStroke()
            bezier2Path.lineWidth = 2
            bezier2Path.stroke()

        }
    }
}
