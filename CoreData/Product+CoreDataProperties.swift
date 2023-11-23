//
//  Product+CoreDataProperties.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 07/11/23.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var productDesc: String?
    @NSManaged public var productName: String?
    @NSManaged public var productPrice: Double
    @NSManaged public var productStock: Int32
    @NSManaged public var isFavorite: Bool
    @NSManaged public var productImage: Data?
    @NSManaged public var isInBasket: Bool
    
//    MARK: - Mengatur Mata uang tampilan Cell Table
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR" 
        return formatter.string(from: NSNumber(value: productPrice)) ?? ""
    }
}

extension Product : Identifiable {

}
