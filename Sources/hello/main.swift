print("Hello, World!") 

// https://www.vadimbulavin.com/pure-functions-higher-order-functions-and-first-class-functions-in-swift/
func add(_ x: Int) -> (_ y: Int) -> Int {
    { y in return x + y }
}

// https://github.com/nrkno/fsharpskolen/blob/master/ddd-fsharp/functional/apply.fsx#L32
// This is option.pure but I do not know how to make an option module in swift yet 

func pure<T>(_ x: T) -> Optional<T> {
    x
}

let fortytwo = 42
let foo = pure(fortytwo)

print(fortytwo)
print(foo)

let addTwo = add(2)

print(addTwo(3))
print(addTwo(5))
