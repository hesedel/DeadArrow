//
//  Arrow.swift
//  DeadArrow
//
//  Created by Hesedel on 1/8/16.
//  Copyright © 2016 Pajaron Creative. All rights reserved.
//

import SpriteKit

class Arrow:SKShapeNode {
    
    // movement
    var dx:CGFloat = 0.0
    var dy:CGFloat = 0.0
    let movementSpeed = 1.0 / 32
    let movementActionKey = "movement"
    var movementTimer = NSTimer()
    
    // ...
    let timeUntilArrowVanishes = 3.0
    var terminationTimer = NSTimer()
    
    // enhancements
    class Enhancements {
        var ricochet = 2
        var pierce = 0
        var multiple = 0
        var multiple2 = 0
    }
    var enhancements = Enhancements()
    
    // ...
    var wallPrevious = SKShapeNode()
    
    override init() {
        super.init()
    }
    
    convenience init(path: CGPath, zRotation: CGFloat, drawDistance: CGFloat) {
        self.init()
        
        self.path = path
        
        self.zRotation = zRotation
        
        self.strokeColor = UIColor.blackColor()
        
        self.physicsBody = SKPhysicsBody(edgeChainFromPath:self.path!)
        
        let rotation = self.zRotation + CGFloat(M_PI_2)
        self.dx = drawDistance * cos(rotation)
        self.dy = drawDistance * sin(rotation)
        
        self.startMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Physics Contact Functions
    
    func didBeginContactWall(wall: SKShapeNode) {
        if (self.enhancements.ricochet == 0 || wall == self.wallPrevious) {
            return
        }
        
        self.terminationTimer.invalidate()
        
        self.invertHorizontalMovement()
            
        self.enhancements.ricochet--
        self.wallPrevious = wall
    }
    
    func didBeginContactMonster() -> Bool {
        if (self.enhancements.pierce > 0) {
            self.enhancements.pierce--
            
            return true
        }
        
        return false
    }
    
    func didEndContactField() {
        self.terminationTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeUntilArrowVanishes, target:self, selector:"terminate", userInfo:nil, repeats:false)
    }
    
    // MARK: Movement Functions
    
    func startMovement() {
        self.updateMovement()
    }
    
    func updateMovement() {
        let actionRotation = SKAction.rotateToAngle(self.zRotation, duration:0.0)
        let action = SKAction.moveBy(CGVector(dx:self.dx, dy:self.dy), duration:self.movementSpeed)
        
        self.runAction(actionRotation)
        self.removeActionForKey(self.movementActionKey)
        self.runAction(SKAction.repeatActionForever(action), withKey:self.movementActionKey)
    }
    
    func stopMovement() {
        self.removeActionForKey(self.movementActionKey)
    }
    
    func invertHorizontalMovement() {
        self.dx *= -1
        self.zRotation *= -1
        
        self.updateMovement()
    }
    
    // MARK: ...
    
    func terminate() {
        self.stopMovement()
        
        self.removeFromParent()
    }
}
