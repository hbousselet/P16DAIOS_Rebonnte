import Foundation
import Firebase

@Observable class MedicineStockViewModel {
    var medicines: [Medicine] = []
    var aisles: [String] = []
    var history: [HistoryEntry] = []
    var alert: String?
    var presentAlert: Bool = false

    private var firestoreService: FirestoreService = FirestoreService()

    @MainActor
    func fetchMedicines() async {
        do {
            for try await medicine: [Medicine] in await firestoreService.stream(reference: .medicines) {
                medicines = medicine
                aisles = Array(Set(medicines.map { $0.aisle })).sorted()
            }
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }

    func fetchHistory(for medicine: Medicine) async {
        guard let medicineId = medicine.id else { return }
        do {
            for try await historyEntry: [HistoryEntry] in await firestoreService.stream(reference: .history, element: medicineId) {
                history.append(contentsOf: historyEntry)
            }
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }

    func updateStock(by value: Int, for medicine: Medicine, and user: String) async {
        guard let id = medicine.id,
            let index = medicines.firstIndex(where: { $0.id == id }) else { return }
        var updatedMedicine = medicine // keep the source of truth from the server
        updatedMedicine.stock += value
        do {
            try await firestoreService.update(model: updatedMedicine, reference: .medicines)
            guard let newHistory = await prepareHistory(by: value, id: id, for: medicines[index], and: user) else { return }
            try await firestoreService.update(model: newHistory, reference: .history)
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
            }
    }

    private func prepareHistory(by value: Int, id: String, for medicine: Medicine, and user: String) async -> HistoryEntry? {
        if value == 0 {
            return HistoryEntry(medicineId: id,
                         user: user,
                         action: "Updated \(medicine.name)",
                         details: "Updated medicine details")
        } else {
            return HistoryEntry(medicineId: id,
                         user: user,
                         action: "\(value > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(value)",
                         details: "Stock changed from \(medicine.stock - value) to \(medicine.stock)")
        }

    }


    //TODO: need to be removed
    func addRandomMedicine(user: String) async {
        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))", stock: Int.random(in: 1...100), aisle: "Aisle \(Int.random(in: 1...10))")
        let historyEntry = HistoryEntry(medicineId: medicine.id ?? "",
                                        user: user,
                                        action: "Added \(medicine.name)",
                                        details: "Added new medicine")
        do {
            try await firestoreService.update(model: medicine, reference: .medicines)
            try await firestoreService.update(model: historyEntry, reference: .history)
        } catch let error {
            // to do implement the error via an alert
        }
    }

    //TODO: need to be implemented
    func deleteMedicines(at offsets: IndexSet) async {
//        offsets.map { medicines[$0] }.forEach { medicine in
//            if let id = medicine.id {
//                do {
//                    try await firestoreService.delete(id: id)
//                } catch {
//
//                }
//
//            }
//        }
    }
}
