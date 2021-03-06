//
//  AppDelegate.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 03/05/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    let userDefault = UserDefaults()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()

        //Cloud FireStore
//        let db = Firestore.firestore()
        
        //Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        

        
        return true
    }
    

    
//    ACCESS and DISCONNECT GOOGLE ACCOUNT
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        return
      }else{
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
            
        Auth.auth().signIn(with: credential){ (result,error) in
            if error == nil{
                print(result?.user.email)
                print(result?.user.displayName)
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                self.window?.rootViewController?.performSegue(withIdentifier: "Segue_To_SignIn_Social", sender: nil)
            }else{
                print(error?.localizedDescription)
            }
            
            let newUserReference = Firestore.firestore().collection("Users").document(((result?.user.uid)!))    // <-- create a document, with the user id from Firebase Auth

            newUserReference.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    newUserReference.updateData([
                                    "ID": result?.user.uid,
                                    "nickname": result?.user.displayName,
                                    "email": result?.user.email,
                                    "registrazione" : "Google",
                                    "timestamp": Timestamp()
                    //                "image": result?.user.photoURL
                                    ])
                } else {
                    print("Document does not exist")
                    newUserReference.setData([
                                    "ID": result?.user.uid,
                                    "nickname": result?.user.displayName,
                                    "email": result?.user.email,
                                    "registrazione" : "Google",
                                    "timestamp": Timestamp()
                    //                "image": result?.user.photoURL
                                    ])
                }
            }
            
        }

        }
//      // Perform any operations on signed in user here.
//      let userId = user.userID                  // For client-side use only!
//      let idToken = user.authentication.idToken // Safe to send to the server
//      let fullName = user.profile.name
//      let givenName = user.profile.givenName
//      let familyName = user.profile.familyName
//      let email = user.profile.email
      // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    
    
//    GOOGLE FUNCTION
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let googleDidHandle2 = GIDSignIn.sharedInstance().handle(url)
        let facebookDidHandle2 = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return googleDidHandle2 || facebookDidHandle2
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url)
        let facebookDidHandle = ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return googleDidHandle || facebookDidHandle
    }
    
//    ALTRO

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}



//guard let authentication = user.authentication else { return }
//let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                  accessToken: authentication.accessToken)
