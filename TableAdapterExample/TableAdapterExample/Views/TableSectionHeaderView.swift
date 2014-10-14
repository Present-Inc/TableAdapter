//
//  TableSectionHeaderView.swift
//  TableAdapterExample
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import UIKit

class TableSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "TableSectionHeaderView", bundle: nil)
    }
}
