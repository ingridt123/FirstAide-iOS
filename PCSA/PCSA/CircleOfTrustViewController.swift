//
//  CircleOfTrustViewController.swift
//  PCSA
//
//  Created by Chamika Weerasinghe on 6/8/16.
//  Copyright © 2016 Peacecorps. All rights reserved.
//

import UIKit
import Contacts

class CircleOfTrustViewController: MainViewController {
    
    // MARK: Properties
    @IBOutlet weak var buttonHelpMe: UIButton!
    
    @IBOutlet weak var constraintNorthHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintSouthHeight: NSLayoutConstraint!
    @IBOutlet weak var imageTrustee1: UIImageView!
    @IBOutlet weak var imageTrustee2: UIImageView!
    @IBOutlet weak var imageTrustee3: UIImageView!
    @IBOutlet weak var imageTrustee4: UIImageView!
    @IBOutlet weak var imageTrustee5: UIImageView!
    @IBOutlet weak var imageTrustee6: UIImageView!
    
    var phoneNumbers = [String]()
    var imageViews = [UIImageView]()
    let messageComposer = MessageComposer()
    
    //MARK: Actions
    @IBAction func helpMe(_ sender: AnyObject) {
        var recipients = [String]()
        
        for number in phoneNumbers {
            if(number.characters.count > 0){
                recipients.append(number)
            }
        }
        
        if(recipients.count > 0){
            if (messageComposer.canSendText()) {
                //ask for user to message type
                let actions = [
                    UIAlertAction(title: "Come get me", style: UIAlertActionStyle.default, handler: { (action) in
                        self.presentMessageSend(recipients, body: "Come and get me. I need help getting home Safely. Call ASAP to get my Location.Sent through First Aide's Circle of Trust.")
                    }),
                    UIAlertAction(title: "Call I need an interruption", style: UIAlertActionStyle.default, handler: { (action) in
                        self.presentMessageSend(recipients, body: "Call and pretend you need me. I need an interruption. Message sent through First Aide's Circle of Trust.")
                    }),
                    UIAlertAction(title: "I need to talk", style: UIAlertActionStyle.default, handler: { (action) in
                        self.presentMessageSend(recipients, body: "I need to talk. Message sent through First Aide's Circle of Trust.")
                    }),
                    UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil),
                    ]
                UIUtil.showAlert(self, title: "Select a request", message: "", actions: actions)
                
                
                
                
            } else {
                // Let the user know if his/her device isn't able to send text messages
                UIUtil.showAlert(self, title: "Send Message", message: "Your device cannot send messages", actions: nil)
            }
            
        }
        else{
            UIUtil.showAlert(self, title: "Numbers", message: "No numbers set. Tap Edit to add/edit numbers", actions: nil)
        }
    }
    
    @IBAction func unwindToNumberSave(_ sender:UIStoryboardSegue){
        if let sourceViewController = sender.source as? CircleOfTrustEditViewController{
            //Since numbers update only when save button in CircleOfTrustEditViewController is pressed
            phoneNumbers = sourceViewController.numbers
            updateImageViews(phoneNumbers)
        }
        
    }
    
    func presentMessageSend(_ recipients:[String],body:String){
        // Obtain a configured MFMessageComposeViewController
        let messageComposeVC = messageComposer.configuredMessageComposeViewController(recipients, textBody: body)
        present(messageComposeVC, animated: true, completion: nil)
    }
    
    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUtil.initViewControllerViews(self)
        
        //reposition buttons 1,2,5,6 (buttons which are not in center Y)
        let radius = imageTrustee4.frame.origin.x - buttonHelpMe.frame.origin.x
        let height = radius * sin(NumberUtil.degToRad(60))/UIScreen.main.scale
        
        constraintNorthHeight.constant = height
        constraintSouthHeight.constant = height
        
        imageViews += [imageTrustee1,imageTrustee2,imageTrustee3,imageTrustee4,imageTrustee5,imageTrustee6]
        
        if let savedNumbers = loadNumbers() {
            phoneNumbers += savedNumbers
        }else{
            for _ in 0...5{
                phoneNumbers.append("")
            }
        }
        
        for imageView in imageViews{
            imageView.layer.borderWidth = 1.0
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            imageView.clipsToBounds = true
        }
        
        updateImageViews(phoneNumbers)
    }
    
     /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: Data
    func loadNumbers() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: CircleOfTrustEditViewController.ArchiveURL.path) as? [String]
    }
    
    func updateImageViews(_ numbers:[String]){
        loadContactPhotos(numbers)
    }
    
    func loadContactPhotos(_ numbers:[String]){
        var images=[Data]()
        let contactStroe = CNContactStore()
        let keysToFetch = [
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey]
        contactStroe.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
            if granted {
                
                DispatchQueue.global().async {
                    
                    //retrieve images in background
                    let predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactStroe.defaultContainerIdentifier())
                    var contacts: [CNContact]! = []
                    do {
                        contacts = try contactStroe.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])// [CNContact]
                    }catch {
                        
                    }
                    for contact in contacts {
                        var phoneStr = ""
                        var number: CNPhoneNumber!
                        if contact.phoneNumbers.count > 0 {
                            number = contact.phoneNumbers[0].value 
                            phoneStr = number.stringValue
                            for i in 0..<numbers.count{
                                if(numbers[i] == phoneStr && contact.imageDataAvailable){
                                    images.append(contact.thumbnailImageData!)
                                }
                            }
                        }
                    }
                    NSLog("images.count \(images.count)")
                    
                    
                    
                    
                    
                    DispatchQueue.main.async {
                        // update UI main thread
                        
                        if(images.count > 0 ){
                            for i in 0..<images.count{
                                let image = UIImage(data:images[i],scale:1.0)
                                let imageView = self.imageViews[i]
                                imageView.image = image
                                imageView.setNeedsDisplay()
                            }
                        }
                        //reset other images
                        if(images.count < self.phoneNumbers.count){
                            for i in images.count..<self.phoneNumbers.count {
                                let imageView = self.imageViews[i]
                                imageView.image = UIImage(named: "TrusteeDefault")
                                imageView.setNeedsDisplay()
                            }
                        }
                        
                    }
                }
            }
        })
    }
}
