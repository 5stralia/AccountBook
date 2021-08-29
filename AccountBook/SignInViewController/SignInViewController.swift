//
//  SignInViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import FBSDKLoginKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController {
    @IBOutlet weak var facebookButtonContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let facebookButton = FBLoginButton()
        facebookButton.delegate = self
        self.facebookButtonContainer.addSubview(facebookButton)
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            facebookButton.leadingAnchor.constraint(equalTo: self.facebookButtonContainer.leadingAnchor),
            facebookButton.topAnchor.constraint(equalTo: self.facebookButtonContainer.topAnchor),
            facebookButton.trailingAnchor.constraint(equalTo: self.facebookButtonContainer.trailingAnchor),
            facebookButton.bottomAnchor.constraint(equalTo: self.facebookButtonContainer.bottomAnchor)
        ])
    }
    
    @IBAction func signInWithGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                // ...
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    let authError = error as NSError
                    //                  if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        // The user is a multi-factor user. Second factor challenge is required.
                        let resolver = authError
                            .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        var displayNameString = ""
                        for tmpFactorInfo in resolver.hints {
                            displayNameString += tmpFactorInfo.displayName ?? ""
                            displayNameString += " "
                        }
                        self.showTextInputPrompt(
                            withMessage: "Select factor to sign in\n\(displayNameString)",
                            completionBlock: { userPressedOK, displayName in
                                var selectedHint: PhoneMultiFactorInfo?
                                for tmpFactorInfo in resolver.hints {
                                    if displayName == tmpFactorInfo.displayName {
                                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                                    }
                                }
                                PhoneAuthProvider.provider()
                                    .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                                       multiFactorSession: resolver
                                                        .session) { verificationID, error in
                                        if error != nil {
                                            print(
                                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                                            )
                                        } else {
                                            self.showTextInputPrompt(
                                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                                completionBlock: { userPressedOK, verificationCode in
                                                    let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                                        .credential(withVerificationID: verificationID!,
                                                                    verificationCode: verificationCode!)
                                                    let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                                        .assertion(with: credential!)
                                                    resolver.resolveSignIn(with: assertion!) { authResult, error in
                                                        if error != nil {
                                                            print(
                                                                "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                                            )
                                                        } else {
                                                            self.navigationController?.popViewController(animated: true)
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                            }
                        )
                    } else {
                        self.showMessagePrompt(error.localizedDescription)
                        return
                    }
                    // ...
                    return
                }
                // User is signed in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    /*! @fn showTextInputPromptWithMessage
     @brief Shows a prompt with a text field and 'OK'/'Cancel' buttons.
     @param message The message to display.
     @param completion A block to call when the user taps 'OK' or 'Cancel'.
     */
    func showTextInputPrompt(withMessage message: String,
                             completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = weakPrompt?.textFields?.first?.text else { return }
            completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    private func showMessagePrompt(_ message: String) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        prompt.addAction(okAction)
        self.present(prompt, animated: true, completion: nil)
    }
    
}

extension SignInViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let credential = FacebookAuthProvider
          .credential(withAccessToken: AccessToken.current!.tokenString)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
              if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                // The user is a multi-factor user. Second factor challenge is required.
                let resolver = authError
                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                var displayNameString = ""
                for tmpFactorInfo in resolver.hints {
                  displayNameString += tmpFactorInfo.displayName ?? ""
                  displayNameString += " "
                }
                self.showTextInputPrompt(
                  withMessage: "Select factor to sign in\n\(displayNameString)",
                  completionBlock: { userPressedOK, displayName in
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                      if displayName == tmpFactorInfo.displayName {
                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                      }
                    }
                    PhoneAuthProvider.provider()
                      .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                         multiFactorSession: resolver
                                           .session) { verificationID, error in
                        if error != nil {
                          print(
                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
                          )
                        } else {
                          self.showTextInputPrompt(
                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                            completionBlock: { userPressedOK, verificationCode in
                              let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                .credential(withVerificationID: verificationID!,
                                            verificationCode: verificationCode!)
                              let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                .assertion(with: credential!)
                              resolver.resolveSignIn(with: assertion!) { authResult, error in
                                if error != nil {
                                  print(
                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                  )
                                } else {
                                  self.navigationController?.popViewController(animated: true)
                                }
                              }
                            }
                          )
                        }
                      }
                  }
                )
              } else {
                self.showMessagePrompt(error.localizedDescription)
                return
              }
              // ...
              return
            }
            // User is signed in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
