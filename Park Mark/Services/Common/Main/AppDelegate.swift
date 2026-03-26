import SwiftUI
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    static var shared: AppDelegate?
    let domain: String = "https://parkmark.space"
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        DataCollectorAttribution.shared.initialize(appID: "id6761077806", decryptionKey: "fA2tM5pL8xM2nK1vR7qZ4yJ9bS0wG3hD", endpoint: "https://parkmark.space/info") { initialized in
            // ✅ Проверяем бан статус ПОСЛЕ получения конфига
            if initialized {
                print("✅ [AppDelegate] Config loaded, checking ban status...")
                self.checkBanStatusOnLaunch()
            }
        }
        
        DataCollectorAttribution.shared.requestPermissions()
        
        // 📸 Debug easter egg initialization (3 screenshots in 3 sec - activated if server sends debugModeEnabled = true)
        _ = DebugScreenshotHelper.shared
        
        // ❌ Background Task УДАЛЕН: синхронизация только при входе в приложение
        // Проверка бана происходит в checkBanStatusOnLaunch() после загрузки конфига
        
        return true
    }
    
    // MARK: - Ban Status Check on Launch
    private func checkBanStatusOnLaunch() {
        print("🔍 [AppDelegate] Checking ban status on launch...")
        
        BackgroundTaskManager.shared.performManualBanCheck { isBanned, success in
            if isBanned {
                print("⚠️ [AppDelegate] App is BANNED - local notifications scheduled")
            } else {
                print("✅ [AppDelegate] App is NOT banned")
            }
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        DataCollectorAttribution.shared.setPushToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo

        if let data = userInfo as? [String: Any], let pushId = data["pushId"] as? String {
            let id = pushId
            sendDeliveredEvent(pushId: id)
        }
        
        // 💾 Save push to storage (for potential ban scenario)
        savePushToStorage(notification: notification.request)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
     
        let userInfo = response.notification.request.content.userInfo
        

        
        if let data = userInfo as? [String: Any], let pushId = data["pushId"] as? String {
            let id = pushId
            sendOpenedEvent(pushId: id)
        }
        
        completionHandler()
    }
    
    private func sendDeliveredEvent(pushId: String) {
            let urlString = "\(domain)/push-event/\(pushId)/delivered"
            logPrint(urlString)
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    return
                }
                
                if let responseString = String(data: data ?? Data(), encoding: .utf8) {
//                                   logPrint("Full response string:\n\(responseString)")
                               }
                
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    
                }
            }
            task.resume()
        }
    
    private func sendOpenedEvent(pushId: String) {
            let urlString = "\(domain)/push-event/\(pushId)/opened"
            logPrint(urlString)
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    return
                }
                
                if let responseString = String(data: data ?? Data(), encoding: .utf8) {
//                            logPrint("Full response string:\n\(responseString)")
                }
                
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {

                }
            }
            task.resume()
        }
    
    // MARK: - Save Push to Storage
    private func savePushToStorage(notification: UNNotificationRequest) {
        let storedPush = StoredPush(from: notification)
        PushStorageService.shared.savePush(storedPush)
        print("💾 [AppDelegate] Saved push to storage: \(storedPush.title ?? "No title")")
    }

}
