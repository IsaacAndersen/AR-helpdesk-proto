//
//  ScenarioTableViewCell.swift
//  AR-helpdesk-proto
//
//  Created by ANDERSEN, ISAAC L on 8/15/17.
//  Copyright © 2017 IsaacAndersen. All rights reserved.
//

import UIKit

class ScenarioTableViewCell: UITableViewCell {
    //MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
