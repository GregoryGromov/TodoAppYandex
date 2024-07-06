import SwiftUI
import UIKit



class MyCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MyCollectionViewCell"
    
    private let dayLabel = UILabel()
    private let monthLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            
            monthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 5)
        ])
        
        contentView.layer.cornerRadius = 5
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func configure(with day: Int, month: String, isSelected: Bool) {
        dayLabel.text = "\(day)"
        monthLabel.text = month
        
        if isSelected {
            contentView.backgroundColor = UIColor(hex: "#D7D7CC")
            contentView.layer.borderColor = UIColor(hex: "#A1A1A1")?.cgColor
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

struct CalendarUIViewRepresentable: UIViewRepresentable {
    var dateTuples: [(day: Int, month: String)]
    @Binding var selectedDate: (day: Int, month: String)
    var onDelete: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 62, height: 62)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.addTarget(context.coordinator, action: #selector(context.coordinator.deleteButtonTapped), for: .touchUpInside)
        
        let selectedDateLabel = UILabel()
        selectedDateLabel.textAlignment = .center
        selectedDateLabel.text = "Selected Date: \(selectedDate.day) \(selectedDate.month)"
        
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(selectedDateLabel)
        container.addSubview(deleteButton)
        container.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 62),
            
            selectedDateLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            selectedDateLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            selectedDateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 10),
            deleteButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            
        ])
        
        if let index = dateTuples.firstIndex(where: { $0 == selectedDate }) {
            let indexPath = IndexPath(item: index, section: 0)
            DispatchQueue.main.async {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                context.coordinator.collectionView(collectionView, didSelectItemAt: indexPath)
                // Центрируем ячейку
                context.coordinator.centerCell(at: indexPath, in: collectionView)
            }
        }
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let label = uiView.subviews.compactMap({ $0 as? UILabel }).first {
            label.text = "Selected Date: \(selectedDate.day) \(selectedDate.month)"
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, selectedDate: $selectedDate, onDelete: onDelete)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: CalendarUIViewRepresentable
        var selectedIndexPath: IndexPath?
        var onDelete: () -> Void
        @Binding var selectedDate: (day: Int, month: String)
        
        init(_ parent: CalendarUIViewRepresentable, selectedDate: Binding<(day: Int, month: String)>, onDelete: @escaping () -> Void) {
            self.parent = parent
            self._selectedDate = selectedDate
            self.onDelete = onDelete
            if let index = parent.dateTuples.firstIndex(where: { $0 == selectedDate.wrappedValue }) {
                self.selectedIndexPath = IndexPath(item: index, section: 0)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return parent.dateTuples.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.reuseIdentifier, for: indexPath) as! MyCollectionViewCell
            let dateTuple = parent.dateTuples[indexPath.item]
            let isSelected = indexPath == selectedIndexPath
            cell.configure(with: dateTuple.day, month: dateTuple.month, isSelected: isSelected)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedIndexPath = indexPath
            parent.selectedDate = parent.dateTuples[indexPath.item]
            collectionView.reloadData()
            // Центрируем ячейку
            centerCell(at: indexPath, in: collectionView)
        }
        
        func centerCell(at indexPath: IndexPath, in collectionView: UICollectionView) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        @objc func deleteButtonTapped() {
            onDelete()
        }
    }
}
