//
//  HomeViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/14/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

private let reuseIdentifer = "Cell"

protocol MindMapDataProtocol {
    var filePath: String { get set }
}

class HomeViewController: UIViewController, MindMapDataProtocol {
    
    @IBOutlet weak var previewCollectionView: UICollectionView!
    var filePath: String = ""
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the collectionView Delegate and DataSource
        previewCollectionView.delegate = self
        previewCollectionView.dataSource = self
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as? ViewAndEditViewController
        vc?.delegate = self
    }

}

// MARK: - Collection View Delegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        print("Selected: " + String(cell.tag))
        
        guard let view = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? UIView else { return }
        guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
        controller.customView = view
        controller.delegate = self
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Collection View DataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        // Return the Number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return the number of items
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! HomePreviewCollectionViewCell
        cell.previewImageView.image = UIImage(named: "image1")
        cell.tag = count
        count += 1
        
        // Configure the cell
        return cell

        
    }
    
}
