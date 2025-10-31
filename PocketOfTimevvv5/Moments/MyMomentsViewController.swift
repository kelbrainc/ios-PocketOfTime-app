//
//  MyMomentsViewController.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//

import UIKit

final class MyMomentsViewController: UIViewController, AddMemoryDelegate, CalendarFilterDelegate {

    // MARK: - Sections & Items (Diffable)
    private enum Section: Int, CaseIterable, Hashable {
        case empty
        case top
        case recent

        var title: String {
            switch self {
            case .empty:  return ""
            case .top:    return "Newest Moment"
            case .recent: return "Recent Moments"
            }
        }
    }

    nonisolated enum Item: Hashable {
        case empty(UUID)
        case topMemory(Memory)
        case recentMemory(Memory)
    }

    // MARK: - Data
    private var allMemories: [Memory] = []
    private var currentFilterDate: Date? = nil  // filters by month when set

    // MARK: - UI
    private var collectionView: UICollectionView!
    
    // background
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background2")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
//        let glassEffect = UIGlassEffect()
//        let visualEffectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()

//    private lazy var headerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .systemIndigo.withAlphaComponent(0.9)
//        view.layer.cornerRadius = 16
//        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // rounded bottom
//        view.clipsToBounds = true
//        return view
//    }()

    
    @MainActor
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true

