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
    
    //WCSessionDelegate stub for conformance. Not used by this app
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    //IBOutlet properties
    @IBOutlet weak var welcomeTextTitle: WKInterfaceLabel!
    @IBOutlet weak var welcomeTextBody: WKInterfaceLabel!
    @IBOutlet weak var hideTextButton: WKInterfaceButton!
    
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
