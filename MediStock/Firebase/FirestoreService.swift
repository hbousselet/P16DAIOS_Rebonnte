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

    var medicineDBlistener: ListenerRegistration?

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
            }
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
         return try await db.collection("medicines").document(id).updateData([
            "stock": newStock
        ])
    }
}
