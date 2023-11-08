//
//  CatalogTableViewCell.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 07/11/23.
//

import UIKit

protocol CatalogTableViewCellDelegate: AnyObject {
    func addToFavoriteButtonTapped(cell: CatalogTableViewCell)
}

class CatalogTableViewCell: UITableViewCell {
    
    @IBOutlet var imageViewProduct: UIImageView!
    @IBOutlet var labelNameProduct: UILabel!
    @IBOutlet var addToFavorit: UIButton!
    
    weak var delegate: CatalogTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageViewProduct.layer.cornerRadius = 4
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        delegate?.addToFavoriteButtonTapped(cell: self)
    }
}
