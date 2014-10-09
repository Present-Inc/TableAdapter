//
//  TableViewDataSource.swift
//  TableAdapter
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol TableViewDataSourceDelegate {
    optional func tableViewDidScroll(tableView: UIScrollView)
}

public class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak public var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    public weak var delegate: TableViewDataSourceDelegate?
    
    public internal(set) var sections: [TableViewSection] = [TableViewSection]()
    public var numberOfSections: Int {
        return sections.count
    }
    
    // MARK:
    // MARK: Section Management
    // MARK:
    
    public func dataSourceForIndexPath(indexPath: NSIndexPath) -> [AnyObject]? {
        return self.tableSectionForIndexPath(indexPath)?.objects
    }
    
    public func tableSectionForIndexPath(indexPath: NSIndexPath) -> TableViewSection? {
        return self.tableSectionForIndex(indexPath.section)
    }
    
    public func tableSectionForIndex(index: Int) -> TableViewSection? {
        if index >= 0 && index < self.sections.count {
            return self.sections[index]
        }
        
        return nil
    }
    
    // MARK: Add Sections
    
    public func addSections(sections: [TableViewSection]) {
        self.sections.extend(sections)
        
        self.tableView.reloadData()
    }
    
    public func addSection(section: TableViewSection) {
        self.addSections([section])
    }
    
    public func insertSection(section: TableViewSection, atIndex index: Int) {
        self.sections.insert(section, atIndex: index)
        self.tableView.reloadData()
    }
    
    // MARK: Delete Sections
    
    public func deleteAllSections() {
        self.sections.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    public func deleteSectionsInRange(range: Range<Int>) {
        println("Delete sections \(range.startIndex) to \(range.endIndex)")
        
        var objcRange = NSMakeRange(range.startIndex, range.endIndex - range.startIndex)
        
        println("Delete sections \(objcRange.location) to \(objcRange.location + objcRange.length)")
        
        var indexSet = NSIndexSet(indexesInRange: objcRange)
        self.tableView.deleteSections(indexSet, withRowAnimation: .None)
    }
    
    public func deleteSectionAtIndex(index: Int) {
        self.sections.removeAtIndex(index)
        self.tableView.reloadData()
    }
    
    // MARK: Hide Section
    
    public func hideSectionAtIndex(index: Int) {
        self.sections[index].hide()
    }
    
    public func hideSectionsInRange(range: Range<Int>) {
        for i in range {
            self.hideSectionAtIndex(i)
        }
    }
    
    // MARK: Show Sections
    public func showSectionAtIndex(index: Int) {
        self.sections[index].show()
    }
    
    // MARK: Replace Sections
    
    public func replaceSectionAtIndex(index: Int, withSection section: TableViewSection) {
        if index >= 0 && index < self.numberOfSections {
            self.sections.removeAtIndex(index)
            self.sections.insert(section, atIndex: index)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: Reload Sections
    
    public func reloadSections() {
        self.tableView.reloadData()
    }
    
    public func reloadSection(index: Int) {
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: .None)
    }
    
    public func reloadSectionsInRange(range: Range<Int>) {
        var rangeToReload = NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
        self.tableView.reloadSections(NSIndexSet(indexesInRange: rangeToReload), withRowAnimation: .None)
    }
    
    public func itemForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let dataSource = self.dataSourceForIndexPath(indexPath) {
            if !dataSource.isEmpty {
                return dataSource[indexPath.row]
            }
        }
        
        return nil
    }
    
    // MARK:
    // MARK: UITableView
    // MARK:
    // MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableSectionForIndex(section)?.numberOfRows ?? 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.tableSectionForIndex(section)?.title? ?? ""
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if let tableSection = self.tableSectionForIndexPath(indexPath) {
            var item: AnyObject? = self.itemForIndexPath(indexPath)
            let reuseIdentifier = tableSection.cellIdentifierBlock(item: item, indexPath: indexPath)
            
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell
            
            tableSection.cellConfigurationBlock(cell: cell, item: item, indexPath: indexPath)
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableSectionForIndex(section)?.headerConfigurationBlock?(section: section) ?? nil
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableSectionForIndex(section)?.footerConfigurationBlock?(section: section) ?? nil
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableSectionForIndex(section)?.sectionHeaderHeight ?? tableView.sectionHeaderHeight
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableSectionForIndex(indexPath.section)?.rowHeight ?? UITableViewAutomaticDimension
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableSectionForIndex(section)?.sectionFooterHeight ?? tableView.sectionFooterHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableSectionForIndex(indexPath.section)?.rowHeight ?? tableView.estimatedRowHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableSectionForIndex(section)?.sectionHeaderHeight ?? tableView.estimatedSectionHeaderHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return self.tableSectionForIndex(section)?.sectionFooterHeight ?? tableView.estimatedSectionFooterHeight
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableSectionForIndexPath(indexPath)?.selectionBlock?(cell: tableView.cellForRowAtIndexPath(indexPath)!, indexPath: indexPath)
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView!) {
        delegate?.tableViewDidScroll?(scrollView)
    }
}
