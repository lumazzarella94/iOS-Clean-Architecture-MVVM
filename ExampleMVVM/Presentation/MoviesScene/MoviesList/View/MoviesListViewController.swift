//
//  MoviesListViewControllerNew.swift
//  ExampleMVVM
//
//  Created by Luigi Mazzarella on 27/05/24.
//

import UIKit

final class MoviesListViewController: UIViewController, Alertable {
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    private lazy var emptyDataLabel: ReactiveLabel = {
        let label = ReactiveLabel(keyPath: \.isHidden,
                                  viewModel.$showEmptyLabel)
        label.font = .boldSystemFont(ofSize: 24)
        label.text = NSLocalizedString("The list is empty", comment: "")
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        return label
    }()
    
    private lazy var moviesTableView: ReactiveTableView<[MoviesListItemViewModel]>  = {
        let tableView = ReactiveTableView<[MoviesListItemViewModel]>(items: viewModel.$items)
        tableView.backgroundColor = .black
        return tableView
    }()
    
    private let viewModel: MoviesListViewModel
    init(viewModel: MoviesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    static func create(with viewModel: MoviesListViewModel) -> MoviesListViewController {
        .init(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupSearchBar()
        setupTableView()
        setupLayout()
    }
    
    
    //MARK: - Private methods
    private func setupLayout(){
        title =  viewModel.title
        view.add(subviews: moviesTableView)
        
        moviesTableView.tableHeaderView = searchController.searchBar
        moviesTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.leadingAnchor,
                               bottom: view.bottomAnchor,
                               trailing: view.trailingAnchor)
        
        moviesTableView.insertSubview(emptyDataLabel, at: 0)
        emptyDataLabel.centerInSuperview()
        
        navigationItem.leftBarButtonItems = [
            .init(title: NSLocalizedString("Clear", comment: ""),
                  style: .done,
                  target: self,
                  action: #selector(clearMoviesList))
        ]
    }
    
    private func setupSearchBar() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
    }
    
    private func setupTableView() {        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.register(MoviesListItemCell.self,
                                 forCellReuseIdentifier: MoviesListItemCell.reuseIdentifier)

        moviesTableView.estimatedRowHeight = MoviesListItemCell.height
        moviesTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func updateQueriesSuggestions() {
        guard searchController.searchBar.isFirstResponder else {
            viewModel.closeQueriesSuggestions()
            return
        }
        viewModel.showQueriesSuggestions()
    }
    
    //MARK: - objc methods
    @objc
    private func clearMoviesList() {
        viewModel.resetPages()
    }
}

//MARK: - Searchbar delegate
extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        viewModel.didSearch(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
    }
}

//MARK: - SearchbarController delegate
extension MoviesListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
}

//MARK: - TableView Delegate
extension MoviesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MoviesListItemCell.reuseIdentifier,
            for: indexPath
        ) as? MoviesListItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(MoviesListItemCell.self) with reuseIdentifier: \(MoviesListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }
        
        cell.fill(with: viewModel.items[indexPath.row],
                  posterImagesRepository: viewModel.posterImagesRepository)
        
        if indexPath.row == viewModel.items.count - 1 {
            viewModel.didLoadNextPage()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
