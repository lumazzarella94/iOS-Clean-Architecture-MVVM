//
//  ReactiveLabel.swift
//  ExampleMVVM
//
//  Created by Luigi Mazzarella on 27/05/24.
//

import UIKit


final class ReactiveLabel: UILabel, ReactiveView {
    
    var observers: [AnyObserverValue] = []
    
    deinit {
        observers.forEach { observer in
            observer.unbind()
        }
    }
    
    convenience init<Value>(keyPath: ReferenceWritableKeyPath<ReactiveLabel, Value>, _ observableValue: ObservableValue<Value>) {
        self.init(frame: .zero)
        addBinding(keyPath: keyPath,
                   observableValue)
    }
}
