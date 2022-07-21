import SwiftUI
import UserNotifications
import Asterism

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
  
  static let keychain = KeychainSwift()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("D'oh: \(error.localizedDescription)")
      } else {
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
          UNUserNotificationCenter.current().setNotificationCategories(AppDelegate.categories)
        }
      }
    }
    UNUserNotificationCenter.current().delegate = self
    
    Self.keychain.set("1234567890", forKey: "1", withAccess: .accessibleWhenUnlocked)
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Token: \(token)")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error.localizedDescription)
  }
}

@main
struct ActionablePushExampleApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

extension AppDelegate {
  static var categories: Set<UNNotificationCategory> {
    var categories = Set<UNNotificationCategory>()
    let yesAction = UNNotificationAction(identifier: "Yes", title: "Yes")
    let noAction = UNNotificationAction(identifier: "No", title: "No")
    categories.insert(UNNotificationCategory(identifier: "YesNo", actions: [yesAction, noAction], intentIdentifiers: []))
    return categories
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    guard let userinfo = response.notification.request.content.userInfo as? [String: AnyObject] else {
      completionHandler()
      return
    }
    
    switch response.actionIdentifier {
    case "Yes":
      guard let value = Self.keychain.get("1") else {
        let pushRequest = PushRequest(dataToSend: "Unable to access Keychain")
        Networking.send(pushRequest)
        completionHandler()
        return
      }
      let pushRequest = PushRequest(dataToSend: value)
      Networking.send(pushRequest)
    case "No":
      let pushRequest = PushRequest(dataToSend: "No")
      Networking.send(pushRequest)
    default:
      print("Other Action")
    }
    
    
    print(userinfo)
    completionHandler()
  }
}
