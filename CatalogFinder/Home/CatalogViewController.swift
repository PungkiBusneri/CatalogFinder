//
//  CatalogViewController.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 07/11/23.
//

import UIKit
import CoreData

class CatalogViewController: UIViewController, UITextFieldDelegate, BasketViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var searchbar: UITextField!
    @IBOutlet var catalogList: UITableView!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    private let cellIdentifier = "CatalogTableViewCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let basketViewController = BasketViewController(shoppingChart: BasketManager.shared.shoppingChart)
    
    var items: [Product]?
    var filteredItems: [Product]?
    var isFavorite: Bool?
    var selectedImage: UIImage?
    var productImage: Data?
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catalogList.dataSource = self
        catalogList.delegate = self
        fecthProduct()
        
        searchbar.delegate = self
        let placeholdertext = "Cari di sini"
        let placeholderColor = UIColor.white
        
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor]
        searchbar.attributedPlaceholder = NSAttributedString(string: placeholdertext, attributes: placeholderAttributes)
        
        searchbar.textColor = UIColor.white
        
        let nib = UINib(nibName: "CatalogTableViewCell", bundle: nil)
        catalogList.register(nib, forCellReuseIdentifier: "CatalogTableViewCell")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        backButton.isHidden = true
        
        //        MARK: - For Button Shopping Chart Product
        let shoppingChartButton = UIButton(type: .system)
        shoppingChartButton.setImage(UIImage(systemName: "basket"), for: .normal)
        shoppingChartButton.addTarget(self, action: #selector(buttonShoppingChart), for: .touchUpInside)
        view.addSubview(shoppingChartButton)
        
        shoppingChartButton.translatesAutoresizingMaskIntoConstraints = false
        
        //        MARK: - For auto layout shopping chart button
        shoppingChartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14).isActive = true
        shoppingChartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 244).isActive = true
        shoppingChartButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        shoppingChartButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        shoppingChartButton.tintColor = .red
    }
    
    @objc func buttonShoppingChart() {
        showBasket()
    }
    
    func productRemovedFromBasket(product: Product) {
        print("Product removed from basket: \(product.productName)")
    }
    
    func showBasket() {
        let basketViewController = BasketViewController(shoppingChart: BasketManager.shared.shoppingChart)
        basketViewController.delegate = self
        self.navigationController?.pushViewController(basketViewController, animated: true)
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
    @IBAction func backButtonTapped(_ sender: Any) {
        print("button was connect")
        let newViewController = CatalogViewController()
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func favoriteProductTapped(_ sender: Any) {
        print("isFavoriteTapped was called")
        
        if let isfilteringFavorite = filteredItems?.first?.isFavorite {
            if isfilteringFavorite {
                
                filteredItems = filteredItems?.filter{ $0.isFavorite }
            } else {
                filteredItems = items?.filter { $0.isFavorite }
            }
        } else {
            filteredItems = items?.filter { $0.isFavorite }
        }
        backButton.isHidden = false
        catalogList.reloadData()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Tambah Produk", message: "Masukan Detail produk anda disini", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Nama Produk"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Harga"
            textField.keyboardType = .decimalPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Deskripsi"
            
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Stock Produk"
            textField.keyboardType = .numberPad
        }
        
        let imagePickerButton = UIAlertAction(title: "Tambah Gambar", style: .default) { [weak self] (action) in
            self?.alert = alert
            self?.showImagePickerForNewProduct(alert: alert)
        }
        let submitButton = UIAlertAction(title: "Tambah", style: .default) { (action) in
            
            let nameTextField = alert.textFields![0]
            let priceTextField = alert.textFields![1]
            let descriptionTextField = alert.textFields![2]
            let stockTextField = alert.textFields![3]
            
            if let name = nameTextField.text, !name.isEmpty,
               let price = Double(priceTextField.text ?? ""),
               let description = descriptionTextField.text,
               let stock = Int32(stockTextField.text ?? "") {
                
                let newProduct = Product(context: self.context)
                newProduct.productName = name
                newProduct.productDesc = description
                newProduct.productPrice = price
                newProduct.productStock = Int32(stock)
                
                if let selectedImage = self.selectedImage {
                    newProduct.productImage = selectedImage.jpegData(compressionQuality: 1.0)
                }
                
                do {
                    try self.context.save()
                    print("berhasil di simpan")
                }
                catch {
                }
                self.fecthProduct()
            } else {
                let emptyFieldALert = UIAlertController(title: " Informasi tidak valid", message: "Tolong lengkapi semua detail produk", preferredStyle: .alert)
                emptyFieldALert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyFieldALert, animated: true, completion: nil)
            }
        }
        
        alert.addAction(imagePickerButton)
        alert.addAction(submitButton)
        alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showImagePickerForNewProduct(alert: UIAlertController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            selectedImage = editImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
//        Dismiss alert after selected image
        picker.dismiss(animated: true)
        self.present(self.alert!, animated: true, completion: nil)
    }
}
    
    extension CatalogViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return filteredItems?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatalogTableViewCell
            
            let product = self.filteredItems![indexPath.row]
            
            if let imageData = product.productImage, let image = UIImage(data: imageData) {
                cell.imageViewProduct.image = image
            } else {
                cell.imageViewProduct.image = UIImage(systemName: "camera.fill")
            }
            
            cell.priceLabel.text = product.formattedPrice
            cell.labelNameProduct.text = product.productName
            cell.delegate = self
            cell.addToFavorit.tintColor = UIColor.systemGray6
            
            if product.isFavorite {
                cell.addToFavorit.setImage(UIImage(named: "heart.fill"), for: .normal)
                cell.addToFavorit.tintColor = UIColor.systemRed
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let product = self.filteredItems![indexPath.row]
            let detailVC = DetailCatalogViewController(nibName: "DetailCatalogViewController", bundle: nil)
            detailVC.product = product
            
            self.navigationController?.pushViewController(detailVC, animated: true)

        }
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Izinkan pengeditan untuk setiap sel di dalam tabel
            return true
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
            backButton.isHidden = false
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
                
                let productID = product.objectID
                
                if let managedProduct = try? context.existingObject(with: productID) as? Product {
                    managedProduct.isFavorite.toggle()
                    
                    if managedProduct.isFavorite {
                        print("product \(managedProduct.productName ?? "") was add")
                    } else {
                        print("cannot \(managedProduct.productName ?? "") to add this product")
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    print("Error saving product to favorites: \(error)")
                }
                
                if product.isFavorite {
                    cell.addToFavorit.setImage(UIImage(named: "heart.fill"), for: .normal)
                    cell.addToFavorit.tintColor = UIColor.systemRed
                } else {
                    
                    cell.addToFavorit.setImage(UIImage(named: "heart"), for: .normal)
                    cell.addToFavorit.tintColor = UIColor.systemGray6
                }
            }
        }
    }
}
