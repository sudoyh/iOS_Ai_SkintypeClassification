//
//  DressingVC.swift
//  Acos3
//
//  Created by Nasrullah Khan on 02/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import SDWebImage

class DressingVC: UIViewController {
    
    @IBOutlet weak var avgSkinBgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skinImgView: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var sensitivityLbl: UILabel!
    @IBOutlet weak var poreLbl: UILabel!
    @IBOutlet weak var oilLbl: UILabel!
    @IBOutlet weak var dryLbl: UILabel!
    @IBOutlet weak var pigmentLbl: UILabel!
    
    var products: [Product] = [Product].init() { didSet { self.tableView.reloadData() }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UITableView.init(frame: .zero)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.updateUI), name: Notification.Name(Constants.UserUpdated), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateUI()
        self.products = Product.shared
    }
            
    @objc func updateUI() {
        
        guard let email = User.shared?.email, let average = User.shared?.average else {
            self.avgSkinBgView.isHidden = true
            return }
        
        self.avgSkinBgView.isHidden = false
        
        if let url = URL.init(string: average.latestImageURL) {
            self.skinImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.skinImgView.sd_setImage(with: url)
        }

        self.emailLbl.text = "UserId: " + email
        self.sensitivityLbl.text = String(format: "%.1f", average.sensitivity)
        self.poreLbl.text = String(format: "%.1f", average.pore)
        self.oilLbl.text = String(format: "%.1f", average.oil)
        self.dryLbl.text = String(format: "%.1f", average.dry)
        self.pigmentLbl.text = String(format: "%.1f", average.pigment)
    }
    
    @IBAction func logoutBtnAction(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            User.shared = nil
            Analysis.shared = []
            Product.shared = []
            let controller = self.storyboard?.instantiateInitialViewController()
            view.window?.rootViewController = controller
            view.window?.makeKeyAndVisible()

        }catch {
            self.showError(with: error.localizedDescription)
        }
    }
}

extension DressingVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
        cell.selectionStyle = .none
        let product = self.products[indexPath.row]
        cell.productLbl.text = "Product name: \(product.name) \nProduct type: \(product.type) \nPeriod: \(product.usingPeriod)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
