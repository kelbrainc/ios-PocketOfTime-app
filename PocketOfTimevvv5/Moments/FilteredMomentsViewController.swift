//
//  FilteredMomentsViewController.swift
//  PocketOfTimevv3
//
//  Created by Kelly Chui on 30/10/25.
//

import UIKit

final class FilteredMomentsViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Mode
    private enum Mode {
        case byMonth(Date)
        case byPredicate(title: String, filter: (Memory) -> Bool)

        var navTitle: String {
            switch self {
            case .byMonth(let date):
                let f = DateFormatter()
                f.dateFormat = "MMMM yyyy"
                return f.string(from: date)
            case .byPredicate(let title, _):
                return title
            }
        }
    }

    // MARK: - Public inits (keeps your old usage working)
    /// Existing usage: month filter
    convenience init(filterDate: Date) {
        self.init(mode: .byMonth(filterDate))
    }

    /// New usage: arbitrary filter (e.g., liked moments)
    convenience init(title: String, predicate: @escaping (Memory) -> Bool) {
        self.init(mode: .byPredicate(title: title, filter: predicate))
    }

    // Designated init
    private init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - State
    private let mode: Mode
    private var filteredMemories: [Memory] = []

    // MARK: - UI
    private var collectionView: UICollectionView!
    @MainActor private var dataSource: UICollectionViewDiffableDataSource<Int, Memory>!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = mode.navTitle
        navigationController?.setNavigationBarHidden(false, animated: false)

        configureCollectionView()
        configureDataSource()
        loadAndFilterData()
        updateSnapshot()
    }

    // MARK: - Setup
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(MemoryCell.self, forCellWithReuseIdentifier: MemoryCell.reuseID)
        
        collectionView.allowsSelection = true
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    // MARK: - Data
    private func loadAndFilterData() {
        let all = PersistenceManager.shared
            .loadMemories()
            .sorted { $0.date > $1.date }

        switch mode {
        case .byMonth(let date):
            filteredMemories = all.filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month) }
        case .byPredicate(_, let filter):
            filteredMemories = all.filter(filter)
        }
    }

    @MainActor
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Memory>(collectionView: collectionView) { [weak self]
            (collectionView, indexPath, memory) -> UICollectionViewCell? in

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoryCell.reuseID, for: indexPath) as? MemoryCell else {
                fatalError("Cannot create MemoryCell")
            }
            cell.configure(with: memory)

            // Optional: enable like toggling inside the filtered list
            cell.likeButtonTapped = { [weak self] in
                self?.toggleLike(for: memory)
            }

            return cell
        }
    }

    @MainActor
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Memory>()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredMemories)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // Handle tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Safest way with diffable DS:
        guard let memory = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = MemoryDetailViewController(memory: memory)
        navigationController?.pushViewController(vc, animated: true)
    }


    private func toggleLike(for memory: Memory) {
        var updated = memory
        updated.isLiked.toggle()
        PersistenceManager.shared.updateMemory(updated)

        // Recompute filter, then refresh UI
        loadAndFilterData()
        Task { @MainActor in
            updateSnapshot()
        }
    }

    // MARK: - Layout (2-column grid)
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(220)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
