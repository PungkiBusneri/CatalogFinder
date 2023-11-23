//
//  BasketViewController.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 21/11/23.
//

import UIKit

protocol BasketViewControllerDelegate: class {
    func productRemovedFromBasket(product: Product)
}

class BasketViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var backButton: UIButton!
    
    var product: Product?
    var shoppingChart: [Product] = []
    weak var delegate: BasketViewControllerDelegate?
    
    private let cellIdentifier = "CatalogTableViewCell"
    
    init(shoppingChart: [Product], delegate: BasketViewControllerDelegate? = nil) {
        super.init(nibName: "BasketViewController", bundle: nil)
        self.shoppingChart = shoppingChart
        self.delegate = delegate
    }
    required init?(coder eDecoder: NSCoder) {
        super.init(coder: eDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "CatalogTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        BasketManager.shared.loadShoppingChart()
    }
    
    func updateUI(with product: Product) {
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func removeFromShopingChart(product: Product) {
        guard let index = shoppingChart.firstIndex(where: { $0.id == product.id}) else {
            return
        }
        
        let removedProduct = shoppingChart.remove(at: index)
        product.productStock += 1
        updateUI(with: product)
        product.isInBasket = false
        BasketManager.shared.saveShoppingChart()
        delegate?.productRemovedFromBasket(product: removedProduct)
        
        print("Removing Product From Shopping Chart: \(product.productName)")
    }
    
}
extension BasketViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingChart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatalogTableViewCell
        let product = shoppingChart[indexPath.row]
        
        cell.priceLabel.text = product.formattedPrice
        
        if let imageData = product.productImage, let image = UIImage(data: imageData) {
            cell.imageViewProduct.image = image
        } else {
            cell.imageViewProduct.image = UIImage(named: "camera.fill")
        }
        cell.configure(with: product)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
        let action = UIContextualAction(style: .destructive, title: "Hapus") { (action, view, completionhandler) in
            let productToRemove = self.shoppingChart[indexPath.row]
            self.removeFromShopingChart(product: productToRemove)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionhandler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
