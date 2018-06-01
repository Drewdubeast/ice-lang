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
    
    //Analyzing
    let analyzer = SemanticAnalyzer(with: file)
    try analyzer.analyze()
    
    //Generating
    let IRGen = IRGenerator(with: file)
    try IRGen.emit()
    
    //Output Object File
    try targetMachine.emitToFile(module: IRGen.module, type: CodegenFileType.object, path: "./ice.o")
    
    //Assemble - call clang on it
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["clang", "-o", "\(CommandLine.arguments[1]).out", "ice.o"]
    task.launch()
    
    //Verify the LLVM Code
    try IRGen.module.verify()
    
} catch {
    print(error)
}
