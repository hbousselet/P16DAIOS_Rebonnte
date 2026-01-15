import Foundation
import Firebase

class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    private var db = Firestore.firestore()

    private var firestoreService: FirestoreService = FirestoreService()

    @MainActor
    func fetchMedicines() async {
        for await medicine: [Medicine] in firestoreService.stream(reference: .medicines) {
            print("medicine received : \(medicine)")
            medicines = medicine
            aisles = Array(Set(medicines.map { $0.aisle })).sorted()
        }
    }

    func fetchHistory(for medicine: Medicine) async {
        guard let medicineId = medicine.id else { return }
        for await historyEntry: [HistoryEntry] in firestoreService.stream(reference: .history, element: medicineId) {
            history.append(contentsOf: historyEntry)
        }
    }

    func removeHistoryListener() {

    }

    func addRandomMedicine(user: String) async {
        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))", stock: Int.random(in: 1...100), aisle: "Aisle \(Int.random(in: 1...10))")
        do {
            try db.collection("medicines").document(medicine.id ?? UUID().uuidString).setData(from: medicine)
            try await firestoreService.addHistory(action: "Added \(medicine.name)", user: user, medicineId: medicine.id ?? "", details: "Added new medicine")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

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

    func updateStock(by value: Int, for medicine: Medicine, and user: String) async {
        guard let id = medicine.id,
            let index = medicines.firstIndex(where: { $0.id == id }) else { return }
        var updatedMedicine = medicine // keep the source of truth from the server
        updatedMedicine.stock += value
        do {
            try? await firestoreService.update(model: updatedMedicine, reference: .medicines)
            guard let newHistory = await prepareHistory(by: value, id: id, for: medicines[index], and: user) else { return }
            try await firestoreService.update(model: newHistory, reference: .history)
        } catch {

            }
    }

    private func prepareHistory(by value: Int, id: String, for medicine: Medicine, and user: String) async -> HistoryEntry? {
        return HistoryEntry(medicineId: id,
                     user: user,
                     action: "\(value > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(value)",
                     details: "Stock changed from \(medicine.stock - value) to \(medicine.stock)")
    }

    func updateMedicine(_ medicine: Medicine, user: String) async {
        guard let id = medicine.id else { return }
        do {
            try await firestoreService.updateMedicine(medicine, user: user)
            try await firestoreService.addHistory(action: "Updated \(medicine.name)", user: user, medicineId: id, details: "Updated medicine details")
        } catch let error {
            print("Error updating document: \(error)")
        }
    }
}
