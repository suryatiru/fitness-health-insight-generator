import Foundation

extension PushNotification {
  public protocol Scheduler: Sendable {
    func schedule(_ notification: PushNotification) async throws
  }
}
