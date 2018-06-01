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
    case DuplicateArgument(String)
    case DuplicateVariable(String)
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
                
                //make sure symbol isn't in symbol table already - if it is, then it must be a duplicate
                guard (symbols[name]![arg] == nil) else {
                    throw SemanticError.DuplicateArgument(arg)
                }
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
            
        case .call(let function, let args):
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
        case .ifelse(let cond, let ifBody, let elseBody):
            try parseExprForSymbols(cond, function)
            try parseExprForSymbols(ifBody, function)
            try parseExprForSymbols(elseBody, function)
            break
        case .variable(let name):
            //parse variable, check if name is in symbol table
            guard symbols[function] != nil else {
                throw SemanticError.UndefinedFunction(function)
            }
            if (symbols[function]![name] == nil) {
                //try main function
                guard symbols["main"]![name] != nil else {
                    throw SemanticError.UndefinedVariable(name)
                }
            }
        case .assignment(let name, let assignment):
            //try parsing the assignment
            try parseExprForSymbols(assignment, function)
            
            //check variable that it is being stored in if it exists
            if(symbols[function]?[name] != nil) {
                throw SemanticError.DuplicateVariable(name)
            }
            
            //add to symbol table
            symbols[function]?[name] = 1
            break
        default:
            return
        }
    }
}
