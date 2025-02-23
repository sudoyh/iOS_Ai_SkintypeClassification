//
//  DiaryViewController.swift
//  Acos3
//
//  Created by Nasrullah Khan on 03/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import SDWebImage
import Charts


import GoogleMobileAds

class DiaryViewController: UIViewController, GADFullScreenContentDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var analysis: [Analysis] = [Analysis].init() { didSet { self.tableView.reloadData() }}
    
    // 전면광고
    var interstitial: GADInterstitialAd?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UITableView.init(frame: .zero)
        self.getUserProfile()
        self.loadAnalysis()
        self.loadProducts()
        
        // 전면광고
        let request = GADRequest()
        //info.plist에선 앱설정의 ID 필요, 여기서는 광고단위 ID필요
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-4491351582080200/8178639002",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                               }
        )
        
        
    }
    
    @IBAction func addDiaryBtnAction(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func findSameSkinBtnAction(_ sender: UIBarButtonItem) {
        
        guard Product.shared.isEmpty || Analysis.shared.isEmpty else {
            self.sameSkinSheet()
            return }
        
        let alert = UIAlertController(title: "", message: "같은 피부를 찾으려면, \n 최소한 하나의 \(Analysis.shared.isEmpty ? "분석" : "제품")이 필요합니다!", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if Analysis.shared.isEmpty {
                self.tabBarController?.selectedIndex = 1
            }else if Product.shared.isEmpty {
                self.tabBarController?.selectedIndex = 2
            }else {
                self.sameSkinSheet()
            }
          }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func setChart() {
        
        guard !Analysis.shared.isEmpty else { return }
      
        let array = Analysis.shared
            .sorted(by: {$0.createdAt.dateValue() < $1.createdAt.dateValue()})
            .map { object -> Analysis in
                var analysis = object
                analysis.date = object.createdAt.dateValue().toString(format: "dd/MMM")
                return analysis
            }
        
        var analysisArray = [Analysis].init()
        for obj in array {
            if analysisArray.contains(where: {$0.date == obj.date}),
               let index = analysisArray.firstIndex(where: {$0.date == obj.date}) {
                let analysisObj = analysisArray[index]

                if obj.createdAt.dateValue() > analysisObj.createdAt.dateValue() {
                    analysisArray[index] = obj
                }
            }else {
                analysisArray.append(obj)
            }
        }
        
        let senDataSet = self.getDataSet(label: "Sensitivity", color: .systemRed, yValues: analysisArray.map({$0.sensitivity}))
        let poreDataSet = self.getDataSet(label: "Pore", color: .systemOrange, yValues: analysisArray.map({$0.pore}))
        let oilDataSet = self.getDataSet(label: "Oil", color: .systemYellow, yValues: analysisArray.map({$0.oil}))
        let dryDataSet = self.getDataSet(label: "Dry", color: .systemPurple, yValues: analysisArray.map({$0.dry}))
        let pigmentDataSet = self.getDataSet(label: "Pigment", color: .systemBlue.withAlphaComponent(0.8), yValues: analysisArray.map({$0.pigment}))

        let data = LineChartData.init(dataSets: [senDataSet, poreDataSet, oilDataSet, dryDataSet, pigmentDataSet])

        
        data.setValueTextColor(.systemGray2)
        data.setValueFont(.systemFont(ofSize: 12))
        
        self.lineChartView.data = data
        self.lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: analysisArray.compactMap({$0.date}))
        self.lineChartView.xAxis.granularity = 1
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.legend.verticalAlignment = .top
        self.lineChartView.extraTopOffset = 15
        self.lineChartView.setVisibleXRangeMaximum(5)
        
    }
        
    func getDataSet(label: String, color: UIColor, yValues: [Double]) -> LineChartDataSet{
        
        var entries = [ChartDataEntry].init()
        for (index, item) in yValues.enumerated() {
            entries.append(ChartDataEntry.init(x: Double(index), y: item))
        }
        
        let set = LineChartDataSet(entries: entries, label: label)
        set.axisDependency = .right
        set.setColor(color)
        set.setCircleColor(.systemGray2)
        set.lineWidth = 2
        set.circleRadius = 3
        set.fillAlpha = 65/255
        set.fillColor = UIColor.yellow.withAlphaComponent(200/255)
        set.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set.drawCircleHoleEnabled = false
        
        return set
    }
    
    func getUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userCollection = Firestore.firestore().collection("user")
        
        print("firebase email = ", Auth.auth().currentUser?.email)
        userCollection
            .whereField("uid", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                
                guard let snap = querySnapshot else {
                    self.tableView.reloadData()
                    return
                }
                
                snap.documentChanges.forEach { (diff) in
                    
                    print("user profile = ", diff.document.data())
                    User.shared = try! FirestoreDecoder().decode(User.self, from: diff.document.data())

                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name(Constants.UserUpdated), object: nil)
                    
                    if let dressingVC = ((self.tabBarController?.viewControllers?.last as? UINavigationController)?.viewControllers.first as? DressingVC), dressingVC.isViewLoaded {
                          dressingVC.updateUI()
                    }
                }
        }
    }
    
    func loadAnalysis() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let productCollection = Firestore.firestore().collection("Analysis")
        UIApplication.showLoader()
        
        self.analysis = []
        
        productCollection
            .whereField("createdBy", isEqualTo: userId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener(includeMetadataChanges: true)  { querySnapshot, error in
                UIApplication.hideLoader()
                
                guard let snap = querySnapshot else {
                    self.tableView.reloadData()
                    return
                }
                
                snap.documentChanges.forEach { (diff) in
                    
                    if diff.document.metadata.hasPendingWrites {return}
                    let analysis = try! FirestoreDecoder().decode(Analysis.self, from: diff.document.data())
                    
                    if diff.type == .added {
                        Analysis.shared.append(analysis)
                    }
                    
                    if diff.type == .modified {
                        if let index = Analysis.shared.firstIndex(where: { $0.id == analysis.id }){
                            Analysis.shared[index] = analysis
                        }else {
                            Analysis.shared.append(analysis)
                        }
                    }
                    
                    if diff.type == .removed {
                        if let index = Analysis.shared.firstIndex(where: { $0.id == analysis.id }){
                            Analysis.shared.remove(at: index)
                        }
                    }
                    
                    self.analysis = Analysis.shared.sorted(by: {$0.createdAt.dateValue() < $1.createdAt.dateValue()})
                    
                    self.setChart()
                }
            }
    }
    
    func loadProducts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let productCollection = Firestore.firestore().collection("Products")
        UIApplication.showLoader()
        
        Product.shared = []
        
        productCollection
            .whereField("createdBy", isEqualTo: userId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener(includeMetadataChanges: true)  { querySnapshot, error in
                UIApplication.hideLoader()
                
                guard let snap = querySnapshot else {
                    self.tableView.reloadData()
                    return
                }
                
                snap.documentChanges.forEach { (diff) in

                    if diff.document.metadata.hasPendingWrites {return}
                    let product = try! FirestoreDecoder().decode(Product.self, from: diff.document.data())
                    
                    if diff.type == .added {
                        Product.shared.append(product)
                    }
                    
                    if diff.type == .modified {
                        if let index = Product.shared.firstIndex(where: { $0.productId == product.productId }){
                            Product.shared[index] = product
                        }else {
                            Product.shared.append(product)
                        }
                    }
                    
                    if diff.type == .removed {
                        if let index = Product.shared.firstIndex(where: { $0.productId == product.productId }){
                            Product.shared.remove(at: index)
                        }
                    }
                }
            }
    }

    // MARK: Action Sheet for same skin
    func sameSkinSheet(){
        
        let controller = self.storyboard?.instantiateViewController(identifier: "SameSkinViewController") as! SameSkinViewController
        let actionSheet = UIAlertController(title: "어떤 피부고민이 있으신가요? ", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "민감성 피부", style: .default, handler: { (action:UIAlertAction)in
            
            //전면광고 실행
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            
            controller.analysisPoint = .sensitivity
            self.navigationController?.pushViewController(controller, animated: true)
            
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "모공 크기", style: .default, handler: { (action:UIAlertAction)in
            
            //전면광고 실행
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            
            controller.analysisPoint = .pore
            self.navigationController?.pushViewController(controller, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "유분량", style: .default, handler: { (action:UIAlertAction)in
            
            //전면광고 실행
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            
            controller.analysisPoint = .oil
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "건조도", style: .default, handler: { (action:UIAlertAction)in
            
            //전면광고 실행
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            controller.analysisPoint = .dry
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "기미,색소침작", style: .default, handler: { (action:UIAlertAction)in
            
            //전면광고 실행
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            
            controller.analysisPoint = .pigment
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        
        // sheet cancel button
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // prsented sheet
        self.present(actionSheet, animated: true, completion: nil)
        
    }
}

extension DiaryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.analysis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnalysisTableCell") as! AnalysisTableCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let analysis = self.analysis[indexPath.row]
        
        cell.sensitivityLbl.text = String(format: "%g", analysis.sensitivity)
        cell.poreLbl.text = String(format: "%g", analysis.pore)
        cell.oilLbl.text = String(format: "%g", analysis.oil)
        cell.dryLbl.text = String(format: "%g", analysis.dry)
        cell.pigmentLbl.text = String(format: "%g", analysis.pigment)
        cell.dateLbl.text = analysis.createdAt.dateValue().toString(format: "yyyy-MM-dd HH:mm a")
        
        if let url = URL.init(string:  analysis.imageURL) {
            cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgView.sd_setImage(with: url)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension UIViewController {
  var isViewAppeared: Bool { viewIfLoaded?.isAppeared == true }
}

extension UIView {
  var isAppeared: Bool { window != nil }
}
