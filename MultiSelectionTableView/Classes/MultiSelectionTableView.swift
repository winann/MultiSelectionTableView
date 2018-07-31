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
    
    /// 排序好的结果，按照选择的顺序（只有 config 中的showSortedResult 为 true 的时候生效）
    lazy public var sortedSelectResults: [ItemModel] = []
    
    /// 最外层的 Model
    public var sectionModel: SectionModel? {
        didSet {
            layoutTableView(model: sectionModel)
        }
    }
    
    /// 选择达到最大值
    public var maxSelectionCallBack: (() -> Void)?
    
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
    
    private lazy var bottomView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        var tempFrame = bounds
        tempFrame.origin.y = bounds.height
        tempFrame.size.height = 0
        view.frame = tempFrame
        return view
    }()
    
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
        var currentSelect = selectItems[componentsNum]
        // 清除掉当前选择的内容，重新选择
        selectItems[componentsNum] = currentSelect.filter { (item) -> Bool in
            return !currentModel.items.contains(item)
        }
        selectItems[componentsNum].append(contentsOf: currentModel.selectItems.map { $0.value }.filter { $0.subsection == nil && !selectItems[componentsNum].contains($0) })
        
        if config.showSortedResult {
            if sortedSelectResults.isEmpty {
                sortedSelectResults = selectResults
            } else {
                sortedSelectResults = sortedSelectResults.filter { (item) -> Bool in
                    return selectResults.contains(item)
                }
                sortedSelectResults.append(contentsOf: selectResults.filter({ (item) -> Bool in
                    return !sortedSelectResults.contains(item)
                }))
            }
        }
        
    }
    
    /// 每个SectionView 每次选中都会走这个
    private func sectionViewSelect(componentsNum: Int, subsectionModel: SectionModel?, currentModel: SectionModel) {
        /// 整体UI 更新
        relateRefreshAllSectionView(with: componentsNum)
        
        // 布局下一级的视图
        layoutTableView(componentsNum: componentsNum + 1, model: subsectionModel)
        
        // 存储选中的项
        storeSelection(for: componentsNum, currentModel: currentModel)
        
        /// 布局选中的项
        layoutBottomView()
    }
    
    func isMaxSelection() -> Bool {
        guard config.maxSelectCount > 0 else {
            return false
        }
        let isMax = selectResults.count >= config.maxSelectCount
        if let callBack = maxSelectionCallBack, isMax {
            callBack()
        }
        return isMax
    }
    
    /// 添加SectionView
    private func addSectionView(super componentsNum: Int, model: SectionModel) {
        var sectionView: SectionView!
        if sectionViews.count > componentsNum {
            sectionView = sectionViews[componentsNum]
        } else {
            sectionView = SectionView(frame: CGRect(x: bounds.width, y: 0, width: 0, height: bounds.height), model: model, componentsNum: componentsNum)
            sectionView.selectResult = sectionViewSelect
            sectionView.isMaxSelection = isMaxSelection
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
    
    /// removeSelectItem
    private func removeSelectItem(item: ItemModel) {
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configAppearance()
    }
    
    /// 布局底部的展示视图
    private func layoutBottomView() {
        guard config.showSelectedView else { return }
//        let btns = sortedSelectResults.map { (item) -> TagButton in
//            return TagButton.initial(with: item.title, tintColor: config.selectinHightlightColor)
//        }
        addSubview(bottomView)
        let originBtns = bottomView.subviews.filter { (view) -> Bool in
            if let btn = view as? TagButton {
                if sortedSelectResults.contains(where: { (item) -> Bool in
                    return item.title == btn.titleLabel?.text
                }) {
                    return true
                } else {
                    view.removeFromSuperview()
                }
            }
            return false
        }
        var btns = originBtns
        btns.append(contentsOf: Array(repeating: TagButton.initial(with: "", tintColor: config.selectinHightlightColor), count: sortedSelectResults.count - btns.count))
        for (i, btn) in btns.enumerated() {
            if let `btn` = btn as? TagButton {
                let item = sortedSelectResults[i]
                btn.update(title: item.title)
                btn.currntID = item.itemID
                btn.addTarget(self, action: #selector(removeSelect), for: .touchUpInside)
            }
            var tempFrame = btn.frame
            tempFrame.origin.y = 25
            if i > 0 {
                tempFrame.origin.x = btns[i - 1].frame.maxX + 15
                tempFrame.origin.y = btns[i - 1].frame.minY
                if tempFrame.maxX > bottomView.bounds.width - 15 {
                    tempFrame.origin.y = btns[i - 1].frame.maxY + 15
                    tempFrame.origin.x = 15
                }
            } else {
                tempFrame.origin.x = 15
            }
            btn.frame = tempFrame
            bottomView.addSubview(btn)
        }
        
        var bottomFrame = bottomView.frame
        if let lastBtn = btns.last {
            var tempBottonViewFrame = bottomView.frame
            let height =  lastBtn.frame.maxY + 25
            tempBottonViewFrame.origin.y = bounds.height - height
            tempBottonViewFrame.size.height = height
            bottomFrame = tempBottonViewFrame
        } else {
            var tempBottomFrame = bottomView.frame
            tempBottomFrame.size.height = 0
            tempBottomFrame.origin.y = bounds.height
            bottomFrame = tempBottomFrame
        }
        
        /// bottomView 不能超过三分之一高
        if bottomFrame.height > bounds.height / 3 {
            var tempFrame = bottomFrame
            tempFrame.size.height = bounds.height / 3
            tempFrame.origin.y = bounds.height - tempFrame.height
            self.bottomView.contentSize = bottomFrame.size
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.bottomView.frame = tempFrame
                self?.bottomView.contentOffset = CGPoint(x: 0, y: bottomFrame.height - tempFrame.height)
            }
        } else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.bottomView.frame = bottomFrame
            }
        }
        
        for sectionView in sectionViews {
            var tempFrame = sectionView.frame
            tempFrame.size.height = bounds.height - bottomView.frame.height
            UIView.animate(withDuration: 0.3) {
                sectionView.frame = tempFrame
            }
        }
    }
    
    @objc func removeSelect(sender: TagButton) {
        if let rmIndex = sortedSelectResults.index(where: { (item) -> Bool in
            return item.itemID == sender.currntID
        }) {
            let rmItem = sortedSelectResults.remove(at: rmIndex)
            layoutBottomView()
            removeSelectItem(item: rmItem)
        }
    }
}
