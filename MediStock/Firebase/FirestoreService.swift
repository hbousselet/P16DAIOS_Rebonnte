//
//  FirestoreService.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 19/12/2025.
//

import Foundation
import Firebase

protocol FirestoreProtocol: Actor {
    func create(model: any ModelProtocol, reference: CollectionReference) async throws -> String?
    func delete(id: String, reference: CollectionReference) async throws
    func stream<T: Decodable & Sendable>(
        reference: CollectionReference,
        element: String?
    ) -> AsyncThrowingStream<[T], any Error>
    func update(model: ModelProtocol, reference: CollectionReference) async throws
}

actor FirestoreService: FirestoreProtocol {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func stream<T: Decodable & Sendable>(
        reference: CollectionReference,
        element: String? = nil
    ) -> AsyncThrowingStream<[T], any Error> {
        AsyncThrowingStream { continuation in
            let listenerRegistration = self.listener(
                for: T.self,
                reference: reference,
                element: element
            ) { result in
                do {
                    let items = try result.get()
                    continuation.yield(items)
                } catch {
                    continuation.finish(throwing: error)
                }
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
        handler: @escaping (Result<[T], Error>) -> Void
    ) -> ListenerRegistration {
        if let element {
            return db.collection(reference.rawValue)
                .whereField(reference.id, isEqualTo: element)
                .addSnapshotListener { (querySnapshot, error) in
                    if let error = error {
                        handler(.failure(MedistockError.addListenerError(error.localizedDescription)))
                    } else {
                        let items = querySnapshot?.documents.compactMap { document in
                            return try? document.data(as: T.self)
                        } ?? []
                        handler(.success(items))
                    }
                }
        } else {
            return db.collection(reference.rawValue)
                .addSnapshotListener { (querySnapshot, error) in
                    if let error = error {
                        handler(.failure(MedistockError.addListenerError(error.localizedDescription)))
                    } else {
                        let items = querySnapshot?.documents.compactMap { document in
                            return try? document.data(as: T.self)
                        } ?? []
                        handler(.success(items))
                    }
                }
        }
    }

    public func update(model: any ModelProtocol, reference: CollectionReference) async throws {
        switch reference {
        case .medicines:
            guard let id = model.id else { return }
            do {
                try await db.collection(reference.rawValue).document(id)
                    .setData(model.dictionary)
            } catch {
                throw MedistockError.updateError(error.localizedDescription)
            }
        default:
            return
        }
    }

    public func create(model: any ModelProtocol, reference: CollectionReference) async throws -> String? {
        do {
            let document = try await db.collection(reference.rawValue)
                .addDocument(data: model.dictionary)
            return document.documentID
        } catch {
            throw MedistockError.createError(error.localizedDescription)
        }
    }

    public func delete(id: String, reference: CollectionReference) async throws {
        do {
            try await db.collection(reference.rawValue).document(id)
                .delete()
            if reference == .medicines {
                // get documents
                let documents = try await db.collection(CollectionReference.history.rawValue).whereField("medicine_id", isEqualTo: id).getDocuments()

                //loop in the documents and delete each one
                for document in documents.documents {
                    try await db.collection(CollectionReference.history.rawValue).document(document.documentID)
                        .delete()
                }
            }
        } catch {
            throw MedistockError.deleteError(error.localizedDescription)
        }
    }
}
