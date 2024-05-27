//
//  UIView+Extension.swift
//  TestUI
//
//  Created by Luigi Mazzarella on 08/03/24.
//


import UIKit

///
/// anchor constraint
///
struct AnchoredConstraints {
    var top: NSLayoutConstraint?
    var leading: NSLayoutConstraint?
    var trailing: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    var width: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    var centerX: NSLayoutConstraint?
    var centerY: NSLayoutConstraint?
}

extension UIView {
    ///Add multiple views to superview
    ///
    ///- Parameters:
    ///  - subviews: variadics parameter that requires view to add to superview
    ///
    ///# Example #
    ///```swift
    ///let superview = UIView()
    ///let subview1 = UIView()
    ///let subview2 = UIView()
    ///superview.add(subview1, subview2)
    ///```
    ///
    func add(subviews: UIView...) {
        subviews.forEach { subiew in
            addSubview(subiew)
        }
    }
}

extension UIView {
    
    /// this methods anchors on a view to its superview
    ///
    ///- Parameters:
    ///  - superview: superview
    ///  - padding: UIEdgeInsets with default at zero
    ///- Returns: Return the list of set NSLayoutConstraint
    ///
    ///# Example #
    ///```swift
    ///let superview = UIView()
    ///let subview1 = UIView()
    ///subview1.fill(superview: superview)
    ///```
    ///- example with no zero padding
    ///```swift
    ///let superview = UIView()
    ///let subview1 = UIView()
    ///subview1.fill(superview: superview,
    ///               padding: .init(top: 10,
    ///                             left: 10,
    ///                             bottom: 10,
    ///                             right: 10)
    ///```
    @discardableResult
    func fill(superview: UIView, padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        removeFromSuperview()
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        return anchor(top: self.superview!.topAnchor,
                      leading: self.superview!.leadingAnchor,
                      bottom: self.superview!.bottomAnchor,
                      trailing: self.superview!.trailingAnchor,
                      padding: padding)
    }
    
    /// this methods anchors on a view to its superview using safeArea
    ///
    ///- Parameters:
    ///  - superview: superview
    ///  - padding: UIEdgeInsets with default at zero
    ///- Returns: Return the list of set NSLayoutConstraint
    ///
    ///# Example #
    ///```swift
    ///let superview = UIView()
    ///let subview1 = UIView()
    ///subview1.fillSafeArea(superview: superview)
    ///```
    ///- example with no zero padding
    ///```swift
    ///let superview = UIView()
    ///let subview1 = UIView()
    ///subview1.fillSafeArea(superview: superview,
    ///               padding: .init(top: 10,
    ///                             left: 10,
    ///                             bottom: 10,
    ///                             right: 10)
    ///```
    @discardableResult
    func fillSafeArea(superview: UIView, padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        removeFromSuperview()
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        return anchor(top: self.superview!.safeAreaLayoutGuide.topAnchor,
                      leading: self.superview!.safeAreaLayoutGuide.leadingAnchor,
                      bottom: self.superview!.safeAreaLayoutGuide.bottomAnchor,
                      trailing: self.superview!.safeAreaLayoutGuide.trailingAnchor,
                      padding: padding)
    }
    
