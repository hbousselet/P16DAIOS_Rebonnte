//
//  FirestoreServiceMock.swift
//  MediStockTests
//
//  Created by Hugues BOUSSELET on 15/02/2026.
//

import Foundation
import FirebaseAuth
import Firebase
@testable import MediStock

final actor FirestoreServiceMock: FirestoreProtocol {
    nonisolated(unsafe) var shouldSuccess: Bool = true
    nonisolated(unsafe) var medistockInput: [Any] = []
    nonisolated(unsafe) var error: MedistockError? = nil

    func stream<T>(reference: MediStock.CollectionReference, element: String?) -> AsyncThrowingStream<[T], any Error> where T : Decodable, T : Sendable {
        let mediConverted: [T] = medistockInput as! [T]
        return AsyncThrowingStream { continuation in
            if let error = self.error {
                continuation.finish(throwing: error)
                return
            }
            continuation.yield(mediConverted)

            continuation.finish()
        }
    }

    func create(model: any MediStock.ModelProtocol, reference: MediStock.CollectionReference) async throws -> String? {
        if shouldSuccess {
            return "created"
        } else {
            throw MedistockError.createError("error while creating.")
        }
    }
    
    func delete(id: String, reference: MediStock.CollectionReference) async throws {
        if !shouldSuccess {
            throw MedistockError.deleteError("error while deleting.")
        }
    }

    func update(model: any MediStock.ModelProtocol, reference: MediStock.CollectionReference) async throws {
        if !shouldSuccess {
            throw MedistockError.updateError("error while updating.")
        }
    }
}
