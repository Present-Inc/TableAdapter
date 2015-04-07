//
//  TableSection.swift
//  TableAdapter
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import Foundation
import UIKit

public typealias CellConfiguration = (cell: UITableViewCell, item: AnyObject?, indexPath: NSIndexPath) -> Void
public typealias CellSelection = (cell: UITableViewCell, indexPath: NSIndexPath) -> Void
public typealias CellIdentifier = (item: AnyObject?, indexPath: NSIndexPath) -> String

public typealias SupplementalViewConfiguration = (section: Int) -> UIView

public typealias TableCellCanEdit = (rowIndex: Int) -> Bool

public class TableViewSection: NSObject {
    /**
        The section's data source.
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
    public lazy var objects: [AnyObject] = []
    
    public var estimatedRowHeight: CGFloat?
    public var rowHeight: CGFloat? {
        didSet {
            estimatedRowHeight = rowHeight
        }
    }
    public var headerHeight: CGFloat = 0
    public var footerHeight: CGFloat = 0
    
    public var cellIdentifier: CellIdentifier!
    public var cellConfiguration: CellConfiguration?
    public var cellSelection: CellSelection?
    
    public var headerConfiguration: SupplementalViewConfiguration?
    public var footerConfiguration: SupplementalViewConfiguration?
    
    public var canEditRow: TableCellCanEdit = { _ in return false }
    
    public var numberOfRows: Int {
        set {
            _numberOfRows = newValue
        }
        get {
            if self.hidden {
                return 0
            }
            
            return _numberOfRows ?? objects.count
        }
    }
    
    public var isEmpty: Bool {
        if _numberOfRows != nil {
            return _numberOfRows == 0
        }
        
        return objects.count == 0
    }
    
    /**
        Indicates whether or not the section is active.
    
        A section is considered active if it's been added
        to a TableViewDataSource instance.
     */
    public var isActive: Bool {
        return dataSource != nil
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
    
    /**
        Appends object to the section. Automatically inserts a new row
        if the section is active.
     */
    public func addObject(object: AnyObject) {
        objects.append(object)

        let index = objects.count - 1
        insertRowAtIndex(index)
    }
    
    /**
        Inserts `object` at `index`. Inserts a new row at `index`
        if the section is active.
     */
    public func insertObject(object: AnyObject, atIndex index: Int) {
        objects.insert(object, atIndex: index)
        insertRowAtIndex(index)
    }
    
    /**
        Removes `object` at `index`. Removes the row at `index`
        if the section is active.
     */
    public func removeObjectAtIndex(index: Int) {
        objects.removeAtIndex(index)
        
        removeRowAtIndex(index)
    }
    
    /**
        Reloads the section if active.
     */
    public func reload() {
        if let sectionIndex = sectionIndex {
            dataSource?.reloadSection(sectionIndex)
        }
    }
    
    /**
        Hides and reloads the section.
     */
    public func hide() {
        if !hidden {
            hidden = true
            reload()
        }
    }
    
    /**
        Shows and reloads the section.
     */
    public func show() {
        if hidden {
            hidden = false
            reload()
        }
    }
    
    /**
        Returns the cell for the row, if the section is active.
     */
    public func cellForRow(rowIndex: Int) -> UITableViewCell? {
        if let indexPath = indexPathForRowIndex(rowIndex) {
            return dataSource?.tableView?.cellForRowAtIndexPath(indexPath)
        }
        
        return nil
    }
    
    public func canEditRowAtIndex(index: Int) -> Bool {
        return canEditRow(rowIndex: index)
    }
}

private extension TableViewSection {
    func indexPathForRowIndex(rowIndex: Int) -> NSIndexPath? {
        if let sectionIndex = sectionIndex {
            return NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
        }
        
        return nil
    }
    
    func insertRowAtIndex(index: Int, withRowAnimation animation: UITableViewRowAnimation? = .None) {
        if let indexPath = indexPathForRowIndex(index) {
            dataSource?.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: animation ?? .None)
        }
    }
    
    func removeRowAtIndex(index: Int, withRowAnimation animation: UITableViewRowAnimation? = nil) {
        if let indexPath = indexPathForRowIndex(index) {
            dataSource?.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation ?? .None)
        }
    }
}