//
//  BasketManager.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 21/11/23.
//

import Foundation
import UIKit
import CoreData

class BasketManager {
    static let shared = BasketManager()
    var shoppingChart: [Product] = []
    var isInBasket: Bool?
    
    public var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init () {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    func saveShoppingChart() {
        do {
            try context.save()
        } catch {
            print("product tidak berhasil di simpan: \(error)")
        }
    }
    
    func loadShoppingChart() {
        do {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            request.predicate = NSPredicate(format: "isInBasket == YES")
            self.shoppingChart = try context.fetch(request)
            print("Number of product in shopping chart : \(self.shoppingChart.count)")
        } catch {
            print("erro loading shopping chart: \(error)")
            self.shoppingChart = []
        }
    }
}
