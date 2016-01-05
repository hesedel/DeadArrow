//
//  Monster.swift
//  DeadArrow
//
//  Created by Hesedel on 1/3/16.
//  Copyright © 2016 Pajaron Creative. All rights reserved.
//

import SpriteKit

class Monster:SKShapeNode {
    var baseUnit:CGFloat = 0.0
    var radius:CGFloat = 0.0
    
    var movementSpeed = 1.0
    var lifeMax = 0.0
    var life = 0.0
    
    enum Enhancements:UInt32 {
        case none = 0b00
        case movementSpeed = 0b01
        case sideStepping = 0b10
        case all = 0b11
    }
    
    var enhancements = Enhancements.none.rawValue
    
    override init() {
        super.init()
    }
    
    convenience init(baseUnit: CGFloat, randomizeRadiusAndMovementSpeed: Bool = false, enhancements: UInt32 = Enhancements.none.rawValue) {
        self.init()
        
        self.baseUnit = baseUnit
        self.radius = self.baseUnit / 3
        
        if (randomizeRadiusAndMovementSpeed) {
            self.randomizeRadius()
        }
        
        self.enhancements = enhancements
        
        self.path = SKShapeNode(circleOfRadius:self.radius).path
        
        self.fillColor = UIColor.redColor()
        self.strokeColor = UIColor.blackColor()
        
        self.physicsBody = SKPhysicsBody(circleOfRadius:(self.radius * (2 / 3)))
        self.physicsBody!.affectedByGravity = false
        
        if (randomizeRadiusAndMovementSpeed) {
            self.randomizeMovementSpeed()
        }
        
        self.addMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func addMovement() {
        let action = SKAction.moveBy(CGVector(dx:0.0, dy:-(self.radius * 2)), duration:(Enhancements.movementSpeed.rawValue & self.enhancements == Enhancements.none.rawValue ? self.movementSpeed : self.movementSpeed / 2))
        
        self.runAction(SKAction.repeatActionForever(action))
    }
}
