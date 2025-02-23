//
//  ResultVC.swift
//  Acos3
//
//  Created by mac on 2021/05/12.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class ResultVC: UIViewController {
    
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var SurveyResultLabel: UILabel!
    
    @IBOutlet weak var result11: UILabel!
    @IBOutlet weak var resultOilLabel: UILabel!
    @IBOutlet weak var resultPigmentLabel: UILabel!
    @IBOutlet weak var resultPoreLabel: UILabel!
    
    var analysis: Analysis!
    
    // 머신러닝 결과
    
    var SurveyResultVC : String = ""
    var result1 : String = ""
    var resultOil : String = ""
    var resultPigment : String = ""
    var resultPore : String = ""
    
    var intSurveyResultVC: Array<CGFloat>.ArrayLiteralElement = 0
    var intResult1ResultVC : Array<CGFloat>.ArrayLiteralElement = 0
    var intResultOilResultVC : Array<CGFloat>.ArrayLiteralElement = 0
    var intResultPigmentResultVC : Array<CGFloat>.ArrayLiteralElement = 0
    var intResultPoreResultVC : Array<CGFloat>.ArrayLiteralElement = 0
    
    
    // bar 차트
    var chartName: String?
    
    
    
    
    
    // 결과라벨
    @IBOutlet weak var ResultTextLabel: UILabel!
    
   
   

    
    
    // 이미지
    var ResultVCImage : UIImage?
    @IBOutlet weak var Beforeimage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 결과 텍스트
        
        SurveyResultLabel.text = SurveyResultVC
        resultOilLabel.text = resultOil
        result11.text = result1
        resultPoreLabel.text = resultPore
        resultPigmentLabel.text = resultPigment
        
        
        // 결과 텍스트 장문
        var labelArray: [String] = []
   
        if analysis.sensitivity >= 3 {
            labelArray.append("민감도")
        }
        
        if analysis.oil >= 3 {
            labelArray.append("유분량")
        }
        
        if analysis.dry >= 3 {
            labelArray.append("건조도")
        }
        
        if analysis.pore >= 3 {
            labelArray.append("모공크기")
        }
        
        if analysis.pigment >= 3 {
            labelArray.append("색소 침작")
        }
        
        
        let sentence = labelArray.joined(separator: ",")
        
        if labelArray.isEmpty  {
            ResultTextLabel.text = "당신의 피부는 정상적인 상태입니다!"
        } else if labelArray.count >= 1 {
            ResultTextLabel.text =  "분석결과 값이 3이상인 항목은 \n " +  sentence  + " 입니다.\n"
                + "이 항목들은 정상적인 수치를 벗어난 \n 항목들로 피부관리가 필요한 상태입니다"
        }
        
        
        
        

        
        
        //bar 차트
        let barChart = self.setBarChart()
        self.view.addSubview(barChart)
        
        
        // 이전이미지를 appDelegate에 저장하여 Asynchronous 방식으로 불러온다
        let ad = UIApplication.shared.delegate as? AppDelegate
        if let im = ad?.imgApp {
            Beforeimage.image = im
        }
        
        // 공유하기 버튼
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"공유하기",style: UIBarButtonItem.Style.plain, target: self, action: #selector(presentShareSheet))
    
        
    
    }
        
    @IBAction func saveBtnAction(_ sender: UIButton) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UIApplication.showLoader()
        
        let analysisCollection = Firestore.firestore().collection("Analysis")
        let name = "\(Date().timeIntervalSince1970).jpg"
        let doc = analysisCollection.document()
        let path = "\(userId)/\(analysisCollection.path)/\(doc.documentID)/\(name)"
        
        Uploader.uploadImage(image: self.Beforeimage.image!, path: path) { (url) in
            
            if let url = url {
                let analysis = Analysis.data(id: doc.documentID, createdBy: userId, imageURL: url, sensitivity: self.analysis.sensitivity, pore: self.analysis.pore, oil: self.analysis.oil, dry: self.analysis.dry, pigment: self.analysis.pigment)
                
                var sensitivity = Analysis.shared.map({$0.sensitivity})
                sensitivity.append(self.analysis.sensitivity)
                
                var pore = Analysis.shared.map({$0.pore})
                pore.append(self.analysis.pore)
                
                var oil = Analysis.shared.map({$0.oil})
                oil.append(self.analysis.oil)
                
                var dry = Analysis.shared.map({$0.dry})
                dry.append(self.analysis.dry)

                var pigment = Analysis.shared.map({$0.pigment})
                pigment.append(self.analysis.pigment)
                
                doc.setData(analysis) { (error) in
                    
                    let avgParams: [String: Any] = [
                        "sensitivity": sensitivity.average,
                        "pore": pore.average,
                        "oil": oil.average,
                        "dry": dry.average,
                        "pigment": pigment.average,
                        "latestImageURL": url
                    ]

                    
                    if let err = error {
                        UIApplication.hideLoader()
                        self.showError(with: err.localizedDescription)
                    }else{
                        
                        Firestore.firestore().collection("user").document(userId).updateData(["average": avgParams]) { (error) in
                            
                            UIApplication.hideLoader()
                            // 에러발생
                            if let err = error {
                                self.showError(with: err.localizedDescription)
                            }else{
                                self.prompt(title: "Success", message: "Analysis Saved Successfully", okClick: {
                                    self.tabBarController?.selectedIndex = 0
                                    self.navigationController?.popToRootViewController(animated: false)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setBarChart() -> PNBarChart {
        
        let barChart = PNBarChart(frame: CGRect(x: 0, y: 135, width: 320, height: 200))
        barChart.backgroundColor = UIColor.clear
        barChart.animationType = .Waterfall
        barChart.labelMarginTop = 5.0
        barChart.xLabels = ["민감도", "유분량", "건조도", "색소침작", "모공"]
        barChart.yValues = [intSurveyResultVC,intResultOilResultVC, intResult1ResultVC, intResultPigmentResultVC, intResultPoreResultVC]
        barChart.strokeChart()
        
        barChart.center = self.view.center
        return barChart
        
        
    }
    
    
    
    
    @objc private func presentShareSheet(){
        guard let viewImage = myView.transfromToImage()  else {
            return
        }
        
        let shareSheetVC = UIActivityViewController(
            activityItems: [
                viewImage ]
            , applicationActivities: nil)
        present(shareSheetVC, animated: true)
    }
    
    
    
    
    //
}

// 현재 뷰를 이미지로 변환
extension UIView {
    func transfromToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
