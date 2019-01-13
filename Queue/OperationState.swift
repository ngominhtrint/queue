//
//  OperationState.swift
//  Queue
//
//  Created by TriNgo on 1/12/19.
//  Copyright © 2019 RoverDream. All rights reserved.
//

import Foundation

// `Operation` State class.
// Used to save the `Operation` State.
// This class allows to save the current queue state.
public class OperationState: Codable {
    
    // `Operation` name.
    public var name: String
    
    // `Operation` progress
    public var progress: Int
    
    // `Operation` dependencies. It
    public var dependencies: [String]
    
    // Initialize an `OperationState`.
    //
    // - Parameters:
    //  - name: `Operation` name.
    //  - progress: `Operation` progress.
    //  - dependencies: `Operation` dependencies.
    public init(name: String, progress: Int, dependencies: [String]) {
        self.name = name
        self.progress = progress
        self.dependencies = dependencies
    }
}

// `OperationState` extension to allow custom print of the class.
extension OperationState: CustomStringConvertible {
    public var description: String {
        return "Operation Name: \(name)\nOperation Description: \(progress)\nOperation Dependencies: \(dependencies)"
    }
}
