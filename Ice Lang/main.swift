//
//  main.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

let lex = Lexer(for: "5.132l ( ) int main def if 5 myInt () \n")

let toks = lex.tokens

if let tokens = toks {
    for token in tokens {
        print(token)
    }
}
