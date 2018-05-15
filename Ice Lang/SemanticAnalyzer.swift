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

class SemanticAnalyzer {
    //
    // Purpose of this class is to go through the file and make sure nothing is called/used
    // without being defined.
    //
    // Should catch:
    // -calling a variable or function that hasn't been defined should be caught here
    // -incorrect amount of arguments
    //
    let file: File
    
    init(with file: File) {
        self.file = file
    }
    
    
}
