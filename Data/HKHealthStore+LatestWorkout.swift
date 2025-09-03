import Foundation
import HealthKit

extension HKHealthStore: WorkoutReading.LatestReader {
    func latestWorkout() async throws -> WorkoutReading? {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout()],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )
        return try await descriptor.result(for: self).first.map {
            .init(workout: $0)
        }
    }
}

extension WorkoutReading {
    init(workout: HKWorkout) {
        self.init(
            id: workout.uuid,
            dateInterval: DateInterval(start: workout.startDate, end: workout.endDate),
            activityType: ActivityOptions(hkType: workout.workoutActivityType),
            totalEnergyActive: workout.statistics(for: .quantityType(forIdentifier:
                .activeEnergyBurned)!)?
                .sumQuantity()?
                .doubleValue(for: .largeCalorie())
        )
    }
}

extension WorkoutReading.ActivityOptions {
    init(hkType: HKWorkoutActivityType) {
        switch hkType {
        // --- Strength-related workouts
        case .traditionalStrengthTraining,
             .functionalStrengthTraining,
             .pilates,
             .yoga,
             .flexibility,
             .coreTraining,
             .barre:
            self = .strength

        // --- HIIT & cardio-intensive workouts
        case .highIntensityIntervalTraining,
             .running,
             .walking,
             .cycling,
             .rowing,
             .elliptical,
             .stairClimbing,
             .hiking,
             .swimming,
             .crossTraining,
             .cardioDance,
             .kickboxing,
             .martialArts,
             .boxing,
             .mixedCardio,
             .skatingSports,
             .snowSports,
             .surfingSports,
             .paddleSports:
            self = .hiit

        // --- Any unhandled type → default bucket
        default:
            self = .hiit
        }
    }
}
