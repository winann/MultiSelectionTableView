//
//  MultiSelectionTableView.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/25.
//

import UIKit

internal var checkIcon: UIImage = BundleProvider.image("MultiSelection_Check")!
internal var uncheckIcon: UIImage = BundleProvider.image("MultiSelection_Uncheck")!
public class MultiSelectionTableView: UIView {
    
    /// 选中的结果输出
    public var selectResults: [ItemModel] {
        return selectItems.flatMap { $0 }
    }
    
    /// 最外层的 Model
    public var sectionModel: SectionModel? {
        didSet {
            layoutTableView(model: sectionModel)
        }
    }
    
    
    /// 展示UI的配置
    public var config: MultiSelectionConfig = MultiSelectionConfig() {
        didSet {
            configAppearance()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(frame: CGRect, config: MultiSelectionConfig? = nil) {
        self.init(frame: frame)
        if let `config` = config {
            self.config = config
        }
    }
    
    
    /// 存储每个SectionView（创建后不会删除）
    private var sectionViews: [SectionView] = []
    
    /// 选中的内容
    private var selectItems: [[ItemModel]] = []
    
    public override func layoutSubviews() {
        if 1 == sectionViews.count {
            sectionViews[0].frame = bounds
        }
    }
    
    /// 布局tableView
    private func layoutTableView(componentsNum: Int = 0, model: SectionModel?) {
        if let tempModel = model {
            addSectionView(super: componentsNum, model: tempModel)
        } else {
            removeSectionView(super: componentsNum)
        }
    }
    
    private func configAppearance() {
        backgroundColor = config.backgroundColor
        checkIcon = config.checkIcon
        uncheckIcon = config.uncheckIcon
    }
    
    /// 级联刷新所有的UI
    private func relateRefreshAllSectionView(with componentsNum: Int) {
        let currentSectionView = sectionViews[componentsNum]
        if componentsNum > 0 {
            let parentSectionView = sectionViews[componentsNum - 1]
            /// 递归刷新父视图的展示UI
            if var currentModel = parentSectionView.model, let parentSelectIndex = parentSectionView.currentIndex, let selectModel = currentSectionView.model {
                //                currentModel.items[currentSelectIndex.row].subsection?.selectItems = selectModel.selectItems
                currentModel.items[parentSelectIndex.row].subsection = selectModel
                /// 如果有子项目选中，则父视图认为选中了这一条
                if selectModel.selectItems.isEmpty {
                    currentModel.selectItems.removeValue(forKey: parentSelectIndex)
                } else {
                    currentModel.selectItems[parentSelectIndex] = currentModel.items[parentSelectIndex.row]
                }
                parentSectionView.model = currentModel
                // 递归刷新父SectionView 控件
                relateRefreshAllSectionView(with: componentsNum - 1)
                if let parentSelectIndex = parentSectionView.currentIndex {
                    parentSectionView.tableView.reloadRows(at: [parentSelectIndex], with: .none)
                }
            }
        }
        
        /// 如果当前选择是单选，则全部置空子视图的选择
        if componentsNum < sectionViews.count - 1 {
            if true != currentSectionView.model?.multiSelect, let currentIndex = currentSectionView.currentIndex, let currentLastIndex = currentSectionView.lastIndex, currentIndex != currentLastIndex {
                removeAllSubselections(forCurrent: componentsNum, currentLastIndex: currentLastIndex)
            }
        }
    }
    /// 移除所有的子选中状态
    private func removeAllSubselections(forCurrent componentsNum: Int, currentLastIndex: IndexPath) {
//        /// 存储当前及之前的所有 index 方便查找对应的 Model
//        let parentIndexs = sectionViews
//            .prefix(through: componentsNum)
//            .compactMap { $0.currentIndex?.row }
        if var lastModel = sectionViews[componentsNum].model?.items[currentLastIndex.row] {
            if var subsection = lastModel.subsection {
                subsection.removeAllSubselection()
                lastModel.subsection = subsection
                sectionViews[componentsNum].model?.items[currentLastIndex.row] = lastModel
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
                    self?.sectionViews[componentsNum].tableView.reloadRows(at: [currentLastIndex], with: .none)
                }
            }
        }
    }
    
    /// 存储选中的内容
    private func storeSelection(for componentsNum: Int, currentModel: SectionModel) {
        // 如果没有存储的地方就创建啊
        if componentsNum > selectItems.count - 1 {
            selectItems.append(contentsOf: Array<[ItemModel]>(repeating: [], count: selectItems.count - componentsNum + 1))
        }
        // 如果当前是单选的，则把后面的所有选择清除掉
        if !currentModel.multiSelect, componentsNum < selectItems.count {
            for index in componentsNum..<selectItems.count {
                selectItems[index] = []
            }
        }
        selectItems[componentsNum].append(contentsOf: currentModel.selectItems.map { $0.value }.filter { $0.subsection == nil && !selectItems[componentsNum].contains($0) })
    }
    
    /// 每个SectionView 每次选中都会走这个
    private func sectionViewSelect(componentsNum: Int, subsectionModel: SectionModel?, currentModel: SectionModel) {
        /// 整体UI 更新
        relateRefreshAllSectionView(with: componentsNum)
        
        // 布局下一级的视图
        layoutTableView(componentsNum: componentsNum + 1, model: subsectionModel)
        
        // 存储选中的项
        storeSelection(for: componentsNum, currentModel: currentModel)
    }
    
    /// 添加SectionView
    private func addSectionView(super componentsNum: Int, model: SectionModel) {
        var sectionView: SectionView!
        if sectionViews.count > componentsNum {
            sectionView = sectionViews[componentsNum]
        } else {
            sectionView = SectionView(frame: CGRect(x: bounds.width, y: 0, width: 0, height: bounds.height), model: model, componentsNum: componentsNum)
            sectionView.selectResult = sectionViewSelect
            sectionViews.append(sectionView)
        }
        sectionView.update(model: model)
        addSubview(sectionView)
        if componentsNum == 0 {
            sectionView.frame = bounds
        } else {
            var originFrame = sectionViews.map { $0.frame }
            if sectionViews.count < componentsNum {
                originFrame.append(CGRect(x: bounds.width, y: 0, width: 0, height: bounds.height))
            }
            let targetFrames = originFrame.enumerated().map { (index, frame) -> CGRect in
                var tempFrame = frame
                if index <= componentsNum {
                    tempFrame.size.width = bounds.width / CGFloat(componentsNum + 1)
                    tempFrame.origin.x = CGFloat(index) * tempFrame.size.width
                } else {
                    tempFrame.size.width = 0
                    tempFrame.origin.x = bounds.width
                }
                
                return tempFrame
            }
            
            UIView.animate(withDuration: 0.3) {
                for (index, sectionView) in self.sectionViews.enumerated() {
                    sectionView.frame = targetFrames[index]
                }
            }
        }
    }
    
    /// 移除SectionView
    private func removeSectionView(super componentsNum: Int) {
        var leftWidths = (0..<componentsNum).map { (num) -> CGFloat in
            return bounds.width / CGFloat(componentsNum)
        }
        let originFrames = sectionViews.map { $0.frame }
        let targetFrames = originFrames.enumerated().map { (index, frame) -> CGRect in
            var tempFrame = frame
            if index < componentsNum {
                tempFrame.origin.x = CGFloat(index) * leftWidths[index]
                tempFrame.size.width = leftWidths[index]
            } else {
                tempFrame.origin.x = bounds.width
            }
            return tempFrame
        }
        UIView.animate(withDuration: 0.3) {
            for (index, sectionView) in self.sectionViews.enumerated() {
                sectionView.frame = targetFrames[index]
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configAppearance()
    }
}
