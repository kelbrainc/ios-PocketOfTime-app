//
//  AddMemoryViewController.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import UIKit

// class that conform to protocol implement the didFinishSavingMemory function
protocol AddMemoryDelegate: AnyObject {
    func didFinishSavingMemory()
}

class AddMemoryViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // hold a reference to the class that will listen for our signal
    weak var delegate: AddMemoryDelegate?
    
    // --- Data ---
    private var selectedImage: UIImage?
    public var prefilledText: String?
    
    // for camera
    public var prefilledImage: UIImage?

    
    // --- UI Components ---
    
    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What moment did you capture?"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var memoryTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 18)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.delegate = self // To manage placeholder text
        return textView
    }()
    
    private lazy var addPhotoButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Add Photo"
        config.image = UIImage(systemName: "photo.on.rectangle")
        config.imagePadding = 8
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAddPhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.isHidden = true // Start hidden
        return imageView
    }()
    
    // --- View Lifecycle ---
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureNavBar()
        setupUI()
        
        if let text = prefilledText {
            memoryTextView.text = text + " " 
        }
        
        if let img = prefilledImage {
            selectedImage = img
            photoPreviewImageView.image = img
            photoPreviewImageView.isHidden = false
        }
    }
    
    // --- Setup ---
    
    private func configureNavBar() {
        title = "Add a Moment"
        
        // Add Cancel and Save buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
    }
    
    private func setupUI() {
        view.addSubview(promptLabel)
        view.addSubview(memoryTextView)
        view.addSubview(addPhotoButton)
        view.addSubview(photoPreviewImageView)
        
        // --- Constraints ---
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            memoryTextView.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 8),
            memoryTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            memoryTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            memoryTextView.heightAnchor.constraint(equalToConstant: 150),
            
            addPhotoButton.topAnchor.constraint(equalTo: memoryTextView.bottomAnchor, constant: 20),
            addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            photoPreviewImageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 16),
            photoPreviewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoPreviewImageView.widthAnchor.constraint(equalToConstant: 100),
            photoPreviewImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // --- Actions ---
    
    @objc private func didTapCancel() {
        // Dismiss this modal view
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSave() {
        // 1. Get the text
        guard let text = memoryTextView.text, !text.isEmpty else {
            // Show an alert to the user
            print("Text is empty")
            return
        }
        
        // 2. Get the image data
        var imageData: Data?
        if let image = selectedImage {
            // Compress the image to save space
            imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        // 3. Create a new Memory object
        let newMemory = Memory(id: UUID(),
                               text: text,
                               date: Date(), // Use the current date and time
                               imageData: imageData)
        
        // 4. Save it using our PersistenceManager
        PersistenceManager.shared.addMemory(newMemory)
        
        // 5. Dismiss this view
        //dismiss(animated: true, completion: nil)
        //notify delegate to handle dismiss and switch tab
        delegate?.didFinishSavingMemory()
    }
    
//    @objc private func didTapAddPhoto() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary // Allow picking from the library
//        present(imagePicker, animated: true, completion: nil)
//    }
    
    @objc private func didTapAddPhoto() {
        let ac = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ac.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.presentImagePicker(source: .camera)
            })
        }
        ac.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentImagePicker(source: .photoLibrary)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let pop = ac.popoverPresentationController {
            pop.sourceView = addPhotoButton
            pop.sourceRect = addPhotoButton.bounds
        }
        present(ac, animated: true)
    }

    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    
    // --- Image Picker Delegate ---
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 1. Get the selected image
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            photoPreviewImageView.image = image
            photoPreviewImageView.isHidden = false
        }
        
        // 2. Dismiss the picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
