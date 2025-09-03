import Foundation
import Tagged
import UUIDV7

// MARK: - PushNotification

public struct PushNotification: Hashable, Sendable {
  public typealias ID = Tagged<Self, UUIDV7>

  public let id: ID
  public var title: String
  public var body: String
  public var schedule: Schedule

  public init(id: ID, title: String, body: String, schedule: Schedule) {
    self.id = id
    self.title = title
    self.body = body
    self.schedule = schedule
  }
}

// MARK: - Schedule

extension PushNotification {
  public enum Schedule: Hashable, Sendable {
    case immediate
    case timeInterval(TimeInterval, repeats: Bool = false)
  }
}
