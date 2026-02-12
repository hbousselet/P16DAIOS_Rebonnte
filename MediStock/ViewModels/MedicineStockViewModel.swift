import Foundation
import Firebase

@Observable class MedicineStockViewModel {
    var medicines: [Medicine] = []
    var newMedicine: Medicine = Medicine(name: "Medicine", stock: 0, aisle: "Aisle", userId: "") // need to be cleared when updated in db
    var aisles: [String] = []
    var history: [HistoryEntry] = []
    var showLoading: Bool = false

    var alertTabViews: String?
    var presentAlertTabViews: Bool = false

    var alertDetailsView: String?
    var presentAlertDetailsView: Bool = false

    var user: AuthUserProtocol?

    private var firestoreService: FirestoreService = FirestoreService()
    private var medicineStreamTask: Task<Void, Never>?
    private var historyStreamTask: Task<Void, Never>?

    @MainActor
    func fetchMedicines() async {
        medicineStreamTask?.cancel()

        medicineStreamTask = Task {
            showLoading = true
            do {
                for try await medicine: [Medicine] in await firestoreService.stream(reference: .medicines) {
                    guard !Task.isCancelled else { break }
                    medicines = medicine
                    aisles = Array(Set(medicines.map { $0.aisle })).sorted()
                    showLoading = false
                }
            } catch {
                showLoading = false
                presentAlertTabViews = true
                alertTabViews = (error as? MedistockError)?.errorDescription
            }
        }
    }

    @MainActor
    func fetchHistory(for medicine: Medicine) async {
        historyStreamTask?.cancel()

        historyStreamTask = Task {
            showLoading = true
            do {
                for try await historyEnt: [HistoryEntry] in await firestoreService.stream(reference: .history, element: medicine.id) {
                    guard !Task.isCancelled else { break }
                    history = historyEnt
                    showLoading = false
                }
            } catch {
                showLoading = false
                presentAlertDetailsView = true
                alertDetailsView = (error as? MedistockError)?.errorDescription
            }
        }
    }

    func updateStock(by value: Int, for medicine: Medicine) async {
        print("### Update with new value: \(value)")
        guard let id = medicine.id,
            let index = medicines.firstIndex(where: { $0.id == id }) else { return }
        showLoading = true
        var updatedMedicine = medicine // keep the source of truth from the server
        print("### Stock before: \(updatedMedicine.stock)")
        updatedMedicine.stock += value
        print("### Stock after: \(updatedMedicine.stock)")

        do {
            try await firestoreService.update(model: updatedMedicine, reference: .medicines)
            guard let newHistory = await prepareHistory(by: value, action: .operation, id: id, for: medicines[index]) else { return }
            let _ = try await firestoreService.create(model: newHistory, reference: .history)
            showLoading = false
        } catch {
            showLoading = false
            presentAlertDetailsView = true
            alertDetailsView = (error as? MedistockError)?.errorDescription
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
                  let userUID = user?.uid,
                  let email = user?.email else { return nil }
            return HistoryEntry(medicineId: id,
                                userId: userUID,
                                userEmail: email,
                                action: "\(value > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(value)",
                                details: "Stock changed from \(medicine.stock - value) to \(medicine.stock)")
        case .create:
            guard let id,
                  let userUID = user?.uid,
                  let email = user?.email else { return nil }
            return HistoryEntry(medicineId: id,
                                userId: userUID,
                                userEmail: email,
                                action: "Created \(medicine.name)",
                                details: "Create new medicine with quantity: \(medicine.stock)")
        case .update:
            guard let id,
                  let userUID = user?.uid,
                  let email = user?.email else { return nil }
            return HistoryEntry(medicineId: id,
                                userId: userUID,
                                userEmail: email,
                                action: "Updated \(medicine.name)",
                                details: "Updated medicine details")
        }
    }

    func createStock(for medicine: Medicine) async -> Bool {
        if !medicine.aisle.containsANumber() {
            prepareAlert(MedistockError.noNumberInAisleName)
            return false
        }
        if medicine.name.isEmpty {
            prepareAlert(MedistockError.emptyMedicineName)
            return false
        }
        if medicine.aisle.isEmpty {
            prepareAlert(MedistockError.emptyAisleName)
            return false
        }
        if medicine.stock == 0 {
            prepareAlert(MedistockError.emptyStockMedicineCreation)
            return false
        }
        if medicines.filter({$0.name == medicine.name && $0.aisle == medicine.aisle}).first != nil {
            prepareAlert(MedistockError.alreadyExists)
            return false
        }
        do {
            showLoading = true
            let medicineId = try await firestoreService.create(model: medicine, reference: .medicines)
            guard let newHistory = await prepareHistory(action: .create, id: medicineId, for: medicine) else { return false}
            let _ = try await firestoreService.create(model: newHistory, reference: .history)
            showLoading = false
            return true
        } catch {
            showLoading = false
            presentAlertDetailsView = true
            alertDetailsView = (error as? MedistockError)?.errorDescription
            return false
        }
    }

    func deleteMedicines(id: String?) async {
        guard let id else { return }
        do {
            showLoading = true
            try await firestoreService.delete(id: id, reference: .medicines)
            showLoading = false
        } catch {
            showLoading = false
            presentAlertTabViews = true
            alertTabViews = (error as? MedistockError)?.errorDescription
        }
    }

    private func prepareAlert(_ error: MedistockError) {
        showLoading = false
        presentAlertDetailsView = true
        alertDetailsView = error.errorDescription
    }

    func removeAlert() {
        presentAlertDetailsView = false
        alertDetailsView = nil
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
