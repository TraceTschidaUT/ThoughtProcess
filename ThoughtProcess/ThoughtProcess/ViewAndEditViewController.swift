//
//  ViewAndEditViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/8/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class ViewAndEditViewController: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.customView != nil {
            
            // Get the scrollView
            guard let scrollView = self.customView?.viewWithTag(1820) as? UIScrollView else { return }
            guard let canvasView = scrollView.viewWithTag(320) else { return }
            
            // Iterate through each section to build the SectionViews
            for canvasSubview in canvasView.subviews {
                var numSections = 0
                guard let section = canvasSubview as? ArrowView else { continue }
                
                
                section.delegate = self
                section.tag = numSections
                self.addGestureRecognizers(arrow: section)
                
                self.canvasView.addSubview(section)
                self.sections[numSections] = section
                numSections += 1
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
        
        // Save the view data
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("trace").path else { return }
        let saved = NSKeyedArchiver.archiveRootObject(self.view, toFile: path)
        print(saved)
        self.delegate?.filePath = path
    }
    
    // UI Properties
    @IBOutlet weak var viewAndEditScrollView: UIScrollView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var optionsToolBar: UIToolbar!
    var sections: [Int: ArrowView] = [:]
    var selectedTextView: UITextView?
    var alertController: UIAlertController? = nil
    var colorPicker: UIPickerView?
    var textPropertyPicker: UIPickerView?
    var blurView: UIVisualEffectView?
    
    // Controller Properties
    let colors: [String] = ["Black", "Red", "Blue", "Green", "Gray", "Light Gray", "Purple", "Orange", "Yellow"]
    let fontStyles: [String] = ["Body", "Callout", "Caption 1", "Caption 2", "Footnote", "Headline", "Subheadline", "Large Title", "Title 1", "Title 2", "Title 3"]
    var delegate: MindMapDataProtocol?
    var customView: UIView?
    
    // UI Methods
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
        
        let saved = NSKeyedArchiver.archiveRootObject(self.view, toFile: (self.delegate?.filePath)!)
        print(saved)
    }
    @IBAction func changeTextButton(_ sender: UIBarButtonItem) {
        
        // Get the users defaults for the property picker
        guard let sectionView = self.selectedTextView?.superview as? ArrowView else { return }
        let fontTypeNum: Int = sectionView.fontType.value
        let fontColorNum: Int = sectionView.fontColor.value
        let backgroundColorNum: Int = sectionView.fontBackgroundColor.value
        
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
        
        // Create a new Arrow shape
        let viewCenter: CGPoint = CGPoint(x: self.viewAndEditScrollView.center.x - 100, y: self.viewAndEditScrollView.center.y - 100)
        let arrow = ArrowView(frame: CGRect(origin: viewCenter, size: CGSize(width: canvasView.bounds.maxX / 4, height: canvasView.bounds.maxY / 6)))
        arrow.tag = sections.count + 1
        
        self.addGestureRecognizers(arrow: arrow)
        
        // Add a delegate to the textView
        arrow.delegate = self
        
        // Add the arrows to an array
        self.sections[arrow.tag] = arrow
        
        // Add the arrow to the canvas
        self.canvasView.addSubview(arrow)
        
    }
    
    func addGestureRecognizers(arrow: ArrowView) {
        
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
        // updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // view?.transform = CGAffineTransform(scaleX: scale, y: scale)
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
            
        else if newFrame.maxY > canvas.bounds.maxY {
            view.center.y = canvas.bounds.maxY - view.frame.size.height / 2
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
            for (_, section) in self.sections {
                section.viewColor = color
            }
            
            // Remove the color picker and blur effect
            self.colorPicker?.removeFromSuperview()
            
            // Remove the blur effect
            self.blurView?.removeFromSuperview()
            
        default:
            
            // Get the super view
            guard let sectionView = self.selectedTextView?.superview as? ArrowView else { return }
            
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
                sectionView.fontBackgroundColor = FontBackgroundColor(name: self.colors[row], value: row, type: self.getUIColor(row))
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
