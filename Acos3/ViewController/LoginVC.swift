//
//  LoginVC.swift
//  Acos3
//
//  Created by mac on 2021/05/10.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import AuthenticationServices

import CryptoKit

class LoginVC: UIViewController,GIDSignInDelegate, ASAuthorizationControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet var GooglesignButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
       // GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        // 애플로그인
        self.addButton()
        
        #if DEBUG
        self.emailTextField.text = "t@gmail.com"
      //  self.emailTextField.text = "test1@gmail.com"
        self.emailTextField.text = "test2@naver.com"
        self.emailTextField.text = "test6@naver.com"
        self.passwordTextField.text = "tttt1234!"
        #endif
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        if error != nil {
            // ...로그인 시 오류처리
            
            return
        }
        
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        
        
        
        
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                //...저장시 오류처리
                return
            }
            
            
        }
        
        print("User email : \(user.profile.email ?? "No Email")")
        
        Auth.auth().addStateDidChangeListener({ (user,err) in
            if let user = user.currentUser {
                let params = ["firstname":user.displayName ?? "N/A", "lastname": " ", "uid":user.uid, "email": user.providerData.first?.email ?? "N/A" ] as [String: Any]
                
                Firestore.firestore().collection("user").document(user.uid).updateData(params)
                
                self.transitionToHome()
            }
        })
        
    }
    
    func transitionToHome(){
        //  tabbarController의 스토리보드 id - TabC 로 이동
        let homeViewController =  storyboard?.instantiateViewController(identifier: Constants.Storyboard2.tabBarController) as? UITabBarController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // Validata Text Field
        
        // create cleaned version of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // SignIn in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result,error) in
            
            if error != nil {
                // 에러 표시
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
                
            } else {
                // HomeVC로 이동
                self.transitionToHome()
            }
        }
    }
    
    // 네비게이션 바 보이기
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); navigationController?.setNavigationBarHidden(false, animated: animated) }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); navigationController?.setNavigationBarHidden(true, animated: animated) }
    
    // 버튼 UI 이미지
    func setUpElements() {
        
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
        
    }
    
    // 화면밖으로 터치시 키보드 사라지게
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    //아래부턴 apple로그인
    @IBOutlet weak var ApplesignInView: UIStackView!
    
    func addButton() {
        
        
        let button = ASAuthorizationAppleIDButton(type: .default, style: .whiteOutline)
        button.addTarget(self, action: #selector(loginHandler), for: .touchUpInside)
        
        ApplesignInView.addArrangedSubview(button)
        
        
        
    }
    
    @objc func loginHandler() {
        
        
        //         let request = ASAuthorizationAppleIDProvider().createRequest()
        //        request.requestedScopes = [.fullName, .email]
        //         let controller = ASAuthorizationController(authorizationRequests: [request])
        //         controller.delegate = self
        //         controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        //         controller.performRequests() // 여기서 에러메세지 발생했었슴
        
        
        startSignInWithAppleFlow()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        
        
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            let userIdentifier = appleIDCredential.user
            let firstName = appleIDCredential.fullName?.givenName
            let lastName = appleIDCredential.fullName?.familyName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: appleIDCredential.fullName)) \n Email id is \(String(describing: email))")

            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let err = error {
                    self.showError(with: err.localizedDescription)
                }else if let user = authResult?.user {
                    
                    let params = ["firstname":firstName ?? " ", "lastname": lastName ?? " ", "uid":user.uid, "email": (email ?? user.providerData.first?.email) ?? "N/A" ] as [String: Any]
                    
                    Firestore.firestore().collection("user").document(user.uid).updateData(params)
                    
                    self.transitionToHome()
                }
            }
            
            
            // Reauthenticate current Apple user with fresh Apple credential.
            //            Auth.auth().currentUser?.reauthenticate(with: credential) { (authResult, error) in
            //              //guard error != nil else { return }
            //              // Apple user successfully re-authenticated.
            //              // ...
            //                if (error != nil) {
            //                    print(error?.localizedDescription)
            //                return
            //              }
            //                self.transitionToHome()
            //            }
            //
            //
            
            
            
            
            
            
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "인증 Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        
        
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        
        
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

extension LoginVC : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

