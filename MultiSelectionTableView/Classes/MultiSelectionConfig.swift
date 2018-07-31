//
//  MultiSelectionConfig.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/30.
//

import Foundation

/// 整体配置
public struct MultiSelectionConfig {
    public init() {
        
    }
    /// 文字颜色
    public var textColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    /// 背景颜色
    public var backgroundColor: UIColor = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1)
    /// 有子项目的选中是否展示选中背景颜色
    public var showSelectBGColor: Bool = true
    /// 有子项目的时候选中的背景色： showSelectBGColor true 的时候有效
    public var selectBGColor: UIColor = UIColor.white
    /// 选中项是否高亮
    public var selectinHightlightColor: UIColor = UIColor(red: 82/255.0, green: 137/255.0, blue: 254/255.0, alpha: 1)
    /// 选中项是否高亮
    public var selectionIsHightlight: Bool = true
    /// 可选项没有选中的状态
    public var uncheckIcon: UIImage = BundleProvider.image("MultiSelection_Uncheck")!
    /// 选中图标的状态
    public var checkIcon: UIImage = BundleProvider.image("MultiSelection_Check")!
    /// 是否显示子项目选中的个数
    public var showSubselectionCount: Bool = true
    /// cell分割线的颜色
    public var separatorColor: UIColor = UIColor(red: 232.0 / 255, green: 232.0 / 255, blue: 232.0 / 255, alpha: 1)
    
    /// 最大选择个数
    public var maxSelectCount: Int = 0
    
    /// 是否显示底部展示的内容
    public var showSelectedView: Bool = false
    
    /// 是否存储排序好的结果，会占用更多的内存
    public var showSortedResult: Bool = false
}

public struct MultiSelectionSectionConfig {
    public init() {}
    /// 当前 section 的背景颜色
    public var sectionBGColors: UIColor = UIColor.clear
    /// 是否显示可选的图标
    public var showSelectIcon: Bool = true
    /// 当前 section 的cell 背景色
    public var cellBGColor: UIColor = UIColor(red: 244 / 255.0, green: 244 / 255.0, blue: 244 / 255.0, alpha: 1)
}
