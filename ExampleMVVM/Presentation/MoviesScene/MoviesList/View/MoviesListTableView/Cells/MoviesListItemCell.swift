import UIKit

final class MoviesListItemCell: UITableViewCell {

    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.sizeToFit()
        return label
    }()
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.sizeToFit()
        return label
    }()
    private var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    private var posterImageView: UIImageView = UIImageView()

    private var viewModel: MoviesListItemViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType = DispatchQueue.main
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    func setupLayout() {
        contentView.add(subviews: titleLabel, dateLabel, overviewLabel, posterImageView)
        
        posterImageView.anchor(top: contentView.topAnchor,
                               bottom: contentView.bottomAnchor,
                               trailing: contentView.trailingAnchor,
                               padding: .init(top: 10,
                                     left: 10,
                                     bottom: 10,
                                     right: 10))
        posterImageView.constraintSize(.init(width: 80,
                                             height: 120))
        
        titleLabel.anchor(top: contentView.topAnchor,
                          leading: contentView.leadingAnchor,
                          trailing: posterImageView.leadingAnchor,
                          padding: .init(top: 10,
                                         left: 10,
                                         bottom: 10,
                                         right: 10))
        dateLabel.anchor(top: titleLabel.bottomAnchor,
                         leading: titleLabel.leadingAnchor,
                         trailing: posterImageView.leadingAnchor)
        
        overviewLabel.anchor(top: dateLabel.bottomAnchor,
                             leading: titleLabel.leadingAnchor,
                             bottom: contentView.bottomAnchor,
                             trailing: posterImageView.leadingAnchor,
                             padding: .init(top: 0,
                                            left: 0,
                                            bottom: 10,
                                            right: 0))
        
        
    }
    
    func fill(
        with viewModel: MoviesListItemViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) {
        self.viewModel = viewModel
        self.posterImagesRepository = posterImagesRepository

        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.releaseDate
        overviewLabel.text = viewModel.overview
        updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }

    private func updatePosterImage(width: Int) {
        posterImageView.image = nil
        guard let posterImagePath = viewModel.posterImagePath else { return }

        imageLoadTask = posterImagesRepository?.fetchImage(
            with: posterImagePath,
            width: width
        ) { [weak self] result in
            self?.mainQueue.async {
                guard self?.viewModel.posterImagePath == posterImagePath else { return }
                if case let .success(data) = result {
                    self?.posterImageView.image = UIImage(data: data)
                }
                self?.imageLoadTask = nil
            }
        }
    }
}
