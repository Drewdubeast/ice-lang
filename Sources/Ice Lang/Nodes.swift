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

//TODO: create variable node and change variable expression to var reference, i.e. varRef
//This will allow for separation between expression and variables and will make it easier to parse and check for semantic correctness.
//Then, add a section to the File class where I can add variable assignments! Much easier to parse. Can emit easily in IRGen stage


