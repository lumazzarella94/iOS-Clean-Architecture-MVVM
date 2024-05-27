import Foundation

struct MoviesListViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}


class MoviesListViewModel {
    
    @ObservableValue var items: [MoviesListItemViewModel] = []
    @ObservableValue var loading: MoviesListViewModelLoading? = .none
    @ObservableValue var query: String = ""
    @ObservableValue var error: String = ""
    @ObservableValue var showEmptyLabel = true
    
    var title: String { NSLocalizedString("Movies", comment: "") }
    var searchBarPlaceholder: String {NSLocalizedString("Search Movies", comment: "")}
    var posterImagesRepository: PosterImagesRepository?
    
    private var currentPage: Int = 0
    private var totalPageCount: Int = 1
    private var hasMorePages: Bool { currentPage < totalPageCount }
    private var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let actions: MoviesListViewModelActions?
    private let mainQueue: DispatchQueueType
    private var emptyValueBinding: String?
    
    
    //MARK:  - Deinit
    deinit {
        if let emptyValueBinding {
            self.$items.unbind(emptyValueBinding)
            self.emptyValueBinding = nil
        }
    }
    
        //MARK: - init
    init(
        searchMoviesUseCase: SearchMoviesUseCase,
        actions: MoviesListViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main,
        posterImagesRepository: PosterImagesRepository?
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
        self.mainQueue = mainQueue
        self.posterImagesRepository = posterImagesRepository
        
        emptyValueBinding = self.$items.bind { [weak self] newValue in
            self?.showEmptyLabel = !newValue.isEmpty
        }
    }
    
    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading = loading
        query = movieQuery.query
        
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                self?.appendPage(page)
            },
            completion: { [weak self] result in
                switch result {
                case .success(let page):
                    self?.appendPage(page)
                case .failure(let error):
                    self?.handle(error: error)
                }
                self?.loading = .none
            })
    }
    
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        pages = pages
            .filter { $0.page != moviesPage.page }
        + [moviesPage]
        
        items = pages.movies.map(MoviesListItemViewModel.init)
    }
    
    func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.removeAll()
    }
    
    private func handle(error: Error) {
        self.error = error.isInternetConnectionError ?
        NSLocalizedString("No internet connection", comment: "") :
        NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
    
    func didLoadNextPage() {
        guard hasMorePages, loading == .none else { return }
        load(movieQuery: .init(query: query),
             loading: .nextPage)
    }
    
    func didSelectItem(at index: Int) {
        actions?.showMovieDetails(pages.movies[index])
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }
    
    func didCancelSearch() {
        moviesLoadTask?.cancel()
    }
    
    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions(update(movieQuery:))
    }
    
    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }
}

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
