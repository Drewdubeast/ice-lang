//
//  SemanticAnalyzer.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/15/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

enum SemanticError: Error {
    case UndefinedFunction(String)
    case UndefinedVariable(String)
    case IncorrectArgumentCount
}

enum Scope {
    case main
    case function(String)
}

class SemanticAnalyzer {
    //
    // Purpose of this class is to go through the file and make sure nothing is called/used
    // without being defined.
    //
    // Should catch:
    // -calling a variable or function that hasn't been defined should be caught here
    // -incorrect amount of arguments
    //
    
    //
    // Steps:
    // 1. Grab each function and prototype and record number of arguments and symbols used
    // 2. If any of the function calls have incorrect function name or arg count, throw error
    // 3. Go through function bodies - if there are incorrect variables used there, throw error
    
    //
    // TODO: Add file level expression support
    //
    
    var symbols: [String : [String : Int]] //function name and args associated with it
    
    let file: File
    
    init(with file: File) {
        self.file = file
        symbols = [String : [String : Int]]()
        symbols["main"] = [String : Int]()
    }
    func analyze() throws {
        // Steps:
        // 1. Go through file level function declarations and get their arguments
        // 2. Use these args and add them to a symbol table
        
        //first get symbols from function arguments
        for prototype in file.prototypes {
            //add function names
            let name = prototype.value.name
            symbols[name] = [String : Int]()
            //add function args
            for arg in prototype.value.args {
                symbols[name]![arg] = 1
            }
        }
        
        //check function bodies to ensure only argument variables used
        for function in file.definitions {
            let functionName = function.prototype.name
            let body = function.body
            
            try parseExprForSymbols(body, functionName)
        }
        
        //check expressions for calls with
        for expression in file.expressions {
            try parseExprForSymbols(expression, "main")
        }
    }
    
    func parseExprForSymbols(_ expr: expr, _ function: String) throws {
        switch(expr) {
        case .binOp:
            guard case let .binOp(expr1, _, expr2) = expr else {
                return
            }
            //parse binary operator for expr 1 and expr 2
            try parseExprForSymbols(expr1, function)
            try parseExprForSymbols(expr2, function)
            
        case .call:
            guard case let .call(function, args) = expr else {
                return
            }
            guard (symbols[function] != nil) else {
                throw SemanticError.UndefinedFunction(function)
            }
            var count = 0
            for arg in args {
                try parseExprForSymbols(arg, function)
                count += 1
            }
            if count != symbols[function]!.count {
                throw SemanticError.IncorrectArgumentCount
            }
            break
        case .variable:
            //parse variable, check if name is in symbol table
            guard case let .variable(name) = expr else {
                return
            }
            guard symbols[function] != nil else {
                throw SemanticError.UndefinedFunction(function)
            }
            guard (symbols[function]![name] != nil) else {
                throw SemanticError.UndefinedVariable(name)
            }
        default:
            return
        }
    }
}
