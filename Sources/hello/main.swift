print("Hello, World!") 

// https://www.vadimbulavin.com/pure-functions-higher-order-functions-and-first-class-functions-in-swift/
func add(_ x: Int) -> (_ y: Int) -> Int {
    { y in return x + y }
}

let addTwo = add(2)

print(addTwo(3))
print(addTwo(5))


// https://github.com/nrkno/fsharpskolen/blob/master/ddd-fsharp/functional/apply.fsx#L32
// This is option.pure but I do not know how to make an option module in swift yet 
func pure<T>(_ x: T) -> Optional<T> {
    x
}

func id<T>(param: T) -> T {
    return param
}

let fortytwo = 42
let foo = pure(fortytwo)

print(fortytwo)
print(foo)


// Apply: E<(a->b)> -> E<a> -> E<b>
// In the option case here
// (a->b) option -> a option -> b option
// The apply function for Options
// https://github.com/nrkno/fsharpskolen/blob/master/ddd-fsharp/functional/apply.fsx#L48
func apply<A,B>(fOpt: ((A) -> (B))?) -> (_ xOpt: A?) -> (B?) 
{
    { xOpt in
        switch (fOpt, xOpt) {
            case (.some(let f), .some(let x)):
                return f(x) 
            case (_,_):
                return .none
    }
}
