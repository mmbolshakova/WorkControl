//
//  RegisterViewController.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 21.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var positionPicker: UIPickerView!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    
    var alert = Alert()
    let positions = [" ", "ДевОпс", "Разработчик", "Дизайнер", "Аналитик", "Тим-лидер"]
    var idPosition = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        positionPicker.delegate = self
        positionPicker.dataSource = self
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return positions[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return positions.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        idPosition = row
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let login = loginField.text!
        let email = emailField.text!
        let pass = passField.text!
        let position = ConvertPosition().convertIdtoPosition(id: idPosition)
        
        if !login.isEmpty && !pass.isEmpty && !email.isEmpty && idPosition != 0 {
            Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in
                if error == nil {
                    if let result = result {
                        print(result.user.uid)
                        let ref = Database.database().reference().child(position)
                        ref.child(result.user.uid).updateChildValues(["login" : login, "email" : email, "pass" : pass, "position" : position])
                        self.alert.showAlert(fromController: self, title: "", message: "Регистрация прошла успешно")
                        self.loginField.text = ""
                        self.emailField.text = ""
                        self.passField.text = ""
                    }
                }
                else {
                    self.alert.showAlert(fromController: self, title: "Ошибка", message: "Пользователь с таким E-mail уже существует")
                    print(error.debugDescription)
                }
            }
        }
        else {
            alert.showAlert(fromController: self, title: "Ошибка", message: "Пожалуйста, заполните все поля")
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        let authVC = storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthorizeViewController
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
