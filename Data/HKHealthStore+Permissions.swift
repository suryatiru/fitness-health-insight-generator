import HealthKit

extension HKHealthStore {
    func requestPermissions() async throws {
        try await self.requestAuthorization(toShare: [], read: [.workoutType()])
    }
}
