//
//  BundleProvider.swift
//  MultiSelectionTableView
//
//  Created by Winann on 2018/7/25.
//

internal let RESOUCENAME: String = "MultiSelectionTableView"

internal class BundleProvider {
    static func bundle() -> Bundle {
        return MGResourceTool.bundle(forClass: BundleProvider.self, withResource: RESOUCENAME) ?? Bundle.main
    }
    public static func image(_ name: String) -> UIImage? {
        return UIImage(named: name, in: BundleProvider.bundle(), compatibleWith: nil)
    }
}

fileprivate class MGResourceTool {
    
    /// 取Bundle 通过类名来取
    ///
    /// - Parameters:
    ///   - aClass: 类名
    ///   - name: 资源Bundle的名字 默认为空时取frameWork名字
    /// - Returns: Bundle
    public static func bundle(forClass aClass: Swift.AnyClass,
                              withResource name: String? = nil) -> Bundle? {
        var bundle: Bundle? = Bundle(for: aClass)
        if let classBundle = bundle,
            let resourcePath = classBundle.resourcePath {
            let pathArr = resourcePath.components(separatedBy: "/")
            if let lastP = pathArr.last {
                let lastPArr = lastP.components(separatedBy: ".")
                if let bundleName = lastPArr.first,
                    let path = classBundle.path(forResource: name ?? bundleName, ofType: "bundle") {
                    bundle = Bundle(path: path)
                }
            }
        }
        return bundle
    }
}
