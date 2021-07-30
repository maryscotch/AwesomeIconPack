import UIKit

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionLabel: UILabel!
    static let identifier: String = "SectionHeader"
    static func nib() -> UINib {
        return UINib(nibName: SectionHeader.identifier, bundle: nil)
    }
}
