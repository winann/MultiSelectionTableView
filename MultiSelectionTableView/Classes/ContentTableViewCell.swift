//
//  ContentTableViewCell.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/25.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    var model: ItemModel? {
        didSet {
            update()
        }
    }
    var config: MultiSelectionConfig = MultiSelectionConfig() {
        didSet {
            update()
        }
    }
    
    /// 是否展示选中图标
    var showSelectIcon: Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func update() {
        guard let `model` = model else { return }
        titleLabel.text = model.title
        if let subselectCount = model.subsection?.selectItems.count, subselectCount > 0, config.showSubselectionCount {
            titleLabel.text = model.title + " (\(subselectCount))"
        }
        if config.selectionIsHightlight, model.isSelect {
            titleLabel.textColor = config.selectinHightlightColor
        } else {
            titleLabel.textColor = config.textColor
        }
        if showSelectIcon {
            if nil != model.subsection {
                imageWidth.constant = 0
            } else {
                imageWidth.constant = 50
                checkImageView?.image = model.isSelect ? checkIcon : uncheckIcon
            }
        } else {
            imageWidth.constant = 0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
