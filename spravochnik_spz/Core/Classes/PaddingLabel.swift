//
//  PaddingCostLabel.swift
//  spravochnik_spz
//
//  Created by Максим Косников on 08.02.2023.
//

import UIKit

class PaddingLabel: UILabel {
    var edgeInset: UIEdgeInsets = .zero

        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets.init(top: edgeInset.top,
                                           left: edgeInset.left,
                                           bottom: edgeInset.bottom,
                                           right: edgeInset.right)
            super.drawText(in: rect.inset(by: insets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + edgeInset.left + edgeInset.right + 20,
                          height: size.height + edgeInset.top + edgeInset.bottom + 8)
        }
}
