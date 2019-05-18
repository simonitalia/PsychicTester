//
//  InterfaceController.swift
//  PhysicTester WatchKit Extension
//
//  Created by Simon Italia on 4/28/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    //
    var setAllCardsToStar = false
    
    //WCSessionDelegate stub for conformance. Not used by this app
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    //IBOutlet properties
    @IBOutlet weak var welcomeTextTitle: WKInterfaceLabel!
    @IBOutlet weak var welcomeTextBody: WKInterfaceLabel!
    @IBOutlet weak var hideTextButton: WKInterfaceButton!
    
    
    @IBOutlet weak var setCardToStarButton: WKInterfaceButton!
    @IBAction func setCardToStarButtonPressed() {
        //card.front.image = UIImage(named: "cardStar")
        
        //Attempt to send message to phone
        //Check phone is reachable, and if so send a message
        if (WCSession.default.isReachable) {
            var message: [String: String]
            
            //Flip setAllCardsToStar flag
            setAllCardsToStar = !setAllCardsToStar
            
            if setAllCardsToStar == true {
                setCardToStarButton.setTitle("⚪️")
                message = ["Message": "true"]
                WCSession.default.sendMessage(message, replyHandler: nil)
            
            } else {
                setCardToStarButton.setTitle("🔴")
                message = ["Message": "false"]
                WCSession.default.sendMessage(message, replyHandler: nil)
            }
        }
        
    }
    
    //Hide welcome texts on button press
    @IBAction func hideTextButtonPressed() {
        welcomeTextTitle.setHidden(true)
        welcomeTextBody.setHidden(true)
        hideTextButton.setHidden(true)
        
    }
    
    //Tap wrist when message is received from Phone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WKInterfaceDevice().play(.click)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
