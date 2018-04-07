//
//  ViewAndEditViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/8/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class ViewAndEditViewController: UIViewController, UINavigationControllerDelegate {
    
    // UI Properties
    @IBOutlet weak var viewAndEditScrollView: UIScrollView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var optionsToolBar: UIToolbar!
    var sections: [Int: ColorChangeProtocol] = [:]
    var selectedTextView: UITextView?
    var alertController: UIAlertController? = nil
    var colorPicker: UIPickerView?
    var textPropertyPicker: UIPickerView?
    var blurView: UIVisualEffectView?
    
    // Controller Properties
    let Db = DbContext.sharedInstance
    var id: UUID?
    var type: MindMapType?
    let colors: [String] = ["Black", "Red", "Blue", "Green", "Gray", "Light Gray", "Purple", "Orange", "Yellow"]
    let fontStyles: [String] = ["Body", "Callout", "Caption 1", "Caption 2", "Footnote", "Headline", "Subheadline", "Large Title", "Title 1", "Title 2", "Title 3"]
    var customView: UIView?
    var shareName: String = ""

    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.customView != nil {
            
            // Get the scrollView
            guard let scrollView = self.customView?.viewWithTag(1820) as? UIScrollView else { return }
            guard let canvasView = scrollView.viewWithTag(320) else { return }
            guard let type = self.type else { return }
            
            // Iterate through each section to build the SectionViews
            for canvasSubview in canvasView.subviews {
                var numSections = 0

                // Convert each section into a SectionView
                var section: FlowMapView

                // Try to convert the view
                do {
                    if type == .arrow {
                        try section = self.castArrow(subview: canvasSubview)
                    }
                    else if type == .bubble {
                        try section = self.castBubble(subview: canvasSubview)
                    }
                    else {
                        try section = self.castBox(subview: canvasSubview)
                    }
                    
                    // Set the delgate so the section can access the controller
                    section.delegate = self
                    
                    // Add a tag
                    section.tag = numSections
                    
                    // Hold all of the sections so you can access them later
                    self.sections[numSections] = section
                    numSections += 1
                    
                    // Add the gesture recognizers
                    self.addGestureRecognizers(arrow: section)
                    
                    // Add the section to the subview
                    self.canvasView.addSubview(section)
                }
                catch {
                    guard let connection = canvasSubview as? ConnectionView else { continue }
                    
                    // Add a tag
                    connection.tag = numSections
                    
                    // Hold all of the sections so you can access them later
                    self.sections[numSections] = connection
                    numSections += 1
                    
                    self.addGestureRecognizers(arrow: connection)
                    self.addRotation(connection)
                    self.canvasView.addSubview(connection)
                }
            }
        }
        
        // Connect the scroll view delegate and configure size
        self.viewAndEditScrollView.delegate = self
        self.viewAndEditScrollView.minimumZoomScale = 1.0
        self.viewAndEditScrollView.maximumZoomScale = 4.0
        self.viewAndEditScrollView.zoomScale = 2.0
        self.viewAndEditScrollView.tag = 1820
        
        // Hook up tge keyboard dismissal
        viewAndEditScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        
        // Confine the subview to this view
        self.canvasView.clipsToBounds = true
        self.canvasView.tag = 320
        
        // Create a tap recognizer for the canvas to dismiss the keyboard
        let tapCanvas = UITapGestureRecognizer(target: self, action: #selector(tapCanvas(_:)))
        canvasView.addGestureRecognizer(tapCanvas)
        
        // Create a menu option for highlighting
        let highlight = UIMenuItem(title: "Highlight", action: #selector(highlightText(_:)))
        UIMenuController.shared.menuItems = [highlight]
        
        // Title
        self.navigationItem.title = self.title!
        
        // Create a new entry if the view is loaded
        if self.id == nil {
            
            // Save the view data
            let data = NSKeyedArchiver.archivedData(withRootObject: self.view)
            
            // Create a new entity
            self.id = UUID()
            guard let id = self.id else { return }
            guard let type = self.type else { return }
            Db.createMindMapSection(title: self.title!, view: data, mindMapID: id, mapType: type)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("View and Edit View: \n\t Func: viewWillDisappear: cleaning up and taking screenshot")
        
        // Create new image context with the same size of the view
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0.0)
        
        // Draw the view and subview into the context
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        self.view.layer.render(in: currentContext)
        
        // Create an image from the context
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        
        // Close the Context
        UIGraphicsEndImageContext()
        
        // Save the image to the mind map section
        guard let id = self.id else { return }
        Db.addImageToMindMap(image: image, id: id)
        
        self.saveView()
    }
    
    // UI Methods
    @IBAction func addConnectionButton(_ sender: UIBarButtonItem) {
        
        // Draw the connection
        let center: CGPoint = self.viewAndEditScrollView.center
        let size: CGSize = CGSize(width: 5, height: 100)
        let frame: CGRect =  CGRect(origin: center, size: size)
        let connection = ConnectionView(frame: frame)
        
        // Add the gestures
        self.addGestureRecognizers(arrow: connection)
        self.addRotation(connection)
        
        // Set the tag to make changes later
        connection.tag = self.sections.count + 1
        
        // Add the arrows to an array
        self.sections[connection.tag] = connection
        
        // Add the connection to the subview
        self.canvasView.addSubview(connection)
    }
    
    @IBAction func shareMindMap(_ sender: UIBarButtonItem) {
        
        var nameTextField:UITextField? = nil
        
        self.alertController = UIAlertController(title: "Export Mind Map", message: "Choose file type to export as and give your mind map a name", preferredStyle: UIAlertControllerStyle.alert)
        
        let pdf = UIAlertAction(title: "PDF", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            let data = NSMutableData()
            UIGraphicsBeginPDFContextToData(data, self.view.frame, nil)
            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
            UIGraphicsBeginPDFPage()
            self.view.layer.render(in: currentContext)
            UIGraphicsEndPDFContext()
            
            guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            guard let text = nameTextField?.text else { return }
            self.shareName = text
            
            if self.shareName == "" {
                self.shareName = "My Mind Map"
            }
            
            path.appendPathComponent("\(self.shareName).pdf")
            
            do {
                try data.write(to: path)
            }
            catch {
                print("Not saved")
            }
            
            print(path)
            
            
            self.share(url: path)
        }
        
        let jpeg = UIAlertAction(title: "JPEG", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            UIGraphicsBeginImageContext(self.view.frame.size)
            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
            self.view.layer.render(in: currentContext)
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
            UIGraphicsEndImageContext()
            
            guard let data = UIImageJPEGRepresentation(image, 1) else { return }
            
            // Create a temporary path
            guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            guard let text = nameTextField?.text else { return }
            self.shareName = text
            
            if self.shareName == "" {
                self.shareName = "My Mind Map"
            }
            
            path.appendPathComponent("\(self.shareName).jpeg")
            
            do {
                try data.write(to: path)
            }
            catch {
                print("Not saved")
            }
            
            print(path)
            
            self.share(url: path)
        }
        
        let png = UIAlertAction(title: "PNG", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            UIGraphicsBeginImageContext(self.view.frame.size)
            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
            self.view.layer.render(in: currentContext)
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
            UIGraphicsEndImageContext()
            
            guard let data = UIImagePNGRepresentation(image) else { return }
            
            // Create a temporary path
            guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            guard let text = nameTextField?.text else { return }
            self.shareName = text
            
            if self.shareName == "" {
                self.shareName = "My Mind Map"
            }
            
            path.appendPathComponent("\(self.shareName).png")
            
            do {
                try data.write(to: path)
            }
            catch {
                print("Not saved")
            }
            
            print(path)
            
            self.share(url: path)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        
        self.alertController!.addAction(pdf)
        self.alertController!.addAction(jpeg)
        self.alertController!.addAction(png)
        self.alertController?.addAction(cancel)
        
        self.alertController?.addTextField { (textField) -> Void in
            nameTextField = textField
            nameTextField?.placeholder = "File Name"
        }
        
        self.present(self.alertController!, animated: true, completion:nil)
    }
    
    func share(url: URL) {
        let docVC = UIDocumentPickerViewController(url: url, in: .exportToService)
        self.navigationController?.present(docVC, animated: true, completion: nil)
    }
    
    @IBAction func insertButton(_ sender: UIBarButtonItem) {
        
        // Check if access to saved photos
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
            
        // Request access to the device's photo library
        else {
            
        }
    }
    
    
    @IBAction func applyTextChanges(_ sender: UIButton) {
        
        // Remove the blur, text property picker, and button from the view
        self.blurView?.removeFromSuperview()
        self.textPropertyPicker?.removeFromSuperview()
        sender.removeFromSuperview()
    }
    @IBAction func changeTextButton(_ sender: UIBarButtonItem) {
        
        // Get the users defaults for the property picker
        guard let sectionView: FlowMapView = self.selectedTextView?.superview as? FlowMapView else { return }
        
        let fontTypeNum: Int = sectionView.fontType.value
        let fontColorNum: Int = sectionView.fontColor.value
        let backgroundColorNum: Int = sectionView.textViewBackgroundColor.value
        
        // Create a floating text property picker
        let textPropertyPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX, height: self.view.frame.maxY))
        textPropertyPicker.showsSelectionIndicator = true
        textPropertyPicker.dataSource = self
        textPropertyPicker.delegate = self
        textPropertyPicker.tag = 1
        self.textPropertyPicker = textPropertyPicker
        
        // Create a select button
        let selectButton: UIButton = UIButton(frame: CGRect(x: self.view.frame.maxX * 0.80, y: self.view.frame.maxY * 0.80, width: 125, height: 50))
        selectButton.setTitle("Apply Changes", for: .normal)
        selectButton.setTitleColor(UIColor.white, for: .normal)
        selectButton.setTitleColor(UIColor.lightGray, for: .selected)
        selectButton.backgroundColor = UIColor.clear
        selectButton.layer.borderColor = UIColor.blue.cgColor
        selectButton.layer.cornerRadius = 10
        selectButton.addTarget(self, action: #selector(applyTextChanges(_:)), for: .touchUpInside)
        
        // Create blur effect
        self.createBlurEffect()
        
        // Add text property picker to view
        self.view.addSubview(textPropertyPicker)
        self.view.addSubview(selectButton)
        
        // Set the user settings
        textPropertyPicker.selectRow(fontTypeNum, inComponent: 0, animated: false)
        textPropertyPicker.selectRow(fontColorNum, inComponent: 1, animated: false)
        textPropertyPicker.selectRow(backgroundColorNum, inComponent: 2, animated: false)
        
    }
    
    @IBAction func changeColorButton(_ sender: UIBarButtonItem) {
        
        // Create a floating color picker
        let colorPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX, height: self.view.frame.maxY))
        colorPicker.dataSource = self
        colorPicker.delegate = self
        colorPicker.tag = 0
        self.colorPicker = colorPicker
        
        // Create Blur Effect
        self.createBlurEffect()
        
        // Add the color picker color
        self.view.addSubview(colorPicker)
        
    }
    
    
    @IBAction func addSectionButton(_ sender: UIBarButtonItem) {
        
        // Create a new section shape
        let viewCenter: CGPoint = CGPoint(x: self.viewAndEditScrollView.center.x - 100, y: self.viewAndEditScrollView.center.y - 100)
        let shape: FlowMapView
        
        // Get the current type
        guard let type = self.type else { return }
        
        if type == .arrow {
            shape = ArrowView(frame: CGRect(origin: viewCenter, size: CGSize(width: canvasView.bounds.maxX / 4, height: canvasView.bounds.maxY / 6)))
        }
        else if type == .bubble {
            shape = BubbleView(frame: CGRect(origin: viewCenter, size: CGSize(width: canvasView.bounds.maxX / 4, height: canvasView.bounds.maxY / 6)))
        }
        else {
            shape = BoxView(frame: CGRect(origin: viewCenter, size: CGSize(width: canvasView.bounds.maxX / 4, height: canvasView.bounds.maxY / 6)))
        }
        
        // Set the tag to make changes later
        shape.tag = sections.count + 1
        
        self.addGestureRecognizers(arrow: shape)
        
        // Add a delegate to the textView
        shape.delegate = self
        
        // Add the arrows to an array
        self.sections[shape.tag] = shape
        
        // Add the arrow to the canvas
        self.canvasView.addSubview(shape)
        
    }
    
    func addGestureRecognizers(arrow: UIView) {
        
        // Add a pan gesture recognizer to the arrow
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleArrowPan(_:)))
        pan.name = "pan"
        pan.delegate = self
        arrow.addGestureRecognizer(pan)
        
        // Add a zooming gesturing for each map part
        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(handleArrowZoom(_:)))
        arrow.addGestureRecognizer(zoom)
        
        // Add a long press gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleArrowLongPress(_:)))
        longPress.minimumPressDuration = CFTimeInterval(1)
        longPress.numberOfTapsRequired = 0
        longPress.numberOfTouchesRequired = 1
        arrow.addGestureRecognizer(longPress)
        
        let movementLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleSectionMovementLongPress(_:)))
        movementLongPress.minimumPressDuration = CFTimeInterval(0.0001)
        movementLongPress.numberOfTapsRequired = 1
        movementLongPress.numberOfTouchesRequired = 1
        movementLongPress.delegate = self
        movementLongPress.name = "movementLongPress"
        arrow.addGestureRecognizer(movementLongPress)
    }
    
    func addRotation(_ view: UIView) {
        
        // Create the rotation gesture
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleConnectionRotation(_:)))
        view.addGestureRecognizer(rotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}

