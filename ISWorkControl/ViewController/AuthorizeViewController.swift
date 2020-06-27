//
//  AuthViewController.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 21.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import UIKit
import Firebase

class AuthorizeViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    var alert = Alert()
    let positions = ConvertPosition().positions
    var namePos: String?
    var resultUid: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func signIn(_ sender: Any) {
        let email = emailField.text!
        let pass = passField.text!
        
        if !pass.isEmpty && !email.isEmpty {
            authorizeAndSave(email: email, pass: pass)
        }
        else {
            alert.showAlert(fromController: self, title: "Ошибка", message: "Неправильно введен E-mail или пароль")
        }
    }
    
    func authorizeAndSave(email: String, pass: String) {
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if error == nil {
                if let result = result {
                    print(result.user.uid)
                    self.saveUid(uid: result.user.uid)
                    for position in self.positions {
                        let ref = Database.database().reference().child(position)
                        ref.child(result.user.uid).child("position").observe(.value) { (snapshot) in
                            if snapshot.exists() {
                                self.namePos = snapshot.value as? String
                                self.openStoryboardPosition(position: self.namePos!)
                            }
                        }
                    }
                }
            }
            else {
                self.alert.showAlert(fromController: self, title: "Ошибка", message: "Неправильно введен E-mail или пароль")
            }
            self.emailField.text = ""
            self.passField.text = ""
        }
    }
    
    func saveUid(uid: String) {
        resultUid = uid
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    func openStoryboardPosition(position: String) {
        if position == "teamleaders" {
            let positionVC = storyboard?.instantiateViewController(withIdentifier: "TeamLeaderViewController") as! TeamLeaderViewController
            navigationController?.pushViewController(positionVC, animated: true)
        }
        else {
            let positionVC = storyboard?.instantiateViewController(withIdentifier: "OtherPositionViewController") as! OtherPositionViewController
            positionVC.uidUser = resultUid!
            positionVC.position = position
            navigationController?.pushViewController(positionVC, animated: true)
        }
    }
}
