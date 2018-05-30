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
    
    let input = try String(contentsOfFile: CommandLine.arguments[1])
    let lexer = Lexer(for: input)
    let toks = lexer.lex()
    let parser = Parser(for: toks!)
    let file = try parser.parse()
    let analyzer = SemanticAnalyzer(with: file)
    try analyzer.analyze()
    //let IRGen = IRGenerator(with: file)
    //try IRGen.emit()
    //IRGen.module.dump()
    //try IRGen.module.verify()
    
} catch {
    print(error)
}
