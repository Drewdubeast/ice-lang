//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

let lexer = Lexer(for: "def fib(x) x*x; print; x+x; printf(2);")

let toks = lexer.lex()

let parser = Parser(for: toks!)

do {
    print(try parser.parse())
} catch {
    print(error)
}
