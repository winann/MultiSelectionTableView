//
//  TagButton.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/31.
//

import UIKit

class TagButton: UIButton {
    
    var currntID: String = ""

    static func initial(with title: String, tintColor: UIColor = UIColor.blue) -> TagButton {
        let btn = TagButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(tintColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.borderColor = tintColor.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 2
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        if #available(iOS 9.0, *) {
            btn.semanticContentAttribute = .forceRightToLeft
        } else {
            // Fallback on earlier versions
        }
        btn.setImage(BundleProvider.image("MultiSelection_remove"), for: .normal)
        if let size = btn.titleLabel?.sizeThatFits(CGSize(width: 0, height: 25)) {
            let frame = CGRect(x: 0, y: 0, width: size.width + 25, height: 25)
            btn.frame = frame
        }
        return btn
    }
    
    func update(title: String) {
        setTitle(title, for: .normal)
        if let size = titleLabel?.sizeThatFits(CGSize(width: 0, height: 25)) {
            let tempFrame = CGRect(x: 0, y: 0, width: size.width + 25, height: 25)
            frame = tempFrame
        }
    }
}
