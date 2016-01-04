//
//  GameScene2.swift
//  DeadArrow
//
//  Created by Hesedel on 12/26/15.
//  Copyright (c) 2015 Pajaron Creative. All rights reserved.
//

import SpriteKit

class GameScene2: SKScene, SKPhysicsContactDelegate {
    var width:CGFloat = 0.0
    var baseUnit:CGFloat = 0.0
    
    enum Categories:UInt32 {
        case none = 0b000
        case field = 0b001
        case arrow = 0b010
        case monster = 0b100
        case all = 0b111
    }
    
    var reusablePath = CGPathCreateMutable()
    
    var field = SKShapeNode()
    var bow = Bow()
    var bowDrawingZone = SKShapeNode()
    var fingerHasCrossedBowDrawingZone = false
    let arrowSpeed = 1.0 / 32
    
    var hasGameStarted = false
    let monsterSpawnDelay = 3.0
    var monsterSpawnTimer = NSTimer()
    let timeUntilBodiesVanish = 3.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        //myLabel.text = "Hello, World!"
        //myLabel.fontSize = 45
        //myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.width = self.view!.bounds.width
        self.baseUnit = self.width / 7
        
        self.physicsWorld.contactDelegate = self
        
        self.field = SKShapeNode(rect:CGRect(origin:CGPoint(x:-(self.width / 2), y:0.0), size:CGSize(width:self.width, height:self.width)))
        self.bow = Bow(baseUnit:self.baseUnit)
        self.bowDrawingZone = SKShapeNode(rect:CGRect(origin:CGPoint(x:-self.bow.width_2, y:-self.bow.height), size:CGSize(width:self.bow.width, height:self.bow.height)))
        
        self.bowDrawingZone.userInteractionEnabled = true
        
        self.field.position = CGPoint(x:CGRectGetMidX(self.frame), y:(self.width * (1 / 3)))
        self.bow.position = self.field.position
        self.bowDrawingZone.position = self.bow.position
        
        self.field.fillColor = UIColor.cyanColor()
        self.field.lineWidth = 0.0
        self.bowDrawingZone.lineWidth = 0.0
        
        self.field.physicsBody = SKPhysicsBody(polygonFromPath:self.field.path!)
        self.field.physicsBody!.affectedByGravity = false
        self.field.physicsBody!.categoryBitMask = Categories.field.rawValue
        self.field.physicsBody!.collisionBitMask = Categories.none.rawValue
        
        //self.addChild(myLabel)
        self.addChild(self.field)
        self.addChild(self.bowDrawingZone)
        self.addChild(self.bow)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        //for touch in touches {
            //let location = touch.locationInNode(self)
            
            //let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            //sprite.xScale = 0.5
            //sprite.yScale = 0.5
            //sprite.position = location
            
            //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            //sprite.runAction(SKAction.repeatActionForever(action))
            
            //self.addChild(sprite)
        //}
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            if (!self.fingerHasCrossedBowDrawingZone && CGRectContainsPoint(self.bowDrawingZone.frame, location)) {
                self.fingerHasCrossedBowDrawingZone = true
            }
            
            if (!self.fingerHasCrossedBowDrawingZone) {
                return
            }
            
            let drawDistanceX = self.bow.position.x - location.x
            let drawDistanceY = self.bow.position.y - location.y
            let drawDistance = sqrt((drawDistanceX * drawDistanceX) + (drawDistanceY * drawDistanceY))
            
            if (drawDistance <= self.bow.height) {
                self.bow.drawBow()
                
                return
            }
            
            if (location.y > self.bow.position.y) {
                self.bow.zRotation = location.x >= self.bow.position.x ? CGFloat(M_PI_2) : -CGFloat(M_PI_2)
                
                self.bow.drawBow(abs(drawDistanceX))
                
                return
            }
            
            self.bow.zRotation = atan2(location.y - self.bow.position.y, location.x - self.bow.position.x) + CGFloat(M_PI_2)
            
            self.bow.drawBow(drawDistance)
            
            self.startGame()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if (self.bow.drawDistance == 0.0) {
                return
            }
            
