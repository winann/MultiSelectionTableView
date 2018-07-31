//
//  SectionView.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/26.
//

import UIKit

public typealias SelectCallBack = (_ num: Int, _ subsectionModel: SectionModel?, _ currentModel: SectionModel) -> Void

class SectionView: UIView {
    /// 选中的回调
    public var selectResult: SelectCallBack?
    /// 是否达到最大的选中
    public var isMaxSelection: (() -> Bool)?
    internal var model: SectionModel? {
        didSet {
            if let `model` = model {
                self.model?.items = model.items.map { (item) -> ItemModel in
                    var `item` = item
                    item.isSelect = model.selectItems.contains { $0.value == item }
                    return item
                }
                appearenceConfig()
            }
        }
    }
    internal var globalConfig: MultiSelectionConfig = MultiSelectionConfig() {
        didSet {
            appearenceConfig()
        }
    }
    /// cell 的背景色
    private var cellBGColor: UIColor = UIColor(red: 244 / 255.0, green: 244 / 255.0, blue: 244 / 255.0, alpha: 1)
    /// cell 选中的颜色
    private var cellSelectBGColor: UIColor = UIColor.white
    /// 分割线的颜色
    private var separatorColor = UIColor(red: 232.0 / 255, green: 232.0 / 255, blue: 232.0 / 255, alpha: 1) {
        didSet {
            tableView.separatorColor = separatorColor
        }
    }
    /// 有子项目的选中是否展示选中背景颜色
    private var showSelectBGColor: Bool = true
    
    private var componentsNum: Int = 0
    /// 上次选中的 Index（用于单选的反选操作）
    internal var lastIndex: IndexPath?
    /// 显示选中的框
    private var showSelectIcon: Bool = true
    /// 当前选中的Index
    internal var currentIndex: IndexPath? {
        didSet {
            lastIndex = oldValue
        }
    }
    lazy var tableView: UITableView  = {
        let tableView = UITableView(frame: bounds, style: .plain)
        tableView.register(UINib(nibName: "ContentTableViewCell", bundle: BundleProvider.bundle()), forCellReuseIdentifier: "ContentTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = separatorColor
        tableView.tableFooterView = UIView()
        return tableView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(frame: CGRect, model: SectionModel, componentsNum: Int) {
        self.init(frame: frame)
        self.model = model
        self.componentsNum = componentsNum
        backgroundColor = UIColor.clear
        layoutTableView()
    }
    
    public func update(model: SectionModel) {
        self.model = model
        self.currentIndex = nil
        self.tableView.reloadData()
    }
    
    
    /// 展示的配置
    private func appearenceConfig() {
        backgroundColor = model?.config.sectionBGColors
        showSelectIcon = model?.config.showSelectIcon ?? true
        cellBGColor = model?.config.cellBGColor ?? cellBGColor
        
        showSelectBGColor = globalConfig.showSelectBGColor
        cellSelectBGColor = globalConfig.selectBGColor
        separatorColor = globalConfig.separatorColor
    }
    
    override func layoutSubviews() {
        tableView.frame = bounds
    }
    
    private func layoutTableView() {
        addSubview(tableView)
//        tableView.equalToSuperView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeSelections(indexPaths: [IndexPath], sectionModel: SectionModel) -> SectionModel {
        guard !indexPaths.isEmpty else { return sectionModel }
        var model = sectionModel
        for tempIndex in indexPaths {
            model.selectItems.removeValue(forKey: tempIndex)
        }
        model.items = model.items.enumerated().map { (index, item) -> ItemModel in
            var `item` = item
            if indexPaths.contains(where: { (tempIndexPath) -> Bool in
                return index == tempIndexPath.row
            }) {
                item.isSelect = false
            }
            return item
        }
        return model
    }
}

extension SectionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var `model` = model, indexPath.row < model.items.count else {
            return
        }
        var selectItem = model.items[indexPath.row]
        
        if nil == selectItem.subsection || (nil != selectItem.subsection && !selectItem.isSelect) {
            selectItem.isSelect = !selectItem.isSelect
        }
        
        @discardableResult
        func addSelection() -> Bool {
            model.items[indexPath.row] = selectItem
            // 没有下一级的才可以选中
            if nil == selectItem.subsection {
                if let callBack = isMaxSelection {
                    if callBack() {
                        return false
                    }
                }
                model.selectItems[indexPath] = selectItem
            }
            return true
        }
        
        var indexPaths = [indexPath]
        if model.multiSelect {
            if selectItem.isSelect {
                if !addSelection() {
                    return 
                }
            } else {
                model = removeSelections(indexPaths: [indexPath], sectionModel: model)
            }
        } else {
            let removeIndexPaths = Array(model.selectItems.keys)
            if selectItem.isSelect {
                model = removeSelections(indexPaths: removeIndexPaths, sectionModel: model)
                addSelection()
                indexPaths.append(contentsOf: removeIndexPaths)
            } else {
                model = removeSelections(indexPaths: removeIndexPaths, sectionModel: model)
                indexPaths = removeIndexPaths
            }
        }
        if let tempIndex = currentIndex, !indexPaths.contains(tempIndex) {
            indexPaths.append(tempIndex)
        }
        currentIndex = indexPath
        self.model = model
        tableView.reloadRows(at: indexPaths, with: .none)
        if let callBack = selectResult {
            callBack(componentsNum, selectItem.subsection, model)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = cellBGColor
    }
    
}

extension SectionView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell") as? ContentTableViewCell {
            cell.model = model?.items[indexPath.row]
            cell.backgroundColor = cellBGColor
            if currentIndex == indexPath, let _ = cell.model?.subsection {
                if showSelectBGColor {
                    cell.backgroundColor = UIColor.white
                } else if globalConfig.selectionIsHightlight {
                    cell.titleLabel.textColor = globalConfig.selectinHightlightColor
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
}
