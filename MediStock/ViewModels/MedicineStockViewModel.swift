import Foundation
import Firebase

@Observable class MedicineStockViewModel {
    var medicines: [Medicine] = []
    var aisles: [String] = []
    var history: [HistoryEntry] = []
    var alert: String?
    var presentAlert: Bool = false

    private var firestoreService: FirestoreService = FirestoreService()

    var currentUser: String? {
        FirebaseAuth.Auth.auth().currentUser?.uid
    }

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

    @MainActor
    func fetchHistory(for medicine: Medicine) async {
        do {
            for try await historyEnt: [HistoryEntry] in await firestoreService.stream(reference: .history, element: medicine.id) {
                history = historyEnt
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
            guard let newHistory = await prepareHistory(by: value, action: .operation, id: id, for: medicines[index], and: user) else { return }
            let _ = try await firestoreService.create(model: newHistory, reference: .history)
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
            }
    }

    private func prepareHistory(by value: Int? = nil,
                                action: MedistockAction,
                                id: String?,
                                for medicine: Medicine,
                                and user: String) async -> HistoryEntry? {
        switch action {
        case .operation:
            guard let value, let id else { return nil }
            return HistoryEntry(medicineId: id,
                         user: user,
                         action: "\(value > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(value)",
                         details: "Stock changed from \(medicine.stock - value) to \(medicine.stock)")
        case .create:
            guard let id else { return nil }
            return HistoryEntry(medicineId: id,
                                            user: user,
                                            action: "Created \(medicine.name)",
                                details: "Create new medicine with quantity: \(medicine.stock)")
        case .update:
            guard let id else { return nil }
            return HistoryEntry(medicineId: id,
                         user: user,
                         action: "Updated \(medicine.name)",
                         details: "Updated medicine details")
        }
    }


    //FIXME: Need to be removed later
    func addRandomMedicine(user: String) async {
        guard let currentUser else { return }
        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))", stock: Int.random(in: 1...100), aisle: "Aisle \(Int.random(in: 1...10))", user: currentUser)

        do {
            let medicineId = try await firestoreService.create(model: medicine, reference: .medicines)
            guard let newHistory = await prepareHistory(action: .create, id: medicineId, for: medicine, and: user) else { return }
            let _ = try await firestoreService.create(model: newHistory, reference: .history)
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }

    func deleteMedicines(id: String?) async {
        guard let id else { return }
        do {
            try await firestoreService.delete(id: id, reference: .medicines)
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }
}
