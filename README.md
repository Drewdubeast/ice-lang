# Ice Lang

Welcome to Ice Lang, a simple, simple, simple (x100000) little toy language/compiler, written in Swift.

## Overview ##

This little toy language/compiler is for my toy language "ice". I chose the name *because it sounded cool*. So far, it is heavily based on the **Kaleidoscope** toy language in the LLVM tutorials. It currently supports basic one-expression functions and function calls with basic math. 

**How it works**: All parts are written in Swift - the lexing, parsing, semantic analysis, and LLVM IR generation. The IR generation is done through **LLVMSwift**, a Swift wrapper for the LLVM C API, written by Harlan Haskins and Robert Widmann: https://github.com/llvm-swift/LLVMSwift

Here is a sample *ice* program:

```
def addTwo(a,b) a + b;
def subTwo(a,b) a - b;
def compareTwo(a,b) a=b;
def allOperations(a,b,c,d,e,f) a+b-c*d/e%f;

addTwo(1,2); //returns 3;
subTwo(2,1); //returns 1
compareTwo(2,1); //returns 0, they aren't equal
compareTwo(2,2); //returns 1, they are equal
allOperations(1,2,3,4,5,6); //returns 0.6
```

## Future ##

I would really love to add more features to this language and change up the syntax a bit to really make it my own. Things I plan on doing in the future are:

* Multi-expression function calls
* Adding external C function calls and capability i.e. `printf`.
* If/else/conditions
* Other datatypes, currently it only supports double

## Acknowledgements ##

A few sources I used to help get this rolling:

* Harlan Haskins (@harlanhaskins) - he had several blog posts on the subject that helped immensely, and he released LLVMSwift, which is a Swift wrapper to the LLVM C API.
* LLVM Tutorials for Kaleidoscope - gave a basic walkthrough of lexing, parsing, and more

## Authors ## 

Drew Wilken (@drewdubeast)
