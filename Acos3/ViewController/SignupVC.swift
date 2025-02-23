//
//  SignupVC.swift
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

class SignupVC: UIViewController,GIDSignInDelegate,ASAuthorizationControllerDelegate {
    
    @IBOutlet weak var FirstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet var GooglesignButton: GIDSignInButton!
    
    
    // 화면밖으로 터치시 키보드 사라지게
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.FirstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passWordTextField.resignFirstResponder()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
      //  GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        addButton()
        
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
        
        
        
        Auth.auth().addStateDidChangeListener({ (user,err) in
          
            if let user = user.currentUser {
                let params = ["firstname":user.displayName ?? "N/A", "lastname": " ", "uid":user.uid, "email": user.providerData.first?.email ?? "N/A" ] as [String: Any]
                
                Firestore.firestore().collection("user").document(user.uid).setData(params)
                
                self.transitionToOnboardVC()
            }
        })
        
    }
    
    // 네비게이션 바 보이기
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); navigationController?.setNavigationBarHidden(false, animated: animated) }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); navigationController?.setNavigationBarHidden(true, animated: animated) }
    
    
    
    
    func setUpElements() {
        
        
        errorLabel.alpha = 0
        
        Utilities.styleTextField(FirstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passWordTextField)
        Utilities.styleFilledButton(signUpButton)
        
    }
    
    
    // check the fields and validate that the data is correct
    func validateFields() -> String? {
        // Check that all fields are filled in
        if FirstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passWordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            
            return "공백을 채워주세요!( Please fill in all fields)"
        }
        
        // Check if the password is secure
        let cleanedPassword = passWordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "비밀번호는 8자리 이상,특수문자와 숫자를 포함해야해요! (Password shoud be least 8 characters, contains a special character and a number)"
        }
        
        
        return nil
    }
    
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        // validate the field
        let error = validateFields()
        if error != nil {
            // There's something wrong with the fields, show error message
            showError(error!)
            
        } else {
            
            // cleand version of data
            let firstName = FirstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastNmae = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passWordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            
            // create the user - 구글공식문서
            
            Auth.auth().createUser(withEmail: email, password: password) { (result,err) in
                
                // ...
                if err != nil {
                    // 에러발생
                    self.showError("올바른 E-mail 형식을 넣어주세요")
                } else if let userId = result?.user.uid, let email = result?.user.email {
                    // 성공적으로 아이디 생성
                    let db = Firestore.firestore()
                    
                    //firestore에 key value값을 생성한곳에 넣는다
                    
                    let params = ["firstname":firstName, "lastname":lastNmae, "uid":userId, "email": email ] as [String: Any]
                    
                    db.collection("user").document(userId).setData(params) { (error) in
                        
                        // 에러발생
                        if error != nil {
                            // show error message
                            self.showError("Error saving user data")
                        }
                    }
                    
                    // transition to the homescreen
                    self.transitionToOnboardVC()
                    
                }
            }
        }
        //
    }
    
    
    
    
    func showError(_ message : String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    
    
    func transitionToOnboardVC(){
        //  스토리보드의 segue id 로 이동
        
        self.performSegue(withIdentifier: "OnboardSegue", sender: nil)
    }
    
    
    
    //애플 회원가입
    
    
    @IBOutlet weak var ApplesignUpview: UIStackView!
    
    
    
    func addButton() {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        button.addTarget(self, action: #selector(loginHandler), for: .touchUpInside)
        
        ApplesignUpview.addArrangedSubview(button)
        
    }
    
    
    @objc func loginHandler() {
        startSignInWithAppleFlow()
    }
    
    
    
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
                    print("provider data email = ", user.providerData.first?.email)
                    print("provider data = ", user.providerData)
                    let params = ["firstname":firstName ?? " ", "lastname": lastName ?? " ", "uid":user.uid, "email": email ?? user.providerData.first?.email ?? "N/A" ] as [String: Any]
                    
                    Firestore.firestore().collection("user").document(user.uid).setData(params)
                    
                    self.transitionToOnboardVC()
                }
            }
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
    
    
    
    
    
    
    
    //
}




extension SignupVC : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}


