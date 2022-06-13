//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Jordan Peralta on 2022-06-07.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var todoListTableView: UITableView!
    
    private let database = Database.database().reference()
    private var dataSource: [(String, Any)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoListTableView.dataSource = self
        todoListTableView.delegate = self
        
        title = "My Notes"
        let myLogo = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: myLogo, style: .plain, target: self, action: #selector(logoTapped))
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAll))
        ]
        fetchItemsFromDB()
    }
    
    @objc func logoTapped() {
        let logoAlert = UIAlertController(title: "Version 1.0", message: nil, preferredStyle: .alert)
        logoAlert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(logoAlert, animated: true)
    }
    
    @objc func addNote() {
        let noteAdded = UIAlertController(title: "Enter a note", message: nil, preferredStyle: .alert)
        
        noteAdded.addTextField { field in field.placeholder = "Enter some text" }
        
        noteAdded.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        noteAdded.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] addActionCode in
            
            if let textField = noteAdded.textFields?.first,
               let note = textField.text,
               !note.isEmpty {
                self?.saveItemToDB(item: note)
            }
        }))
        present(noteAdded, animated: true)
    }

    @objc func deleteAll() {
        let eraseAll = UIAlertController(title: "Are you sure?", message: "Deleting all notes.", preferredStyle: .alert)
        
        eraseAll.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        eraseAll.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.database.child("MyToDoList").removeValue()
        }))
        present(eraseAll, animated: true)
    }
    
    func saveItemToDB(item: String) {
        database.child("MyToDoList").childByAutoId().setValue(item)
        fetchItemsFromDB()
    }
    
    func fetchItemsFromDB() {
        database.child("MyToDoList").observe(.value) { [weak self] snapshot in
            guard let items = snapshot.value as? [String: Any] else {
                return
            }
            self?.dataSource.removeAll()
            let sortedItems = items.sorted { $0.0 < $1.0 }
            for (key, item) in sortedItems {
                self?.dataSource.append((key, item))
            }
            self?.todoListTableView.reloadData()
        }
    }
    
    func removefromDB(item: String) {
        database.child("MyToDoList/\(item)").removeValue()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoListCell", for: indexPath)
        var noteBody = cell.defaultContentConfiguration()
        noteBody.text = dataSource[indexPath.row].1 as? String
        cell.contentConfiguration = noteBody
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: false)
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: "editMode") as? EditViewVC else {
            return
    }
        let noteTitleData = self.dataSource[indexPath.row].0
        let noteBodydata = self.dataSource[indexPath.row].1 as? String
        vc.noteTitleData = noteTitleData
        vc.noteBodyData = noteBodydata
        //
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //remove an item from the firebase database (from cloud)
            removefromDB(item: dataSource[indexPath.row].0)
            //remove an item from the tableview datasource
            dataSource.remove(at: indexPath.row)
            //delete a row from the table (locally)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
