//
//  ConvertPosition.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 24.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import Foundation

class ConvertPosition {
    let positions = ["teamleaders", "developers", "designers", "analytics", "devops"]
    
    func convertIdtoPosition(id: Int) -> String {
        switch id {
        case 1:
            return "devops"
        case 2:
            return "developers"
        case 3:
            return "designers"
        case 4:
            return "analytics"
        case 5:
            return "teamleaders"
        default:
            return "error"
        }
    }
}
