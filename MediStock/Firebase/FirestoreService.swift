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

    static var medicines: AsyncStream<[Medicine]> {
        AsyncStream { continuation in
            let service = FirestoreService()
            service.medicineHandler = { medicine in
                continuation.yield(medicine)
            }
            continuation.onTermination = { @Sendable _ in
                // remove listener
            }
            service.fetch()
        }
    }

    func fetch() {
        db.collection("medicines").addSnapshotListener { (querySnapshot, error) in
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
