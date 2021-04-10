
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
func ListApply<A,B>(_ f: (Array<(A) -> (B)>)) -> (_ x: Array<A>) -> (Array<B>) {
    { x in
        f.flatMap { 
            f in x.map { x in f(x)}} 
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


// Have not tested them, the signature looks ok but need to figure out if they work
func OptBind<A,B>(_ fOpt: @escaping ((A) -> Optional<(B)>)) -> (_ xOpt: Optional<A>) -> (Optional<B>) 
{
    { xOpt in
        switch xOpt {
            case .some(let x):
                return fOpt(x) 
            case .none:
                return .none
        }
    }
}

func ListBind<A,B>(_ f: @escaping ((A) -> Array<(B)>)) -> (_ xs: Array<A>) -> (Array<B>) {
    { xs in
        xs.flatMap { x in f(x) }
    }
}

// We do not need to do this stuff anymore, because we have higher order
// functions that can do it for us
func parseNumbers (_ s: Array<String>) -> [Optional<Int>] {
    return s.compactMap{ Int($0)} 
}

// So we can instead make a simple function that does it
func parseNumber (_ nr: String) -> Optional<Int> {
    return Int(nr)
}

// and just lift the function to work on lists
let parseNumbers2 = ListMap(parseNumber)

let someNumbers = ["2", "To", "4", "Fire"]
// These are the same, but List.map takes care of making the parseNumber 
print(parseNumbers(someNumbers))
print(parseNumbers2(someNumbers))

// We also made a function that we lifted from summing numbers to summing optional numbers. We can lift that one to work on lists as well
let maybeTwoerListerAdder = ListMap(maybeTwoerAdder) 
print(maybeTwoerListerAdder(parseNumbers2(someNumbers)))