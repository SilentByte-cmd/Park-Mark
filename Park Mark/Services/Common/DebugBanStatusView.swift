import SwiftUI

struct DebugBanStatusView: View {
    @State private var isBanned: Bool?
    @State private var pushCount: Int = 0
    @State private var pendingNotifications: Int = 0
    @State private var lastCheck: Date?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Ban Status Section
                Section {
                    if let banned = isBanned {
                        HStack {
                            Text("Забанено:")
                            Spacer()
                            Text(banned ? "ДА ⚠️" : "НЕТ ✅")
                                .foregroundColor(banned ? .red : .green)
                                .bold()
                        }
                    } else {
                        HStack {
                            Text("Статус:")
                            Spacer()
                            Text("Неизвестно")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let lastCheck = lastCheck {
                        HStack {
                            Text("Последняя проверка:")
                            Spacer()
                            Text(lastCheck, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Последняя проверка:")
                            Spacer()
                            Text("Никогда")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("Статус бана", systemImage: "shield.fill")
                }
                
                // MARK: - Storage Section
                Section {
                    HStack {
                        Label("Сохранено пушей", systemImage: "envelope.fill")
                        Spacer()
                        Text("\(pushCount) / 60")
                            .bold()
                            .foregroundColor(pushCount >= 55 ? .orange : .primary)
                    }
                    
                    HStack {
                        Label("Запланировано", systemImage: "clock.fill")
                        Spacer()
                        Text("\(pendingNotifications)")
                            .bold()
                            .foregroundColor(.blue)
                    }
                    
                    if pushCount > 0 {
                        NavigationLink {
                            StoredPushesListView()
                        } label: {
                            Label("Просмотр пушей", systemImage: "list.bullet")
                        }
                    }
                } header: {
                    Label("Хранилище", systemImage: "internaldrive.fill")
                } footer: {
                    Text("iOS лимит: 64 local notifications. Мы планируем максимум 60.")
                        .font(.caption)
                }
                
                // MARK: - Actions Section
                Section {
                    Button(action: checkNow) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Label("Проверить сейчас", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(isLoading)
                    
                    Button(role: .destructive, action: clearStorage) {
                        Label("Очистить хранилище", systemImage: "trash.fill")
                    }
                } header: {
                    Label("Действия", systemImage: "bolt.fill")
                }
                
                // MARK: - Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🔍 Проверка бана происходит только при запуске приложения")
                        Text("📱 Background tasks отключены для экономии батареи")
                        Text("🔄 Локальные пуши работают по расписанию от сервера")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                } header: {
                    Label("Информация", systemImage: "info.circle.fill")
                }
            }
            .navigationTitle("🔍 Ban Status Debug")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadData)
            .alert("Результат", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Load Data
    private func loadData() {
        pushCount = PushStorageService.shared.getPushCount()
        lastCheck = BanStatusService.shared.getLastCheckTime()
        
        LocalNotificationScheduler.shared.getPendingNotificationsCount { count in
            DispatchQueue.main.async {
                self.pendingNotifications = count
            }
        }
    }
    
    // MARK: - Check Now
    private func checkNow() {
        isLoading = true
        BackgroundTaskManager.shared.performManualBanCheck { banned, success in
            DispatchQueue.main.async {
                self.isBanned = banned
                self.isLoading = false
                
                if success {
                    if banned {
                        self.alertMessage = "⚠️ Приложение ЗАБАНЕНО!\n\nЗапланированы local notifications для показа пушей."
                    } else {
                        self.alertMessage = "✅ Приложение НЕ забанено.\n\nВсё работает нормально."
                    }
                } else {
                    self.alertMessage = "❌ Ошибка при проверке.\n\nПроверьте подключение к интернету."
                }
                
                self.showAlert = true
                self.loadData()
            }
        }
    }
    
    // MARK: - Clear Storage
    private func clearStorage() {
        PushStorageService.shared.clearAll()
        LocalNotificationScheduler.shared.cancelAllScheduledNotifications()
        
        alertMessage = "🗑️ Хранилище очищено!\n\nВсе сохранённые пуши и запланированные нотификации удалены."
        showAlert = true
        
        loadData()
    }
}

// MARK: - Stored Pushes List View
struct StoredPushesListView: View {
    @State private var pushes: [StoredPush] = []
    
    var body: some View {
        List {
            ForEach(Array(pushes.enumerated()), id: \.element.id) { index, push in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("#\(index + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(push.receivedAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let title = push.title {
                        Text(title)
                            .font(.headline)
                    }
                    
                    if let body = push.body {
                        Text(body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let badge = push.badge {
                        HStack {
                            Image(systemName: "app.badge.fill")
                                .font(.caption)
                            Text("Badge: \(badge)")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Сохранённые пуши")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            pushes = PushStorageService.shared.loadPushes()
        }
    }
}

// MARK: - Preview
#Preview {
    DebugBanStatusView()
}


