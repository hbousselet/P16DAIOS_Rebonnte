import Foundation
import FirebaseFirestoreSwift

struct HistoryEntry: Identifiable, Codable, ModelProtocol {
    @DocumentID var id: String?
    var medicineId: String
    var userId: String
    var userEmail: String
    var action: String
    var details: String
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case medicineId = "medicine_id"
        case userId = "user_id"
        case userEmail = "user_email"
        case action
        case details
        case timestamp
        case id
    }

    init(id: String? = nil, medicineId: String, userId: String, userEmail: String, action: String, details: String, timestamp: Date = Date()) {
        self.id = id
        self.medicineId = medicineId
        self.userId = userId
        self.userEmail = userEmail
        self.action = action
        self.details = details
        self.timestamp = timestamp
    }

    var dictionary: [String: Any] {
        let dict = ["medicine_id": medicineId,
                    "user_id": userId,
                    "user_email": userEmail,
                    "action": action,
                    "details": details,
                    "timestamp": timestamp
        ] as [String : Any]
        return dict.compactMapValues { $0 }
    }
}
