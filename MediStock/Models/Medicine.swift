import Foundation
import FirebaseFirestoreSwift

struct Medicine: Identifiable, Codable, Equatable, ModelProtocol {
    @DocumentID var id: String?
    var name: String
    var stock: Int
    var aisle: String
    var userId: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case stock
        case aisle
        case userId = "user_id"
    }

    init(id: String? = nil, name: String, stock: Int, aisle: String, userId: String) {
        self.id = id
        self.name = name
        self.stock = stock
        self.aisle = aisle
        self.userId = userId
    }

    static func == (lhs: Medicine, rhs: Medicine) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.stock == rhs.stock &&
        lhs.aisle == rhs.aisle &&
        lhs.userId == rhs.userId
    }

    var dictionary: [String: Any] {
        let dict = ["name": name,
                    "stock": stock,
                    "aisle": aisle,
                    "user_id": userId] as [String : Any]
        return dict.compactMapValues { $0 }
    }

    static func createNewStock(for user: User?) -> Self {
        return Medicine(name: "Medicine",
                        stock: 0,
                        aisle: "Aisle",
                        userId: user?.uid ?? "not found")
    }
}
