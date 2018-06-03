# Ice Lang

Welcome to Ice Lang, a simple, simple, simple (x100000) little toy language/compiler, written in Swift.

## Overview ##

This little toy language/compiler is for my toy language "ice". I chose the name *because it sounded cool*. So far, it is heavily based on the **Kaleidoscope** toy language in the LLVM tutorials. It currently supports basic one-expression functions and function calls with basic math. It also supports `extern` functions, which are the use of C standard library functions without writing them in Ice. Basic conditionals are supported, along with global variables. 

**How it works**: All parts are written in Swift - the lexing, parsing, semantic analysis, and LLVM IR generation. The IR generation is done through **LLVMSwift**, a Swift wrapper for the LLVM C API, written by Harlan Haskins and Robert Widmann: https://github.com/llvm-swift/LLVMSwift

Here is a sample *ice* program:

```
extern sqrt(arg); //external C library function

var myVar = 12;
var myVar2 = 23;

block addTwo(a,b) 
  a + b;
block subTwo(a,b) 
  a - b;
block compareTwo(a,b) 
  a=b;
block allOperations(a,b,c,d,e,f) 
  a+b-c*d/e%f;
block conditional(a,b)
  if(a=b)
    a+b
  else
    a-b;


addTwo(myVar,myVar2); //returns 100;

subTwo(myVar,myVar2); //returns -11;

compareTwo(myVar,myVar2); //returns 0, they aren't equal

compareTwo(2,2); //returns 1, they are equal

allOperations(1,2,3,4,5,6); //returns 0.6

conditional(1,2); //returns -1

sqrt(16); //returns 4

```

## Language Features ##

The Ice language so far supports basic features in a bare-bones sense.
* Conditionals
* Comparisons
* Precedence-correct math
* External C library functions, such as `sqrt()`
* Basic functions

### Functions ###
A function in Ice is defined as an Ice `block`. They are structured like so:
```
block [name](args)
  [expression];
```

For example,
```
block addTwo(a, b)
  a + b;
```

Then, you can call the function like so:
```
addTwo(10,20); //returns 30
```


### Externs ###
To declare an extern in Ice, all you need to do is declare it by name in the file some place:
`extern sin(arg)`, then it is callable, like `sin(20);`

### Conditionals ###
Conditionals in Ice are very bare. They are structured like so:
```
if(value)
  [expression]
else
  [expression];
```

For example:
```
if(n=1)
  n+2;
else
  n+3;
```

### Variables ###
Currently, in Ice, only global variables are supported. These are declared like so:
```
var [name] = [expression]
```

for example:
```
var myVar = 10;
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
