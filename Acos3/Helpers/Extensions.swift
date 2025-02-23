//
//  Extensions.swift
//  Acos3
//
//  Created by Nasrullah Khan on 02/07/2021.
//

import UIKit
import SVProgressHUD
import FirebaseFirestore
import CodableFirebase

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Date{
    func toString(format:String, timezone:TimeZone? = nil)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: self)
    }
}

extension Array where Element: BinaryFloatingPoint {

    /// The average value of all the items in the array
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}

extension UIViewController {
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            loginViewController.modalPresentationStyle = .formSheet
            loginViewController.isModalInPresentation = true
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    func showHomeVC(){
        //  tabbarController의 스토리보드 id - TabC 로 이동
        let homeViewController =  storyboard?.instantiateViewController(identifier: Constants.Storyboard2.tabBarController) as? UITabBarController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func showError(with message: String){
        let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        self.present(alert, animated: true, completion: nil)
    }

    func prompt(title: String = String.init(), message: String = String.init()){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func prompt(title:String = String.init(), message: String, okClick: @escaping ()->Void ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            okClick()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- LOADER
extension UIApplication {
    static func setupHud(){
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setMaximumDismissTimeInterval(1)
    }
    static func showLoader(message : String? = nil){
        DispatchQueue.main.async {
            if let msg = message{
                SVProgressHUD.show(withStatus: msg)
            }else{
                SVProgressHUD.show(withStatus: message)
            }
        }
    }
    static func hideLoader(delay : Int = 0){
        DispatchQueue.main.async {
            SVProgressHUD.dismiss(withDelay: TimeInterval(delay))
        }
    }
    static func showSuccess(message : String? = nil, delay : Int? = nil){
        DispatchQueue.main.async {
            if let msg = message{
                SVProgressHUD.showSuccess(withStatus: msg)
            }else{
                SVProgressHUD.showSuccess(withStatus: message)
            }
            if let delay = delay { hideLoader(delay: delay) }
        }
    }
    static func showError(message : String? = nil, delay : Int? = nil){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if let msg = message{
                SVProgressHUD.showError(withStatus: msg)
            }else{
                SVProgressHUD.showError(withStatus: message)
            }
            if let delay = delay { hideLoader(delay: delay) }
        })
    }
}


