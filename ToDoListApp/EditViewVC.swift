//
//  EditViewVC.swift
//  ToDoListApp
//
//  Created by Jordan Peralta on 2022-06-08.
//

import UIKit
import FirebaseDatabase

class EditViewVC: UIViewController {
    
    private let database = Database.database().reference()
    private var dataSource: [(String, Any)] = []
    
    var noteTitleData: String?
    var noteBodyData: Any?
    
    @IBOutlet weak var showNoteBody: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        showNoteBody.text = noteBodyData as? String
    }
    
    @IBAction func saveNote(_ sender: UIButton) {
        
        self.database.child("MyToDoList/\(self.noteTitleData!)").setValue(showNoteBody.text)
        
        let saveAlert = UIAlertController(title: "Note saved!", message: nil, preferredStyle: .alert)
        saveAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(saveAlert, animated: true)
    }
    
    @IBAction func deleteNote(_ sender: UIButton) {
        
        let deleteAlert = UIAlertController(title: "Are you sure?", message: "This will delete the note from database.", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { deleteAction in self.database.child("MyToDoList/\(self.noteTitleData!)").removeValue()
            
            let confirmDeletion = UIAlertController(title: "Note successfully deleted!", message: nil, preferredStyle: .alert)
            confirmDeletion.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "mainScreen") as? ViewController else {
                    return
                }
                self.navigationController?.pushViewController(vc, animated: true)
                
            }))
            self.present(confirmDeletion, animated: true)
        }))
        present(deleteAlert, animated: true)
    }
    

}
