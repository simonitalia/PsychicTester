//
//  CardViewController.swift
//  PhysicTester
//
//  Created by Simon Italia on 4/28/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    weak var delegate: ViewController!
    var front: UIImageView!
    var back: UIImageView!
    
    var isCorrect = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set view size
        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        
        //Add card front and back images
        front = UIImageView(image: UIImage(named: "cardBack"))
        back = UIImageView(image: UIImage(named: "cardBack"))
        
        view.addSubview(front)
        view.addSubview(back)
            //note! UIimageView size auto sets to the size of image
        
        //Set cardFront imageView to hidden by default
        front.isHidden = true

        //Hide cardBack imageView initially, then transition to shown
        back.alpha = 0
        
        UIView.animate(withDuration: 2.0) {
            self.back.alpha = 1
        }
        
        //Recognise uers taps on each card, but pass control of the tap to the mina VC
        let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(tappedCard))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(tapOnCard)
        
        //Call wiggleCards method
        perform(#selector(wiggleCards), with: nil, afterDelay: 1)
        
    } //End go viewDidLoad()
    
    //Method to pass message that user tapped a card to the main VC to handle
    @objc func tappedCard() {
        delegate.card(tapped: self)
        
    }
    
    func wasTapped() {
        UIView.transition(with: view, duration: 0.7, options: [.transitionFlipFromRight], animations: { [unowned self] in
                self.back.isHidden = true
                self.front.isHidden = false
        })
        
    }
    
    @objc func wasntTapped() {
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0
        }
    }
    
    //Animate a random card slighltly, run indefinitely, at random intervals
    @objc func wiggleCards() {
        if Int.random(in: 0...3) == 1 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
                    self.back.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            }) { _ in
                self.back.transform = CGAffineTransform.identity
            }
            
            perform(#selector(wiggleCards), with: nil, afterDelay: 8)
        
        } else {
            perform(#selector(wiggleCards), with: nil, afterDelay: 2)
        }
    }
}
