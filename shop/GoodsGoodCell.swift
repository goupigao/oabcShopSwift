//
//  GoodsGoodCell.swift
//  shop
//
//  Created by goupigao on 16/9/2.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Kingfisher

class GoodsGoodCell: UICollectionViewCell {
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var goodImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var couponPrice: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var id:Int = 0
    var imageTask:RetrieveImageTask?
}
