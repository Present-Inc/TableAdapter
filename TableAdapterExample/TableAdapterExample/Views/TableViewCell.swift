//
//  TableViewCell.swift
//  TableAdapterExample
//
//  Created by Justin Makaila on 1/12/15.
//  Copyright (c) 2015 Present. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "TableViewCell", bundle: nil)
    }
}