        setupBackgroundAndHeader()
        configureNavBar()
        configureCollectionView()
        configureDataSource()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData() // refresh when returning from other tabs
    }

    // MARK: - Nav Bar and background
    
    private func setupBackgroundAndHeader() {
        // Background image
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Liquid glass blur overlay
        view.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureNavBar() {
        title = "Moments"
        navigationController?.navigationBar.prefersLargeTitles = true

        let add = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
            self?.didTapAdd()
        })
        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(didTapCalendar))
        let clear = UIBarButtonItem(title: "Show All",
                                    style: .plain,
                                    target: self,
                                    action: #selector(didTapShowAll))

        navigationItem.rightBarButtonItems = [add, calendar, clear]
        
        let liked = UIBarButtonItem(image: UIImage(systemName: "heart.fill"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(didTapLiked))
        navigationItem.leftBarButtonItem = liked

    }

    // MARK: - Collection View
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Cells
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: EmptyStateCell.reuseID)
        collectionView.register(TopMomentCell.self, forCellWithReuseIdentifier: TopMomentCell.reuseID)
        collectionView.register(MemoryCell.self, forCellWithReuseIdentifier: MemoryCell.reuseID)

        // Section headers
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.reuseID)
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
            UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
                guard let self else { return nil }
                // 0 => either .empty or .top depending on snapshot; both layouts safe.

                let header: NSCollectionLayoutBoundarySupplementaryItem = {
                    let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                    return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
                }()

                // Empty layout (centered box)
                func empty() -> NSCollectionLayoutSection {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    let sec = NSCollectionLayoutSection(group: group)
                    sec.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)
                    return sec
                }

                // Top (big card)
                func top() -> NSCollectionLayoutSection {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(270))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    let sec = NSCollectionLayoutSection(group: group)
                    sec.boundarySupplementaryItems = [header]
                    sec.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 4, trailing: 0)
                    return sec
                }

                // Recent (compact rows)
                func recent() -> NSCollectionLayoutSection {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(76))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    let sec = NSCollectionLayoutSection(group: group)
                    sec.boundarySupplementaryItems = [header]
                    sec.interGroupSpacing = 4
                    sec.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 12, trailing: 0)
                    return sec
                }

                // Heuristic: if snapshot has only .empty, first section will use empty()
                let sections = self.dataSource?.snapshot().sectionIdentifiers ?? []
                if sections.indices.contains(sectionIndex) {
                    switch sections[sectionIndex] {
                    case .empty:  return empty()
                    case .top:    return top()
                    case .recent: return recent()
                    }
                }
                // Fallback
                return recent()
            }
    }

    
    @MainActor
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }

            
            switch item {
            case .empty:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.reuseID, for: indexPath) as! EmptyStateCell
                cell.configure(with: "No moments yet.\nTap “+” to capture your first!")
                return cell

            case .topMemory(let mem):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoryCell.reuseID, for: indexPath) as! MemoryCell
                cell.configure(with: mem)
                cell.likeButtonTapped = { [weak self] in self?.toggleLike(for: mem) }
                return cell

            case .recentMemory(let mem):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopMomentCell.reuseID, for: indexPath) as! TopMomentCell
                cell.configure(with: mem)
                cell.onViewTapped = { [weak self] in self?.showDetail(for: mem) }
                return cell

            }
        }

        // Supplementary (section headers)
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self,
                  kind == UICollectionView.elementKindSectionHeader else { return nil }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            guard section != .empty else { return nil }  // no header for empty

            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseID,
                for: indexPath
            ) as! SectionHeaderView
            header.setTitle(section.title)
            return header
        }

    }

    // MARK: - Data Loading & Snapshot
    private func loadData() {
        let loaded = PersistenceManager.shared.loadMemories()
        // newest first
        allMemories = loaded.sorted(by: { $0.date > $1.date })
        updateSnapshot()
    }

    private func filteredMemories() -> [Memory] {
        guard let month = currentFilterDate else { return allMemories }
        return allMemories.filter { Calendar.current.isDate($0.date, equalTo: month, toGranularity: .month) }
    }
    
    @MainActor
    private func updateSnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        let list = filteredMemories()

        if list.isEmpty {
            snapshot.appendSections([.empty])
            snapshot.appendItems([Item.empty(UUID())], toSection: .empty)
        } else {
            snapshot.appendSections([.top, .recent])

            // Top = first item
            if let first = list.first {
                snapshot.appendItems([Item.topMemory(first)], toSection: .top)
            }

            // Recent = the rest
            let rest = Array(list.dropFirst().prefix(10))
            snapshot.appendItems(rest.map { Item.recentMemory($0) }, toSection: .recent)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Actions
    private func didTapAdd() {
        let addVC = AddMemoryViewController()
        addVC.delegate = self
        let nav = UINavigationController(rootViewController: addVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    @objc private func didTapCalendar() {
        let cal = CalendarFilterViewController()
        cal.delegate = self
        let nav = UINavigationController(rootViewController: cal)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    @objc private func didTapShowAll() {
        currentFilterDate = nil
        loadData()                               // reload from disk (not just snapshot)
        collectionView.setContentOffset(.zero, animated: true)  // scroll to top for feedback
    }


    private func toggleLike(for memory: Memory) {
        // flip liked state and persist
        var updated = memory
        updated.isLiked.toggle()
        PersistenceManager.shared.updateMemory(updated)

        // update in-memory copy
        if let idx = allMemories.firstIndex(where: { $0.id == updated.id }) {
            allMemories[idx] = updated
        }
        updateSnapshot()
    }
    
    @objc private func didTapLiked() {
        let vc = FilteredMomentsViewController(title: "Liked Moments") { $0.isLiked }
        navigationController?.pushViewController(vc, animated: true)
    }
    


    // MARK: - AddMemoryDelegate
    func didFinishSavingMemory() {
        dismiss(animated: true) { [weak self] in
            self?.loadData()
        }
    }

    // MARK: - CalendarFilterDelegate
    func didSelectDate(date: Date) {
        currentFilterDate = date
        loadData()
        updateSnapshot()
        collectionView.setContentOffset(.zero, animated: true)
    }
}

// MARK: - Simple Section Header
private final class SectionHeaderView: UICollectionReusableView {
    static let reuseID = "SectionHeaderView"

    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .label
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTitle(_ text: String) { label.text = text }
}

extension MyMomentsViewController {
    fileprivate func showDetail(for memory: Memory) {
        let vc = MemoryDetailViewController(memory: memory)
        navigationController?.pushViewController(vc, animated: true)
    }
}


#Preview {
    let myMomentsVC = MyMomentsViewController()
    return UINavigationController(rootViewController: myMomentsVC)
}
