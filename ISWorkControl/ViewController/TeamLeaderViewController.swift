//
//  TeamLeaderViewController.swift
//  ISWorkControl
//
//  Created by OUT-Bolshakova-MM on 22.06.2020.
//  Copyright © 2020 Большакова Мария. All rights reserved.
//

import UIKit
import Firebase

class TeamLeaderViewController: UIViewController {

    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var inProgressButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    
    var ref = DatabaseReference.init()
    let colors = Colors()
    var arrayTasks = [Task]()
    var statusTasks: String? = nil
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.getJsonTasks()
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        taskTableView.register(nib, forCellReuseIdentifier: "cellXib")
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.addSubview(refreshControl)
        taskTableView.rowHeight = UITableView.automaticDimension
        taskTableView.estimatedRowHeight = 600
        
        allButton.layer.borderColor = colors.whiteCol.cgColor
        navigationController?.navigationBar.isHidden = true
    }
    @objc private func refresh() {
        print ("refresh")
        self.getJsonTasks()
        refreshControl.endRefreshing()
    }
    
    func getJsonTasks() {
        var refQuery = ref.child("tasks").queryOrderedByKey()
        if statusTasks != nil {
            refQuery = ref.child("tasks").queryOrdered(byChild: "status").queryEqual(toValue: self.statusTasks)
        }
        refQuery.observeSingleEvent(of: .value) { (snapshot) in
            self.arrayTasks.removeAll()
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if let dict = snap.value as? [String:AnyObject] {
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
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let authVC = storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthorizeViewController
            navigationController?.pushViewController(authVC, animated: true)
        } catch {
            print(error)
        }
    }
    @IBAction func addTaskAction(_ sender: Any) {
        let addTaskVC = storyboard?.instantiateViewController(withIdentifier: "AddTaskViewController") as! AddTaskViewController
        navigationController?.present(addTaskVC, animated: true, completion: nil) // модальное окно
        //navigationController?.pushViewController(addTaskVC, animated: true) // весь экран
    }
    
    @IBAction func allAction(_ sender: Any) {
        setDefaultColors()
        statusTasks = nil
        self.getJsonTasks()
        allButton.setTitleColor(colors.whiteCol, for: .normal)
        allButton.layer.borderColor = colors.whiteCol.cgColor
    }
    
    @IBAction func openAction(_ sender: Any) {
        setDefaultColors()
        statusTasks = "open"
        self.getJsonTasks()
        self.taskTableView.reloadData()
        openButton.setTitleColor(colors.blueCol, for: .normal)
        openButton.layer.borderColor = colors.blueCol.cgColor
    }
    
    @IBAction func inProgressAction(_ sender: Any) {
        setDefaultColors()
        statusTasks = "in progress"
        self.getJsonTasks()
        inProgressButton.setTitleColor(colors.yellowCol, for: .normal)
        inProgressButton.layer.borderColor = colors.yellowCol.cgColor
    }
    
    @IBAction func doneAction(_ sender: Any) {
        setDefaultColors()
        statusTasks = "done"
        self.getJsonTasks()
        doneButton.setTitleColor(colors.redCol, for: .normal)
        doneButton.layer.borderColor = colors.redCol.cgColor
    }
    
    func setDefaultColors() {
        allButton.setTitleColor(colors.defaultCol, for: .normal)
        allButton.layer.borderColor = colors.defaultCol.cgColor
        
        openButton.setTitleColor(colors.defaultCol, for: .normal)
        openButton.layer.borderColor = colors.defaultCol.cgColor
        
        inProgressButton.setTitleColor(colors.defaultCol, for: .normal)
        inProgressButton.layer.borderColor = colors.defaultCol.cgColor
        
        doneButton.setTitleColor(colors.defaultCol, for: .normal)
        doneButton.layer.borderColor = colors.defaultCol.cgColor
    }
}

extension TeamLeaderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "cellXib", for: indexPath) as? TaskTableViewCell
        cell?.TaskModel = arrayTasks[indexPath.row]
        return cell!
    }
    
    func deleteRow(indexPathAt indexPath: IndexPath) -> UIContextualAction{
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { (_, _, _) in
            let idTask = self.arrayTasks[indexPath.row].id!
            self.arrayTasks.remove(at: indexPath.row)
            self.taskTableView.beginUpdates()
            self.taskTableView.deleteRows(at: [indexPath], with: .automatic)
            self.taskTableView.endUpdates()
            Database.database().reference().child("tasks").child(String(idTask)).removeValue()
        }
        delete.backgroundColor = colors.redCol
        return delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = self.deleteRow(indexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    
}
