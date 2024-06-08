
import Foundation

struct Tweet: Codable {
    var id = UUID().uuidString
    let author: SnsUser
    let authorID: String
    let tweetContent: String
    var likeCount: Int
    var likers: [String]
    let isReply: Bool
    let parentReference: String?
}
