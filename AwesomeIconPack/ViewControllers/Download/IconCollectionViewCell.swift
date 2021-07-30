import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        iconImageView.layer.cornerRadius = 17
        iconImageView.clipsToBounds = true
    }
    
    override var isSelected: Bool{
      didSet{
        if self.isSelected {
            self.alpha = 0.3
        } else {
            self.alpha = 1
        }
     }
   }

}
