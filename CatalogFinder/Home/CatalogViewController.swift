//
//  CatalogViewController.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 07/11/23.
//

import UIKit
import CoreData

class CatalogViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var searchbar: UITextField!
    @IBOutlet var catalogList: UITableView!
    @IBOutlet var favoriteButton: UIButton!
    
    private let cellIdentifier = "CatalogTableViewCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Product]?
    var filteredItems: [Product]?
    var dummyData: [Product]?
    var isFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catalogList.dataSource = self
        catalogList.delegate = self
        fecthProduct()
        
        searchbar.delegate = self
        let placeholdertext = "Search Product Here"
        let placeholderColor = UIColor.white
        
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor]
        searchbar.attributedPlaceholder = NSAttributedString(string: placeholdertext, attributes: placeholderAttributes)
        
        searchbar.textColor = UIColor.white
        
      let nib = UINib(nibName: "CatalogTableViewCell", bundle: nil)
        catalogList.register(nib, forCellReuseIdentifier: "CatalogTableViewCell")
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func fecthProduct() {
        do {
            self.items = try context.fetch(Product.fetchRequest())
            self.filteredItems = self.items
            DispatchQueue.main.async {
                self.catalogList.reloadData()
            }
        }
        catch {
            
        }
    }
    
    @IBAction func favoriteProductTapped(_ sender: Any) {
        isFavorite = true
        catalogList.reloadData()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Product", message: "What this product name?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let textfield = alert.textFields![0]
            
            let newProduct = Product(context: self.context)
            newProduct.productName = textfield.text
            newProduct.productDesc = "Description"
            newProduct.productPrice = 2000000
            
            do {
                try self.context.save()
            }
            catch {
            }
            self.fecthProduct()
        }
        
        alert.addAction(submitButton)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CatalogViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFavorite == true {
            return dummyData?.count ?? 0
        } else {
            return filteredItems?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatalogTableViewCell
        
        let product = self.filteredItems![indexPath.row]
        cell.labelNameProduct.text = product.productName
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let product = self.filteredItems![indexPath.row]
        
        let alert = UIAlertController(title: "Edit product", message: "Edit product name", preferredStyle: .alert)
        alert.addTextField()
        
        let textfield = alert.textFields![0]
        textfield.text = product.productName
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            let textfield = alert.textFields![0]
            
            product.productName = textfield.text
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fecthProduct()
        }
        alert.addAction(saveButton)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let productToRemove = self.items![indexPath.row]
            
            self.context.delete(productToRemove)
            
            do {
                try self.context.save()
            } catch {
                
            }
            self.fecthProduct()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func filterContentForSearchtext(_ searchText: String) {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items?.filter { $0.productName?.lowercased().contains(searchText.lowercased()) ?? false }
        }
        catalogList.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        filterContentForSearchtext(currentText)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchbar.placeholder = nil
    }
}

extension CatalogViewController: CatalogTableViewCellDelegate {
    
    func addToFavoriteButtonTapped(cell: CatalogTableViewCell) {
        
        if let indexPath = catalogList.indexPath(for: cell) {
            
            if let filteredItems = filteredItems, indexPath.row < filteredItems.count {
                
                let product = filteredItems[indexPath.row]
                
                let favoriteProduct = Product(context: context)
                
                favoriteProduct.productName = product.productName
                do {
                    try context.save()
                } catch {
                    print("Error saving product to favorites: \(error)")
                }
                
                cell.addToFavorit.setImage(UIImage(named: "heart.fill"), for: .normal)
                cell.addToFavorit.isEnabled = false
            }
        }
    }
}
