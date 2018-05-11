//
//  MainMenu.swift
//  FinalProject
//
//  Created by Andrew J Kulpa on 5/5/16.
//  Copyright (c) 2016 Andrew J Kulpa. All rights reserved.
//

import UIKit
import SpriteKit

//Initialize Global Variables
var MenuBackground1, MenuBackground2: SKSpriteNode!
var button, playIcon: SKSpriteNode!
var playLabel: SKLabelNode = SKLabelNode(text: "PLAY")
var title: SKLabelNode = SKLabelNode(text: "Asteroids2.0")
var musicStarted = false

class MainMenu: SKScene {
    override func didMoveToView(view: SKView) {
        initializeBackgroundMusic() //Starts the background music! :D
        initializeSceneItems() //load PlayButton(includes: button, play icon, playlabel) + Title
        animateBackground() //Set the background images of the game and setup to become animated.
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches { //For every touch on the screen
            let location = touch.locationInNode(self) //set location to that touch locaiton
            if button.containsPoint(location){ //if the playbutton is pressed..
                var gameScene = GameScene(size: self.size) //start up loading the game scene
                gameScene.scaleMode = .AspectFit //set scaling to Aspect Fit
                self.scene!.view?.presentScene(gameScene) //Show the new scene!
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        for i in [MenuBackground1, MenuBackground2]{ //Animates the background by moving left 4 pixels ea. frame
            i.position = CGPoint(x: i.position.x - 2, y: i.position.y) //Shifts the position left 2px
            if i.position.x <= -i.size.width{ //if is no longer showing in the frame
                i.position = CGPointMake(i.position.x + i.size.width * 2, i.position.y) //set it back to its starting pos
            }
        }
    }
    func initializeSceneItems(){
        button = SKSpriteNode(imageNamed: "BlueButton") //apply sprites to the SKSpriteNodes
        playIcon = SKSpriteNode(imageNamed: "PlayIcon") //^^^^^
        title.fontSize = playIcon.frame.height * 2 //since the size on screens is relative, set this to the relative size of the play icon
        playLabel.fontSize = playIcon.frame.height //Make the text just as large as the play icon -- relative size~~
        button.position = CGPoint(x:self.frame.width/2, y: self.frame.height/2) //center the button in the middle fo the frame
        title.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + button.frame.size.height/2 + 30) //title above button
        playIcon.position = CGPoint(x:self.frame.width/2 + button.size.width/4, y: self.frame.height/2) //Icon is relatively RightAligned in the button
        playLabel.position = CGPointMake(playIcon.position.x - playIcon.frame.width/2 - playLabel.frame.size.width/2 - 20, self.frame.size.height/2 - playLabel.frame.size.height/2) //the playLabel is left of the playIcon
        //Set xPositioning
        button.zPosition = 5
        playIcon.zPosition = 6
        playLabel.zPosition = 6
        //Display these
        self.addChild(title)
        self.addChild(playLabel)
        self.addChild(playIcon)
        self.addChild(button)
    }
    func animateBackground(){
        //Set the background images of the game and setup to become animated.
        MenuBackground1 = SKSpriteNode(imageNamed: "backgroundMenu")
        MenuBackground2 = SKSpriteNode(imageNamed: "backgroundMenu")
        for i in [MenuBackground1, MenuBackground2]{
            i.anchorPoint = CGPointZero
            i.position = CGPoint(x: 0, y:0) //Initialize at start of the screen
            if(i == MenuBackground2){
                i.position = CGPointMake(MenuBackground1.size.width, 0) //Initialize at start of the end of the first background image
            }
            i.zPosition = -2
            i.size = CGSize(width: frame.width, height: frame.height)
            self.addChild(i)
        }
    }
    func initializeBackgroundMusic(){
        if !musicStarted{
            musicStarted = true
            if self.actionForKey("BackgroundMusic") == nil {
                self.runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("Disco Century.wav", waitForCompletion: true)))//SKAction.sequence([SKAction.playSoundFileNamed("Disco Century.wav", waitForCompletion: true),   SKAction.playSoundFileNamed("Laser Millenium.wav", waitForCompletion: true), SKAction.runBlock({musicStarted = false})])), withKey: "BackgroundMusic") //PLAY GAME MUSIC
                    //Sound files were removed above to save space.
                    //Note: AVAudioPlayer is WAYYYYYY BETTER at this. Do not use playSoundFileNamed for anything besides minor sounds..
            }
        }
    }
}

