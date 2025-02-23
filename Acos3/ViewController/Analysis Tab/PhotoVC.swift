//
//  PhotoVC.swift
//  Acos3
//
//  Created by mac on 2021/05/12.
//

import Foundation
import UIKit
import Vision
import CoreML

import GoogleMobileAds

// 진짜광고id ca-app-pub-4491351582080200/8178639002
// test광고id ca-app-pub-3940256099942544/5135589807


class PhotoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,GADFullScreenContentDelegate  {
    
    @IBOutlet weak var image: UIImageView!
    
    //카메라,앨범 불러오기
    let imagePicker = UIImagePickerController()
    let photoLibraryPicker = UIImagePickerController()
    
    // 사진 자르는부분
    let cropper = UIImageCropper(cropRatio: 2/3)
    
    // 설문조사 결과
    var SurveyResult : String = ""
    
    // 머신러닝 결과 넘겨주는 텍스트
    var SkinResultDry : String = ""
    var SkinResultOil : String = ""
    var SkinResultPore : String = ""
    var SkinResultPigment : String = ""
    
    var intSurveyResultPhotoVC: Array<CGFloat>.ArrayLiteralElement = 0
    var intResult1PhotoVC : Array<CGFloat>.ArrayLiteralElement = 0
    var intResultOilPhotoVC : Array<CGFloat>.ArrayLiteralElement = 0
    var intResultPigmentPhotoVC : Array<CGFloat>.ArrayLiteralElement = 0
    var intResultPorePhotoVC : Array<CGFloat>.ArrayLiteralElement = 0
        
    var senstivity: Double = 0
    var oil: Double = 0
    var dry: Double = 0
    var pore: Double = 0
    var pigment: Double = 0
    
