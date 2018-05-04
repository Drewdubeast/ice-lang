//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

let lexer = Lexer(for: "x + y * 1 - 2")

let toks = lexer.lex()

if let tokens = toks {
    for token in tokens {
        print(token)
    }
}
