//
//  AppDelegate.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 05/07/25.
//
import UIKit
import Firebase
//import FirebaseMessaging
import GoogleSignIn

class AppDelegate: UIResponder, UIApplicationDelegate/*, UNUserNotificationCenterDelegate, MessagingDelegate*/ {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        /*
        // 🔔 Richiesta registrazione alle notifiche
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self*/
        
        
        
        return true
    }
    
    
    // ✅ Questo viene chiamato da iOS una volta ottenuto il token APNS
    /*func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Fallita registrazione APNS: \(error.localizedDescription)")
    }*/
    
    

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
