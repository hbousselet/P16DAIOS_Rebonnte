import Foundation
import Firebase

class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    private var db = Firestore.firestore()

    private var firestoreService: FirestoreService = FirestoreService()

    func fetchMedicines() async {
        for await medecine in firestoreService.medicines {
            medicines.append(contentsOf: medecine)
            aisles = Array(Set(medicines.map { $0.aisle })).sorted()
        }
    }

    func addRandomMedicine(user: String) {
        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))", stock: Int.random(in: 1...100), aisle: "Aisle \(Int.random(in: 1...10))")
        do {
            try db.collection("medicines").document(medicine.id ?? UUID().uuidString).setData(from: medicine)
            addHistory(action: "Added \(medicine.name)", user: user, medicineId: medicine.id ?? "", details: "Added new medicine")
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
            self.addHistory(action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)", user: user, medicineId: id, details: "Stock changed from \(medicine.stock - amount) to \(newStock)")
        } catch {
            print("Error updating stock: \(error)")
        }
    }

    func updateMedicine(_ medicine: Medicine, user: String) {
        guard let id = medicine.id else { return }
        do {
            try db.collection("medicines").document(id).setData(from: medicine)
            addHistory(action: "Updated \(medicine.name)", user: user, medicineId: id, details: "Updated medicine details")
        } catch let error {
            print("Error updating document: \(error)")
        }
    }

    private func addHistory(action: String, user: String, medicineId: String, details: String) {
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        do {
            try db.collection("history").document(history.id ?? UUID().uuidString).setData(from: history)
        } catch let error {
            print("Error adding history: \(error)")
        }
    }

    func fetchHistory(for medicine: Medicine) {
        guard let medicineId = medicine.id else { return }
        db.collection("history").whereField("medicineId", isEqualTo: medicineId).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting history: \(error)")
            } else {
                self.history = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: HistoryEntry.self)
                } ?? []
            }
        }
    }
}
