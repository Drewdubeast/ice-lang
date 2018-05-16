//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

let lexer = Lexer(for: "n=5; n+n;")

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
