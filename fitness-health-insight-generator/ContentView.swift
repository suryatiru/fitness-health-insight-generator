import SwiftUI
import HealthKit
import Tagged
import UUIDV7

struct ContentView: View {
    @State private var observer = HKWorkoutObserver(healthStore: .shared)
    @State private var scheduler = UNUserNotifications(center: .current())
    @State private var latestWorkout: HKWorkout?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            if latestWorkout != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Workout").font(.headline)
                                Text("Type: \(String(describing: latestWorkout?.workoutActivityType))")
                                Text("Duration: \((latestWorkout?.duration ?? 0) / 60, specifier: "%.1f") min")
                            }
                            .padding()
                        } else {
                            Text("No workouts observed yet")
                                .foregroundStyle(.secondary)
                        }
        }
        .padding()
        .task {
            try? await HKHealthStore.shared.requestPermissions()
            _ = try? await scheduler.request()
            _ = try? await observer.startObserving { reading in
                latestWorkout = try await reading.asHKWorkout(healthStore: .shared)
                let notification = PushNotification(id: PushNotification.ID(
                    rawValue: UUIDV7()),
                    title: "Look at it!!!",
                    body: "Nice Work! You had 10% improvement from a similar workout.",
                    schedule: .immediate)
                _ = try await scheduler.schedule(notification)
            }
        }
    }
}

#Preview {
    ContentView()
}

// observer.startObserving will provide the data ( _ )
// Assign that value to a state variable
// UI to show the data
