//
//  TaskTableViewCell.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 23.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var imagePosition: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var whoLabel: UILabel!
    
    var TaskModel: Task? {
        didSet {
            setImage(position: TaskModel?.position)
            setColorStatus(status: TaskModel?.status)
            nameLabel.text = TaskModel?.name
            descriptionLabel.text = TaskModel?.description
            statusLabel.text = TaskModel?.status
            whoLabel.text = TaskModel?.who
        }
    }
    
    func setColorStatus(status: String?) {
        switch status {
        case "open":
            statusLabel.layer.borderColor = Colors().blueCol.cgColor
            statusLabel.textColor = Colors().blueCol
        case "in progress":
            statusLabel.layer.borderColor = Colors().yellowCol.cgColor
            statusLabel.textColor = Colors().yellowCol
        case "done":
            statusLabel.layer.borderColor = Colors().redCol.cgColor
            statusLabel.textColor = Colors().redCol
        default:
            statusLabel.layer.borderColor = Colors().defaultCol.cgColor
            statusLabel.textColor = Colors().defaultCol
        }
    }
    
    func setImage(position: String?) {
        switch position {
        case "developers":
            imagePosition.image = UIImage(systemName: "keyboard")
        case "designers":
            imagePosition.image = UIImage(systemName: "pencil.and.outline")
        case "devops":
            imagePosition.image = UIImage(systemName: "arrow.2.circlepath")
        case "analytics":
            imagePosition.image = UIImage(systemName: "briefcase")
        default:
            imagePosition.image = UIImage(systemName: "pencil")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
