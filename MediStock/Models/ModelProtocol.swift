//
//  ModelProtocol.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 14/01/2026.
//

import Foundation

protocol ModelProtocol {
    var id: String? { get set }
    var dictionary: [String: Any] { get }
}

enum CollectionReference: String {
    case medicines, history

    var id: String {
        "medicine_id"
    }

    var user: String {
        "user_id"
    }
}
