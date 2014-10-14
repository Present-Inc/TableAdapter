//
//  ViewController.swift
//  TableAdapterExample
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import UIKit
import TableAdapter

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var tableDataSource = TableViewDataSource()
    
    var tableHeaderView: TableHeaderView?
    
    let dataSource = [
        "These",
        "are",
        "from",
        "the",
        "data",
        "source"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupHeaderView()
        
        // If not using storyboards or .xib's, cell classes must be manually registered with table view
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TestCell")
        tableView.registerNib(TableSectionHeaderView.nib(), forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        // !!!: You must set the TableViewDataSource tableView
        tableDataSource.tableView = tableView
        
        // !!!: Configure the section
        var sectionOne = TableViewSection()
        sectionOne.objects = dataSource
        sectionOne.rowHeight = 50
        sectionOne.sectionHeaderHeight = 75
        sectionOne.sectionFooterHeight = 15
        sectionOne.cellIdentifierBlock = { _, _ in return "TestCell" }
        sectionOne.headerConfigurationBlock = headerConfiguration
        sectionOne.cellConfigurationBlock = cellConfiguration
        sectionOne.footerConfigurationBlock = footerConfiguration
        sectionOne.selectionBlock = cellSelectionBlock
        
        tableDataSource.addSection(sectionOne)
    }
    
    func setupHeaderView() {
        if tableHeaderView == nil {
            tableHeaderView = TableHeaderView.nib().instantiateWithOwner(self, options: nil).first as? TableHeaderView
            tableHeaderView?.button.hidden = true
        }
        
        self.tableHeaderView?.frame = CGRectMake(0, 0, 320, 300)
        
        self.tableView.tableHeaderView = self.tableHeaderView
    }
    
    func headerConfiguration(section: Int) -> UIView {
        var headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as TableSectionHeaderView
        // TODO: These should be configured with a view model
        headerView.titleLabel.text = "Hey man!"
        headerView.subtitleLabel.text = "What's up?"
        
        return headerView
    }
    
    func cellConfiguration(cell: UITableViewCell, item: AnyObject?, indexPath: NSIndexPath) {
        if let item = item as? String {
            cell.textLabel?.text = item
        }
    }
    
    func footerConfiguration(section: Int) -> UIView {
        // ???: You could just make another .xib for the footer
        var footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as TableSectionHeaderView
        footerView.titleLabel.text = "This is the footer view"
        footerView.subtitleLabel.hidden = true
        
        return footerView
    }
    
    func cellSelectionBlock(cell: UITableViewCell, indexPath: NSIndexPath) {
        println("You selected \(cell) in section \(indexPath.section) at row \(indexPath.row)")
    }

}

