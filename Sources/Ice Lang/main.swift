//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation
import LLVM

let lexer = Lexer(for: "def fib(x,n,y) x+n+2+4+y; fib(1,2,3);")

let toks = lexer.lex()

let parser = Parser(for: toks!)

do {
    let file = try parser.parse()
    print(file)
    print()
    let analyzer = SemanticAnalyzer(with: file)
    try analyzer.analyze()
} catch {
    print(error)
}
