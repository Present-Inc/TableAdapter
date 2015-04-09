//
//  ViewController.swift
//  TableAdapterExample
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import UIKit
import TableAdapter

let testData = [
    "This is an example string that contains more than 140 characters. If I use PHPs substring function it will split it in the middle of this word.",
    "These",
    "are",
    "from",
    "the",
    "data",
    "source",
    "and",
    "the",
    "thing",
    "they",
    "call",
    "my",
    "mind"
]

class ViewController: UIViewController, TableViewDataSourceDelegate {
    @IBOutlet private var tableView: UITableView!
    
    let tableDataSource = TableViewDataSource()
    let sectionOne = TableViewSection()
    
    var tableHeaderView: TableHeaderView?
    
    var dataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If not using storyboards or .xib's, cell classes must be manually registered with table view
        tableView.registerNib(TableViewCell.nib(), forCellReuseIdentifier: "TestCell")
        tableView.registerNib(TableSectionHeaderView.nib(), forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        // !!!: You must set the TableViewDataSource tableView
        tableDataSource.tableView = tableView
        tableDataSource.delegate = self
        
        // !!!: Configure the section
        sectionOne.objects = dataSource
        sectionOne.cellIdentifier = { _, _ in return "TestCell" }
        sectionOne.cellConfiguration = cellConfiguration
        sectionOne.cellSelection = cellSelectionBlock
        sectionOne.estimatedRowHeight = 100
        sectionOne.canEditRow = { _ in return false }
        
        tableDataSource.addSection(sectionOne)
    }
    
    func headerConfiguration(section: Int) -> UIView {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as! TableSectionHeaderView
        // TODO: These should be configured with a view model
        headerView.titleLabel.text = "Hey man!"
        headerView.subtitleLabel.text = "What's up?"
        
        return headerView
    }
    
    func cellConfiguration(cell: UITableViewCell, item: AnyObject?, indexPath: NSIndexPath) {
        let labelString = item as? String
        
        if let cell = cell as? TableViewCell {
            cell.label.text = labelString!
        }
    }
    
    func footerConfiguration(section: Int) -> UIView {
        // ???: You could just make another .xib for the footer
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as! TableSectionHeaderView
        footerView.titleLabel.text = "This is the footer view"
        footerView.subtitleLabel.hidden = true
        
        return footerView
    }
    
    func cellSelectionBlock(cell: UITableViewCell, indexPath: NSIndexPath) {
        deleteCellAtIndex(indexPath.row)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        deleteCellAtIndex(indexPath.row)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        var titles = [UITableViewIndexSearch, "#"]
        
        for title in UILocalizedIndexedCollation.currentCollation().sectionTitles as! [String] {
            titles.append(title)
        }
        
        return titles
    }
    
    func deleteCellAtIndex(index: Int) {
        dataSource.removeAtIndex(index)
        sectionOne.removeObjectAtIndex(index)
    }

    @IBAction func hideSectionButtonPressed(sender: AnyObject) {
        sectionOne.hidden ? sectionOne.show() : sectionOne.hide()
    }
    
    @IBAction func addRowPressed(sender: AnyObject) {
        let index = dataSource.count
        if index >= testData.count {
            return
        }
        
        let newItem = testData[index]
        dataSource.append(newItem)
        sectionOne.addObject(newItem)
    }

}

