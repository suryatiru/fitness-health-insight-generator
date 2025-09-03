import Foundation
import HealthKit

struct WorkoutReading: Sendable, Hashable, Identifiable {
    let id: UUID
    let dateInterval: DateInterval
    let activityType: ActivityOptions // HIIT or Strength
    let totalEnergyActive: Double?        // kilocalories
}

extension WorkoutReading {
    enum ActivityOptions: String {
        case strength
        case hiit
    }
}

extension WorkoutReading {
    protocol LatestReader {
        func latestWorkout() async throws -> WorkoutReading?
    }
}

extension WorkoutReading {
    func asHKWorkout(healthStore: HKHealthStore) async throws -> HKWorkout {
        // 1. Map custom type to HKWorkoutActivityType
        let hkActivityType: HKWorkoutActivityType
        switch activityType {
        case .strength:
            hkActivityType = .traditionalStrengthTraining
        case .hiit:
            hkActivityType = .highIntensityIntervalTraining
        }

        // 2. Create configuration
        let config = HKWorkoutConfiguration()
        config.activityType = hkActivityType

        // 3. Create a builder
        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: config,
            device: .local()
        )

        // 4. Begin session
        try await builder.beginCollection(at: dateInterval.start)

        // 5. End session
        try await builder.endCollection(at: dateInterval.end)

        // 6. Add quantities (e.g. calories)
        if let totalEnergyActive {
            let energyQuantity = HKQuantity(unit: .kilocalorie(),
                                            doubleValue: totalEnergyActive)

            let sample = HKQuantitySample(
                type: HKQuantityType(.activeEnergyBurned),
                quantity: energyQuantity,
                start: dateInterval.start,
                end: dateInterval.end
            )

            try await builder.add([sample], completion: { _, _ in })
        }

        // 7. Finish workout
        let workout = try await builder.finishWorkout()
        return workout!

    }
}



