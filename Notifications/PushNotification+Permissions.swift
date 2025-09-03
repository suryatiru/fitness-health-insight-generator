// MARK: - PermissionStatus

extension PushNotification {
  public enum PermissionStatus: Equatable, Sendable {
    case notDetermined
    case provisional
    case denied
    case authorized
    case ephemeral
  }
}

// MARK: - Permissions

extension PushNotification {
  public protocol Permissions {
    func status() async throws -> PermissionStatus
    func request() async throws -> PermissionStatus
  }
}
