//
//  ViewController.swift
//  MultiSelectionTableView
//
//  Created by winann on 07/25/2018.
//  Copyright (c) 2018 winann. All rights reserved.
//

import UIKit
import MultiSelectionTableView

class ViewController: UIViewController {

    @IBOutlet weak var multiSelectionTableView: MultiSelectionTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var thirdSectionModel1 = SectionModel()
        thirdSectionModel1.multiSelect = false
        thirdSectionModel1.items = (97...122).map({ (num) -> ItemModel in
            var model = ItemModel()
            model.title = String(Character(UnicodeScalar(num)!))
            model.itemID = model.title
            return model
        })
        var thirdSectionModel = SectionModel()
        thirdSectionModel.multiSelect = true
        thirdSectionModel.items = (97...122).map({ (num) -> ItemModel in
            var model = ItemModel()
            model.title = String(Character(UnicodeScalar(num)!))
            model.itemID = model.title
            if num % 4 ==  0 {
                var sectionModel = thirdSectionModel1
                sectionModel.sectionID = (sectionModel.sectionID ?? "") + "\(num)"
                model.subsection = sectionModel
            }
            return model
        })
        
        var secondSectionModel = SectionModel()
//        secondSectionModel.multiSelect = true
        secondSectionModel.items = (65...90).enumerated().map({ (index, num) -> ItemModel in
            var model = ItemModel()
            model.title = String(Character(UnicodeScalar(num)!))
            model.itemID = model.title
            if index % 3 == 0 {
                var sectionModel = thirdSectionModel
                sectionModel.sectionID = (sectionModel.sectionID ?? "") + "\(num)"
                model.subsection = sectionModel
            }
            return model
        })
        
        var firstSectionModel = SectionModel()
        firstSectionModel.sectionID = "000"
//        firstSectionModel.multiSelect = true
        firstSectionModel.items = (1...10).enumerated().map { (index, num) -> ItemModel in
            var model = ItemModel()
            model.title = "\(num)"
            model.itemID = model.title
            
            if index < 5 {
                let items = secondSectionModel.items
                var sectionModel = SectionModel()
                sectionModel.multiSelect = true
                let start = index * 5
                sectionModel.items = Array(items[start..<start + 5])
                model.subsection = sectionModel
            }
            return model
        }
        
        /// 代码创建
        let vc = MultiSelectionTableView()
        vc.frame = view.bounds
        vc.sectionModel = firstSectionModel
        view.addSubview(vc)
        
        /// xib
//        multiSelectionTableView.sectionModel = firstSectionModel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

