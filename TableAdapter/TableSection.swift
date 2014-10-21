//
//  TableSection.swift
//  TableAdapter
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import Foundation
import UIKit

public typealias CellConfigurationBlock = (cell: UITableViewCell, item: AnyObject?, indexPath: NSIndexPath) -> ()
public typealias CellSelectionBlock = (cell: UITableViewCell, indexPath: NSIndexPath) -> ()
public typealias SupplementalViewConfigurationBlock = (section: Int) -> UIView!

public class TableViewSection: NSObject {
    /**
        The delegate for tableView methods that require an in-depth implementation.
     */
    public internal(set) weak var dataSource: TableViewDataSource?
    
    /**
        Indicates if the receiver is hidden.
     */
    public internal(set) var hidden: Bool = false
    
    /**
        The title for the section. For book keeping purposes right now.
     */
    public var title: String?
    
    /**
        The objects to send to the cellConfigurationBlock.
     */
    public lazy var objects = [AnyObject]()
    
    public var cellIdentifierBlock: ((item: AnyObject?, indexPath: NSIndexPath) -> String)!
    public var rowHeight: CGFloat?
    
    public var cellConfigurationBlock: CellConfigurationBlock?
    public var headerConfigurationBlock: SupplementalViewConfigurationBlock?
    public var footerConfigurationBlock: SupplementalViewConfigurationBlock?
    
    public var sectionHeaderHeight: CGFloat?
    public var sectionFooterHeight: CGFloat?
    
    public var selectionBlock: CellSelectionBlock?
    
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
    
    public var sectionIndex: Int? {
        if let dataSource = dataSource {
            return find(dataSource.sections, self)
        }
            
        return nil
    }
    
    private var _numberOfRows: Int?
    
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
        if let sectionIndex = sectionIndex {
            //dataSource?.reloadSection(sectionIndex)
            dataSource?.reloadSections()
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
    
    public func cellForRow(rowIndex: Int) -> UITableViewCell? {
        if let sectionIndex = sectionIndex {
            return dataSource?.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: rowIndex, inSection: sectionIndex))
        }
        
        return nil
    }
}