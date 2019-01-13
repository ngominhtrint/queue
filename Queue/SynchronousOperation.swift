//
//  SynchronousOperation.swift
//  Queue
//
//  Created by TriNgo on 1/13/19.
//  Copyright © 2019 RoverDream. All rights reserved.
//

import Foundation

// It allows synchronous tasks, has a pause and resume states,
// can be easily added to a queue and can be created with a block.
public class SynchronousOperation: ConcurrentOperation {
    
    // Private `Semaphore` instance.
    private let semaphore = Semaphore()
    
    // Set the `Operation` as synchronous.
    public override var isAsynchronous: Bool {
        return false
    }
    
    // Notify the completion of synchronous task and hence the completion of the `Operation`.
    // Must be called when the `Operation` is finished.
    //
    // - Parameter success: Set it to `false` if the `Operation` has failed, otherwise `true`.
    //                      Default is `true`.
    public override func finish(success: Bool = true) {
        super.finish(success: success)
        
        semaphore.continue()
    }
    
    // Advises the `Operation` object that it should stop executing its task.
    public override func cancel() {
        super.cancel()
        
        semaphore.continue()
    }
    
    // Execute the `Operation`.
    // If `executionBlock` is set, it will be executed and also `finish()` will be called.
    public override func execute() {
        super.execute()
        
        semaphore.wait()
    }
}
