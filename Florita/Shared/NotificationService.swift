import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    private init() {}

    func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            Task { @MainActor in
                try? await self.center.requestAuthorization(options: [.alert, .badge])
            }
        }
    }

    func scheduleCareReminder(at date: Date) {
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.careReminder])

        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = Localization.string("notification_title")
        content.body = Localization.string("notification_body")
        content.sound = nil

        let request = UNNotificationRequest(identifier: Identifiers.careReminder, content: content, trigger: trigger)
        center.add(request)
    }

    private enum Identifiers {
        static let careReminder = "florita.careReminder"
    }
}
