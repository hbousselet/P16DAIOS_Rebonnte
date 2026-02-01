import Foundation
import Firebase

@Observable class MedicineStockViewModel {
    var medicines: [Medicine] = []
    var aisles: [String] = []
    var history: [HistoryEntry] = []
    var alert: String?
    var presentAlert: Bool = false

    var session: SessionStore?

    private var firestoreService: FirestoreService = FirestoreService()
    private var medicineStreamTask: Task<Void, Never>?
    private var historyStreamTask: Task<Void, Never>?

    @MainActor
    func fetchMedicines() async {
        medicineStreamTask?.cancel()

        medicineStreamTask = Task {
            do {
                for try await medicine: [Medicine] in await firestoreService.stream(reference: .medicines) {
                    guard !Task.isCancelled else { break }
                    medicines = medicine
                    aisles = Array(Set(medicines.map { $0.aisle })).sorted()
                }
            } catch {
                presentAlert = true
                alert = (error as? MedistockError)?.errorDescription
            }
        }
    }

    @MainActor
    func fetchHistory(for medicine: Medicine) async {
        historyStreamTask?.cancel()

        historyStreamTask = Task {
            do {
                for try await historyEnt: [HistoryEntry] in await firestoreService.stream(reference: .history, element: medicine.id) {
                    guard !Task.isCancelled else { break }
                    history = historyEnt
                }
            } catch {
                presentAlert = true
                alert = (error as? MedistockError)?.errorDescription
            }
        }
    }

    func updateStock(by value: Int, for medicine: Medicine) async {
        guard let id = medicine.id,
            let index = medicines.firstIndex(where: { $0.id == id }) else { return }
        var updatedMedicine = medicine // keep the source of truth from the server
        updatedMedicine.stock += value
        do {
            try await firestoreService.update(model: updatedMedicine, reference: .medicines)
            guard let newHistory = await prepareHistory(by: value, action: .operation, id: id, for: medicines[index]) else { return }
            let _ = try await firestoreService.create(model: newHistory, reference: .history)
        } catch {
            presentAlert = true
            alert = (error as? MedistockError)?.errorDescription
            }
    }

    private func prepareHistory(by value: Int? = nil,
                                action: MedistockAction,
                                id: String?,
                                for medicine: Medicine) async -> HistoryEntry? {
        switch action {
        case .operation:
            guard let value,
                  let id,
                  let user = session?.session?.uid,
                  let email = session?.session?.email else { return nil }
            return HistoryEntry(medicineId: id,
                                userId: user,
                                userEmail: email,
                                action: "\(value > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(value)",
                                details: "Stock changed from \(medicine.stock - value) to \(medicine.stock)")
        case .create:
            guard let id,
                  let user = session?.session?.uid,
                  let email = session?.session?.email else { return nil }
            return HistoryEntry(medicineId: id,
                                userId: user,
                                userEmail: email,
                                action: "Created \(medicine.name)",
                                details: "Create new medicine with quantity: \(medicine.stock)")
        case .update:
            guard let id,
                  let user = session?.session?.uid,
                  let email = session?.session?.email else { return nil }
            return HistoryEntry(medicineId: id,
                                userId: user,
                                userEmail: email,
                                action: "Updated \(medicine.name)",
                                details: "Updated medicine details")
        }
    }

    func createStock(for medicine: Medicine) async {
        do {
            let medicineId = try await firestoreService.create(model: medicine, reference: .medicines)
            guard let newHistory = await prepareHistory(action: .create, id: medicineId, for: medicine) else { return }
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

extension MedicineStockViewModel {
    func stopMedicineStream() {
        medicineStreamTask?.cancel()
        medicineStreamTask = nil
    }

    func stopHistoryStream() {
        historyStreamTask?.cancel()
        historyStreamTask = nil
    }
}
