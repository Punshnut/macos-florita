import Foundation

struct Note: Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var createdDate: Date
    var modifiedDate: Date
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}