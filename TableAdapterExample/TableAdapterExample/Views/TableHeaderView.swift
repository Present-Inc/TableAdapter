//
//  TableHeaderView.swift
//  TableAdapterExample
//
//  Created by Justin Makaila on 10/6/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

import UIKit

class TableHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var button: UIButton!
    
    var buttonPressed: ((UIButton) -> ())?
    
    class func nib() -> UINib {
        return UINib(nibName: "TableHeaderView", bundle: nil)
    }
    
    @IBAction func _buttonPressed(sender: UIButton) {
        self.buttonPressed?(sender)
    }
}
