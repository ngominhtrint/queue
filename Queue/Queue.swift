//
//  Queue.swift
//  Queue
//
//  Created by TriNgo on 1/12/19.
//  Copyright © 2019 RoverDream. All rights reserved.
//

import Foundation

// Queue class.
public class Queue {
    
    // Shared Queue.
    public static let shared = Queue.init(name: "Queue")
    
    // Queue `OperationQueue`.
    public let queue = OperationQueue()
    
    // Total `Operation` count in queue.
    public var operationCount: Int {
        return queue.operationCount
    }
    
    // `Operation`s currently in queue.
    public var operations: [Operation] {
        return queue.operations
    }
    
    // The default service level to apply to `Operation`s executed using the queue.
    public var qualityOfService: QualityOfService {
        get {
            return queue.qualityOfService
        }
        
        set {
            queue.qualityOfService = qualityOfService
        }
    }
    
    // Returns if the queue is executing or is in pause.
    // Call `resume()` to make it running.
    // Call `pause()` to make to pause it.
    public var isExecuting: Bool {
        return !queue.isSuspended
    }
    
    // Define the max concurrent `Operation`s count.
    public var maxConcurrentOperationCount: Int {
        get {
            return queue.maxConcurrentOperationCount
        }
        set {
            queue.maxConcurrentOperationCount = newValue
        }
    }
    
    // Create a new queue.
    //
    // - Parameters:
    //  - name: Custom queue name
    //  - maxConcurrentOperationCount: The max concurrent `Operation`s count
    //  - qualityOfService: The default service level to apply to `Operation`s executed using the queue.
    public init(name: String, maxConcurrentOperationCount: Int = Int.max, qualityOfService: QualityOfService = .default) {
        queue.name = name
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.qualityOfService = qualityOfService
    }
    
    // Cancel all `Operation`s in queue.
    public func cancelAll() {
        queue.cancelAllOperations()
    }
    
    // Pause the queue.
    public func pause() {
        queue.isSuspended = true
        
        for operation in queue.operations {
            if let concurrentOperation = operation as? ConcurrentOperation {
                concurrentOperation.pause()
            }
        }
    }
    
    // Resume the queue.
    public func resume() {
        queue.isSuspended = false
        
        for operation in queue.operations {
            if let concurrentOperation = operation as? ConcurrentOperation {
                concurrentOperation.resume()
            }
        }
    }
    
    // Blocks the current thread until all of the receiver's queued and executing
    // `Operation`s finish executing.
    public func waitUntilAllOperationsAreFinished() {
        queue.waitUntilAllOperationsAreFinished()
    }
}

// MARK: - Queue Operations and Chaining

// `Queue` extension with `Operation`s and chaining handling
public extension Queue {
    
    // Add an `Operation` to be executed asynchronously.
    //
    // - Parameter block: Block to be executed.
    public func addOperation(_ operation: @escaping () -> Void) {
        queue.addOperation(operation)
    }
    
    // Add an `Operation` to be executed asynchronously.
    //
    // - Parameter block: Block to be executed.
    public func addOperation(_ operation: Operation) {
        queue.addOperation(operation)
    }
    
    // Add an array of chained `Operations`s.
    //
    // Example:
    //
    // [A, B, C] = A -> B -> C -> completionHandler.
    // - Parameter:
    //   - operations: `Operation`s Array.
    //   - completionHandler: Completion block to be executed when all `Operation`s
    //                        are finished.
    public func addChainedOperations(_ operations: [Operation], completionHandler: (() -> Void)? = nil) {
        for (index, operation) in operations.enumerated() {
            if index > 0 {
                operation.addDependency(operations[index - 1])
            }
            
            addOperation(operation)
        }
        
        guard let completionHandler = completionHandler else {
            return
        }
        
        addCompletionHandler(completionHandler)
    }
    
    // Add an array of chained `Operation`s.
    //
    // Example:
    //
    //  [A, B, C] = A -> B -> C completionHandler.
    // - Parameter:
    //  - operations: `Operation`s Array.
    //  - completionHandler: Completion block to be executed when all `Operation`s
    //                       are finished.
    public func addChainedOperation(_ operations: Operation..., completionHandler: (() -> Void)? = nil) {
        addChainedOperations(operations, completionHandler: completionHandler)
    }
    
    // Add completion block to the queue.
    //
    // - Parameter completionHandler: Completion handler to be executed as last `Opearation`.
    public func addCompletionHandler(_ completionHandler: @escaping () -> Void) {
        let completionOperation = BlockOperation(block: completionHandler)
        if let lastOperation = operations.last {
            completionOperation.addDependency(lastOperation)
        }
        addOperation(completionOperation)
    }
}

// MARK: - Queue State restoration

// `Queue` extension with state restoration feature.
public extension Queue {
    
    // `OperationState` array typealias.
    public typealias QueueStateList = [OperationState]
    
    // Creates the queue state.
    //
    // - Returns: Returns the current queue state
    public func state() -> QueueStateList {
        return Queue.state(of: queue)
    }
    
    
    public static func state(of queue: OperationQueue) -> QueueStateList {
        var operations: QueueStateList = []
        
        for operation in queue.operations {
            if let concurrentOperation = operation as? ConcurrentOperation, let operationName = concurrentOperation.name {
                operations.append(OperationState.init(name: operationName, progress: concurrentOperation.progress, dependencies: operation.dependencies.compactMap { $0.name }))
            }
        }
        
        return operations
    }
}


