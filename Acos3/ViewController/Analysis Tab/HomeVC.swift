//
//  HomeVC.swift
//  Acos3
//
//  Created by mac on 2021/05/10.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet weak var checkbox1: Checkbox!
    @IBOutlet weak var checkbox2: Checkbox!
    @IBOutlet weak var checkbox3: Checkbox!
    @IBOutlet weak var checkbox4: Checkbox!
    @IBOutlet weak var checkbox5: Checkbox!
    
    
    
    @IBAction func check1(_ sender: Checkbox) {
        update1()
    }
    
    @IBAction func check2(_ sender: Checkbox) {
        update2()
    }
    
    @IBAction func check3(_ sender: Checkbox) {
        update3()
    }
    
    @IBAction func check4(_ sender: Checkbox) {
        update4()
    }
    
    @IBAction func check5(_ sender: Checkbox) {
        update5()
    }

    
    
    
    @IBAction func NextButton(_ sender: Any) {
        
        ButtonSum = resultNum1 + resultNum2 + resultNum3 + resultNum4 + resultNum5
            
        if ButtonSum > 0 {
            transitionToPhotoVC()
        } else {
            let alert = UIAlertController(title: "Check", message: "상태 중 하나를 선택해주세요!", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                   }
            alert.addAction(okAction)
            present(alert, animated: false, completion: nil)
        }
        
        
    }
    
    
    
    
    
    
    // 민감도 결과 넘겨주는 텍스트
    var ButtonSum = 0
    var SenseResult = 0

    var resultNum1 : Int = 0
    var resultNum2 : Int = 0
    var resultNum3 : Int = 0
    var resultNum4 : Int = 0
    var resultNum5 : Int = 0
    
    
    
    // 결과 text값 전달 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotoVC {
            let vc = segue.destination as? PhotoVC
            
            SenseResult = resultNum1 + resultNum2 + resultNum3 + resultNum4 + resultNum5
            let SenseResult2 : String = String(SenseResult)
            
            // ResultVC의 SurveyResult 로 민감도 값인 SenseResult2를 전달
            vc?.SurveyResult = SenseResult2
            
            // int를 CGFloast 타입으로 변환후 전달
            let casting : Array<CGFloat>.ArrayLiteralElement = Array<CGFloat>.ArrayLiteralElement(SenseResult)
            vc?.intSurveyResultPhotoVC = casting
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    
    
    private func update1() {
         if checkbox1.checked {
             //print("1번박스")
            checkbox2.checked = false
            checkbox3.checked = false
            checkbox4.checked = false
            checkbox5.checked = false
            
            resultNum1 = 1
            resultNum2 = 0
            resultNum3 = 0
            resultNum4 = 0
            resultNum5 = 0
            
//            print("1번",resultNum1)
//           print("2번" ,resultNum2)
//            print("3번" ,resultNum3)
//            print("4번" ,resultNum4)
//             print("5번" ,resultNum5)
            
         } else if !checkbox1.checked {
            //print("1번박스 해제")
           checkbox2.checked = false
           checkbox3.checked = false
           checkbox4.checked = false
           checkbox5.checked = false
           resultNum1 -= 1
            
            
           //print(resultNum1)
         }
        
    }
    
    private func update2() {
        
        if checkbox2.checked {
           
           checkbox1.checked = false
           checkbox3.checked = false
           checkbox4.checked = false
           checkbox5.checked = false
           
            resultNum1 = 0
            resultNum2 = 2
            resultNum3 = 0
            resultNum4 = 0
            resultNum5 = 0
            
           
        } else if !checkbox2.checked {
          
          checkbox1.checked = false
          checkbox3.checked = false
          checkbox4.checked = false
          checkbox5.checked = false
          
           resultNum2 -= 2
            
            
       }
        
    }
    
    private func update3() {
        
        if checkbox3.checked {
        
           checkbox1.checked = false
           checkbox2.checked = false
           checkbox4.checked = false
           checkbox5.checked = false
           
            resultNum1 = 0
            resultNum2 = 0
            resultNum3 = 3
            resultNum4 = 0
            resultNum5 = 0
            
            
        } else if !checkbox3.checked {
          
          checkbox1.checked = false
          checkbox2.checked = false
          checkbox4.checked = false
          checkbox5.checked = false
          
          resultNum3 -= 3
         
       }
    }
    
    
    
    private func update4() {
        
        if checkbox4.checked {
           
           checkbox1.checked = false
           checkbox2.checked = false
           checkbox3.checked = false
           checkbox5.checked = false
           
            resultNum1 = 0
            resultNum2 = 0
            resultNum3 = 0
            resultNum4 = 4
            resultNum5 = 0
            
            
        } else if !checkbox4.checked {
          
          checkbox1.checked = false
          checkbox2.checked = false
          checkbox3.checked = false
          checkbox5.checked = false
          
          resultNum4 -= 4
          
       }
    }
    
    
    private func update5() {
        
        if checkbox5.checked {
          
           checkbox1.checked = false
           checkbox2.checked = false
           checkbox4.checked = false
           checkbox3.checked = false
           
            resultNum1 = 0
            resultNum2 = 0
            resultNum3 = 0
            resultNum4 = 0
            resultNum5 = 5
            
            
        } else if !checkbox5.checked {
          
          checkbox1.checked = false
          checkbox2.checked = false
          checkbox4.checked = false
          checkbox3.checked = false
          
          resultNum5 -= 5
          
       }
    }
    

    
    
    
    func transitionToPhotoVC(){
       //  스토리보드의 segue id 로 이동
        self.performSegue(withIdentifier: "ToPhotoVC", sender: nil)
    }
    

}
