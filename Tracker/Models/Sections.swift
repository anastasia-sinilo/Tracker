import Foundation
enum Section: Int, CaseIterable {
    
    case emoji
    case color
    
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .color: return "Цвет"
        }
    }
}
