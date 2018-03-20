//
//  HomeViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/14/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifer = "Cell"

class HomeViewController: UIViewController {
    
    @IBOutlet weak var previewCollectionView: UICollectionView!
    let Db = DbContext.sharedInstance
    var alertController: UIAlertController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the collectionView Delegate and DataSource
        previewCollectionView.delegate = self
        previewCollectionView.dataSource = self
        self.navigationController?.delegate = self
        
        // Configure the navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.blue
        self.navigationItem.title = "Mind Map Library"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sortByButton(_ sender: UIButton) {
        
        // Get all of the mind maps
        let mindMaps = Db.fetchAllMindMaps()
        
        // Sort the mind maps accordingly
        let ascendingTitleSorted = mindMaps.sorted(by: {(mm1, mm2) in
            
            guard let title1 = mm1.title else { return false}
            guard let title2 = mm2.title else { return true}
            
            return title1 < title2
        })
    }
}
    
// MARK: - Navigation
extension HomeViewController {
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let vc = segue.destination as? ViewAndEditViewController else { return }
        
        // Create an alert for the name of Mind Map
        // Create an alert controller for the section deletion
        let alertController = UIAlertController(title: "Name of New Mind Map", message: "Enter the Name of your New Mind Map", preferredStyle: UIAlertControllerStyle.alert)
        
        // Have the User enter the mind map name
        let enterName = UIAlertAction(title: "Name Input", style: .default, handler: { (alertAction) in
            let textField = alertController.textFields![0] as UITextField
            print(textField)
            })
        
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter new Mind Map Name"
        })
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
            self.previewCollectionView.reloadData()
            
        })
        
        alertController.addAction(enterName)
        alertController.addAction(deleteAction)
        self.alertController = alertController
        
        // Present the alert
        self.present(self.alertController!, animated: true, completion: nil)
        
    }
 
}

extension HomeViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.previewCollectionView.reloadData()
    }
}

// MARK: - Collection View Delegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get the view that from the file path
        let filePath = Db.fetchAllFilePaths()
        guard let view = NSKeyedUnarchiver.unarchiveObject(withFile: filePath[indexPath.row]) as? UIView else { return }
        print(indexPath.row)
        
        // Create a new view controller
        guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
        
        // Set up the controller
        controller.customView = view
        controller.path = filePath[indexPath.row]
        
        // Show the controller
        self.navigationController?.pushViewController(controller, animated: true)
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
        return Db.fetchAllFilePaths().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! HomePreviewCollectionViewCell
        
        // Put the corresponding image on the cell
        cell.previewImageView.image = UIImage(named: "image1")
        
        // Add a long press gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.numberOfTapsRequired = 0
        longPress.numberOfTouchesRequired = 1
        longPress.minimumPressDuration = CFTimeInterval(1)
        cell.addGestureRecognizer(longPress)
        
        // Return the finished cell
        return cell  
    }
    
}

// MARK: - Gestures
extension HomeViewController {
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        // Get the indexPath of the touchPoint
        let touchPoint: CGPoint = recognizer.location(in: self.previewCollectionView)
        guard let indexPath: IndexPath = self.previewCollectionView.indexPathForItem(at: touchPoint) else { return }
        
        // Get the filePath to delete
        let filePath = Db.fetchAllFilePaths()[indexPath.row]
        
        // Create an alert controller for the section deletion
        self.alertController = UIAlertController(title: "Delete Section", message: "Would you like to delete this Mind Map?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
            // Get the section to delete
            guard let section = recognizer.view else { return }
            
            // Remove the section from the view hiearchy
            section.removeFromSuperview()
            
            // Remove the mind map
            self.Db.deleteMindMapSection(filePath: filePath)
            
            self.previewCollectionView.reloadData()
            
        })
        
        self.alertController?.addAction(cancelAction)
        self.alertController?.addAction(deleteAction)
        
        // Present the alert
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
}

// MARK: - Navigation
extension HomeViewController {
    
    @objc func handleBackButton() {
        print("handleBackButton")
    }
}
