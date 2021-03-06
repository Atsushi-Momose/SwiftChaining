//
//  Suspender.swift
//

import Foundation

public class Suspender {
    public var isSuspend: Bool {
        get { return self.holder.value }
        set { self.holder.value = newValue }
    }
    
    private let holder: ValueHolder<Bool>
    fileprivate let notifier = Notifier<Bool>()
    private let observer: AnyObserver
    
    public init(_ isSuspend: Bool = false) {
        self.holder = ValueHolder(isSuspend)
        self.observer = self.holder.chain().receive(self.notifier).end()
    }
    
    public func chain() -> ValueHolder<Bool>.SenderChain {
        return self.holder.chain()
    }
}

extension Suspender: Receivable {
    public func receive(value: Bool) {
        self.holder.receive(value: value)
    }
}

extension Chain {
    public func suspend(_ suspender: Suspender) -> Chain<HandlerOut, HandlerOut, Sender> {
        return self.guard { [weak suspender] _ in !(suspender?.isSuspend ?? false) }
    }
}

extension Chain where Sender: Fetchable {
    public func suspend(_ suspender: Suspender) -> Chain<HandlerOut, HandlerOut?, Sender> {
        var cache: HandlerOut?
        
        let chain = self
            .pair(suspender.notifier.chain())
            .to { [weak suspender] (lhs, rhs) -> HandlerOut? in
                let isSuspend = suspender?.isSuspend ?? false
                
                if let lhs = lhs {
                    if isSuspend {
                        cache = lhs
                        return nil
                    } else {
                        return lhs
                    }
                } else if let rhs = rhs {
                    if rhs {
                        cache = nil
                        return nil
                    } else {
                        return cache
                    }
                } else {
                    fatalError()
                }
            }
            .guardUnwrap()
        
        return chain
    }
}
