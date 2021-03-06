//
//  File.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/14/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

public class File: CustomStringConvertible {
    
    private(set) var externs = [PrototypeNode]()
    private(set) var prototypes = [String: PrototypeNode]()
    private(set) var definitions = [FunctionNode]()
    private(set) var expressions = [expr]()
    
    func prototype(_ name: String) -> PrototypeNode? {
        return prototypes[name]
    }
    
    func addExtern(_ proto: PrototypeNode) {
        externs.append(proto)
        prototypes[proto.name] = proto
    }

    func addDefinition(_ functionNode: FunctionNode) {
        definitions.append(functionNode)
        prototypes[functionNode.prototype.name] = functionNode.prototype
    }
    
    func addExpression(_ expr: expr) {
        expressions.append(expr)
    }
    
    public var description: String {
        return "Prototypes: \(prototypes), Definitions: \(definitions), Expressions: \(expressions)"
    }
}