        /// this methods anchors on a view with specific anchors
        ///
        ///- Parameters:
        ///  - top: Top anchor to set
        ///  - leading: Leading anchor to set
        ///  - bottom: Bottom anchor to set
        ///  - trailing: Trailing anchor to set
        ///  - size: View size
        ///  - padding: UIEdgeInsets with default at zero
        ///- Returns: Return the list of set NSLayoutConstraint
        ///
        ///# Example #
        ///```swift
        ///let superview = UIView()
        ///let subview = UIView()
        ///subview.anchor(top: superview.topAnchor,
        ///               leading: superview.leadingAnchor,
        ///               bottom: superview.bottomAnchor,
        ///               trailing: superview.trailingAnchor,
        ///               padding: .init(top: 10,
        ///                              left: 10,
        ///                              bottom: 10,
        ///                              right: 10))
        ///```
        ///
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero,
                size: CGSize = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing,
         anchoredConstraints.width,
         anchoredConstraints.height].forEach { $0?.isActive = true }
        
        return anchoredConstraints
    }
    
        /// this methods anchors on a center of superview
        ///
        ///- Parameters:
        ///  - size: View size
        ///- Returns: Return the list of set NSLayoutConstraint
        ///
        ///# Example #
        ///```swift
        ///let superview = UIView()
        ///let subview = UIView()
        ///subview.centerInSuperview(size: CGSize(width: 200, height: 200))
        ///```
        ///
    @discardableResult
    func centerInSuperview(size: CGSize = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        if let superviewCenterX = superview?.centerXAnchor {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: superviewCenterX)
        }
        if let superviewCenterY = superview?.centerYAnchor {
            anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: superviewCenterY)
        }
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchoredConstraints.centerX,
         anchoredConstraints.centerY,
         anchoredConstraints.width,
         anchoredConstraints.height].forEach { $0?.isActive = true }
        
        return anchoredConstraints
    }
    
        /// this methods anchors on a center x of superview
        ///
        ///- Returns: Return the list of set NSLayoutConstraint
        ///
        ///# Example #
        ///```swift
        ///let superview = UIView()
        ///let subview = UIView()
        ///subview.centerXToSuperview()
        ///```
        ///
    @discardableResult
    func centerXToSuperview() -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        if let superviewCenterX = superview?.centerXAnchor {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: superviewCenterX)
        }
        anchoredConstraints.centerX?.isActive = true
        
        return anchoredConstraints
    }
    
        /// this methods anchors on a center Y of superview
        ///
        ///- Returns: Return the list of set NSLayoutConstraint
        ///
        ///# Example #
        ///```swift
        ///let superview = UIView()
        ///let subview = UIView()
        ///subview.centerYToSuperview()
        ///```
        ///
    @discardableResult
    func centerYToSuperview() -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        if let superviewCenterY = superview?.centerYAnchor {
            anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: superviewCenterY)
        }
        anchoredConstraints.centerY?.isActive = true
        return anchoredConstraints
    }
    
        /// Sets the width with a multiplier.
        ///
        /// This method sets the width relative to another dimension using a specified multiplier.
        /// Returns a list of the set `NSLayoutConstraint`.
        ///
        /// - Parameters:
        ///   - width: The reference dimension (`NSLayoutDimension`) to which you want to anchor the width.
        ///   - multiplier: The multiplier to apply to the reference dimension. The default value is `1`.
        /// - Returns: Returns an `AnchoredConstraints` object containing the set constraint.
        ///
        /// # Example #
        /// ```swift
        /// let superview = UIView()
        /// let subview = UIView()
        /// superview.addSubview(subview)
        /// subview.constraintWidth(superview.widthAnchor, multiplier: 0.5)
        /// // This sets the width of `subview` to 50% of the width of `superview`.
        /// ```
    @discardableResult
    func constraintWidth(_ width: NSLayoutDimension, multiplier: CGFloat = 1) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.width = widthAnchor.constraint(equalTo: width, multiplier: multiplier)
        anchoredConstraints.width?.isActive = true
        
        return anchoredConstraints
    }
    
        /// Sets the height with a multiplier.
        ///
        /// This method sets the height relative to another dimension using a specified multiplier.
        /// Returns a list of the set `NSLayoutConstraint`.
        ///
        /// - Parameters:
        ///   - height: The reference dimension (`NSLayoutDimension`) to which you want to anchor the height.
        ///   - multiplier: The multiplier to apply to the reference dimension. The default value is `1`.
        /// - Returns: Returns an `AnchoredConstraints` object containing the set constraint.
        ///
        /// # Example #
        /// ```swift
        /// let superview = UIView()
        /// let subview = UIView()
        /// superview.addSubview(subview)
        /// subview.constraintHeight(superview.heightAnchor, multiplier: 0.5)
        /// // This sets the height of `subview` to 50% of the height of `superview`.
        /// ```
    @discardableResult
    func constraintHeight(_ height: NSLayoutDimension, multiplier: CGFloat = 1) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.height = heightAnchor.constraint(equalTo: height, multiplier: multiplier)
        anchoredConstraints.height?.isActive = true
        
        return anchoredConstraints
    }
    
        /// Sets the size of the view.
        ///
        /// This method sets the width and height of the view to the specified size.
        /// Returns a list of the set `NSLayoutConstraint`.
        ///
        /// - Parameters:
        ///   - size: The desired size (`CGSize`) to set for the view's width and height.
        /// - Returns: Returns an `AnchoredConstraints` object containing the set constraints.
        ///
        /// # Example #
        /// ```swift
        /// let superview = UIView()
        /// let subview = UIView()
        /// superview.addSubview(subview)
        /// subview.constraintSize(CGSize(width: 100, height: 50))
        /// // This sets the width of `subview` to 100 points and the height to 50 points.
        /// ```
    @discardableResult
    func constraintSize(_ size: CGSize) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        anchoredConstraints.width?.isActive = true
        anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        anchoredConstraints.height?.isActive = true
        
        return anchoredConstraints
    }
    
        /// Sets the width of the view.
        ///
        /// This method sets the width of the view to the specified constant value.
        /// Returns a list of the set `NSLayoutConstraint`.
        ///
        /// - Parameters:
        ///   - constant: The desired width (`CGFloat`) to set for the view.
        /// - Returns: Returns an `AnchoredConstraints` object containing the set constraint.
        ///
        /// # Example #
        /// ```swift
        /// let superview = UIView()
        /// let subview = UIView()
        /// superview.addSubview(subview)
        /// subview.constraintWidth(100)
        /// // This sets the width of `subview` to 100 points.
        /// ```
    @discardableResult
    func constraintWidth(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.width?.isActive = true
        
        return anchoredConstraints
    }
    
        /// Sets the height of the view.
        ///
        /// This method sets the height of the view to the specified constant value.
        /// Returns a list of the set `NSLayoutConstraint`.
        ///
        /// - Parameters:
        ///   - constant: The desired height (`CGFloat`) to set for the view.
        /// - Returns: Returns an `AnchoredConstraints` object containing the set constraint.
        ///
        /// # Example #
        /// ```swift
        /// let superview = UIView()
        /// let subview = UIView()
        /// superview.addSubview(subview)
        /// subview.constraintHeight(50)
        /// // This sets the height of `subview` to 50 points.
        /// ```
    @discardableResult
    func constraintHeight(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.height?.isActive = true
        
        return anchoredConstraints
    }
    
}
