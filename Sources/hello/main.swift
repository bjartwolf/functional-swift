
// https://github.com/nrkno/fsharpskolen/blob/master/ddd-fsharp/functional/apply.fsx#L32
// This is option.pure but I do not know how to make an option module in swift yet 
func OptPure<T>(_ x: T) -> Optional<T> {
    .some(x)
}

func id<T>(param: T) -> T {
    return param
}

// Apply: E<(a->b)> -> E<a> -> E<b>
// In the option case here
// (a->b) option -> a option -> b option
// The apply function for Options
// https://github.com/nrkno/fsharpskolen/blob/master/ddd-fsharp/functional/apply.fsx#L48
//func apply<A,B>(_ fOpt: ((A) -> (B))?) -> (_ xOpt: A?) -> (B?) 
func OptApply<A,B>(_ fOpt: (Optional<(A) -> (B)>)) -> (_ xOpt: Optional<A>) -> (Optional<B>) 
{
    { xOpt in
        switch (fOpt, xOpt) {
            case (.some(let f), .some(let x)):
                //return .some(f(x)) // looks like i can just do f(x) and the compiler does stuff
                return f(x) // looks like i can just do f(x) and the compiler does stuff
            case (_,_):
                return .none
        }
    }
}

// OPtion map a->b og lager en E<A> til E<A> til E<B>
func OptMap<A,B>(_ fn: @escaping (A)->(B)) -> ((Optional<A>) -> (Optional<B>)) {
    OptApply(OptPure(fn))
}

func ListPure<T>(_ x: T) -> [T] {
    [x]
}


func incrementValues(a: [Int]) -> [Int] { 
    return a.map { $0 + 1 } 
} 


//https://subscription.packtpub.com/book/application_development/9781787284500/6/ch06lvl1sec48/the-join-function
// This only does it for one list of fs, but I want apply as list of f and list of x so I used flatmap and some stuff
// because it did not have any generators I could understand...
func ListApply<A,B>(_ fOpt: (Array<(A) -> (B)>)) -> (_ xOpt: Array<A>) -> (Array<B>) {
    { xOpt in
        fOpt.flatMap { 
            f in xOpt.map { x in f(x)}} 
    }
}

func ListMap<A,B>(_ fn: @escaping (A)->(B)) -> ((Array<A>) -> (Array<B>)) {
    ListApply(ListPure(fn))
}

// https://www.vadimbulavin.com/pure-functions-higher-order-functions-and-first-class-functions-in-swift/
func add(_ x: Int) -> (_ y: Int) -> Int {
    { y in return x + y }
}

// Make a function that can add 2 to anything
let addTwo = add(2)
// For example we can add two to 
print(addTwo(5))

// We can lift this into option land using optmap, so now
// it works on optional numbers instead of regular numbers
let maybeTwoerAdder = OptMap(addTwo)

let aFive = Int("5") 
print(aFive)

// So we can use it with an optional number with a value
let result = maybeTwoerAdder(aFive)
print(result)

// And it works for for the .none types too 
let result2 = maybeTwoerAdder(Int("Five"))
print(result2)

// We can now use the same function on lists by lifting it to lists
let listAdder = ListMap(addTwo)

print(listAdder([1,2,3]))