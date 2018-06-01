//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation
import LLVM

extension String: Error {}

do {
    guard CommandLine.arguments.count > 1 else {
        throw "Usage: ice <file>"
    }
    
    //Target Machine for Object Code
    let targetMachine: TargetMachine
    targetMachine = try TargetMachine()
    
    //Get contents of file
    let input = try String(contentsOfFile: CommandLine.arguments[1])
    
    //Lexing
    let lexer = Lexer(for: input)
    let toks = lexer.lex()

    //Parsing
    let parser = Parser(for: toks!)
    let file = try parser.parse()
    print(file)
    /*
    //Analyzing
    let analyzer = SemanticAnalyzer(with: file)
    try analyzer.analyze()
    
    //Generating
    let IRGen = IRGenerator(with: file)
    try IRGen.emit()
    
    //Output Object File
    try targetMachine.emitToFile(module: IRGen.module, type: CodegenFileType.object, path: "./\(CommandLine.arguments[1]).o")
    
    //Assemble - call clang on it
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["clang", "-o", "\(CommandLine.arguments[1]).out", "\(CommandLine.arguments[1]).o"]
    task.launch()
    
    //Verify the LLVM Code
    //IRGen.module.dump()
    try IRGen.module.verify()*/
    
} catch {
    print(error)
}
/*
 Planning for having multiple
 expression functions and conditionals
 
 Currently, only single expression bodies are supported.
 
 Thoughts:
 1. have an array of expressions
 2. enclose the bodies inside {} characters or something else creative
 3. Parse expressions within the functions etc
 
 For main body expressions, if I want to implement variables and assignments eventually:
 1. Change equals to assignment operator
 2. Change comparison to double '=' operator
 3. Use index in file.expressions to make sure that something is declared and assigned before it is used or referenced: IE, only put it in the symbol table if it is assigned a value.
 4. could use keyword 'var' to declare a variable
 */
