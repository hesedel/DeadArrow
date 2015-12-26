//
//  GameScene2.swift
//  DeadArrow
//
//  Created by Hesedel on 12/26/15.
//  Copyright (c) 2015 Pajaron Creative. All rights reserved.
//

import SpriteKit

class GameScene2: SKScene {
    //let bowAnchor = SKShapeNode(circleOfRadius:10.0)
    //let bow = SKShapeNode()
    var bow = Bow()
    let finger1 = SKShapeNode(circleOfRadius:10.0)
    let line = SKShapeNode()
    var baseUnit:CGFloat = 0.0
    var reusablePath = CGPathCreateMutable()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        //myLabel.text = "Hello, World!"
        //myLabel.fontSize = 45
        //myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.baseUnit = CGRectGetMaxX(self.frame) / 12
        self.bow = Bow(baseUnit: self.baseUnit)
        self.bow.position = CGPoint(x:CGRectGetMidX(self.frame), y:(CGRectGetMidY(self.frame) / 2))
        self.finger1.position = CGPoint(x:self.bow.position.x, y:(self.bow.position.y - self.bow.height))
        self.finger1.fillColor = UIColor.blueColor()
        self.finger1.strokeColor = UIColor.blackColor()
        self.line.strokeColor = UIColor.blackColor()
        
        //self.addChild(myLabel)
        self.addChild(self.bow)
        self.addChild(self.line)
        self.addChild(self.finger1)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            //let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            //sprite.xScale = 0.5
            //sprite.yScale = 0.5
            //sprite.position = location
            self.finger1.position = location
            self.reusablePath = CGPathCreateMutable()
            CGPathMoveToPoint(self.reusablePath, nil, self.bow.position.x, self.bow.position.y)
            CGPathAddLineToPoint(self.reusablePath, nil, location.x, location.y)
            self.line.path = self.reusablePath
            
            self.updateBow()
            
            //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            //sprite.runAction(SKAction.repeatActionForever(action))
            
            //self.addChild(sprite)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            self.finger1.position = location
            self.reusablePath = CGPathCreateMutable()
            CGPathMoveToPoint(self.reusablePath, nil, self.bow.position.x, self.bow.position.y)
            CGPathAddLineToPoint(self.reusablePath, nil, location.x, location.y)
            self.line.path = self.reusablePath
            
            self.updateBow()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func updateBow() {
        let distanceX = self.bow.position.x - self.finger1.position.x
        let distanceY = self.bow.position.y - self.finger1.position.y
        let drawDistance = sqrt((distanceX * distanceX) + (distanceY * distanceY))
        
        self.bow.zRotation = atan2(self.finger1.position.y - self.bow.position.y, self.finger1.position.x - self.bow.position.x) + CGFloat(M_PI_2)
        self.bow.drawBow(drawDistance)
    }
}
