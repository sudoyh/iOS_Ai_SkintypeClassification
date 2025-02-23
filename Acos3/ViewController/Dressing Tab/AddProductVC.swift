//
//  AddProductVC.swift
//  Acos3
//
//  Created by Nasrullah Khan on 02/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class AddProductVC: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var periodField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        // 1. validation
        guard
            let name = self.nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
            let type = self.typeField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !type.isEmpty,
            let period = self.periodField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !period.isEmpty else {
            
            self.prompt(title: "Warning!", message: "All fields are required.")
            return
        }
        
        // 2. save data into database
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UIApplication.showLoader()
        let productCollection = Firestore.firestore().collection("Products")
        let doct = productCollection.document()
        let docData = Product.data(id: doct.documentID, userId: userId, name: name, type: type, usingPeriod: period)
        
        doct.setData(docData) { error in
            UIApplication.hideLoader()
            if let err = error {
                self.showError(with: err.localizedDescription)
            } else {
                
                // 3. on success show popup and back to dressingvc
                self.prompt(title: "Success", message: "Product added successfully.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
}
