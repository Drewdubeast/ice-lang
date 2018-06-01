//
//  Nodes.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/6/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

struct PrototypeNode: CustomStringConvertible {
    let name: String
    let args: [String]
    var description: String {
        return "FunctionPrototypeNode(\(name) args: \(args))"
    }
}

struct AssignmentNode: CustomStringConvertible {
    let variable: expr
    let value: expr
    
    var description: String {
        return "AssignmentNode(variable: \(variable) value: \(value))"
    }
}

struct FunctionNode: CustomStringConvertible{
    let body: expr
    let prototype: PrototypeNode
    
    var description: String {
        return "FunctionNode(prototype: \(prototype)) body: \(body))"
    }
}

//enums for AST
indirect enum expr {
    case number(Double)
    case identifier(String)
    case call(String,[expr])
    case binOp(expr, BinaryOperator, expr)
    case ifelse(expr, expr, expr)
    case variable(String)
    case assignment(String, expr)
}


