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
    optional func scrollViewDidScroll(scrollView: UIScrollView)
    optional func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    optional func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    optional func scrollViewDidEndDecelerating(scrollView: UIScrollView)
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
        
        for section in sections {
            section.dataSource = self
        }
        
        self.tableView.reloadData()
    }
    
    public func addSection(section: TableViewSection) {
        self.addSections([section])
    }
    
    public func insertSection(section: TableViewSection, atIndex index: Int) {
        self.sections.insert(section, atIndex: index)
        
        section.dataSource = self
        
        self.reloadSection(index)
    }
    
    // MARK: Delete Sections
    
    public func deleteAllSections() {
        for section in sections {
            section.dataSource = nil
        }
        
        self.sections.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    public func deleteSectionsInRange(range: Range<Int>) {
        println("Delete sections \(range.startIndex) to \(range.endIndex)")
        
        var objcRange = NSMakeRange(range.startIndex, range.endIndex - range.startIndex)
        
        println("Delete sections \(objcRange.location) to \(objcRange.location + objcRange.length)")
        
        var indexSet = NSIndexSet(indexesInRange: objcRange)
        self.tableView.deleteSections(indexSet, withRowAnimation: .None)
        
        // TODO: Set the sections controller to nil
    }
    
    public func deleteSectionAtIndex(index: Int) {
        if isValidIndex(index) {
            let section = self.sections[index]
            section.dataSource = nil
            
            self.sections.removeAtIndex(index)
            self.reloadSection(index)
        }
    }
    
    // MARK: Hide Section
    
    public func hideSectionAtIndex(index: Int) {
        if isValidIndex(index) {
            self.sections[index].hide()
        }
    }
    
    public func hideSectionsInRange(range: Range<Int>) {
        for i in range {
            self.hideSectionAtIndex(i)
        }
    }
    
    // MARK: Show Sections
    public func showSectionAtIndex(index: Int) {
        if isValidIndex(index) {
            self.sections[index].show()
        }
    }
    
    // MARK: Replace Sections
    
    public func replaceSectionAtIndex(index: Int, withSection section: TableViewSection) {
        if isValidIndex(index) {
            self.deleteSectionAtIndex(index)
            self.insertSection(section, atIndex: index)
        }
    }
    
    // MARK: Reload Sections
    
    public func reloadSections() {
        self.tableView.reloadData()
    }
    
    public func reloadSection(index: Int, withRowAnimation animation: UITableViewRowAnimation = .None) {
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: animation)
    }
    
    public func reloadSectionsInRange(range: Range<Int>, withRowAnimation animation: UITableViewRowAnimation = .None) {
        let rangeToReload = NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
        self.reloadSectionsInRange(rangeToReload, withRowAnimation: animation)
    }
    
    public func reloadSectionsInRange(range: NSRange, withRowAnimation animation: UITableViewRowAnimation = .None) {
        self.tableView.reloadSections(NSIndexSet(indexesInRange: range), withRowAnimation: animation)
    }
    
    public func itemForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let dataSource = self.dataSourceForIndexPath(indexPath) {
            if !dataSource.isEmpty {
                return dataSource[indexPath.row]
            }
        }
        
        return nil
    }

}

// MARK: - UITableViewDataSource
extension TableViewDataSource: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableSectionForIndex(section)?.numberOfRows ?? 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.tableSectionForIndex(section)?.title? ?? ""
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let tableSection = self.tableSectionForIndexPath(indexPath) {
            assert(tableSection.cellIdentifierBlock != nil, "A TableSection must implement cellIdentifierBlock")
            
            let item: AnyObject? = self.itemForIndexPath(indexPath)
            let reuseIdentifier = tableSection.cellIdentifierBlock(item: item, indexPath: indexPath)
            
            if let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? UITableViewCell {
                tableSection.cellConfigurationBlock?(cell: cell, item: item, indexPath: indexPath)
                
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                
                return cell
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
}

// MARK: - UITableViewDelegate
extension TableViewDataSource: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let tableSection = self.tableSectionForIndex(section) {
            if !tableSection.hidden {
                return tableSection.headerConfigurationBlock?(section: section) ?? nil
            }
        }
        
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let tableSection = self.tableSectionForIndex(section) {
            if !tableSection.hidden {
                return tableSection.footerConfigurationBlock?(section: section) ?? nil
            }
        }
        
        return nil
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = self.tableSectionForIndex(section) {
            if !tableSection.hidden {
                return tableSection.sectionHeaderHeight ?? 0
            }
        }
        
        return 0
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableSectionForIndex(indexPath.section)?.rowHeight ?? UITableViewAutomaticDimension
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableSectionForIndex(section)?.sectionFooterHeight ?? 0
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
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            self.tableSectionForIndexPath(indexPath)?.selectionBlock?(cell: cell, indexPath: indexPath)
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
}

private extension TableViewDataSource {
    func isValidIndex(index: Int) -> Bool {
        return index >= 0 && index < numberOfSections
    }
}
