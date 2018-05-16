//
//  SemanticAnalyzer.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/15/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation
//import LLVM

enum SemanticError: Error {
    case UndefinedFunction(String)
    case UndefinedVariable(String)
    case IncorrectArgumentCount
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
    
    // STEPS:
    // Do a walk over the AST and get variable names and function names
    // Do another walk through and make sure that any calls to the variable have values
    
    
    // Extra notes:
    // Any thing defined at the scope of the file level would just be at the top level - so do a first
    // walk through that just goes through the top level
    // Anything that is used deeper in a tree must have it declared before referenced in a function or anything
    //
    // Try parsing top level expressions first to get any declarations, and then parse deeper.
    
    var symbols: [String : Int]
    
    let file: File
    
    init(with file: File) {
        self.file = file
        symbols = [String : Int]()
    }
    func analyze() throws {
        for expr in file.expressions {
            if case let .binOp(lhs, op, rhs) = expr {
            }
        }
    }
}