extension ViewAndEditViewController: UIScrollViewDelegate {
    // Controller Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        view?.layoutSubviews()
        
    }
    
    func updateMinZoomScaleForSize (_ size: CGSize) {
        let widthScale = size.width / canvasView.bounds.width
        let heightScale = size.height / canvasView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        viewAndEditScrollView.minimumZoomScale = minScale
        viewAndEditScrollView.zoomScale = minScale
    }
}

extension ViewAndEditViewController {
    
    // Gesture Handlers
    @IBAction func handleConnectionRotation(_ recognizer: UIRotationGestureRecognizer) {
        guard let view = recognizer.view else { return }
        view.transform = view.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
    }
    @IBAction func tapCanvas(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.viewAndEditScrollView.isScrollEnabled = true
    }
    
    @IBAction func handleSectionMovementLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .ended {
            
            // Unlock the panning and zooming for the scroll view
            self.viewAndEditScrollView.isScrollEnabled = true
        }
        else if recognizer.state == .began || recognizer.state == .changed {
            
            // Lock the scrolling view
            self.viewAndEditScrollView.isScrollEnabled = false
        }
        
    }
    
    @IBAction func handleArrowLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        // Create an alert controller for the section deletion
        self.alertController = UIAlertController(title: "Delete Section", message: "Would you like to delete this Section?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
            
            // Get the section to delete
            guard let section = recognizer.view else { return }
            
            // Remove the section from the view hiearchy
            section.removeFromSuperview()
            
            // Remove from the array
            self.sections.removeValue(forKey: section.tag)
            
        })
        self.alertController?.addAction(cancelAction)
        self.alertController?.addAction(deleteAction)
        
        self.present(self.alertController!, animated: true, completion: nil)
        
    }
    @IBAction func handleArrowZoom(_ recognizer: UIPinchGestureRecognizer) {
        
        // Make sure the view exists
        guard recognizer.view != nil else { return }
        
        if recognizer.state == .began || recognizer.state == .changed {
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
            
            // Reset the recognizer
            recognizer.scale = 1.0
        }
    }
    @IBAction func handleArrowPan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        guard let view = recognizer.view else { return }
        guard let canvas = view.superview else { return }
        
        // Set the translation
        // Check to make sure the item is not outside the bounds
        var newFrame = view.frame
        newFrame.origin.x += translation.x
        newFrame.origin.y += translation.y
        
        if canvas.bounds.contains(view.frame) {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
            
        // Check the edges
        else if newFrame.minX < canvas.bounds.minX {
            view.center.x = canvas.bounds.minX + view.frame.size.width / 2
        }
            
        else if newFrame.maxX > canvas.bounds.maxX {
            view.center.x = canvas.bounds.maxX - view.frame.size.width / 2
        }
            
        else if newFrame.minY < canvas.bounds.minY {
            view.center.y = canvas.bounds.minY + view.frame.size.height / 2
        }
            
        else if newFrame.maxY + 10.0 > canvas.bounds.maxY {
            view.center.y = canvas.bounds.maxY - view.frame.size.height / 2 - 10
        }
        
        // Reset the translation to 0
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
}

