//
//  Nodes.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/6/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

protocol ExpressionNode: CustomStringConvertible {
}

struct NumberNode: ExpressionNode {
    let value: Double
    var description: String {
        return "NumberNode(\(value))"
    }
}

struct IdentifierNode: ExpressionNode {
    let name: String
    var description: String {
        return "IdentifierNode(\(name))"
    }
}

struct BinaryOperationNode: ExpressionNode {
    let lhs: ExpressionNode
    let rhs: ExpressionNode
    let op: BinaryOperator
    
    var description: String {
        return "BinaryOperationNode(\(op) lhs: \(lhs) rhs: \(rhs)"
    }
}

struct CallNode: ExpressionNode {
    let name: String
    let args: [String]
    
    var description: String {
        return "CallNode(\(name) \(args))"
    }
}

struct VariableNode: ExpressionNode {
    let name: String
    
    var description: String {
        return "VariableNode(\(name))"
    }
}

struct PrototypeNode: CustomStringConvertible {
    let name: String
    let args: [String]
    var description: String {
        return "FunctionPrototypeNode(\(name))"
    }
}

struct FunctionNode: CustomStringConvertible {
    let body: ExpressionNode
    let prototype: PrototypeNode?
    
    var description: String {
        return "FunctionNode(prototype: \(prototype)) body: \(body)"
    }
}
