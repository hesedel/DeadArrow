//
//  Monster.swift
//  DeadArrow
//
//  Created by Hesedel on 1/3/16.
//  Copyright © 2016 Pajaron Creative. All rights reserved.
//

import SpriteKit

class Monster:SKShapeNode {
    
    // measurements
    var baseUnit:CGFloat = 0.0
    var radius:CGFloat = 0.0
    
    // nodes
    var image = SKSpriteNode()
    
    // movement
    var dx:CGFloat = 0.0
    var dy:CGFloat = 0.0
    var movementSpeed = 1.0
    var movementSpeedModifier = 1.0
    let movementActionKey = "movement"
    var movementTimer = NSTimer()
    
    // ...
    var lifeMax = 0.0
    var life = 0.0
    let timeUntilBodyVanishes = 3.0
    
    enum Enhancements:UInt32 {
        case none          = 0b000
        case movementSpeed = 0b001
        case sideStepping  = 0b010
        case sideStepping2 = 0b100
        case all           = 0b111
    }
    
    var enhancements = Enhancements.none.rawValue
    
    override init() {
        super.init()
    }
    
    convenience init(baseUnit: CGFloat, randomizeRadiusAndMovementSpeed: Bool = false, enhancements: UInt32 = Enhancements.none.rawValue) {
        self.init()
        
        self.baseUnit = baseUnit
        self.radius = self.baseUnit / 3
        
        self.dy = -(self.radius * 2)
        
        if (randomizeRadiusAndMovementSpeed) {
            self.randomizeRadius()
        }
        
        self.enhancements = enhancements
        
        // create nodes
        self.path = SKShapeNode(circleOfRadius:self.radius).path
        self.image = SKSpriteNode(imageNamed:"zombie")
        self.image.size.width = self.radius * 2
        self.image.size.height = self.radius * 2
        
        // set nodes' styles
        self.fillColor = UIColor.greenColor()
        self.strokeColor = UIColor.blackColor()
        
        // set nodes' physics bodies
        self.physicsBody = SKPhysicsBody(circleOfRadius:(self.radius * (2 / 3)))
        self.physicsBody!.affectedByGravity = false
        
        // add nodes to self
        self.addChild(image)
        
        if (randomizeRadiusAndMovementSpeed) {
            self.randomizeMovementSpeed()
        }
        
        self.startMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: init Helper Functions
    
    func randomizeRadius() {
        let randomNumber = CGFloat(arc4random_uniform(UInt32(101))) / 100
        let radiusRandomizer = (self.radius / 8) - ((self.radius / 4) * randomNumber)
        
        self.radius = self.radius + radiusRandomizer
    }
    
    func randomizeMovementSpeed() {
        let randomNumber = Double(arc4random_uniform(UInt32(101))) / 100
        let speedRandomizer = (1.0 / 4) - ((1.0 / 2) * randomNumber)
        
        self.movementSpeed = self.movementSpeed + speedRandomizer
    }
    
    // MARK: Physics Contact Functions
    
    func didBeginContactWall() {
        if (Enhancements.sideStepping.rawValue & self.enhancements > Enhancements.none.rawValue) {
            self.invertHorizontalMovement()
        }
    }
    
    // MARK: Movement Functions
    
    func startMovement() {
        if (Enhancements.movementSpeed.rawValue & self.enhancements > Enhancements.none.rawValue) {
            self.movementSpeedModifier *= 2
        }
        
        if (Enhancements.sideStepping.rawValue & self.enhancements > Enhancements.none.rawValue) {
            let rotation = arc4random_uniform(UInt32(2)) == 0 ? M_PI - M_PI_4 : M_PI_4
            
            self.dx = self.dy * CGFloat(cos(rotation))
            self.dy = self.dy * CGFloat(sin(rotation))
        }
        
        if (Enhancements.sideStepping2.rawValue & self.enhancements > Enhancements.none.rawValue) {
            self.sideStepping2()
        }
        
        self.updateMovement()
    }
    
    func updateMovement() {
        let action = SKAction.moveBy(CGVector(dx:self.dx, dy:self.dy), duration:(self.movementSpeed / self.movementSpeedModifier))
        
        self.removeActionForKey(self.movementActionKey)
        self.runAction(SKAction.repeatActionForever(action), withKey:self.movementActionKey)
    }
    
    func stopMovement() {
        self.removeActionForKey(self.movementActionKey)
        
        self.movementTimer.invalidate()
    }
    
    func invertHorizontalMovement() {
        self.dx *= -1
        
        self.updateMovement()
        
        if (Enhancements.sideStepping2.rawValue & self.enhancements > Enhancements.none.rawValue) {
            self.movementTimer.invalidate()
            
            self.sideStepping2()
        }
    }
    
    func sideStepping2(timer: NSTimer = NSTimer()) {
        let randomNumber = Double(arc4random_uniform(UInt32(101))) / 100
        let randomizer = (1.0 / 2) - (1.0 * randomNumber)
        
        self.movementTimer = NSTimer.scheduledTimerWithTimeInterval((1.0 + randomizer), target:self, selector:"sideStepping2:", userInfo:true, repeats:false)
        
        if (timer.userInfo == nil) {
            return
        }
        
        self.invertHorizontalMovement()
    }
    
    // MARK: ...
    
    func takeDamage() -> Bool {
        self.die()
        
        return true
    }
    
    func die() {
        self.fillColor = UIColor.redColor()
        self.image.texture = SKTexture(imageNamed:"zombie--dead")
        
        self.stopMovement()
        
        NSTimer.scheduledTimerWithTimeInterval(self.timeUntilBodyVanishes, target:self, selector:"vanishBody:", userInfo:nil, repeats:false)
    }
    
    func vanishBody(timer: NSTimer) {
        self.removeFromParent()
    }
}
