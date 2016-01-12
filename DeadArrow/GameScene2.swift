//
//  GameScene2.swift
//  DeadArrow
//
//  Created by Hesedel on 12/26/15.
//  Copyright (c) 2015 Pajaron Creative. All rights reserved.
//

import SpriteKit

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    // measurements
    var width:CGFloat = 0.0
    var baseUnit:CGFloat = 0.0
    
    var reusablePath = CGPathCreateMutable()
    
    // nodes
    var field = SKShapeNode()
    var wallLeft = SKShapeNode()
    var wallRight = SKShapeNode()
    var bow = Bow()
    var bowDrawingZone = SKShapeNode()
    
    // timing
    let monsterSpawnDelay = 3.0
    var monsterSpawnTimer = NSTimer()
    
    // game progress
    var fingerHasCrossedBowDrawingZone = false
    var hasGameStarted = false
    var monsterSpawnCount = 0
    var killCount = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        //myLabel.text = "Hello, World!"
        //myLabel.fontSize = 45
        //myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.width = self.view!.bounds.width
        self.baseUnit = self.width / 7
        
        self.physicsWorld.contactDelegate = self
        
        // create nodes
        self.field = SKShapeNode(rect:CGRect(origin:CGPoint(x:-(self.width / 2), y:0.0), size:CGSize(width:self.width, height:self.width)))
        self.wallLeft = SKShapeNode(rect:CGRect(origin:CGPoint(x:-((self.width / 2) + 1.0), y:self.field.position.y), size:CGSize(width:2.0, height:self.width)))
        self.wallRight = SKShapeNode(rect:CGRect(origin:CGPoint(x:((self.width / 2) - 1.0), y:self.field.position.y), size:CGSize(width:2.0, height:self.width)))
        self.bow = Bow(baseUnit:self.baseUnit)
        self.bowDrawingZone = SKShapeNode(rect:CGRect(origin:CGPoint(x:-self.bow.width_2, y:-self.bow.height), size:CGSize(width:self.bow.width, height:self.bow.height)))
        
        // set nodes' interaction
        self.bowDrawingZone.userInteractionEnabled = true
        
        // set nodes' positions
        self.field.position = CGPoint(x:CGRectGetMidX(self.frame), y:(self.width * (1 / 3)))
        self.wallLeft.position = self.field.position
        self.wallRight.position = self.field.position
        self.bow.position = self.field.position
        self.bowDrawingZone.position = self.bow.position
        
        // set nodes' styles
        self.field.fillColor = UIColor.whiteColor()
        self.field.lineWidth = 0.0
        self.wallLeft.fillColor = UIColor.blackColor()
        self.wallLeft.lineWidth = 0.0
        self.wallRight.fillColor = UIColor.blackColor()
        self.wallRight.lineWidth = 0.0
        self.bowDrawingZone.lineWidth = 0.0
        
        // set nodes' physics bodies
        self.field.physicsBody = SKPhysicsBody(polygonFromPath:self.field.path!)
        self.field.physicsBody!.affectedByGravity = false
        self.field.physicsBody!.categoryBitMask = PhysicsCategories.field.rawValue
        self.field.physicsBody!.collisionBitMask = PhysicsCategories.none.rawValue
        self.wallLeft.physicsBody = SKPhysicsBody(polygonFromPath:self.wallLeft.path!)
        self.wallLeft.physicsBody!.affectedByGravity = false
        self.wallLeft.physicsBody!.categoryBitMask = PhysicsCategories.wall.rawValue
        self.wallLeft.physicsBody!.collisionBitMask = PhysicsCategories.none.rawValue
        self.wallRight.physicsBody = SKPhysicsBody(polygonFromPath:self.wallRight.path!)
        self.wallRight.physicsBody!.affectedByGravity = false
        self.wallRight.physicsBody!.categoryBitMask = PhysicsCategories.wall.rawValue
        self.wallRight.physicsBody!.collisionBitMask = PhysicsCategories.none.rawValue
        
        // add nodes to self
        //self.addChild(myLabel)
        self.addChild(self.field)
        self.addChild(self.wallLeft)
        self.addChild(self.wallRight)
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
            
            // TODO: TEST
            self.enumerateChildNodesWithName("test", usingBlock:{
                (node, stop) in
                node.removeFromParent()
            })
            let angle = CGFloat(M_PI_2 / 12)
            let left = self.bow.zRotation + angle
            let adjusted = self.bow.zRotation + CGFloat(M_PI_2)
            let drawD = (self.bow.drawDistance + self.bow.height)
            let maxDrawD = (self.bow.maxDrawDistance + self.bow.height)
            let x = self.bow.position.x - (drawD * cos(adjusted)) - (maxDrawD * sin(left))
            let y = self.bow.position.y - (drawD * sin(adjusted)) + (maxDrawD * cos(left))
            let arrow = Arrow(path:self.bow.arrow.path!, zRotation:left, drawDistance:self.bow.drawDistance, enhancements:[0, 0, 0], parent:self, position:CGPoint(x:x ,y:y))
            arrow.addChild(SKShapeNode(circleOfRadius: 5.0))
            arrow.name = "test"
            arrow.stopMovement()
            self.addChild(arrow)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //if let touch = touches.first {
            if (self.bow.drawDistance == 0.0) {
                return
            }
        
            let position = CGPoint(x:(self.bow.position.x - (self.bow.arrow.position.y * atan(self.bow.zRotation))) , y:(self.bow.position.y + (self.bow.arrow.position.y * cos(self.bow.zRotation))))
            let arrow = Arrow(path:self.bow.arrow.path!, zRotation:self.bow.zRotation, drawDistance:self.bow.drawDistance, enhancements:[1, 0, 1], parent:self, position:position)
        
            self.addChild(arrow)
        
            self.bow.drawBow()
            
            self.bowDrawingZone.zRotation = self.bow.zRotation
            
            self.fingerHasCrossedBowDrawingZone = false
        //}
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Physics Contact Functions
    
    func didBeginContact(contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as! SKShapeNode
        let nodeB = contact.bodyB.node as! SKShapeNode
        
        if (nodeA.physicsBody!.categoryBitMask == PhysicsCategories.arrow.rawValue && nodeB.physicsBody!.categoryBitMask == PhysicsCategories.wall.rawValue) {
            self.didBeginContactBetweenArrowAndWall(nodeA, nodeB:nodeB)
            
            return
        }
        
        if (nodeA.physicsBody!.categoryBitMask == PhysicsCategories.arrow.rawValue && nodeB.physicsBody!.categoryBitMask == PhysicsCategories.monster.rawValue) {
            self.didBeginContactBetweenArrowAndMonster(nodeA, nodeB:nodeB)
            
            return
        }
        
        if (nodeA.physicsBody!.categoryBitMask == PhysicsCategories.wall.rawValue && nodeB.physicsBody!.categoryBitMask == PhysicsCategories.monster.rawValue) {
            self.didBeginContactBetweenMonsterAndWall(nodeA, nodeB:nodeB)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as! SKShapeNode
        let nodeB = contact.bodyB.node as! SKShapeNode
        
        if (nodeA.physicsBody!.categoryBitMask == PhysicsCategories.arrow.rawValue && nodeB.physicsBody!.categoryBitMask == PhysicsCategories.field.rawValue) {
            self.didEndContactBetweenArrowAndField(nodeA, nodeB:nodeB)
            
            return
        }
        
        if (nodeA.physicsBody!.categoryBitMask == PhysicsCategories.field.rawValue && nodeB.physicsBody!.categoryBitMask == PhysicsCategories.monster.rawValue) {
            self.didEndContactBetweenMonsterAndField(nodeA, nodeB:nodeB)
        }
    }
    
    // MARK: Physics Contact Functions - Begin
    
    func didBeginContactBetweenArrowAndWall(nodeA: SKShapeNode, nodeB: SKShapeNode) {
        (nodeA as! Arrow).didBeginContactWall(nodeB)
    }
    
    func didBeginContactBetweenArrowAndMonster(nodeA: SKShapeNode, nodeB: SKShapeNode) {
        let arrow = (nodeA as! Arrow)
        
        if (!arrow.didBeginContactMonster()) {
            nodeA.position = CGPoint(x:(nodeA.position.x - nodeB.position.x), y:(nodeA.position.y - nodeB.position.y))
            
            nodeB.addChild(nodeA)
        }
        
        if ((nodeB as! Monster).takeDamage()) {
            self.killCount++
        }
    }
    
    func didBeginContactBetweenMonsterAndWall(nodeA: SKShapeNode, nodeB: SKShapeNode) {
        (nodeB as! Monster).didBeginContactWall()
    }
    
    // MARK: Physics Contact Functions - End
    
    func didEndContactBetweenArrowAndField(nodeA: SKShapeNode, nodeB: SKShapeNode) {
        (nodeA as! Arrow).didEndContactField()
    }
    
    func didEndContactBetweenMonsterAndField(nodeA: SKShapeNode, nodeB: SKShapeNode) {
        self.endGame()
    }
    
    // MARK: Game Event Functions
    
    func startGame() {
        if (self.hasGameStarted) {
            return
        }
        
        self.monsterSpawnCount = 0
        self.killCount = 0
        
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
            (node as! Monster).stopMovement()
        })
        
        self.hasGameStarted = false
    }
    
    func spawnMonster(timer: NSTimer = NSTimer()) {
        var enhancements = Monster.Enhancements.none.rawValue
        
        if (self.monsterSpawnCount == 8) {
            enhancements |= Monster.Enhancements.movementSpeed.rawValue
        }
        
        if (self.monsterSpawnCount > 8) {
            let probability = 1 + round((1 / CGFloat(self.monsterSpawnCount - 8)) * 100)
            let randomNumber = arc4random_uniform(UInt32(probability))
            
            if (randomNumber == 0) {
                enhancements |= Monster.Enhancements.movementSpeed.rawValue
            }
        }
        
        if (self.monsterSpawnCount == 16) {
            enhancements |= Monster.Enhancements.sideStepping.rawValue
        }
        
        if (self.monsterSpawnCount > 16) {
            let probability = 1 + round((1 / CGFloat(self.monsterSpawnCount - 16)) * 100)
            let randomNumber = arc4random_uniform(UInt32(probability))
            
            if (randomNumber == 0) {
                enhancements |= Monster.Enhancements.sideStepping.rawValue
            }
        }
        
        if (self.monsterSpawnCount == 24) {
            enhancements |= Monster.Enhancements.sideStepping.rawValue
            enhancements |= Monster.Enhancements.sideStepping2.rawValue
        }
        
        if (self.monsterSpawnCount > 24) {
            let probability = 1 + round((1 / CGFloat(self.monsterSpawnCount - 24)) * 100)
            let randomNumber = arc4random_uniform(UInt32(probability))
            
            if (randomNumber == 0) {
                enhancements |= Monster.Enhancements.sideStepping.rawValue
                enhancements |= Monster.Enhancements.sideStepping2.rawValue
            }
        }
        
        let monster = Monster(baseUnit:self.baseUnit, randomizeRadiusAndMovementSpeed:(self.monsterSpawnCount >= 8), enhancements:enhancements)
        
        monster.name = "monster"
        
        monster.position = CGPoint(x:(monster.radius + CGFloat(arc4random_uniform(UInt32(self.width - (monster.radius * 2))))), y:(CGRectGetMaxY(self.field.frame) + monster.radius))
        
        self.addChild(monster)
        
        self.monsterSpawnCount++
        
        let spawnDelayOffset = timer.userInfo == nil ? 0.0 : timer.userInfo as! Double
        let randomNumber = Double(arc4random_uniform(UInt32(101))) / 100
        let spawnDelayRandomizer = (self.monsterSpawnDelay / 2) - (self.monsterSpawnDelay * randomNumber)
        
        self.monsterSpawnTimer = NSTimer.scheduledTimerWithTimeInterval((spawnDelayOffset + self.monsterSpawnDelay + spawnDelayRandomizer), target:self, selector:"spawnMonster:", userInfo:(spawnDelayRandomizer * -1), repeats:false)
    }
}
