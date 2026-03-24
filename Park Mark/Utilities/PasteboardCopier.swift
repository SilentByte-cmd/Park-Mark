import UIKit

enum PasteboardCopier {
    static func copy(_ string: String) {
        UIPasteboard.general.string = string
    }
}
