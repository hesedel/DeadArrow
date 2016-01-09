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
    
    // enhancements
    var ricochet = 0
    var pierce = 0
    var multiple = 0
    var multiple2 = 0
    
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
    
    func didBeginContactMonster(monster: Monster) -> Bool {
        if (monster.takeDamage()) {
            self.stopMovement()
            
            self.removeFromParent()
            
            self.position = CGPoint(x:(self.position.x - monster.position.x), y:(self.position.y - monster.position.y))
            
            monster.addChild(self)
            
            return true
        }
        
        return false
    }
    
    func didEndContactField() {
        self.stopMovement()
        
        self.removeFromParent()
    }
    
    // MARK: Movement Functions
    
    func startMovement() {
        self.updateMovement()
    }
    
    func updateMovement() {
        let action = SKAction.moveBy(CGVector(dx:self.dx, dy:self.dy), duration:self.movementSpeed)
        
        self.runAction(SKAction.repeatActionForever(action), withKey:self.movementActionKey)
    }
    
    func stopMovement() {
        self.removeActionForKey(self.movementActionKey)
    }
}
