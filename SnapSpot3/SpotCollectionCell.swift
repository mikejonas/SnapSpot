//
//  SpotCollectionCell.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 8/11/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class SpotCollectionCell: UICollectionViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        monthLabel.text = "1"
        dayLabel.text = "1"
        locationLabel.text = ".."
        imageThumbnail.image = nil
    }
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageThumbnail: UIImageView!
}
