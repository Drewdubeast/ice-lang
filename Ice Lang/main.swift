//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

let lexer = Lexer(for: "def hello(x) 1+2")

let toks = lexer.lex()

let parser = Parser(for: toks!)

do {
    try parser.parse()
} catch {
    print(error)
}