extension ViewAndEditViewController: UITextViewDelegate {
    
    // Keyboard setup
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.viewAndEditScrollView.isScrollEnabled = false
        self.selectedTextView = textView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.viewAndEditScrollView.isScrollEnabled = true
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // Get the Section class
        guard let section = textView.superview as? ArrowView else { return }
        
        // Save the text to the section class
        section.textView = textView
    }
    
    @objc func highlightText(_ sender: AnyObject?) {
        
        // Get the selected range of text
        guard let start = self.selectedTextView?.selectedRange.lowerBound else { return }
        guard let end = self.selectedTextView?.selectedRange.upperBound else { return }
        if start < end {
            
            // Get the range
            guard let range = self.selectedTextView?.selectedRange else { return }
            
            // Get the selected text
            guard let selectedText = self.selectedTextView?.attributedText.attributedSubstring(from: range) else { return }
            
            // Get all of the text
            guard let allText = self.selectedTextView?.attributedText.string else { return }
            
            // Create a mutable string from the original text
            guard let mutableString = self.selectedTextView?.attributedText.mutableCopy() as? NSMutableAttributedString else { return }
            
            
            // Create the highlight and replace the text
            let highlight = NSMutableAttributedString(attributedString: selectedText)
            highlight.addAttributes([NSAttributedStringKey.backgroundColor: UIColor.yellow], range: NSMakeRange(0, selectedText.string.count))
            mutableString.replaceCharacters(in: range, with: highlight)
            
            // Make the attributed string background clear after the highlight
            let endOfText: NSRange = NSMakeRange(allText.count - 1, 1)
            mutableString.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.clear, range: endOfText)
            
            // Change the mutable string
            self.selectedTextView?.attributedText = mutableString
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ViewAndEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 0:
            return 1
        default:
            // 3 components:
            // Text Font, Text Color, and Background Color
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
            
        case 0:
            return self.colors.count
            
        default:
            
            // Check the component number
            if component == 0 {
                return 11 // The number of fonts
            }
            else {
                return self.colors.count // The number of colors
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch pickerView.tag {
            
        case 0:
            
            let colorString = NSAttributedString(string: self.colors[row], attributes: [NSAttributedStringKey.foregroundColor: self.getUIColor(row)])
            return colorString
            
        default:
            
            // Check if font, color, or backgroun
            if component == 0 {
                let fontString = NSAttributedString(string: self.fontStyles[row], attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: self.getUIFontStyle(row))])
                return fontString
            }
                
            else {
                
                let colorString = NSAttributedString(string: self.colors[row], attributes: [NSAttributedStringKey.foregroundColor: self.getUIColor(row)])
                return colorString
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 0:
            
            // Get the color
            let color: UIColor = self.getUIColor(row)
            
            // Change the color of every section
            for (_, var section) in self.sections {
                section.viewColor = color
            }
            
            // Remove the color picker and blur effect
            self.colorPicker?.removeFromSuperview()
            
            // Remove the blur effect
            self.blurView?.removeFromSuperview()
            
        default:
            
            // Get the super view
            guard let sectionView = self.selectedTextView?.superview as? FlowMapView else { return }
            
            // If the font
            if component == 0 {
                sectionView.fontType = FontType(name: self.fontStyles[row], value: row, type: UIFont.preferredFont(forTextStyle: self.getUIFontStyle(row)))
            }
            // If the text color
            else if component == 1 {
                sectionView.fontColor = FontColor(name: self.colors[row], value: row, type: self.getUIColor(row))
            }
            // If the background color
            else if component == 2 {
                sectionView.textViewBackgroundColor = TextViewBackgroundColor(name: self.colors[row], value: row, type: self.getUIColor(row))
            }
        }
    }
}

