//
//  TasksResponse.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 23.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import Foundation

struct Task: Decodable {
    var name: String?
    var id: Int?
    var description: String?
    var status: String?
    var position: String?
    var who: String?
    
    init(name: String, id: Int, description: String, status: String, position: String, who: String) {
        self.name = name
        self.id = id
        self.description = description
        self.status = status
        self.position = position
        self.who = who
    }
}
