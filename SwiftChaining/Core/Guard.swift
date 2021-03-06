//
//  Guard.swift
//

import Foundation

extension Chain {
    public typealias GuardChain = Chain<HandlerOut, HandlerOut, Sender>
    
    public func `guard`(_ isIncluded: @escaping (HandlerOut) -> Bool) -> GuardChain {
        guard let joint = self.joint else {
            fatalError()
        }
        
        self.joint = nil
        
        let handler = self.handler
        let nextIndex = joint.handlers.count + 1
        
        let guardHandler: (HandlerIn) -> Void = { [weak joint] value in
            let result = handler(value)
            
            guard isIncluded(result) else {
                return
            }
            
            if let nextHandler = joint?.handlers[nextIndex] as? (HandlerOut) -> Void {
                nextHandler(result)
            }
        }
        
        joint.handlers.append(guardHandler)
        
        return GuardChain(joint: joint) { $0 }
    }
}
