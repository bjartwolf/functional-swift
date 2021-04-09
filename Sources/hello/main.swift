print("Hello, World!") 

// https://www.vadimbulavin.com/pure-functions-higher-order-functions-and-first-class-functions-in-swift/
func add(_ x: Int) -> (_ y: Int) -> Int {
    { y in return x + y }
}

let addTwo = add(2)

print(addTwo(3))
print(addTwo(5))
