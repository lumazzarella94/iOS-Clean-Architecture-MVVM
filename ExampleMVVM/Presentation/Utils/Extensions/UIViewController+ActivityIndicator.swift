import UIKit

extension UITableViewController {

    func makeActivityIndicator(size: CGSize) -> UIActivityIndicatorView {
       
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tintColor =  self.traitCollection.userInterfaceStyle == .dark ? .white : .gray
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.frame = .init(origin: .zero, size: size)

        return activityIndicator
    }
}
