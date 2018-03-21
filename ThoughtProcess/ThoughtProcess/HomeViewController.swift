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
    var mindMaps: [MindMapSection] {
        
        get {
            // Return the mind maps from core data
            // Pass in the sorting parameter
            return Db.fetchAllMindMaps()
        }
        
        set {
            self.mindMaps = newValue
        }
    }

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
        
        // Create an action sheet for the different sorting methods
        let alertController = UIAlertController(title: "Sort Mind Maps", message: "Choose how you want your Mind Maps sorted", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let ascendingTitle = UIAlertAction(title: "Ascending Title", style: UIAlertActionStyle.default, handler: { (alertAction) in
            // Sort the mind maps accordingly
            let ascendingTitleSorted = mindMaps.sorted(by: {(mm1, mm2) in
                
                guard let title1 = mm1.title else { return false }
                guard let title2 = mm2.title else { return true }
                
                return title1 < title2
            })
            
            print(ascendingTitleSorted.first?.title)
        })
        
        alertController.addAction(ascendingTitle)
        alertController.popoverPresentationController?.sourceView = self.view
        
        self.present(alertController, animated: true, completion: {
            self.previewCollectionView.reloadData()
        })
    }
    
    
    @IBAction func createNewMindMap(_ sender: UIButton) {
        // Create an alert for the name of Mind Map
        // Create an alert controller for the section deletion
        let alertController = UIAlertController(title: "Name of New Mind Map", message: "Enter the Name of your New Mind Map", preferredStyle: UIAlertControllerStyle.alert)
        var title = Date().description
        
        // Have the User enter the mind map name
        let enterName = UIAlertAction(title: "Name Input", style: .default, handler: { (alertAction) in
            
            guard let textField = alertController.textFields?.first else { return }
            guard let name = textField.text else { return }
            title = name
            
            // Create a new view controller
            guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
            
            // Set up the controller with the correct title
            controller.title = title
            
            // Show the controller
            self.navigationController?.pushViewController(controller, animated: true)
            
        })
        
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter new Mind Map Name"
        })
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
        })
        
        alertController.addAction(enterName)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        
    }}
    
// MARK: - Navigation
extension HomeViewController {
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // guard let vc = segue.destination as? ViewAndEditViewController else { return }
        
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
        let mindMap = Db.fetchAllMindMaps()[indexPath.row]
        guard let filePath: String = mindMap.filePath else { return }
        guard let title: String = mindMap.title else { return }
        
        guard let view = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? UIView else { return }
        print(indexPath.row)
        
        // Create a new view controller
        guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
        
        // Set up the controller
        controller.customView = view
        controller.path = filePath
        controller.title = title
        
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
