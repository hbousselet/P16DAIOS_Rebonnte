//
//  FirestoreService.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 19/12/2025.
//

import Foundation
import Firebase

class FirestoreService {
    private var db = Firestore.firestore()
    var medicineHandler: (([Medicine]) -> Void)?
    var medicineHistoryEntryHandler: (([HistoryEntry]) -> Void)?

    var medicineDBlistener: ListenerRegistration?
    var medicineHistoryEntryDBlistener: ListenerRegistration?

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    var medicines: AsyncStream<[Medicine]> {
        AsyncStream { continuation in
            medicineHandler = { medicine in
                continuation.yield(medicine)
            }
            continuation.onTermination = { @Sendable _ in
                self.medicineDBlistener?.remove()
            } // closure qui s'assure que l'on vient renvoyer des données de maniere thread safe
            createListenerOnMedicineDB()
        }
    }

    func createListenerOnMedicineDB() {
        medicineDBlistener = db.collection("medicines").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let medecines: [Medicine] = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Medicine.self)
                } ?? []
                self.medicineHandler?(medecines)
            }
        }
    }

    func createListenerOnMedicineHistoryEntryDB(medicineId: String) -> AsyncStream<[HistoryEntry]> {
        AsyncStream { continuation in
            medicineHistoryEntryHandler = { history in
                continuation.yield(history)
            }
            continuation.onTermination = { @Sendable _ in
                self.medicineHistoryEntryDBlistener?.remove()
            }
            medicineHistoryEntryDBlistener = db.collection("history").whereField("medicineId", isEqualTo: medicineId).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting history: \(error)")
                } else {
                    let _ = querySnapshot?.documents.compactMap { document in
                        return try? document.data(as: HistoryEntry.self)
                    }
                }
            }
        }
    }

}

// MARK: Delete

extension FirestoreService {
    func delete(id: String) async throws {
        try await db.collection("medicines").document(id).delete()
    }
}

// MARK: Update stock
extension FirestoreService {
    func updateStock(_ medicine: Medicine, by amount: Int, user: String) async throws {
        guard let id = medicine.id else { return }
        let newStock = medicine.stock + amount
         try await db.collection("medicines").document(id).updateData([
            "stock": newStock
        ])
    }
}

// MARK: Update Medicine
extension FirestoreService {
    func updateMedicine(_ medicine: Medicine, user: String) async throws {
        guard let id = medicine.id else { return }
        try await  db.collection("medicines").document(id).setData(medicine.dictionary)
    }
}

// MARK: Add history
extension FirestoreService {
    func addHistory(action: String, user: String, medicineId: String, details: String) async throws {
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        try await db.collection("history").document(history.id ?? UUID().uuidString).setData(history.dictionary)
    }
}

// MARK: Fetch history
extension FirestoreService {
    
}
