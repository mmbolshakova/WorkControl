//
//  OtherPositionViewController.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 22.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import UIKit
import Firebase

class OtherPositionViewController: UIViewController {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var myButton: UIButton!
    var ref = DatabaseReference.init()
    let colors = Colors()
    var arrayTasks = [Task]()
    var uidUser: String = ""
    var saveLoginUser: String = ""
    var position: String = ""
    var currentLogin: String = ""
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    @objc private func refresh() {
        print ("refresh")
        self.getJsonTasks(login: currentLogin)
        refreshControl.endRefreshing()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setPositionLabel()
        self.ref = Database.database().reference()
        self.getLoginFromUid()
        self.getJsonTasks(login: "")
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        taskTableView.register(nib, forCellReuseIdentifier: "cellXib")
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.addSubview(refreshControl)
        taskTableView.rowHeight = UITableView.automaticDimension
        taskTableView.estimatedRowHeight = 600
        allButton.layer.borderColor = colors.whiteCol.cgColor
    }
    func getJsonTasks(login: String?) {
        self.arrayTasks.removeAll()
        let refQuery = ref.child("tasks").queryOrdered(byChild: "position").queryEqual(toValue: position)
        refQuery.observeSingleEvent(of: .value) { (snapshot) in
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if let dict = snap.value as? [String:AnyObject], dict["who"] as! String? == login {
                        let name = dict["name"] as? String ?? ""
                        let id = dict["id"] as? Int
                        let description = dict["description"] as? String ?? ""
                        let position = dict["position"] as? String ?? ""
                        let status = dict["status"] as? String ?? ""
                        let who = dict ["who"] as? String ?? ""
                        self.arrayTasks.append(Task(name: name, id: id!, description: description, status: status, position: position, who: who))
                        self.taskTableView.reloadData()
                    }
                }
            }
        }
        self.taskTableView.reloadData()
    }
    
    func setPositionLabel() {
        switch position {
        case "developers":
            positionLabel.text = "Разработчик"
        case "designers":
            positionLabel.text = "Дизайнер"
        case "devops":
            positionLabel.text = "ДевОпс"
        case "analytics":
            positionLabel.text = "Аналитик"
        default:
            positionLabel.text = ""
        }
    }
    
    func getLoginFromUid(){
        for position in ConvertPosition().positions {
            let ref = Database.database().reference().child(position)
            ref.child(uidUser).child("login").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    self.saveLogin(login: snapshot.value as! String)
                }
            }
        }
    }
    
    private func saveLogin(login: String){
        saveLoginUser = login
    }
    
    @IBAction func myButtonAction(_ sender: Any) {
        myButton.setTitleColor(colors.whiteCol, for: .normal)
        myButton.layer.borderColor = colors.whiteCol.cgColor
        
        allButton.setTitleColor(colors.defaultCol, for: .normal)
        allButton.layer.borderColor = colors.defaultCol.cgColor
        getLoginFromUid()
        currentLogin = saveLoginUser
        getJsonTasks(login: saveLoginUser)
    }
    @IBAction func allButtonAction(_ sender: Any) {
        allButton.setTitleColor(colors.whiteCol, for: .normal)
        allButton.layer.borderColor = colors.whiteCol.cgColor
        
        myButton.setTitleColor(colors.defaultCol, for: .normal)
        myButton.layer.borderColor = colors.defaultCol.cgColor
        currentLogin = ""
        self.getJsonTasks(login: "")
    }
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let authVC = storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthorizeViewController
            navigationController?.pushViewController(authVC, animated: true)
        } catch {
            print(error)
        }
    }
}

extension OtherPositionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "cellXib", for: indexPath) as? TaskTableViewCell
        cell?.TaskModel = arrayTasks[indexPath.row]
        return cell!
    }
    
    func inProgressRow(indexPathAt indexPath: IndexPath) -> UIContextualAction{
        let inProgress = UIContextualAction(style: .normal, title: "Взять в работу") { (_, _, _) in
            let idTask = self.arrayTasks[indexPath.row].id!
            self.arrayTasks.remove(at: indexPath.row)
            self.taskTableView.beginUpdates()
            self.taskTableView.deleteRows(at: [indexPath], with: .automatic)
            self.taskTableView.endUpdates()
            Database.database().reference().child("tasks").child(String(idTask)).updateChildValues(["status": "in progress", "who" : self.saveLoginUser])
            self.getJsonTasks(login: "")
        }
        inProgress.backgroundColor = colors.blueCol
        return inProgress
    }
    
    func doneRow(indexPathAt indexPath: IndexPath) -> UIContextualAction{
        let done = UIContextualAction(style: .normal, title: "Завершить") { (_, _, _) in
            let idTask = self.arrayTasks[indexPath.row].id!
            self.arrayTasks.removeAll()
            Database.database().reference().child("tasks").child(String(idTask)).updateChildValues(["status": "done"])
            self.getJsonTasks(login: self.saveLoginUser)
        }
        done.backgroundColor = colors.yellowCol
        return done
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = self.doneRow(indexPathAt: indexPath)
        let inProgress = self.inProgressRow(indexPathAt: indexPath)
        var swipe = UISwipeActionsConfiguration(actions: [])
        switch self.arrayTasks[indexPath.row].status {
        case "open":
            swipe = UISwipeActionsConfiguration(actions: [inProgress])
        case "in progress":
            swipe = UISwipeActionsConfiguration(actions: [done])
        default:
            swipe = UISwipeActionsConfiguration(actions: [])
        }
        return swipe
    }
}
