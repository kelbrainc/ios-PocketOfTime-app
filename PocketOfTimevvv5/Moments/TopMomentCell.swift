//
//  TopMomentCell.swift
//  PocketOfTimevv3
//
//  Created by Kelly Chui on 30/10/25.
//


import UIKit

final class TopMomentCell: UICollectionViewCell {

    static let reuseID = "TopMomentCell"

    // MARK: - Callback
    /// Set this from the VC to respond when the "View" button is tapped.
    var onViewTapped: (() -> Void)?

    // MARK: - UI

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "Moment image"
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var viewButton: UIButton = {
        var config = UIButton.Configuration.gray()
        config.title = "View"
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)   // wire action
        button.isAccessibilityElement = true
        button.accessibilityLabel = "View moment"
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onViewTapped = nil
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear

        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let mainStack = UIStackView(arrangedSubviews: [imageView, textStack, viewButton])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Configure

    func configure(with memory: Memory) {
        if let data = memory.imageData {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = nil
        }

        // Use the first line of the memory text as the title (matches your model usage).
        titleLabel.text = memory.text.components(separatedBy: .newlines).first ?? "Captured Moment"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: memory.date)
    }

    // MARK: - Actions

    @objc private func viewTapped() {
        onViewTapped?()
    }
}
