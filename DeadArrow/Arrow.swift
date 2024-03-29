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
        var ricochet = 0
        var pierce = 0
        var multiple = 0
    }
    var enhancements = Enhancements()
    
    // ...
    var wallPrevious = SKShapeNode()
    
    override init() {
        super.init()
    }
    
    convenience init(path: CGPath, zRotation: CGFloat, drawDistance: CGFloat, enhancements: [Int] = [0, 0, 0], parent: SKScene, position: CGPoint) {
        self.init()
        
        self.enhancements.ricochet = enhancements[0]
        self.enhancements.pierce = enhancements[1]
        self.enhancements.multiple = enhancements[2]
        
        self.path = path
        
        self.position = position
        
        self.zRotation = zRotation
        
        self.strokeColor = UIColor.blackColor()
        
        self.physicsBody = SKPhysicsBody(edgeChainFromPath:self.path!)
        self.physicsBody!.categoryBitMask = PhysicsCategories.arrow.rawValue
        self.physicsBody!.collisionBitMask = PhysicsCategories.none.rawValue
        self.physicsBody!.contactTestBitMask = PhysicsCategories.field.rawValue | PhysicsCategories.wall.rawValue | PhysicsCategories.monster.rawValue
        
        let rotation = self.zRotation + CGFloat(M_PI_2)
        
        self.dx = drawDistance * cos(rotation)
        self.dy = drawDistance * sin(rotation)
        
        self.startMovement()
        
        let height = CGPathGetBoundingBox(self.path).height
        
        for index in 0..<self.enhancements.multiple {
            let angle = CGFloat(M_PI_2 / 32) * CGFloat(index + 1)
            let rotationLeft = self.zRotation + angle
            let rotationRight = self.zRotation - angle
            var x:CGFloat = 0.0
            var y:CGFloat = 0.0
            
            x = self.position.x - (height * cos(rotation)) - (height * sin(rotationLeft))
            y = self.position.y - (height * sin(rotation)) + (height * cos(rotationLeft))
            
            let arrowLeft = Arrow(path:self.path!, zRotation:rotationLeft, drawDistance:drawDistance, enhancements:[self.enhancements.ricochet, self.enhancements.pierce, 0], parent:parent, position:CGPoint(x:x, y:y))
            
            x = self.position.x - (height * cos(rotation)) - (height * sin(rotationRight))
            y = self.position.y - (height * sin(rotation)) + (height * cos(rotationRight))
            
            let arrowRight = Arrow(path:self.path!, zRotation:rotationRight, drawDistance:drawDistance, enhancements:[self.enhancements.ricochet, self.enhancements.pierce, 0], parent:parent, position:CGPoint(x:x, y:y))
            
            parent.addChild(arrowLeft)
            parent.addChild(arrowRight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Physics Contact Functions
    
    func didBeginContactWall(wall: SKShapeNode) {
        if self.enhancements.ricochet == 0 || wall == self.wallPrevious {
            return
        }
        
        self.terminationTimer.invalidate()
        
        self.invertHorizontalMovement()
            
        self.enhancements.ricochet -= 1
        self.wallPrevious = wall
    }
    
    func didBeginContactMonster() -> Bool {
        if self.enhancements.pierce > 0 {
            self.enhancements.pierce -= 1
            
            return true
        }
        
        self.physicsBody!.categoryBitMask = PhysicsCategories.none.rawValue
        
        self.terminate()
        
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
