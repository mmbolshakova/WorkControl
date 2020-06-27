//
//  Alert.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 22.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import Foundation
import UIKit

class Alert: UIViewController {
    func showAlert(fromController controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
