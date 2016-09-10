//
//  CartCartCell.swift
//  shop
//
//  Created by goupigao on 16/9/3.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class CartCartCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var couponPrice: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var count: UILabel!
    var index:Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        stepper.tintColor = MyColor.green
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
