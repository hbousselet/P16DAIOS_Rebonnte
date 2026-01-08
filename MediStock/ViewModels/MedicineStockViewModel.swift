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
        for await medecine in firestoreService.medicines {
            medicines.append(contentsOf: medecine)
            aisles = Array(Set(medicines.map { $0.aisle })).sorted()
        }
    }

    func fetchHistory(for medicine: Medicine) async {
        guard let medicineId = medicine.id else { return }
        for await historyEntry in firestoreService.createListenerOnMedicineHistoryEntryDB(medicineId: medicineId) {
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

    func updateStok(_ medicine: Medicine, user: String, increase: Bool) async {
        guard let id = medicine.id else { return }
        let amount: Int = increase ? 1 : -1
        do {
            let newStock = medicine.stock + amount
            try await firestoreService.updateStock(medicine, by: 1, user: user)
            if let index = self.medicines.firstIndex(where: { $0.id == id }) {
                self.medicines[index].stock = newStock
            }
            try await firestoreService.addHistory(action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)", user: user, medicineId: id, details: "Stock changed from \(medicine.stock - amount) to \(newStock)")
        } catch {
            print("Error updating stock: \(error)")
        }
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
