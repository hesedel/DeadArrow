//
//  Bow.swift
//  DeadArrow
//
//  Created by Hesedel on 12/26/15.
//  Copyright © 2015 Pajaron Creative. All rights reserved.
//

import SpriteKit

class Bow:SKShapeNode {
    var baseUnit:CGFloat = 0.0
    var width:CGFloat = 0.0
    var width_2:CGFloat = 0.0
    var height:CGFloat = 0.0
    var maxDrawDistance:CGFloat = 0.0
    var drawDistance:CGFloat = 0.0
    var reusablePath = CGPathCreateMutable()
    var bow = SKShapeNode()
    var string = SKShapeNode()
    var arrow = SKShapeNode()
    var anchor = SKShapeNode()
    var left = SKShapeNode()
    var right = SKShapeNode()
    
    override init() {
        super.init()
    }
    
    convenience init(baseUnit:CGFloat) {
        self.init()
        
        self.baseUnit = baseUnit
        
        self.lineWidth = self.baseUnit / 16
        self.width = self.baseUnit * 2
        self.width_2 = self.baseUnit
        self.height = self.baseUnit / 3
        self.maxDrawDistance = self.width_2 - self.height
        
        self.reusablePath = CGPathCreateMutable()
        CGPathMoveToPoint(self.reusablePath, nil, 0, self.maxDrawDistance)
        CGPathAddLineToPoint(self.reusablePath, nil, 0.0, -self.height)
        self.arrow.path = self.reusablePath
        self.anchor = SKShapeNode(circleOfRadius:self.lineWidth)
        self.left = SKShapeNode(circleOfRadius:self.lineWidth)
        self.right = SKShapeNode(circleOfRadius:self.lineWidth)
        
        self.arrow.hidden = true;
        self.left.position = CGPoint(x:-self.width_2, y:-self.height)
        self.right.position = CGPoint(x:self.width_2, y:-self.height)
        
        self.bow.lineWidth = self.lineWidth
        self.bow.strokeColor = UIColor.blackColor()
        self.arrow.strokeColor = UIColor.blackColor()
        self.string.strokeColor = UIColor.blackColor()
        self.anchor.strokeColor = UIColor.blackColor()
        self.left.strokeColor = UIColor.blackColor()
        self.right.strokeColor = UIColor.blackColor()
        
        self.drawBow()
        
        self.addChild(self.string)
        self.addChild(self.bow)
        self.addChild(self.arrow)
        //self.addChild(self.anchor)
        //self.addChild(self.left)
        //self.addChild(self.right)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBow(drawDistance:CGFloat = 0.0) {
        self.drawDistance = [0.0, drawDistance - self.height].maxElement()!
        self.drawDistance = [self.maxDrawDistance, self.drawDistance].minElement()!
        let drawDistance_4 = self.drawDistance / 4
        let newWidth_2 = self.width_2 - drawDistance_4
        let newHeight = self.height + drawDistance_4
        
        self.reusablePath = CGPathCreateMutable()
        CGPathMoveToPoint(self.reusablePath, nil, -newWidth_2, -newHeight)
        CGPathAddCurveToPoint(self.reusablePath, nil, -newWidth_2, -newHeight, -newWidth_2, 0.0, 0.0, 0.0)
        CGPathAddCurveToPoint(self.reusablePath, nil, newWidth_2, 0.0, newWidth_2, -newHeight, newWidth_2, -newHeight)
        self.bow.path = self.reusablePath
        
        self.arrow.hidden = self.drawDistance == 0.0
        self.arrow.position.y = -self.drawDistance
        
        self.reusablePath = CGPathCreateMutable()
        CGPathMoveToPoint(self.reusablePath, nil, -newWidth_2, -newHeight)
        CGPathAddLineToPoint(self.reusablePath, nil, 0.0, -(self.height + self.drawDistance))
        CGPathAddLineToPoint(self.reusablePath, nil, newWidth_2, -newHeight)
        self.string.path = self.reusablePath
    }
}
