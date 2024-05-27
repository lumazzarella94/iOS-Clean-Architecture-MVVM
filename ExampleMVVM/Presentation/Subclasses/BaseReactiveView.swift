//
//  BaseReactiveView.swift
//  ExampleMVVM
//
//  Created by Luigi Mazzarella on 27/05/24.
//

import UIKit

protocol ReactiveView: AnyObject {
    var observers: [AnyObserverValue] { get set }
    func addBinding<Value>(keyPath: ReferenceWritableKeyPath<Self, Value>, _ observableValue: ObservableValue<Value>)
}

extension ReactiveView where Self: UIView {
    
    func addBinding<Value>(keyPath: ReferenceWritableKeyPath<Self, Value>, _ observableValue: ObservableValue<Value>) {
        let binderID = observableValue.bind { [weak self] newValue in
            DispatchQueue.main.async {
                self?[keyPath: keyPath] = newValue
            }
        }
        let observer = Observer(binderID: binderID, observableValue: observableValue)
        observers.append(AnyObserverValue(observer))
    }
}
