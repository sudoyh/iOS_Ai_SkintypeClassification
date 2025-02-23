//
//  AnalysisTableCell.swift
//  Acos3
//
//  Created by Nasrullah Khan on 03/07/2021.
//

import UIKit

class AnalysisTableCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var sensitivityLbl: UILabel!
    @IBOutlet weak var poreLbl: UILabel!
    @IBOutlet weak var oilLbl: UILabel!
    @IBOutlet weak var dryLbl: UILabel!
    @IBOutlet weak var pigmentLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
