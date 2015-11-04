//
//  ViewController.swift
//  Autolayout
//
//  Created by Alexey Tsymlov on 8/5/15.
//  Copyright (c) 2015 Alexey Tsymlov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lastLoginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    var loggedInUser: User?  { didSet { updateUI() } }
    var secure = false { didSet{ updateUI() } }
    
    private func updateUI(){
        passwordField.secureTextEntry = secure
        let password = NSLocalizedString("Password", comment: "Promt for the user's password when it is not secure (i.e. plain text)")
        let securedPassword = NSLocalizedString("Secured Password", comment: "")
        passwordLabel.text = secure ? securedPassword : password
        nameLabel.text = loggedInUser?.name
        nameLabel.text = loggedInUser?.company
        image = loggedInUser?.image
        if let lastLogin = loggedInUser?.lastLogin {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let time = dateFormatter.stringFromDate(lastLogin)
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            let daysAgo = numberFormatter.stringFromNumber(-lastLogin.timeIntervalSinceNow/(60*60*24))!
            
            let lastLoginFormatString = NSLocalizedString("Last Login %@ days ago at %@", comment: "Bla bla bla")
            lastLoginLabel?.text = String.localizedStringWithFormat(lastLoginFormatString, daysAgo, time)
        }else{
            lastLoginLabel?.text = ""
        }
    }
    
    @IBAction func toggleSecurity() {
        secure = !secure
    }
    
    private struct AlertStrings {
        struct LoginError {
            static let Title = NSLocalizedString("Login Error", comment: "")
            static let Message = NSLocalizedString("Invalid user name or password", comment: "")
            static let DismissButton = NSLocalizedString("Try Again", comment: "")
        }
    }
    
    @IBAction func login() {
        loggedInUser = User.login(loginField.text ?? "", password: passwordField.text ?? "")
        if loggedInUser == nil {
            let alert = UIAlertController(title: AlertStrings.LoginError.Title, message: AlertStrings.LoginError.Message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: AlertStrings.LoginError.DismissButton, style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    var image: UIImage? {
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            if let constrainedView = imageView{
                if let newImage = newValue{
                    aspectRationConstraint = NSLayoutConstraint(item: constrainedView, attribute: .Width, relatedBy: .Equal, toItem: constrainedView, attribute: .Height, multiplier: newImage.aspectRatio, constant: 0)
                }else{
                    aspectRationConstraint = nil
                }
            }
        }
    }
    
    var aspectRationConstraint: NSLayoutConstraint?{
        willSet{
            if let existingConstraint = aspectRationConstraint{
                view.removeConstraint(existingConstraint)
            }
        }
        didSet{
            if let newConstraint = aspectRationConstraint{
                view.addConstraint(newConstraint)
            }
        }
    }
}

extension User {
    var image: UIImage? {
        if let image = UIImage(named: login){
            return image
        }else{
            return UIImage(named: "unknown_user")
        }
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}

