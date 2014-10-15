//
//  TableSection.swift
//  TableAdapter
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import Foundation

public typealias CellConfigurationBlock = (cell: UITableViewCell, item: AnyObject?, indexPath: NSIndexPath) -> ()
public typealias CellSelectionBlock = (cell: UITableViewCell, indexPath: NSIndexPath) -> ()
public typealias SupplementalViewConfigurationBlock = (section: Int) -> UIView!

public class TableViewSection: NSObject {
    public internal(set) var hidden: Bool = false
    
    public var title: String?
    
    public internal(set) weak var controller: TableViewDataSource?
    
    public lazy var objects = [AnyObject]()
    
    public var numberOfRows: Int {
        set {
            _numberOfRows = newValue
        }
        get {
            if self.hidden {
                return 0
            }
            
            if _numberOfRows != nil {
                return _numberOfRows!
            } else {
                return objects.count ?? 0
            }
        }
    }
    
    private var _numberOfRows: Int?
    
//    public var numberOfRows: Int {
//        if self.hidden {
//            return 0
//        }
//            
//        return objects.count ?? 0
//    }
    
    public var cellIdentifierBlock: ((item: AnyObject?, indexPath: NSIndexPath) -> String)!
    public var rowHeight: CGFloat?
    
    public var cellConfigurationBlock: CellConfigurationBlock!
    public var headerConfigurationBlock: SupplementalViewConfigurationBlock?
    public var footerConfigurationBlock: SupplementalViewConfigurationBlock?
    
    public var sectionHeaderHeight: CGFloat?
    public var sectionFooterHeight: CGFloat?
    
    public var selectionBlock: CellSelectionBlock?
    
    public override init() {
        super.init()
    }
    
    public init(builder: (TableViewSection) -> ()) {
        super.init()
        builder(self)
    }
    
    public func addObject(object: AnyObject) {
        objects.append(object)
        reload()
    }
    
    public func reload() {
        if let dataSource = controller {
            if let sectionIndex = find(dataSource.sections, self) {
                dataSource.reloadSection(sectionIndex)
            }
        }
    }
    
    public func hide() {
        if !hidden {
            hidden = true
            reload()
        }
    }
    
    public func show() {
        if hidden {
            hidden = false
            reload()
        }
    }
}