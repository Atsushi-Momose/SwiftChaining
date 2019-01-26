//
//  UIControlAlias.swift
//

import UIKit

final public class UIControlAlias<T: UIControl>: NSObject {
    private weak var control: UIControl?
    private let events: UIControl.Event
    
    public init(_ control: T, events: UIControl.Event) {
        self.control = control
        self.events = events
        
        super.init()
        
        control.addTarget(self, action: #selector(UIControlAlias.notify(_:)), for: events)
    }
    
    deinit {
        self.invalidate()
    }
    
    public func invalidate() {
        self.control?.removeTarget(self, action: #selector(UIControlAlias.notify(_:)), for: self.events)
        self.control = nil
    }
    
    @objc private func notify(_ sender: UIControl) {
        if let sender = sender as? T {
            self.broadcast(value: sender)
        }
    }
}

extension UIControlAlias: Sendable {
    public typealias SendValue = T
}