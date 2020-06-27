//
//  AddTaskViewController.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 24.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import UIKit
import Firebase
class AddTaskViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var positionsPicker: UIPickerView!
    
    var alert = Alert()
    let positions = [" ", "ДевОпс", "Разработчик", "Дизайнер", "Аналитик"]
    var idPosition = 0
    var countChildren: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionText.delegate = self
        positionsPicker.delegate = self
        positionsPicker.dataSource = self
        
        descriptionText.text = "Описание"
        descriptionText.textColor = UIColor.lightGray
    }

    @IBAction func addTaskAction(_ sender: Any) {
        let name = nameField.text!
        let description = descriptionText.text!
        let position = ConvertPosition().convertIdtoPosition(id: idPosition)
        
        
        if !name.isEmpty && !description.isEmpty && idPosition != 0 {
            let ref = Database.database().reference().child("tasks")
            ref.queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
                self.countChildren = Int(snapshot.childrenCount)
                print ("🐳 \(self.countChildren)")
                ref.child(String(self.countChildren)).updateChildValues(["name" : name, "id": self.countChildren, "description" : description, "status" : "open", "position" : position, "who" : ""])
            }
            backToTM()
            self.alert.showAlert(fromController: self, title: "", message: "Задача добавлена")
            self.nameField.text = ""
            self.descriptionText.text = ""
        }
        else {
            alert.showAlert(fromController: self, title: "Ошибка", message: "Пожалуйста, заполните все поля")
        }
    }
    
    func backToTM () {
        let tmVC = storyboard?.instantiateViewController(withIdentifier: "TeamLeaderViewController") as! TeamLeaderViewController
        navigationController?.pushViewController(tmVC, animated: true)
    }
}

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionText.textColor == UIColor.lightGray {
            descriptionText.text = nil
            descriptionText.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionText.text.isEmpty {
            descriptionText.text = "Описание"
            descriptionText.textColor = UIColor.lightGray
        }
    }
}

extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
}
