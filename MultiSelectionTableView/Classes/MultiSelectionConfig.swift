//
//  MultiSelectionConfig.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/30.
//

import Foundation

/// 整体配置
public struct MultiSelectionConfig {
    /// 文字颜色
    var textColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    /// 背景颜色
    var backgroundColor: UIColor = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1)
    /// 有子项目的选中是否展示选中背景颜色
    var showSelectBGColor: Bool = true
    /// 有子项目的时候选中的背景色： showSelectBGColor true 的时候有效
    var selectBGColor: UIColor = UIColor.white
    /// 选中项是否高亮
    var selectinHightlightColor: UIColor = UIColor(red: 82/255.0, green: 137/255.0, blue: 254/255.0, alpha: 1)
    /// 选中项是否高亮
    var selectionIsHightlight: Bool = true
    /// 可选项没有选中的状态
    var uncheckIcon: UIImage = BundleProvider.image("MultiSelection_Uncheck")!
    /// 选中图标的状态
    var checkIcon: UIImage = BundleProvider.image("MultiSelection_Check")!
    /// 是否显示子项目选中的个数
    var showSubselectionCount: Bool = true
    /// cell分割线的颜色
    var separatorColor: UIColor = UIColor(red: 232.0 / 255, green: 232.0 / 255, blue: 232.0 / 255, alpha: 1)
}

public struct MultiSelectionSectionConfig {
    /// 当前 section 的背景颜色
    var sectionBGColors: UIColor = UIColor.clear
    /// 是否显示可选的图标
    var showSelectIcon: Bool = true
}
