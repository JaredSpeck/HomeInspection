//
//  InspInfoViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/11/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class InspDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var outerInfoStackView: UIStackView!
    @IBOutlet weak var innerInfoFirstStackView: UIStackView!
    
    
    // MARK: Properties
    
    // Set when selecting inspection on dashboard
    var loadedInspection: Inspection!
    // References to currently loaded inspection details
    var loadedAddress: Address!
    var loadedClient: Client!
    // Core Data context
    var managedObjectContext: NSManagedObjectContext!
    
    
    
    // MARK: Initialization
    
    // Auto-filled fields
    @IBOutlet weak var homeUIImage: UIImageView!
    @IBOutlet weak var inspectorUITextField: UITextField!
    @IBOutlet weak var dateUITextField: UITextField!
    
    // Called once when the view loads into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.hideKeyboardWhenTappedAround()
        
        initNavBar()
        initTextFields()
    }
    
    // Called whenever view will become visible
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInspectionDetails()
    }
    
    // Initializes the navigation bar with buttons and text
    func initNavBar() {
        self.title = "Inspection Details"
        
        let startNavButton = UIBarButtonItem(
            title: "Start",
            style: .plain,
            target: self,
            action: #selector(showInspection(sender:)))
        
        self.navigationItem.rightBarButtonItem = startNavButton
    }

    func initTextFields() {
        streetUITextField.delegate = self
        cityUITextFied.delegate = self
        clientNameUITextField.delegate = self
        clientCompanyUITextField.delegate = self
        clientPhoneUITextField.delegate = self
        clientEmailUITextField.delegate = self
        
        clientPhoneUITextField.keyboardType = .numberPad
    }
    
    func loadInspectionDetails() {
        // Load home image
        if let imageData = loadedInspection.homeImage, let loadedHomeImage = UIImage(data: imageData as Data) {
            // Set image to saved image
            self.homeUIImage.image = loadedHomeImage
        }
        else {
            // Clear the image
            self.homeUIImage.image = UIImage()
        }
        
        // Load timestamp
        dateUITextField.text = loadedInspection.date!
        
        // Load inspector info?
        inspectorUITextField.text = "(Debug placeholder) Inspection ID: \(loadedInspection.id)"
        
        // Load address or create one if not available FIXME: makes dulpicate addresses
        if let tempAddress: Address = loadedInspection.address {
            loadedAddress = tempAddress
        }
        else {
            loadedAddress = Address(context: managedObjectContext)
            loadedInspection.address = loadedAddress
        }
        
        // Load client or create one if not available FIXME: maked duplicate clients
        if let tempClient: Client = loadedInspection.client {
            loadedClient = tempClient
        }
        else {
            loadedClient = Client(context: managedObjectContext)
            loadedInspection.client = loadedClient
        }
        
        streetUITextField.text = loadedAddress.street
        cityUITextFied.text = loadedAddress.city
        
        if let firstName: String = loadedClient.first {
            if let lastName: String = loadedClient.last {
                clientNameUITextField.text = firstName + " " + lastName
            } else {
                clientNameUITextField.text = firstName
            }
        }
        else {
            clientNameUITextField.text = ""
        }
        clientCompanyUITextField.text = loadedClient.company
        clientPhoneUITextField.text = loadedClient.phone
        clientEmailUITextField.text = loadedClient.email
    }
    

    
    // MARK: Image field
    
    @IBAction func cameraButtonTapAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func importButtonTapAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.saveHomePicture(with: image)
            })
        }
    }
    
    func saveHomePicture(with image: UIImage) {
        // Load image into read-only copy of loaded inspection
        loadedInspection.homeImage = NSData(data: UIImageJPEGRepresentation(image, 0.3)!)
        
        // Save the inspection with the new image
        do {
            try managedObjectContext.save()
            loadInspectionDetails()

        } catch {
            print("Error saving inspection image: \(error.localizedDescription)")
        }
    }
    
    
    
    // MARK: Text fields
    
    @IBOutlet weak var streetUITextField: UITextField!
    @IBOutlet weak var cityUITextFied: UITextField!
    
    @IBOutlet weak var clientNameUITextField: UITextField!
    @IBOutlet weak var clientCompanyUITextField: UITextField!
    @IBOutlet weak var clientPhoneUITextField: UITextField!
    @IBOutlet weak var clientEmailUITextField: UITextField!
    
    // Input sanitation (for phone numbers)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == clientPhoneUITextField) {
            // Filter out non-numeric characters
            let newString: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let numericComponents: [String] = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            let numericString: String = numericComponents.joined(separator: "")
            
            let length = numericString.characters.count
            let hasLeadingOne = length > 0 && numericString.characters.first == "1"
            
            // Check length to limit phone number length
            if (length == 0 || (length > 10 && !hasLeadingOne) || length > 11) {
                let newLength = textField.text!.characters.count + string.characters.count - range.length
                return (newLength > 10) ? false : true
            }
            
            var phoneNumIndex = 0
            var formattedNumString: String = ""
            
            // Reformat phone number
            if (hasLeadingOne) {
                formattedNumString.append("1 ")
                phoneNumIndex += 1
            }
            if (length - phoneNumIndex) > 3 {
                let start = numericString.index(numericString.startIndex, offsetBy: phoneNumIndex)
                let end = numericString.index(numericString.startIndex, offsetBy: phoneNumIndex + 3)
                let areaRange: Range = start..<end
                let areaCode = numericString.substring(with: areaRange)
                formattedNumString.append("(\(areaCode)) ")
                phoneNumIndex += 3
            }
            if (length - phoneNumIndex) > 3 {
                let start = numericString.index(numericString.startIndex, offsetBy: phoneNumIndex)
                let end = numericString.index(numericString.startIndex, offsetBy: phoneNumIndex + 3)
                let prefixRange: Range = start..<end
                let prefix = numericString.substring(with: prefixRange)
                formattedNumString.append("\(prefix)-")
                phoneNumIndex += 3
            }
                    
            let remainder = numericString.substring(from: numericString.index(numericString.startIndex, offsetBy: phoneNumIndex))
            formattedNumString.append(remainder)
            
            textField.text = formattedNumString
            return false
        } else {
            return true
        }
    }
    
    // Text field input handling
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField) {
        case streetUITextField:
            print("Street updated")
            if let street: String = textField.text, street != "" {
                loadedAddress.street = street
                safeSaveContext()
            }
            break
        case cityUITextFied:
            print("City updated")
            if let city: String = textField.text, city != "" {
                loadedAddress.city = city
                safeSaveContext()
            }
            break
        case clientNameUITextField:
            print("Client Name updated")
            if let clientName: String = textField.text, clientName != "" {
                let nameParts: [String] = clientName.components(separatedBy: " ")
                
                // Set first name
                let firstName: String = nameParts.first!
                loadedClient.first = firstName
                
                // Set last name (if available)
                if nameParts.count > 1, let lastName: String = nameParts.last {
                    loadedClient.last = lastName
                }
                safeSaveContext()
            }
            break
        case clientCompanyUITextField:
            print("Client Company updated")
            if let clientCompany: String = textField.text, clientCompany != "" {
                loadedClient.company = clientCompany
                safeSaveContext()
            }
            break
        case clientPhoneUITextField:
            print("Client Phone updated")
            if let clientPhone: String = textField.text, clientPhone != "" {
                loadedClient.phone = clientPhone
                safeSaveContext()
            }
            break
        case clientEmailUITextField:
            print("Client Email updated")
            if let clientEmail: String = textField.text, clientEmail != "" {
                loadedClient.email = clientEmail
                safeSaveContext()
            }
            break
        default:
            print("Unknown text field was modified")
        }
    }
    
    
    
    // MARK: Misc functions
    
    // Called when the 'Start' nav button is pressed
    func showInspection(sender: UIBarButtonItem) {
        print("Starting Inspection")
        
        if let navController = self.navigationController as? InspectionNavigationController {            
            navController.popViewController(animated: false)
            navController.pushViewController(navController.inspectionVC, animated: false)
        }
    }
    
    func safeSaveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error writing changes to disk: \(error.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Adjust layout for different orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in
            print("Chnaged rotation")
            let orientation = UIApplication.shared.statusBarOrientation
            
            if orientation.isPortrait {
                self.outerInfoStackView.axis = .vertical
                self.innerInfoFirstStackView.axis = .horizontal
                //self.stackView.axis = .Horizontal
            } else {
                self.outerInfoStackView.axis = .horizontal
                self.innerInfoFirstStackView.axis = .vertical
                //self.stackView.axis = .Vertical
            }
            
        }, completion: nil)    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedPaneInInspDetails") {
            if let paneVC: PaneViewController = segue.destination as? PaneViewController {
                paneVC.showSections = false
            }
        }
    }
}

