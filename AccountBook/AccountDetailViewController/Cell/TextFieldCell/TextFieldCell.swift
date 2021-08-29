//
//  TextFieldCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

class TextFieldCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
