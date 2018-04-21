//
//  HomeViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/14/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit
import CoreData

enum MindMapSorting {
    case ascendingAlpha
    case descendingAlpha
    case ascendingDate
    case descendingDate
}

private let reuseIdentifer = "Cell"

class HomeViewController: UIViewController {
    
    // View Properties
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var sortByBarButton: UIBarButtonItem!
    
    
    // Control Properies
    let defaults = UserDefaults.standard
    
    @IBAction func account(_ sender: UIBarButtonItem) {
        // Create a View Controller and present it
        guard let controller = UIStoryboard(name: "AccountPage", bundle: nil).instantiateInitialViewController() as? AccountPageViewController else { return }
        
        // Present the controller
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var previewCollectionView: UICollectionView!
    
    let Db = DbContext.sharedInstance
    var alertController: UIAlertController? = nil
    var sorting: MindMapSorting = .ascendingAlpha
    var mindMaps: [MindMapSection] {
        
        get {
            
            var dbMindMaps = Db.fetchAllMindMaps()
            
            // Return the mind maps from core data
            if self.sorting == MindMapSorting.ascendingAlpha {
                
                // sort the array by ascending name
                dbMindMaps = dbMindMaps.sorted(by: {(mM1, mM2) in
                    
                    guard let title1 = mM1.title else { return false }
                    guard let title2 = mM2.title else { return true }
                    
                    return title1 < title2
                })
            }
                
            else if self.sorting == .ascendingDate {
                
                // sort the array by ascending date
                dbMindMaps = dbMindMaps.sorted(by: {(mM1, mM2) in
                    
                    guard let date1 = mM1.dateCreated else { return false }
                    guard let date2 = mM2.dateCreated else { return true }
                    
                    return date1 > date2
                })
            }
            
            else if self.sorting == .descendingAlpha {
                
                // sort the array by descending name
                dbMindMaps = dbMindMaps.sorted(by: {(mM1, mM2) in
                    
                    guard let title1 = mM1.title else { return false }
                    guard let title2 = mM2.title else { return true }
                    
                    return title1 > title2
                })
            }
            
            else if self.sorting == .descendingDate {
                
                // sort the array by descending date
                dbMindMaps = dbMindMaps.sorted(by: {(mM1, mM2) in
                    
                    guard let date1 = mM1.dateCreated else { return false }
                    guard let date2 = mM2.dateCreated else { return true }
                    
                    return date1 < date2
                })
            }
            
            return dbMindMaps
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the collectionView Delegate and DataSource
        previewCollectionView.delegate = self
        previewCollectionView.dataSource = self
        self.navigationController?.delegate = self
        
        // Configure the navigation bar
        self.navigationItem.title = "Mind Map Library"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sortByButton(_ sender: UIBarButtonItem) {
        
        // Create an action sheet for the different sorting methods
        let alertController = UIAlertController(title: "Sort Mind Maps", message: "Choose how you want your Mind Maps sorted", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let ascendingTitle = UIAlertAction(title: "Z to A", style: UIAlertActionStyle.default, handler: { (alertAction) in
            
            // Change the sorting and reload the data
            self.sorting = MindMapSorting.ascendingAlpha
            self.previewCollectionView.reloadData()
        })
        
        let ascendingDate = UIAlertAction(title: "Ascending Date", style: .default, handler: { (alertAction) in
            
            // Change the sorting and reload the data
            self.sorting = MindMapSorting.ascendingDate
            self.previewCollectionView.reloadData()
        })
        
        let descendingTitle = UIAlertAction(title: "A to Z", style: .default, handler: { (alertAction) in
            
            // Change the sorting and reload the data
            self.sorting = MindMapSorting.descendingAlpha
            self.previewCollectionView.reloadData()
        })
        
        let descendingDate = UIAlertAction(title: "Descending Date", style: .default, handler: { (alertAction) in
            
            // Change the sorting and reload the data
            self.sorting = MindMapSorting.descendingDate
            self.previewCollectionView.reloadData()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(ascendingTitle)
        alertController.addAction(ascendingDate)
        alertController.addAction(descendingTitle)
        alertController.addAction(descendingDate)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.sourceView = self.toolBar
        alertController.popoverPresentationController?.sourceRect = self.toolBar.bounds
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func createNewMindMap(_ sender: UIBarButtonItem) {
        // Create an alert for the name of Mind Map
        // Create an alert controller for the section deletion
        let alertController = UIAlertController(title: "Name of New Mind Map", message: "Enter the Name of your New Mind Map", preferredStyle: UIAlertControllerStyle.alert)
        var title = Date().description
        
        // Have the User enter the mind map name
        let arrowCreate = UIAlertAction(title: "Create Flow Map", style: .default, handler: { (alertAction) in
            
            guard let textField = alertController.textFields?.first else { return }
            guard let name = textField.text else { return }
            title = name
            
            // Create a new view controller
            guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
            
            // Set up the controller with the correct title and type
            controller.title = title
            controller.type = MindMapType.arrow
            
            // Show the controller
            self.navigationController?.pushViewController(controller, animated: true)
            
        })
        
        let bubbleCreate =  UIAlertAction(title: "Create Bubble Map", style: .default, handler: { (alertAction) in
        
            guard let textField = alertController.textFields?.first else { return }
            guard let name = textField.text else { return }
            title = name
            
            // Create a new view controller
            guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
            
            // Set up the controller with the correct title and type
            controller.title = title
            controller.type = MindMapType.bubble
            
            // Show the controller
            self.navigationController?.pushViewController(controller, animated: true)
            
        })
        
        let boxCreate  = UIAlertAction(title: "Create Box Map", style: .default, handler: { (alertAction) in
        
            guard let textField = alertController.textFields?.first else { return }
            guard let name = textField.text else { return }
            title = name
            
            // Create a new view controller
            guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
            
            // Set up the controller with the correct title and type
            controller.title = title
            controller.type = MindMapType.square
            
            // Show the controller
            self.navigationController?.pushViewController(controller, animated: true)
        
        })
        
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter new Mind Map Name"
        })
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
        })
        
        alertController.addAction(arrowCreate)
        alertController.addAction(bubbleCreate)
        alertController.addAction(boxCreate)
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
        let mindMap = self.mindMaps[indexPath.row]
        guard let title: String = mindMap.title else { return }
        guard let id: UUID = mindMap.id else { return }
        guard let type: MindMapType = MindMapType(rawValue: mindMap.type) else { return }
        
        guard let viewData = mindMap.view else { return }
        guard let view: UIView = NSKeyedUnarchiver.unarchiveObject(with: viewData) as? UIView else { return }
        print(view)
        print(indexPath.row)
        
        // Create a new view controller
        guard let controller = UIStoryboard(name: "ViewAndEdit", bundle: nil).instantiateInitialViewController() as? ViewAndEditViewController else { return }
        
        // Set up the controller
        controller.customView = view
        controller.title = title
        controller.id = id
        controller.type = type
        
        // Show the controller
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Collection View DataSource
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        // Return the Number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return the number of items
        return self.mindMaps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get the cell type
        let cellType = defaults.integer(forKey: "collectionCellType")
        
        if cellType == 0 {
            // Get the cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! HomePreviewCollectionViewCell
            
            // Get the correct mind map
            let mindMap = self.mindMaps[indexPath.row]
            
            // Add a long press gesture recognizer
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.numberOfTapsRequired = 0
            longPress.numberOfTouchesRequired = 1
            longPress.minimumPressDuration = CFTimeInterval(1)
            cell.addGestureRecognizer(longPress)
            
            
            // Put the corresponding image on the cell
            guard let image = mindMap.image as? UIImage else { return cell }
            cell.previewImageView.image = image
            
            // Return the finished cell
            return cell
        }
        else {
            // Get the cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "List", for: indexPath) as! ListHomeCollectionViewCell
            
            // Get the correct mind map
            let mindMap = self.mindMaps[indexPath.row]
            
            // Add a long press gesture recognizer
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.numberOfTapsRequired = 0
            longPress.numberOfTouchesRequired = 1
            longPress.minimumPressDuration = CFTimeInterval(1)
            cell.addGestureRecognizer(longPress)
            
            
            // Put the corresponding image on the cell
            guard let title = mindMap.title else { return cell }
            cell.titleLabel.text = title
            cell.bottomBarView.frame.size = CGSize(width: self.previewCollectionView.frame.width, height: 1.0)
            
            // Return the finished cell
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellType = defaults.integer(forKey: "collectionCellType")
        if cellType == 0 {
            return CGSize(width: self.previewCollectionView.frame.width / 4, height: self.previewCollectionView.frame.height / 5)
        }
        else {
            return CGSize(width: self.previewCollectionView.frame.width, height: 45.0)
        }
    }
    
}

// MARK: - Gestures
extension HomeViewController {
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        // Get the indexPath of the touchPoint
        let touchPoint: CGPoint = recognizer.location(in: self.previewCollectionView)
        guard let indexPath: IndexPath = self.previewCollectionView.indexPathForItem(at: touchPoint) else { return }
        
        // Get the filePath to delete
        guard let id = self.mindMaps[indexPath.row].id else { return }
        
        // Create an alert controller for the section deletion
        self.alertController = UIAlertController(title: "Delete Section", message: "Would you like to delete this Mind Map?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
            // Remove the mind map
            self.Db.deleteMindMapSection(id: id)
            
            // Reload the data
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
