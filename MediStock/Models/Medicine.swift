import Foundation
import FirebaseFirestoreSwift

struct Medicine: Identifiable, Codable, Equatable, ModelProtocol {
    @DocumentID var id: String?
    var name: String
    var stock: Int
    var aisle: String
    var user: String

    init(id: String? = nil, name: String, stock: Int, aisle: String, user: String) {
        self.id = id
        self.name = name
        self.stock = stock
        self.aisle = aisle
        self.user = user
    }

    static func == (lhs: Medicine, rhs: Medicine) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.stock == rhs.stock &&
        lhs.aisle == rhs.aisle &&
        lhs.user == rhs.user
    }

    var dictionary: [String: Any] {
        let dict = ["name": name,
                    "stock": stock,
                    "aisle": aisle,
                    "user": user] as [String : Any]
        return dict.compactMapValues { $0 }
    }
}
