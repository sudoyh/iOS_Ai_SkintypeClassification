//
//  SameSkinViewController.swift
//  Acos3
//
//


import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import SDWebImage

class SameSkinViewController: UIViewController {
    
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
    
    var analysisPoint: AnalysisPoint = .sensitivity
    var userObject: User? = nil { didSet { self.updateUI(); self.loadProducts() }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.avgSkinBgView.isHidden = true
        self.tableView.tableFooterView = UITableView.init(frame: .zero)
        self.getSameSkinUserData()
    }
    
    func getSameSkinUserData() {
        guard let userId = User.shared?.uid, let avg = User.shared?.average else { return }
        let userCollection = Firestore.firestore().collection("user")
        
        var value: Double = avg.sensitivity
        switch self.analysisPoint {
        case .sensitivity:
            value = avg.sensitivity
        case .pore:
            value = avg.pore
        case .oil:
            value = avg.oil
        case .dry:
            value = avg.dry
        case .pigment:
            value = avg.pigment
        }
        
        userCollection
            .whereField("average.\(self.analysisPoint.rawValue)", isGreaterThanOrEqualTo: value)
            .getDocuments { querySnapshot, error in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    if let user = querySnapshot!.documents
                        .compactMap({ document in
                            return try! FirestoreDecoder().decode(User.self, from: document.data())
                        }).first(where: {$0.uid != userId}) {
                        print("user.email ", user.email)
                        self.userObject = user
                    }else {
                        print("get random user")
                        self.getRandomUser()
                    }
                }
            }
    }
    
    func getRandomUser() {
        guard let userId = User.shared?.uid else { return }
        let userCollection = Firestore.firestore().collection("user")
        
        userCollection
            .whereField("uid", isNotEqualTo: userId)
            .getDocuments { querySnapshot, error in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let user = querySnapshot!.documents
                        .compactMap({ document in
                            return try! FirestoreDecoder().decode(User.self, from: document.data())
                        }).first {
                        print(#function, "user.email ", user.email)
                        self.userObject = user
                    }
                }
            }
    }
    
    func loadProducts() {
        guard let userId = self.userObject?.uid else { return }
        
        let productCollection = Firestore.firestore().collection("Products")
        UIApplication.showLoader()
        
        self.products = []
        
        productCollection
            .whereField("createdBy", isEqualTo: userId)
            .order(by: "createdAt", descending: false)
            .getDocuments  { querySnapshot, error in
                UIApplication.hideLoader()
                
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    
                    self.products = querySnapshot?.documents
                        .compactMap({ document in
                            return try! FirestoreDecoder().decode(Product.self, from: document.data())
                        }) ?? []
                }
            }
    }
    
    func updateUI() {
        
        guard let email = self.userObject?.email, let average = self.userObject?.average else {
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
}

extension SameSkinViewController: UITableViewDataSource, UITableViewDelegate {
    
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
