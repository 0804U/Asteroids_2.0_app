//
//  GameScene.swift
//  FinalProject
//
//  Created by Andrew J Kulpa on 5/4/16.
//  Copyright (c) 2016 Andrew J Kulpa. All rights reserved.
//

import SpriteKit
//import AVFoundation //Not used due to lack of time..Not as necessary but AVFoundation seems to be generally used for longer sounds (better control, etc.)

//Initalize Global Variables
var player: SKSpriteNode!
var background1, background2: SKSpriteNode!
let asteroidCategory: UInt32  = 1 << 0
let shipCategory: UInt32  = 1 << 1
let laserCategory: UInt32  = 1 << 2
var alive = true
let blueExplosionAtlas = SKTextureAtlas(named: "BlueExplosion")
var blueExplosion: [SKTexture]!
var score = 0
var highScore = 0
var scoreLabel: SKLabelNode = SKLabelNode(text:  "High Score:" + String(highScore) + "   Score:" + String(score)) //"High Score: 0   Score: 0"
var menuButton: SKNode!
//let backgroundmusic1 = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Disco Century", ofType: "wav")!)//Unused since AVFoundation/AVAudioPlayer not utilized due to lack of time

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: -1.5,dy: 0) //Moving 'right' -all dynamic obj's are pushed 'left'
        scoreLabel.zPosition = 5
        scoreLabel.position = CGPointMake(self.frame.width - scoreLabel.frame.size.width/2 - 20, self.frame.height - 60 - scoreLabel.frame.size.height/2)
        button = SKSpriteNode(imageNamed: "BackIcon")
        button.position = CGPointMake(button.frame.size.width/2 + 20, self.frame.height - 60 - button.frame.size.height/2)
        button.zPosition = 5
        self.addChild(button)
        
        //initialize scene nodes and background
        self.addChild(scoreLabel)
        initializeBlueExplosionAnimation()
        initializeBackground() //Setup background
        initializeAsteroids() //Start the spawning of asteroids
        initializePlayer() //Spawns player
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //Called when a touch begins
        for touch: AnyObject in touches { //For every touch on the screen
            let location = touch.locationInNode(self)
            if alive{
                if location.x > self.frame.width/2{ //If the touch is on the right side
                    initializeLaser() //Shoot a laser
                }
                else if location.x < self.frame.width/2{ //If the touch in on the left side
                    let moveAction = SKAction.moveTo(CGPointMake(self.frame.width*0.2, location.y), duration: 0.5)
                    player.runAction(SKAction.sequence([moveAction])) //Move ship towards location.y or rather the Y Location of the tap
                }
            }
            if button.containsPoint(location){
                var menuScene = MainMenu(size: self.size) //start up loading the game scene
                menuScene.scaleMode = .AspectFit //set scaling to Aspect Fit
                self.scene!.view?.presentScene(menuScene) //Show the new scene!
            }
        }

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for i in [background1, background2]{ //Animates the background by moving left 4 pixels ea. frame
            i.position = CGPoint(x: i.position.x - 4, y: i.position.y)//Shifts the position left 4px
            if i.position.x <= -i.size.width{ //if is no longer showing in the frame
                i.position = CGPointMake(i.position.x + i.size.width * 2, i.position.y) //set it back to its starting pos
            }
        }
        scoreLabel.text = "HighScore:" + String(highScore) + " Score:" + String(score) //Update the high score
        scoreLabel.position = CGPointMake(self.frame.width - scoreLabel.frame.size.width/2 - 20, self.frame.height - 60 - scoreLabel.frame.size.height/2) //Allow to relatively grow in space usage as it's intialized for working with 1 digit --> 2 digits--> n digits
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == shipCategory && contact.bodyB.categoryBitMask == asteroidCategory{//If the player collides with an asteroid
            contact.bodyB.velocity = CGVector(dx: 0, dy:0) //Stop moving the asteroid for a second (stopping force)
            animateExplosion(contact.bodyA.node?.position, action: SKAction.playSoundFileNamed("FailedSFX.mp3", waitForCompletion: false)) //Play 'Failed sound'
            contact.bodyA.node?.removeFromParent() //delete the player
            alive = false //ur dead m8
            if score > highScore{ //Did better than last time?
                highScore = score //new high score recorded
            }
        }
        if contact.bodyA.categoryBitMask == laserCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == laserCategory{ //If a laser collides with an asteroid
            animateExplosion(contact.bodyA.node?.position, action: SKAction.playSoundFileNamed("AcceptSFX.mp3", waitForCompletion: false)) //ExplosionSFX.mp3 was too loud :/
            contact.bodyB.node?.removeFromParent() //Delete them both
            contact.bodyA.node?.removeFromParent() //Delete them both
            score++ //Add to score! :D -- Not perfect, but random number of collisions done is kind of fun -- I promise this is a 'feature'
        }
    }
    override func willMoveFromView(view: SKView) {
        self.removeAllActions() //DOESNT SEEM TO WORK (correction: doesn't work with playSoundFileNamed -- use AVAudioPlayer to fix this)
        self.removeAllChildren() //deconstruct scene
    }
    
    
    
    
    //INITIALIZATION/ANIMATION FUNCTIONS BELOW THIS POINT
    func animateExplosion(explosionPosition: CGPoint!, action: SKAction){
        var explosion = SKSpriteNode(texture: blueExplosion[0])
        if let contactPosition = explosionPosition { //Unwrap position and set position to contactPosition
            explosion.position = contactPosition
        }
        explosion.size = CGSize(width: 100, height: 100) //Set explosion size
        self.addChild(explosion)
        explosion.runAction(SKAction.sequence([SKAction.group([SKAction.animateWithTextures(blueExplosion, timePerFrame: 0.1), action]), SKAction.removeFromParent()])) //run an action to animate each frame starting from blueExplosion1 --> blueExplosion12
    }
    func initializeLaser(){
        let laserArray = ["Beam1", "Beam2","Beam3","Beam4","Beam5","Beam6"] //make array with image names for lasers
        var indexInArray = Int(arc4random_uniform(UInt32(6)))//Int(arc4random())%6 doesnt work on devices before iPhone 6
        let randomLaser = laserArray[indexInArray] //set randomLaser to decided random name of laser within laserArray
        let laser = SKSpriteNode(imageNamed: randomLaser) //create the actual SKSpriteNode from imageNamed: laserImageNameRandomlyChosen
        laser.name = randomLaser
        
        //Prettier and longer means of setting the position of the laser
        var ySpawnLocation: CGFloat = player.position.y
        var xSpawnLocation: CGFloat = player.size.width/2 + self.frame.width * 0.2
        laser.position = CGPoint(x: xSpawnLocation, y: ySpawnLocation)
        
        //Setup physics body information, velocity, etc.
        laser.physicsBody = SKPhysicsBody(texture: laser.texture, size: laser.size)
        laser.zRotation = CGFloat(M_PI_2)
        laser.physicsBody?.categoryBitMask = laserCategory
        laser.physicsBody?.collisionBitMask = asteroidCategory
        laser.physicsBody?.contactTestBitMask = asteroidCategory
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.velocity = CGVector(dx: 500, dy: 0)
        
        //spawn laser and play sound file
        self.addChild(laser)
        self.runAction(SKAction.playSoundFileNamed("LaserSFX.wav", waitForCompletion: false))
    }
    //Very very similar to initialize lasers, except asteroids are spawned continuously, forever.
    func initializeAsteroids(){
        let wait = SKAction.waitForDuration(1, withRange: 1.5)
        let spawnAsteroids = SKAction.runBlock {
            let asteroidArray = ["Asteroid XS", "Asteroid S", "Asteroid M", "Asteroid L"]
            var indexInArray = Int(arc4random_uniform(UInt32(4))) //Int(arc4random())%4
            //Int(arc4random_uniform(UInt32(items.count)))
            let randomAsteroid = asteroidArray[indexInArray] //was Int(rand()) //Use this apparently since its more random..?
            let asteroid = SKSpriteNode(imageNamed: randomAsteroid)
            //asteroid.name = randomAsteroid
            //Setup spawn locations for Asteroids 'randomly'
            var ySpawnLocation: CGFloat = self.frame.height * CGFloat(CGFloat(arc4random()) / CGFloat(UINT32_MAX))
            if ySpawnLocation + asteroid.size.height/2 > self.frame.height{
                ySpawnLocation -= asteroid.size.height/2
            }
            else if ySpawnLocation - asteroid.size.height/2 < 0 {
                ySpawnLocation += asteroid.size.height/2
            }
            asteroid.position = CGPoint(x: self.frame.width*1.2, y: ySpawnLocation ) //Set position to right side of the screen, somewhere between the top and the bottom of the frame
            asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture, size: asteroid.size)//rectangleOfSize: asteroid.size)
            asteroid.physicsBody?.categoryBitMask = asteroidCategory
            asteroid.physicsBody?.collisionBitMask = asteroidCategory | shipCategory
            asteroid.physicsBody?.contactTestBitMask = shipCategory | laserCategory
            self.addChild(asteroid)
        }
        let spawnSequence = SKAction.sequence([wait, spawnAsteroids])
        self.runAction(SKAction.repeatActionForever(spawnSequence))
    }
    
    func initializePlayer(){
        alive = true
        score = 0
        player = SKSpriteNode(imageNamed: "playerSprite")
        //self.removeActionForKey("BackgroundMusic") //How to turn off music
        player.position = CGPointMake(self.frame.width*0.2, self.frame.width/2)
        player.size = CGSize(width: 79.6, height: 60)
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size)
        player.physicsBody?.dynamic = false
        //Set collisions, etc..
        player.physicsBody?.collisionBitMask = asteroidCategory
        player.physicsBody?.categoryBitMask = shipCategory
        player.physicsBody?.contactTestBitMask = asteroidCategory
        self.addChild(player)
    }
    
    func initializeBackground(){
        //Set the background images of the game and setup to become animated.
        background1 = SKSpriteNode(imageNamed: "backgroundGame")
        background2 = SKSpriteNode(imageNamed: "backgroundGame")
        for i in [background1, background2]{
            i.anchorPoint = CGPointZero
            i.position = CGPoint(x: 0, y:0) //Initialize at start of the screen
            if(i == background2){
                i.position = CGPointMake(background1.size.width, 0) //Initialize at start of the end of the first background image
            }
            i.zPosition = -2
            i.size = CGSize(width: frame.width, height: frame.height)
            self.addChild(i)
        }
    }
    //Initialize from the BlueExplosionAtlas all necessary frames for the blueExplosion SKTexture array initialized globally
    func initializeBlueExplosionAnimation(){
        var explosionFrames = [SKTexture]()
        var tempExplosionFrames = [SKTexture]()
        for var i = 1; i <= blueExplosionAtlas.textureNames.count; i++ {
            let textureName = "BlueExplosion\(i).png"
            tempExplosionFrames.append(blueExplosionAtlas.textureNamed(textureName))
        }
        blueExplosion = tempExplosionFrames
    }
}