    // 전면광고
    var interstitial: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
        }
        
        self.photoLibraryPicker.delegate = self
        self.photoLibraryPicker.sourceType = .photoLibrary
      
        
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
        
        
        
        
        // Button Ui
        setUpElements()
    }
    
    
    // mlmodel 실행함수
    func detect(image: CIImage){
        
        // 건조도
        guard let model1 = try? VNCoreMLModel(for: skinDry().model) else {
            fatalError("Loading CoreML model Failed!")
        }
        
        let request1 = VNCoreMLRequest(model: model1) { (request, error) in
            
            guard let results = request.results as?
                    [VNClassificationObservation] else {
                fatalError("Model failed to process image!")
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                //return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                return String(classification.identifier)
            }
            
            
            if let _ = results.first {
                //self.gender.text = firstResult.identifier
                //self.gender.numberOfLines = 5
                //self.gender.text = "Skin Type: \n" + descriptions.joined(separator: "\n")
                
                //출력값 모두 가져오기
                //self.SkinResultDry = "Skin Type: \n" + descriptions.joined(separator: "\n")
                
                //첫번째 값만 가져오기
                self.SkinResultDry = "건조도 : " + descriptions[0]
                self.dry = (descriptions[0] as NSString).doubleValue
                
                //변환
                guard let castDry = Int(descriptions[0]) else {
                    return print("type casting error")
                }
                let castDry2 = Array<CGFloat>.ArrayLiteralElement(castDry)
                self.intResult1PhotoVC = castDry2
                
            }
        }
        
        let handler1 = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler1.perform([request1])
        } catch {
            print(error)
        }
        
        
        
        
        // 유분
        guard let model2 = try? VNCoreMLModel(for: skinOil().model) else {
            fatalError("Loading CoreML model Failed!")
        }
        
        let request2 = VNCoreMLRequest(model: model2) { (request, error) in
            
            guard let results2 = request.results as?
                    [VNClassificationObservation] else {
                fatalError("Model failed to process image!")
            }
            let classifications = results2 as! [VNClassificationObservation]
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                return String(classification.identifier)
            }
            if let _ = results2.first {
                self.SkinResultOil = "유분량 : " + descriptions[0]
                self.oil = (descriptions[0] as NSString).doubleValue
                
                //변환
                guard let castOil = Int(descriptions[0]) else {
                    return print("type casting error")
                }
                let castOil2 = Array<CGFloat>.ArrayLiteralElement(castOil)
                self.intResultOilPhotoVC = castOil2
                
            }
        }
        let handler2 = VNImageRequestHandler(ciImage: image)
        do {
            try handler2.perform([request2])
        } catch {
            print(error)
        }
        
        
        // 색소
        guard let model3 = try? VNCoreMLModel(for: skinPigment().model) else {
            fatalError("Loading CoreML model Failed!")
        }
        
        let request3 = VNCoreMLRequest(model: model3) { (request, error) in
            
            guard let results3 = request.results as?
                    [VNClassificationObservation] else {
                fatalError("Model failed to process image!")
            }
            let classifications = results3 as! [VNClassificationObservation]
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                return String(classification.identifier)
            }
            if let _ = results3.first {
                self.SkinResultPigment = "색소침작 : " + descriptions[0]
                self.pigment = (descriptions[0] as NSString).doubleValue
                
                //변환
                guard let castPigment = Int(descriptions[0]) else {
                    return print("type casting error")
                }
                let castPigment2 = Array<CGFloat>.ArrayLiteralElement(castPigment)
                self.intResultPigmentPhotoVC = castPigment2
            }
        }
        let handler3 = VNImageRequestHandler(ciImage: image)
        do {
            try handler3.perform([request3])
        } catch {
            print(error)
        }
        
        
        
        // 모공
        guard let model4 = try? VNCoreMLModel(for: skinPore().model) else {
            fatalError("Loading CoreML model Failed!")
        }
        
        let request4 = VNCoreMLRequest(model: model4) { (request, error) in
            
            guard let results4 = request.results as?
                    [VNClassificationObservation] else {
                fatalError("Model failed to process image!")
            }
            let classifications = results4 as! [VNClassificationObservation]
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                return String(classification.identifier)
            }
            if let _ = results4.first {
                self.SkinResultPore = "모공크기 : " + descriptions[0]
                self.pore = (descriptions[0] as NSString).doubleValue
                
                //변환
                guard let castPore = Int(descriptions[0]) else {
                    return print("type casting error")
                }
                let castPore2 = Array<CGFloat>.ArrayLiteralElement(castPore)
                self.intResultPorePhotoVC = castPore2
            }
        }
        
        let handler4 = VNImageRequestHandler(ciImage: image)
        do {
            try handler4.perform([request4])
        } catch {
            print(error)
        }
        
        
        // 애드몹 콜백메서드
        /// Tells the delegate that the ad failed to present full screen content.
        func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
          print("Ad did fail to present full screen content.")
        }

        /// Tells the delegate that the ad presented full screen content.
        func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
          print("Ad did present full screen content.")
        }

        /// Tells the delegate that the ad dismissed full screen content.
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
          print("Ad did dismiss full screen content.")
        }
        
        
    }
    
    
    @IBAction func CameraButton(_ sender: Any) {
        
        
        present(imagePicker, animated: true, completion: nil )
        
        cropper.picker = imagePicker
        
        //setup the cropper
        cropper.delegate = self
        //cropper.cropRatio = 2/3 //(can be set during runtime or in init)
        cropper.cropButtonText = "영역 자르기(Crop)" // this can be localized if needed (as well as the cancelButtonText)
        
        
        
    }
    
    
    
    
    @IBAction func AlbumButton(_ sender: Any) {
        
        present(photoLibraryPicker, animated: true, completion: nil )
        
        cropper.picker = photoLibraryPicker
        cropper.delegate = self
        cropper.cropButtonText = "영역 자르기(Crop)"
    }
    
    
    
    // 세그가 실행되기전 결과 text값 전달 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ResultVC {
            let vc = segue.destination as? ResultVC
            
            //ResultVC 로 전달
            
            self.senstivity = (SurveyResult as NSString).doubleValue
            vc?.SurveyResultVC = "민감도 : "+SurveyResult
            
            vc?.result1 = SkinResultDry
            vc?.resultOil = SkinResultOil
            vc?.resultPigment = SkinResultPigment
            vc?.resultPore = SkinResultPore
            
            vc?.analysis = Analysis.init(sensitivity: self.senstivity, oil: self.oil, dry: self.dry, pore: self.pore, pigment: self.pigment)
            
            //CGFloat 값 전달
            vc?.intSurveyResultVC = intSurveyResultPhotoVC
            vc?.intResult1ResultVC = intResult1PhotoVC
            vc?.intResultOilResultVC = intResultOilPhotoVC
            vc?.intResultPigmentResultVC = intResultPigmentPhotoVC
            vc?.intResultPoreResultVC = intResultPorePhotoVC
        }
    }
    
    
    
    @IBAction func analysis(_ sender: Any) {
        
       
        
        //전면광고 실행
        if self.interstitial != nil {
            self.interstitial?.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        
        
        
        
        
    }
    
    
    
    
    // 버튼 UI
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var openGalleryButton: UIButton!
    
    
    func setUpElements(){
        //Utilities.styleHollowButton(cammerLabel)
        Utilities.styleFilledButton(takePictureButton)
        Utilities.styleFilledButton(openGalleryButton)
        
        
    }
    
    
    
}

// 로그아웃 버튼
//    @IBAction func logout(_ sender: Any) {
//
//
//    do {
//      try Auth.auth().signOut()
//    } catch let signOutError as NSError {
//      print ("Error signing out: %@", signOutError)
//    }
//
//    }
//




extension PhotoVC: UIImageCropperProtocol {
    
    
    // 버튼누르고 crop 이후 변형된 이미지
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        
        self.image.image = croppedImage
        
        
        guard let ciImage = CIImage(image: croppedImage!) else {
            fatalError("couldn't convert to ciimage")
        }
        
        
        //머신러닝 실행
        detect(image : ciImage)
        
        // cropped 이미지를 appDelegate에 저장하여 Asynchronous 방식으로 저장한다
        let img = self.image.image
        let ad = UIApplication.shared.delegate as? AppDelegate
        ad?.imgApp = img
        
    }
    
    //optional
    func didCancel() {
        imagePicker.dismiss(animated: true, completion: nil)
        print("did cancel")
    }
}

