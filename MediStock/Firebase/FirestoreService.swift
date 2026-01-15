//
//  FirestoreService.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 19/12/2025.
//

import Foundation
import Firebase

// créer un protocol pour FirestoreService
// créer un enum pour les erreurs
// remove la variable medicines
// mieux hierarchiser cette classe
// mettre FirestoreService en actor ?

enum CollectionReference: String {
    case medicines, history

    var id: String {
        switch self {
        case .medicines: return "medicineId"
        case .history: return "historyId"
        }
    }
}

protocol FirestoreProtocol {
    func stream<T: Decodable & Sendable>(
        reference: CollectionReference,
        element: String?
    ) -> AsyncStream<[T]>
    func delete(id: String) async throws
    func update(model: ModelProtocol, reference: CollectionReference) async throws
}

class FirestoreService: FirestoreProtocol {
    private var db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func stream<T: Decodable & Sendable>(
        reference: CollectionReference,
        element: String? = nil
    ) -> AsyncStream<[T]> {
        AsyncStream { continuation in
            let listenerRegistration = self.listener(
                for: T.self,
                reference: reference,
                element: element
            ) { items in
                continuation.yield(items)
            }
            
            continuation.onTermination = { @Sendable _ in
                listenerRegistration.remove()
            }
        }
    }

    private func listener<T: Decodable>(
        for type: T.Type,
        reference: CollectionReference,
        element: String? = nil,
        handler: @escaping ([T]) -> Void
    ) -> ListenerRegistration {
        if let element {
            return db.collection(reference.rawValue)
                .whereField(reference.id, isEqualTo: element)
                .addSnapshotListener { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        handler([])
                    } else {
                        let items = querySnapshot?.documents.compactMap { document in
                            return try? document.data(as: T.self)
                        } ?? []
                        handler(items)
                    }
                }
        } else {
            return db.collection(reference.rawValue)
                .addSnapshotListener { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        handler([])
                    } else {
                        let items = querySnapshot?.documents.compactMap { document in
                            return try? document.data(as: T.self)
                        } ?? []
                        handler(items)
                    }
                }
        }
    }
    
    func update(model: any ModelProtocol, reference: CollectionReference) async throws {
        guard let id = model.id else { return }
        try await db.collection(reference.rawValue).document(id)
            .setData(model.dictionary)
    }

    public func delete(id: String) async throws {
        try await db.collection("medicines").document(id)
            .delete()
    }
}

// MARK: Update stock
extension FirestoreService {
    public func updateStock(_ medicine: Medicine, by amount: Int, user: String) async throws {
        guard let id = medicine.id else { return }
        let newStock = medicine.stock + amount
         try await db.collection("medicines").document(id)
            .updateData([
            "stock": newStock
        ])
    }
}

// MARK: Update Medicine
extension FirestoreService {
    public func updateMedicine(_ medicine: Medicine, user: String) async throws {
        guard let id = medicine.id else { return }
        try await  db.collection("medicines").document(id)
            .setData(medicine.dictionary)
    }
}

// MARK: Add history
extension FirestoreService {
    public func addHistory(action: String, user: String, medicineId: String, details: String) async throws {
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        try await db.collection("history").document(history.id ?? UUID().uuidString)
            .setData(history.dictionary)
    }
}