            let arrow = SKShapeNode()
            arrow.path = self.bow.arrow.path
            arrow.position = self.bow.position
            arrow.zRotation = self.bow.zRotation
            arrow.strokeColor = UIColor.blackColor()
            arrow.physicsBody = SKPhysicsBody(edgeChainFromPath:arrow.path!)
            arrow.physicsBody!.affectedByGravity = false
            arrow.physicsBody!.categoryBitMask = Categories.arrow.rawValue
            arrow.physicsBody!.collisionBitMask = Categories.none.rawValue
            arrow.physicsBody!.contactTestBitMask = Categories.field.rawValue | Categories.monster.rawValue
            
            let rotation = arrow.zRotation + CGFloat(M_PI_2)
            let action = SKAction.moveBy(CGVector(dx:(self.bow.drawDistance * cos(rotation)), dy:(self.bow.drawDistance * sin(rotation))), duration:self.arrowSpeed)
            arrow.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(arrow)
            
            self.bow.drawBow()
            
            self.bowDrawingZone.zRotation = self.bow.zRotation
            
            self.fingerHasCrossedBowDrawingZone = false
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as! SKShapeNode
        let nodeB = contact.bodyB.node as! SKShapeNode
        
        if (nodeA.physicsBody!.categoryBitMask == Categories.arrow.rawValue && nodeB.physicsBody!.categoryBitMask == Categories.monster.rawValue) {
            nodeA.physicsBody!.categoryBitMask = Categories.none.rawValue
            nodeA.removeAllActions()
            nodeB.fillColor = UIColor.blackColor()
            nodeB.physicsBody!.categoryBitMask = Categories.none.rawValue
            nodeB.removeAllActions()
            
            NSTimer.scheduledTimerWithTimeInterval(self.timeUntilBodiesVanish, target:self, selector:"vanishBodies:", userInfo:[nodeA, nodeB], repeats:false)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as! SKShapeNode
        let nodeB = contact.bodyB.node as! SKShapeNode
        
        if (nodeA.physicsBody!.categoryBitMask == Categories.arrow.rawValue && nodeB.physicsBody!.categoryBitMask == Categories.field.rawValue) {
            nodeA.removeAllActions()
            nodeA.removeFromParent()
            
            return
        }
        
        if (nodeA.physicsBody!.categoryBitMask == Categories.field.rawValue && nodeB.physicsBody!.categoryBitMask == Categories.monster.rawValue) {
            self.endGame()
        }
    }
    
    // MARK: Game Event Functions
    
    func startGame() {
        if (self.hasGameStarted) {
            return
        }
        
        self.enumerateChildNodesWithName("monster", usingBlock:{
            (node, stop) in
            node.removeFromParent()
        })
        
        self.spawnMonster()
        
        self.hasGameStarted = true
    }
    
    func endGame() {
        self.monsterSpawnTimer.invalidate()
        
        self.enumerateChildNodesWithName("monster", usingBlock:{
            (node, stop) in
            node.removeAllActions()
        })
        
        self.hasGameStarted = false
    }
    
    func spawnMonster(timer: NSTimer = NSTimer()) {
        let monster = Monster(baseUnit:self.baseUnit)
        
        monster.name = "monster"
        
        monster.position = CGPoint(x:(monster.radius + CGFloat(arc4random_uniform(UInt32(self.width - (monster.radius * 2))))), y:(CGRectGetMaxY(self.field.frame) + monster.radius))
        
        monster.physicsBody!.categoryBitMask = Categories.monster.rawValue
        monster.physicsBody!.collisionBitMask = Categories.none.rawValue
        monster.physicsBody!.contactTestBitMask = Categories.field.rawValue
        
        self.addChild(monster)
        
        let spawnDelayOffset = timer.userInfo != nil ? timer.userInfo as! Double : 0.0
        let randomNumber = Double(arc4random_uniform(UInt32(101))) / 100
        let spawnDelayRandomizer = (self.monsterSpawnDelay / 2) - (self.monsterSpawnDelay * randomNumber)
        
        self.monsterSpawnTimer = NSTimer.scheduledTimerWithTimeInterval((spawnDelayOffset + self.monsterSpawnDelay + spawnDelayRandomizer), target:self, selector:"spawnMonster:", userInfo:(spawnDelayRandomizer * -1), repeats:false)
    }
    
    func vanishBodies(timer: NSTimer) {
        timer.userInfo![0].removeFromParent()
        timer.userInfo![1].removeFromParent()
    }
}
