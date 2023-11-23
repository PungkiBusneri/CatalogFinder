//
//  DetailCatalogViewController.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 21/11/23.
//

import UIKit

class DetailCatalogViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BasketViewControllerDelegate {

    var product: Product?
    var selectedImage: UIImage?
    var isInBasket: Bool?
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var basketProduct: UIButton!
    @IBOutlet var editDetailproduct: UIButton!
    @IBOutlet var imageProduct: UIImageView!
    @IBOutlet var productName: UILabel!
    @IBOutlet var productPrice: UILabel!
    @IBOutlet var productStock: UILabel!
    @IBOutlet var productDesc: UILabel!
    @IBOutlet var addToBasketProduct: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let product = product {
            updateUI(with: product)
            
            productName.text = product.productName
//            productPrice.text = "Price: \(product.productPrice) IDR"
            productStock.text = "Stock: \(product.productStock) Pcs"
            productDesc.text = product.productDesc
        }
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func basketProduct(_ sender: Any) {
        showShppingChart()
    }
    @IBAction func editDetailProductTapped(_ sender: Any) {
        showEditAlert()
    }
    @IBAction func addToBasketProductTapped(_ sender: Any) {
        print("tombol di tekan")
        guard let product = product, product.productStock > 0 else {
            
            return
        }
        BasketManager.shared.shoppingChart.append(product)
        product.isInBasket = true
        BasketManager.shared.saveShoppingChart()
        
        product.productStock -= 1
        updateUI(with: product)
        print("add to product to shopping Chart: \(product.productName ?? "")")
    }
    
    func showEditAlert() {
        let alert = UIAlertController(title: "Edit Produk", message: "Perbarui Detail Produk", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nama Produk"
            textField.text = self.product?.productName
        }
        let priceFormatter = NumberFormatter()
            priceFormatter.numberStyle = .currency
            priceFormatter.currencyCode = "IDR" // Kode mata uang Rupiah
            priceFormatter.minimumFractionDigits = 0
            priceFormatter.maximumFractionDigits = 0
        
        alert.addTextField { textField in
            textField.placeholder = "Harga"
            textField.keyboardType = .decimalPad
            if let productPrice = self.product?.productPrice {
               
//                textField.text = priceFormatter.string(from: NSNumber(value: productPrice))
            }
            textField.text = "\(self.product?.productPrice ?? 0.0)"
        }
        alert.addTextField { textField in
            textField.placeholder = "Deskripsi"
            textField.text = self.product?.productDesc
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Stok Produk"
            textField.keyboardType = .numberPad
            textField.text = "\(self.product?.productStock ?? 0)"
        }
        
        
        let selectedImageButton = UIAlertAction(title: "Pilih gambar", style: .default) { [weak self] (action) in
            self?.showImagePicker()
        }
        
        let submitButton = UIAlertAction(title: "Simpan Perubahan", style: .default) { [weak self] (action) in
            if let nameTextField = alert.textFields?[0],
               let priceTextField = alert.textFields?[1],
               let descriptionTextField = alert.textFields?[2],
               let stockTextField = alert.textFields?[3] {
                
                if let name = nameTextField.text, !name.isEmpty,
                   let price = Double(priceTextField.text ?? ""),
                   let description = descriptionTextField.text,
                   let stock = Int64(stockTextField.text ?? "") {
                    
                    self?.product?.productName = name
                    self?.product?.productPrice = price
                    self?.product?.productDesc = description
                    self?.product?.productStock = Int32(stock)
                    
                    if let selectedImage = self?.selectedImage {
                        // Convert image to Data
                        if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                            // Update the product's image data
                            self?.product?.productImage = imageData
                            
                        }
                    }
                    print("Before saving changes. product: \(self?.product)")
                    do {
                        try self?.product?.managedObjectContext?.save()
                        print("product berhasil di ubah")
                    } catch {
                        print("perubahan tidak tersimpan: \(error)")
                    }
                    print("After saving changes")
                    self?.updateUI(with: self?.product ?? Product())
                    
                }
            }
        }
        alert.addAction(selectedImageButton)
        alert.addAction(submitButton)
        alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            
            selectedImage = editImage
            imageProduct.image = editImage
            print("Memilih gambar berhasil")
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            imageProduct.image = originalImage
            print("Memilih gambar tidak berhasil")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func updateUI(with product: Product) {
        productName.text = product.productName
        productDesc.text = product.productDesc
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        numberFormatter.maximumFractionDigits = 0
        
        productPrice.text = "Harga: \(numberFormatter.string(from: NSNumber(value: product.productPrice)) ?? "")"
        productStock.text = "Stock: \(product.productStock)"
        
        
        if let imageData = product.productImage {
            imageProduct.image = UIImage(data: imageData)
        } else {
            imageProduct.image = UIImage(systemName: "camera.fill")
        }
    }
    func showShppingChart() {
        let basketViewController = BasketViewController(shoppingChart: BasketManager.shared.shoppingChart)
        basketViewController.delegate = self
        self.navigationController?.pushViewController(basketViewController, animated: true)
        BasketManager.shared.saveShoppingChart()
        
    }
    func productRemovedFromBasket(product: Product) {
        
        updateUI(with: product)
    }
}
