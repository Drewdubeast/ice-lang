//
//  Nodes.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/6/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

protocol ASTNode {
}

protocol ExpressionNode: CustomStringConvertible, ASTNode {
}

struct NumberNode: ExpressionNode {
    let value: Double
    var description: String {
        return "NumberNode(\(value))"
    }
}

struct BinaryOperationNode: ExpressionNode {
    let lhs: ExpressionNode
    let rhs: ExpressionNode
    let op: BinaryOperator
    
    var description: String {
        return "BinaryOperationNode(\(op) lhs: \(lhs) rhs: \(rhs))"
    }
}

struct CallNode: ExpressionNode {
    let name: String
    let args: [ExpressionNode]
    
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

struct PrototypeNode: CustomStringConvertible, ASTNode {
    let name: String
    let args: [String]
    var description: String {
        return "FunctionPrototypeNode(\(name) args: \(args))"
    }
}

struct FunctionNode: CustomStringConvertible, ASTNode {
    let body: ExpressionNode
    let prototype: PrototypeNode
    
    var description: String {
        return "FunctionNode(prototype: \(prototype)) body: \(body)"
    }
}