extension ViewAndEditViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.name == "movementLongPress" && otherGestureRecognizer.name == "pan"
    }
}

extension ViewAndEditViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard var image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Get the attributed text
        guard let mutableString = self.selectedTextView?.attributedText.mutableCopy() as? NSMutableAttributedString else { return }
        guard let endOfString: Int = self.selectedTextView?.attributedText.string.count else { return }
        
        // Get the scale factor to make the image fit within the view
        guard let textViewSize = self.selectedTextView?.frame.size else { return }
        image = resizeImage(image: image, targetSize: textViewSize)
        
        // Create an image attachment
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let imageString = NSAttributedString(attachment: textAttachment)
        
        // Add the image to the mutableString and set that to the text view's data
        let cursorPosition = self.selectedTextView?.selectedRange.upperBound ?? endOfString - 1
        mutableString.insert(imageString, at: cursorPosition)
        
        self.selectedTextView?.attributedText = mutableString
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension ViewAndEditViewController {
    
    func getUIColor(_ row: Int) -> UIColor {
        
        var color: UIColor
        
        switch row {
        case 1:
            color = UIColor.red
        case 2:
            color = UIColor.blue
        case 3:
            color = UIColor.green
        case 4:
            color = UIColor.gray
        case 5:
            color = UIColor.lightGray
        case 6:
            color = UIColor.purple
        case 7:
            color = UIColor.orange
        case 8:
            color = UIColor.yellow
        default:
            color = UIColor.black
        }
        
        return color
    }
    
    func getUIFontStyle(_ row: Int) -> UIFontTextStyle {
        
        var fontStyle: UIFontTextStyle
        
        switch row {
        case 1:
            fontStyle = UIFontTextStyle.callout
        case 2:
            fontStyle = UIFontTextStyle.caption1
        case 3:
            fontStyle = UIFontTextStyle.caption2
        case 4:
            fontStyle = UIFontTextStyle.footnote
        case 5:
            fontStyle = UIFontTextStyle.headline
        case 6:
            fontStyle = UIFontTextStyle.subheadline
        case 7:
            fontStyle = UIFontTextStyle.largeTitle
        case 8:
            fontStyle = UIFontTextStyle.title1
        case 9:
            fontStyle = UIFontTextStyle.title2
        case 10:
            fontStyle = UIFontTextStyle.title3
        default:
            fontStyle = UIFontTextStyle.body
        }
        
        return fontStyle
    }
    
    func createBlurEffect() {
        
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurView = blurEffectView
        view.addSubview(blurEffectView)
    }
}

extension ViewAndEditViewController {
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        print("in here")
     }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        let collectionVC = subsequentVC as? HomeViewController
        collectionVC?.previewCollectionView.reloadData()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("about to show!")
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("showing!")
    }
}

extension ViewAndEditViewController {
    
    func saveView() {
        
        // Save the view
        let data = NSKeyedArchiver.archivedData(withRootObject: self.view)
        guard let id = self.id else { return }
        Db.updateMindMapSection(id: id, data: data)
        
    }
}

// MARK: - Casting
extension ViewAndEditViewController {
    
    func castArrow(subview: UIView) throws -> ArrowView {
        
        guard let section = subview as? ArrowView else {
            throw NSError()
        }
        return section
    }
    
    func castBubble(subview: UIView) throws -> BubbleView {
        guard let section = subview as? BubbleView else {
            throw NSError()
        }
        return section
    }
    
    func castBox(subview: UIView) throws -> BoxView {
        guard let section = subview as? BoxView else {
            throw NSError()
        }
        return section
    }
}
