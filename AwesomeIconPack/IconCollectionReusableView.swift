//
//  IconCollectionReusableView.swift
//  Icon changer
//
//  Created by Mariko on 2021/04/28.
//

import UIKit

final class IconCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var sectionLabel: UILabel!
    
    static let identifier: String = "SectionHeader"

       static func nib() -> UINib {
           return UINib(nibName: IconCollectionReusableView.identifier, bundle: nil)
       }
}
