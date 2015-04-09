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
    optional func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)

    optional func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]!
}

public class TableViewDataSource: NSObject {
    @IBOutlet weak public var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    public weak var delegate: TableViewDataSourceDelegate?
    
    public internal(set) var sections: [TableViewSection] = []
    public var numberOfSections: Int {
        return sections.count
    }
    
    // MARK:
    // MARK: Section Management
    // MARK:
    
    public func dataSourceForIndexPath(indexPath: NSIndexPath) -> [AnyObject]? {
        return tableSectionForIndexPath(indexPath)?.objects
    }
    
    public func tableSectionForIndexPath(indexPath: NSIndexPath) -> TableViewSection? {
        return tableSectionForIndex(indexPath.section)
    }
    
    public func tableSectionForIndex(index: Int) -> TableViewSection? {
        if isValidIndex(index) {
            return sections[index]
        }
        
        return nil
    }
    
    // MARK: Add Sections
    
    public func addSections(sections: [TableViewSection]) {
        self.sections.extend(sections)
        
        for section in sections {
            section.dataSource = self
        }
        
        tableView.reloadData()
    }
    
    public func addSection(section: TableViewSection) {
        addSections([section])
    }
    
    public func insertSection(section: TableViewSection, atIndex index: Int) {
        sections.insert(section, atIndex: index)
        
        section.dataSource = self
        
        reloadSection(index)
    }
    
    // MARK: Delete Sections
    
    public func deleteAllSections() {
        for section in sections {
            section.dataSource = nil
        }
        
        sections.removeAll(keepCapacity: false)
        tableView.reloadData()
    }
    
    public func deleteSectionsInRange(range: Range<Int>) {
        println("Delete sections \(range.startIndex) to \(range.endIndex)")
        
        let objcRange = NSMakeRange(range.startIndex, range.endIndex - range.startIndex)
        
        println("Delete sections \(objcRange.location) to \(objcRange.location + objcRange.length)")
        
        let indexSet = NSIndexSet(indexesInRange: objcRange)
        tableView.deleteSections(indexSet, withRowAnimation: .None)
        
        // TODO: Set the sections controller to nil
    }
    
    public func deleteSectionAtIndex(index: Int) {
        if isValidIndex(index) {
            let section = self.sections[index]
            section.dataSource = nil
            
            sections.removeAtIndex(index)
            tableView.reloadData()
        }
    }
    
    // MARK: Hide Section
    
    public func hideSectionAtIndex(index: Int) {
        if isValidIndex(index) {
            sections[index].hide()
        }
    }
    
    public func hideSectionsInRange(range: Range<Int>) {
        for i in range {
            hideSectionAtIndex(i)
        }
    }
    
    // MARK: Show Sections
    public func showSectionAtIndex(index: Int) {
        if isValidIndex(index) {
            sections[index].show()
        }
    }
    
    // MARK: Replace Sections
    
    public func replaceSectionAtIndex(index: Int, withSection section: TableViewSection) {
        if isValidIndex(index) {
            deleteSectionAtIndex(index)
            insertSection(section, atIndex: index)
        }
    }
    
    // MARK: Reload Sections
    
    public func reloadSections() {
        tableView.reloadData()
    }
    
    public func reloadSection(index: Int, withRowAnimation animation: UITableViewRowAnimation? = .None) {
        let indexSet = NSIndexSet(index: index)
        tableView.reloadSections(indexSet, withRowAnimation: animation ?? .None)
    }
    
    public func reloadSectionsInRange(range: Range<Int>, withRowAnimation animation: UITableViewRowAnimation? = .None) {
        let rangeToReload = NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
        reloadSectionsInRange(rangeToReload, withRowAnimation: animation)
    }
    
    public func reloadSectionsInRange(range: NSRange, withRowAnimation animation: UITableViewRowAnimation? = .None) {
        let indexSet = NSIndexSet(indexesInRange: range)
        tableView.reloadSections(indexSet, withRowAnimation: animation!)
    }
    
    public func itemForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let dataSource = dataSourceForIndexPath(indexPath) {
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
        return numberOfSections
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSectionForIndex(section)?.numberOfRows ?? 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSectionForIndex(section)?.title ?? ""
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get the table section
        if let tableSection = tableSectionForIndexPath(indexPath) {
            assert(tableSection.cellIdentifier != nil, "A TableSection must implement cellIdentifierBlock")
            
            // Get the item
            let item: AnyObject? = itemForIndexPath(indexPath)
            
            // Get the cell's reuse identifier
            let reuseIdentifier = tableSection.cellIdentifier(item: item, indexPath: indexPath)
            
            // Dequeue a cell
            if let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? UITableViewCell {
                // Invoke the section's cell configuration
                tableSection.cellConfiguration?(cell: cell, item: item, indexPath: indexPath)
                
                // Update constraints
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                
                // Return the cell
                return cell
            }
        }
        
        // Return a default UITableViewCell
        return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableSectionForIndex(indexPath.section)?.canEditRowAtIndex(indexPath.row) ?? false
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return delegate?.sectionIndexTitlesForTableView?(tableView)
    }
    
}

// MARK: - UITableViewDelegate
extension TableViewDataSource: UITableViewDelegate {
    
    // MARK: Header and Footer View
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Get the section
        if let tableSection = tableSectionForIndex(section) {
            // If the section's not hidden...
            if !tableSection.hidden {
                // Invoke the section's headerConfiguration
                return tableSection.headerConfiguration?(section: section) ?? nil
            }
        }
        
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Get the section
        if let tableSection = tableSectionForIndex(section) {
            // If the section's not hidden
            if !tableSection.hidden {
                // Invoke the section's footerConfiguartion
                return tableSection.footerConfiguration?(section: section) ?? nil
            }
        }
        
        return nil
    }
    
    // MARK: View Height
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableSectionForIndex(indexPath.section)?.rowHeight ?? UITableViewAutomaticDimension
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeight: CGFloat = 0
        
        if let tableSection = tableSectionForIndex(section) {
            if !tableSection.hidden {
                headerHeight = tableSection.headerHeight
            }
        }
        
        return headerHeight
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var footerHeight: CGFloat = 0
        
        if let tableSection = tableSectionForIndex(section) {
            if !tableSection.hidden {
                footerHeight = tableSection.footerHeight
            }
        }
        
        return footerHeight
    }
    
    // MARK: Estimated View Height
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableSectionForIndex(indexPath.section)?.estimatedRowHeight ?? tableView.estimatedRowHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableSectionForIndex(section)?.headerHeight ?? tableView.estimatedSectionHeaderHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableSectionForIndex(section)?.footerHeight ?? tableView.estimatedSectionFooterHeight
    }
    
    // MARK: Selection
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            tableSectionForIndexPath(indexPath)?.cellSelection?(cell: cell, indexPath: indexPath)
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
