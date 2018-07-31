//
//  SectionModel.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/26.
//

/// 每个列表对应一个 SectionModel
public struct SectionModel: Equatable {
    public static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        return lhs.sectionID == rhs.sectionID
    }
    public init() {
        items = []
        sectionID = "\(Date().timeIntervalSince1970)"
    }
    
    /// 初始化一个实例
    ///
    /// - Parameters:
    ///   - multiSelect: 是否可以多选
    ///   - items: 当前列展示的项目 ItemModel
    ///   - sectionID: 当前区域的父ID（会设置每一个（items））
    ///   - withWeight: 宽度的权重（如果有两列，都为 1，）
    public init(can multiSelect: Bool = false, items: [ItemModel], sectionID: String? = nil, widthWeight: Float = 1, appearceConfig: MultiSelectionSectionConfig? = nil) {
        self.init()
        self.multiSelect = multiSelect
        self.items = items
        self.sectionID = sectionID
        self.widthWeight = widthWeight
        if let config = appearceConfig {
            self.config = config
        }
    }
    public var config: MultiSelectionSectionConfig = MultiSelectionSectionConfig()
    /// 此列是否支持多选
    public var multiSelect: Bool = false
    /// 内容
    public var items: [ItemModel] {
        didSet {
            setParentForItems(false)
        }
    }
    /// 宽度的权重
    public var widthWeight: Float = 1
    
    /// 父节点的ID，如果不知道怎么用就不要传(重设为空需要传空字符串，要唯一)
    /// !!!注意：需要先设置 items 才有用
    public var sectionID: String? {
        didSet {
            setParentForItems()
        }
    }
    /// 选中的项
    public internal(set) var selectItems: [IndexPath: ItemModel] = [:]
    
    private mutating func setParentForItems(_ isForce: Bool = true) {
        guard let id = sectionID else {
            return
        }
        guard !items.isEmpty else {
            return
        }
        guard isForce || nil == items[0].parentID else {
            return
        }
        items = items.map({ (item) -> ItemModel in
            var `item` = item
            item.parentID = id
            return item
        })
    }
    
    internal mutating func removeAllSubselection() {
        func removeSubselection(_ items: [ItemModel]) -> [ItemModel] {
            var resultItems: [ItemModel] = []
            for item in items {
                var `item` = item
                item.isSelect = false
                if var subselection = item.subsection, !subselection.selectItems.isEmpty {
                    subselection.items = removeSubselection(subselection.items)
                    subselection.selectItems.removeAll()
                    item.subsection = subselection
                }
                resultItems.append(item)
            }
            return resultItems
        }
        items = removeSubselection(items)
        selectItems.removeAll()
    }
    
    /// 移除选择指定的Item
    internal mutating func removeSubselection(item: ItemModel) {
        if let index = items.index(of: item) {
            var tempItem = item
            tempItem.isSelect = false
            items[index] = tempItem
            selectItems.removeValue(forKey: IndexPath(row: index, section: 0))
        }
    }
}

/// 每一项的内容
public struct ItemModel: Equatable {
    public static func == (lhs: ItemModel, rhs: ItemModel) -> Bool {
        return lhs.itemID == rhs.itemID && lhs.parentID == rhs.parentID
    }
    
    public init() { }
    /// 标题
    public var title: String = ""
    /// id
    public var itemID: String = ""
    /// 是否选中
    public var isSelect: Bool = false
    /// 是否选择此项后同一级其它不能选择
    public var isExclusive: Bool = false
    /// 要保存的内容，完成之后会返回回去
    public var data: Any?
    /// 是否还有子列
    public var subsection: SectionModel?
    /// 父节点的ID
    public internal(set) var parentID: String?
}
