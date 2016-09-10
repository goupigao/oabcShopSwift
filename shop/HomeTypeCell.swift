//
//  HomeTypeCell.swift
//  shop
//
//  Created by goupigao on 16/9/1.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class HomeTypeCell: UITableViewCell {
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    var index:Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
