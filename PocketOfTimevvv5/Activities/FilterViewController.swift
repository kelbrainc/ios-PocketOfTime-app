//
//  FilterViewController.swift
//  PocketOfTimev3
//
//  Created by Kelly Chui on 24/10/25.
//


import UIKit

// The protocol that will send the selected filter data back.
protocol FilterDelegate: AnyObject {
    func didApplyFilters(ageIndex: Int, categoryIndex: Int)
}

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // A weak delegate to communicate back to ActivitiesViewController.
    weak var delegate: FilterDelegate?
    
    // These properties will hold the data for the pickers.
    private let ageTitles = AgeGroup.allCases.map { $0.rawValue }
    private let categoryTitles = Category.allCases.map { $0.rawValue }
    
    // These will store the starting selection passed from the previous screen.
    var initialAgeIndex: Int = 0
    var initialCategoryIndex: Int = 0
    
    // --- UI Components ---
    
    private lazy var agePickerView: UIPickerView = createPickerView()
    private lazy var categoryPickerView: UIPickerView = createPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Filters"
        
        setupUI()
        
        // Set the initial selections for the pickers.
        agePickerView.selectRow(initialAgeIndex, inComponent: 0, animated: false)
        categoryPickerView.selectRow(initialCategoryIndex, inComponent: 0, animated: false)
    }
    
    private func setupUI() {
        // Configure navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(didTapReset))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(didTapApply))
        
        // Create labels for the pickers
        let ageLabel = createPromptLabel(with: "Age")
        let categoryLabel = createPromptLabel(with: "Category")
        
        // Use a Stack View for easy layout
        let stackView = UIStackView(arrangedSubviews: [ageLabel, agePickerView, categoryLabel, categoryPickerView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.setCustomSpacing(24, after: agePickerView) // Add extra space between the pickers
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // --- Actions ---
    
    @objc private func didTapApply() {
        // Get the currently selected rows
        let selectedAgeIndex = agePickerView.selectedRow(inComponent: 0)
        let selectedCategoryIndex = categoryPickerView.selectedRow(inComponent: 0)
        
        // Send the data back to the delegate
        delegate?.didApplyFilters(ageIndex: selectedAgeIndex, categoryIndex: selectedCategoryIndex)
        
        // Dismiss the modal sheet
        dismiss(animated: true)
    }
    
    @objc private func didTapReset() {
        // Reset the pickers to the first item ("All")
        agePickerView.selectRow(0, inComponent: 0, animated: true)
        categoryPickerView.selectRow(0, inComponent: 0, animated: true)
        
        // Send the reset data back immediately and dismiss
        delegate?.didApplyFilters(ageIndex: 0, categoryIndex: 0)
        dismiss(animated: true)
    }
    
    // --- UIPickerView DataSource & Delegate ---
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Both pickers have only one column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == agePickerView ? ageTitles.count : categoryTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == agePickerView ? ageTitles[row] : categoryTitles[row]
    }
    
    // --- Helper Functions ---
    
    private func createPickerView() -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }
    
    private func createPromptLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }
}
