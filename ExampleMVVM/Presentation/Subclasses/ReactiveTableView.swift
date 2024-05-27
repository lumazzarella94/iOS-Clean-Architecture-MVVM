//
//  File.swift
//  ExampleMVVM
//
//  Created by Luigi Mazzarella on 27/05/24.
//

import UIKit

class ReactiveTableView<TableViewItem>: UITableView {
    var observers: [AnyObserverValue] = []
    
    deinit {
        observers.forEach { observer in
            observer.unbind()
        }
    }
    
    init(items: ObservableValue<TableViewItem>) {
        super.init(frame: .zero, style: .plain)
        
        let bindID = items.bind(observer: { [weak self] newValue in
            DispatchQueue.main.async {
                guard let self else { return }
                self.reloadData()
            }
        })
        
        let observer = Observer(binderID: bindID, observableValue: items)
        observers.append(AnyObserverValue(observer))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
