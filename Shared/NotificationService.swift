import Foundation
import UserNotifications

/// Handles notification permissions and scheduling gentle care reminders.
@MainActor
final class ReminderNotificationService {
    /// Shared singleton used across the application layers.
    static let shared = ReminderNotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    /// Requests notification authorization when the current status is undetermined.
    func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            Task { @MainActor in
                try? await self.center.requestAuthorization(options: [.alert, .badge])
            }
        }
    }

    /// Schedules a single reminder encouraging the user to water Florita.
    /// - Parameter date: Target time for the reminder notification.
    func scheduleCareReminder(at date: Date) {
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.careReminder])

        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = FloritaLocalization.localizedString("notification_title")
        content.body = FloritaLocalization.localizedString("notification_body")
        content.sound = nil

        let request = UNNotificationRequest(identifier: Identifiers.careReminder, content: content, trigger: trigger)
        center.add(request)
    }

    private enum Identifiers {
        static let careReminder = "florita.careReminder"
    }
}
