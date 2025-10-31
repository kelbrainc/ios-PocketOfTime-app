//
//  CalendarFilterViewController.swift
//  PocketOfTimev3
//
//  Created by Kelly Chui on 24/10/25.
//


import UIKit

// protocol to send data back.
protocol CalendarFilterDelegate: AnyObject {
    // This function will be called when a date is selected.
    func didSelectDate(date: Date)
}

class CalendarFilterViewController: UIViewController, UICalendarSelectionSingleDateDelegate {
    
    // A 'weak' delegate to avoid retain cycles.
    weak var delegate: CalendarFilterDelegate?
    
    private lazy var calendarView: UICalendarView = {
        let calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure the calendar
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        
        // Set up date selection
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection
        
        return calendar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Filter by Date"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )

        view.addSubview(calendarView)

        // Preselect today so users can just hit a day immediately
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate {
            let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            selection.setSelected(comps, animated: false)
        }

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    // MARK: - UICalendarSelectionSingleDateDelegate
    
    // This delegate function is called when the user taps a date.
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard
            let comps = dateComponents,
            let pickedDate = Calendar.current.date(from: comps)
        else { return }

        // Normalize to the 1st of the selected month (since Moments filters by month)
        let firstOfMonth = Calendar.current.date(
            from: DateComponents(year: comps.year, month: comps.month, day: 1)
        ) ?? pickedDate

        delegate?.didSelectDate(date: firstOfMonth)
        dismiss(animated: true)
    }
}
