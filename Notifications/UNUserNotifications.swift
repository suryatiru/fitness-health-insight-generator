import Foundation
import UserNotifications

// MARK: - UNUserNotifications

public final actor UNUserNotifications {
  public static let shared = UNUserNotifications(center: .current())
  
  private let center: UNUserNotificationCenter

  public init(center: sending UNUserNotificationCenter) {
    self.center = center
  }
}

// MARK: - PushNotification.Scheduler

extension UNUserNotifications: PushNotification.Scheduler {
  public func schedule(_ notification: PushNotification) async throws {
    let content = UNMutableNotificationContent()
    content.title = notification.title
    content.body = notification.body

    let trigger: UNNotificationTrigger?
    switch notification.schedule {
    case .immediate:
      trigger = nil
    case let .timeInterval(interval, repeats):
      trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: max(interval, 1),
        repeats: repeats
      )
    }

    let request = UNNotificationRequest(
      identifier: notification.id.rawValue.uuidString,
      content: content,
      trigger: trigger
    )
    try await self.center.add(request)
  }
}

// MARK: - PushNotification.Permissions

extension UNUserNotifications: PushNotification.Permissions {
  public func status() async throws -> PushNotification.PermissionStatus {
    switch await self.center.notificationSettings().authorizationStatus {
    case .notDetermined: .notDetermined
    case .denied: .denied
    case .authorized: .authorized
    case .provisional: .provisional
    case .ephemeral: .ephemeral
    @unknown default: .notDetermined
    }
  }

  public func request() async throws -> PushNotification.PermissionStatus {
    let isGranted = try await self.center.requestAuthorization(options: [.alert, .sound, .badge])
    return isGranted ? .authorized : .notDetermined
  }
}
