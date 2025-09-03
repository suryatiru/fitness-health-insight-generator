import HealthKit

let healthStore = HKHealthStore()

func fetchActiveEnergyBurned(completion: @escaping (Double?, Error?) -> Void) {
    guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
        completion(nil, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Energy type unavailable"]))
        return
    }

    let startOfDay = Calendar.current.startOfDay(for: Date())
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
    
    let query = HKStatisticsQuery(
        quantityType: energyType,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
    ) { _, result, error in
        guard let result = result,
              let sum = result.sumQuantity() else {
            completion(nil, error)
            return
        }
        let calories = sum.doubleValue(for: .kilocalorie())
        completion(calories, nil)
    }
    
    healthStore.execute(query)
}

