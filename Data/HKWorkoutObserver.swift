import HealthKit

final actor HKWorkoutObserver {
    private let healthStore: HKHealthStore
    private var workoutObserverQuery: HKObserverQuery?
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    
    func startObserving(onWorkoutFinished: @escaping @Sendable (WorkoutReading) async throws -> Void) async throws {
        try await self.healthStore.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
        self.workoutObserverQuery = HKObserverQuery(
            sampleType: .workoutType(),
            predicate: nil
        ) { [weak self] _, completion, error in
            if let error {
                print("[HKWorkoutObserver] Error: \(error)")
                return
            }
            Task {
                guard let self else { return }
                if let workoutReading = try await self.healthStore.latestWorkout() {
                    try await onWorkoutFinished(workoutReading)
                }
                completion()
            }
        }
        self.healthStore.execute(self.workoutObserverQuery!)
    }
}
