import Foundation
import FirebaseFirestoreSwift

struct HistoryEntry: Identifiable, Codable, ModelProtocol {
    @DocumentID var id: String?
    var medicineId: String
    var user: String
    var action: String
    var details: String
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case medicineId = "medicine_id"
        case user
        case action
        case details
        case timestamp
        case id
    }

    init(id: String? = nil, medicineId: String, user: String, action: String, details: String, timestamp: Date = Date()) {
        self.id = id
        self.medicineId = medicineId
        self.user = user
        self.action = action
        self.details = details
        self.timestamp = timestamp
    }

    var dictionary: [String: Any] {
        let dict = ["medicine_id": medicineId,
                    "user": user,
                    "action": action,
                    "details": details,
                    "timestamp": timestamp
        ] as [String : Any]
        return dict.compactMapValues { $0 }
    }
}
