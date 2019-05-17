//
//  ViewController.swift
//  PhysicTester
//
//  Created by Simon Italia on 4/28/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    //MARK: Watch - WCSessionDelegate stubs. Not required / used by this app
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    //Rate limit property to track messages sent to watch over x period
    var watchLastMessageSentAt: CFAbsoluteTime = 0
    
    //GradeientView IBOutlet property
    @IBOutlet weak var gradientView: GradientView!
    
    //View to display our cards
    @IBOutlet weak var cardContainer: UIView!
    
    var backgroundMusic: AVAudioPlayer!
    
    //Property to store all CardViews controllers
    var allCards = [CardViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Animate View background color
        view.backgroundColor = UIColor.red
        
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
                self.view.backgroundColor = UIColor.blue
        })
        
        //Run ParticleEmitter
        createParticleEffects()
        
        //Load Cards
        loadCards()
        
        //Start game's background music
        playBackgroundMusic()
        
        //MARK: Watch related
        
        //Check watch is supported on ios device (filter out unsupported iphone models, ipad etc), and activate session
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
                //None of the WC delegate methods are used in this app, but delegate is required in order to activate the session with activate()
        } else {
            print("WCSession not supported")
        }
        
    } // End viewDidLoad() method
    
    //Show Game configuration instructions inside an alert when app launches
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let instructions = """
        1. In iPhone Watch app:
        * Disable wake screen on wrist to raise
        * Select Wake for 70s"
        
        2. On Apple Watch:
        * Enable silent mode
        """

        let ac = UIAlertController(title: "Configure Game", message: instructions, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Start", style: .default))
        present(ac, animated: true)
    }
    
    //Detect and track users touch as they move / slide along screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        //Get touch location
        let location = touch.location(in: cardContainer)
        
        for card in allCards {
            
            //Detect card, via rectangle / frame
            if card.view.frame.contains(location) {
                
                //Check if forceTouch (aka 3D Touch) is available on device
//                if view.traitCollection.forceTouchCapability == .available {
//                    if touch.force == touch.maximumPossibleForce {
//                        card.front.image = UIImage(named: "cardStar")
//                        card.isCorrect = true
//                    }
//                }
                
                //Send message to watch if card is correct
                if card.isCorrect {
                    sendWatchMessage()
                }
            }
        }
    }
    
    @objc func loadCards() {
        
        //make cards tappable, as elsewhere this is set to false
        view.isUserInteractionEnabled = true
        
        //setup allCards array by removing all existing CardViewController objects, then remove the view controller containment
        for card in allCards {
            
            //1. Remove child vc from parent
            card.view.removeFromSuperview()
            
            //2. inform child view to remove itself from parent vc
            card.removeFromParent()
        }
        
        //clear the entire array
        allCards.removeAll(keepingCapacity: true)
        
        //create array of card positions
        let viewPositions = [
            
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]
        
        //load and unwrap card images
        let circleImage = UIImage(named: "cardCircle")
        let crossImage = UIImage(named: "cardCross")
        let linesImage = UIImage(named: "cardLines")
        let squareImage = UIImage(named: "cardSquare")
        let starImage = UIImage(named: "cardStar")
        
        //create array of card images, and shuffle array
        var cardImages = [circleImage, crossImage, linesImage, squareImage, starImage, circleImage, crossImage, linesImage]
        cardImages.shuffle()
        
        //loop over each cardPosition and create a new VC for each card object
        for (index, position) in viewPositions.enumerated() {
            let card = CardViewController()
            card.delegate = self
        
            //MARK: view controller containment (3 steps)
            //1. Using view controller containment, add child vc to parent
            addChild(card)
            
            //2. Add child view to main/parent view
            cardContainer.addSubview(card.view)
            
            //3. Pass in the main vc to the child vc (advises child view of its parent) 
            card.didMove(toParent: self)
            
            //Give the card a position in the view
            card.view.center = position
            
            //Give the card an image to be displayed at the position
            card.front.image = cardImages[index]
            
            //Update isCorrect property to true for star card
            if card.front.image == starImage {
                card.isCorrect = true
            }
            
            //Add card object to allAards array
            allCards.append(card)
            
        } //End for loop
        
    } //end loadCards() method
    
    //Method to take action when a user taps a card, insde the cardContainer, passed by Card Container VC
    func card(tapped: CardViewController) {
        
        //when a card is tapped, check user taps are enabled first
        guard view.isUserInteractionEnabled == true else { return }
        
        //if so, as soon as a card is tapped, disble taps on main view
        view.isUserInteractionEnabled = false
        
        //perform card animation actions (excuted by card / child vc)
        for card in allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
                
            } else {
                card.wasntTapped()
            }
        }
        
        perform(#selector(loadCards), with: nil, afterDelay: 2)
    }
    
    //Create Particle Emitters
    func createParticleEffects() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive
        
        //Create the emitter cell
        let emitterCell = CAEmitterCell()
        emitterCell.birthRate = 2
        emitterCell.lifetime = 5.0
        emitterCell.velocity = 100
        emitterCell.velocityRange = 100
        emitterCell.emissionLongitude = .pi
        emitterCell.spinRange = 5
        emitterCell.scale = 0.5
        emitterCell.scaleRange = 0.25
        emitterCell.color = UIColor(white: 1, alpha: 0.1).cgColor
        emitterCell.alphaSpeed = -0.025
        emitterCell.contents = UIImage(named: "particle")?.cgImage
        
        //Assign emitterCell to particleEmitter
        particleEmitter.emitterCells = [emitterCell]
        gradientView.layer.addSublayer(particleEmitter)
    }
    
    //Background Music manager method
    func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                backgroundMusic = audioPlayer
                backgroundMusic.numberOfLoops = -1
                backgroundMusic.play()
            }
        }
    }
    
    //Watch related methods
    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        //If less than 1/2 second has passed, exit method
        if watchLastMessageSentAt + 0.5 > currentTime {
            return
        }
        
        //Else attempt to send message
        //Check watch is reachable, and if so send a message
        if (WCSession.default.isReachable) {
            let message = ["Message": "CorrectCard"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        
        //Update rate limit (messages sent to watch over x time)
        watchLastMessageSentAt = CFAbsoluteTimeGetCurrent()

    }

}

