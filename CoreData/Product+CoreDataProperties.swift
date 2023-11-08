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

    @NSManaged public var productName: String?
    @NSManaged public var productPrice: Int64
    @NSManaged public var productDesc: String?

}

extension Product : Identifiable {

}
