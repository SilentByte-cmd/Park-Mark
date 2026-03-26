import SwiftUI
import WebKit
import SwiftData

struct Loading: View {
    
    @Binding var isLoading: Bool
    
    
    @State var url: String? = nil
    @State var webViewConfig: WebViewConfiguration = WebViewConfiguration()
    @State var dynamicBackgroundColor: Color? = nil
    
    var body: some View {
        ZStack {
            if(url == nil){
//                ProgressView("Loading...")
            } else {
                // Динамічний фон згідно конфігурації
                if webViewConfig.ui.webViewBackgroundColor == "auto" {
                    // Автоматичний колір - використовуємо динамічний колір з WebView
                    if let dynamicColor = dynamicBackgroundColor {
                        dynamicColor.ignoresSafeArea()
                    } else if #available(iOS 15.0, *) {
                        Color.clear.ignoresSafeArea()
                    } else {
                        Color(.systemBackground).ignoresSafeArea()
                    }
                } else if let bgColor = webViewConfig.ui.webViewBackgroundColor {
                    // Hex колір з сервера
                    Color(hex: bgColor).ignoresSafeArea()
                }
                
                SwiftUIWebView(url: URL(string: url!)!, configuration: webViewConfig)
                    .ignoresSafeArea(.all) // Ігноруємо safe area для edge-to-edge layout
                    .id(webViewConfig.ui.webViewBackgroundColor ?? "auto") // Перестворюємо при зміні конфігурації
            }
        }.onAppear {
            // Завантажуємо збережену конфігурацію
            webViewConfig = DataCollectorAttribution.shared.loadWebViewConfiguration()
            
            NotificationCenter.default.addObserver(forName: .serverResponseReceived, object: nil, queue: .main) { notification in
                if let response = notification.object as? String {
                   // ПЕРЕХОД В WEBVIEW с линком response
                    logPrint(response)
                    url = response
                } else {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
            }
            
            // Слухаємо оновлення конфігурації
            NotificationCenter.default.addObserver(forName: .webViewConfigurationUpdated, object: nil, queue: .main) { notification in
                if let updatedConfig = notification.object as? WebViewConfiguration {
                    logPrint("🔄 WebView config updated in ContentView")
                    logPrint("🎨 New background color: \(updatedConfig.ui.webViewBackgroundColor ?? "auto")")
                    webViewConfig = updatedConfig
                }
            }
            
            // Слухаємо зміни кольору сторінки
            NotificationCenter.default.addObserver(forName: .pageBackgroundColorChanged, object: nil, queue: .main) { notification in
                if let color = notification.object as? UIColor {
                    logPrint("🎨 ContentView received page background color: \(color)")
                    dynamicBackgroundColor = Color(uiColor: color)
                }
            }
        }
    }
}
