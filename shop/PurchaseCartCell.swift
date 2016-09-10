//
//  PurchaseCartCell.swift
//  shop
//
//  Created by goupigao on 16/9/3.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class PurchaseCartCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var guige: UILabel!
    @IBOutlet weak var countAndPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
