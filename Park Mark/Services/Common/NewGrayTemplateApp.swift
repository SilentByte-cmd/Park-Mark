import SwiftUI
import BackgroundTasks

struct NewGrayTemplateApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            GrayView()
        }
    }

}




