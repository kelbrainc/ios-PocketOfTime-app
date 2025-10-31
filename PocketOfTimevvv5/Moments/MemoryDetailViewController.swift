//
//  MemoryDetailViewController.swift
//  PocketOfTimevvv5
//
//  Created by Kelly Chui on 30/10/25.
//


import UIKit

final class MemoryDetailViewController: UIViewController {

    // MARK: - State
    private var memory: Memory

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = .systemGray5
        return iv
    }()
    private var imageHeightConstraint: NSLayoutConstraint!

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .semibold)
        l.numberOfLines = 0
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.numberOfLines = 0
        return l
    }()

    // MARK: - Init
    init(memory: Memory) {
        self.memory = memory
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Moment"

        setupNavItems()
        setupLayout()
        apply(memory)
    }

    // MARK: - Nav Items
    private func setupNavItems() {
        // Heart toggle
        let heart = UIBarButtonItem(
            image: UIImage(systemName: memory.isLiked ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleLike)
        )
        heart.tintColor = memory.isLiked ? .systemPink : .label

        // Optional share button (shares text + image if present)
        let share = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped)
        )
        navigationItem.rightBarButtonItems = [share, heart]
    }

    private func refreshHeartIcon() {
        // update the last rightBarButtonItem (heart)
        guard var items = navigationItem.rightBarButtonItems, let last = items.last else { return }
        last.image = UIImage(systemName: memory.isLiked ? "heart.fill" : "heart")
        last.tintColor = memory.isLiked ? .systemPink : .label
        items[items.count - 1] = last
        navigationItem.rightBarButtonItems = items
    }

    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentStack)

        // Image height (collapsible if no image)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 240)
        imageHeightConstraint.isActive = true

        // Add arranged subviews
        contentStack.addArrangedSubview(imageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(dateLabel)
        contentStack.addArrangedSubview(bodyLabel)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Populate
    private func apply(_ memory: Memory) {
        if let data = memory.imageData, let img = UIImage(data: data) {
            imageView.image = img
            imageView.isHidden = false
            imageHeightConstraint.constant = 240
        } else {
            imageView.image = nil
            imageView.isHidden = true
            imageHeightConstraint.constant = 0
        }

        // Title = first line of text
        titleLabel.text = memory.text.components(separatedBy: .newlines).first ?? "Captured Moment"

        let df = DateFormatter()
        df.dateStyle = .medium
        dateLabel.text = df.string(from: memory.date)

        // Body = full text (can be the same as title if one-liner)
        bodyLabel.text = memory.text
        refreshHeartIcon()
    }

    // MARK: - Actions
    @objc private func toggleLike() {
        memory.isLiked.toggle()
        // Persist the change
        PersistenceManager.shared.updateMemory(memory)
        // Reflect in UI
        refreshHeartIcon()
    }

    @objc private func shareTapped() {
        var items: [Any] = [memory.text]
        if let data = memory.imageData, let img = UIImage(data: data) {
            items.append(img)
        }
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }
}
