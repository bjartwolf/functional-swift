// https://www.vadimbulavin.com/pure-functions-higher-order-functions-and-first-class-functions-in-swift/
func add(_ x: Int) -> (_ y: Int) -> Int {
    { y in return x + y }
}


// https://github.com/nrkno/fsharpskolen/blob/master/ddd-fsharp/functional/apply.fsx#L32
// This is option.pure but I do not know how to make an option module in swift yet 
func OptPure<T>(_ x: T) -> Optional<T> {
    .some(x)
}

func id<T>(param: T) -> T {
    return param
}

let fortytwo = 42
let foo = OptPure(fortytwo)

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

let addTwo = add(2)
print(addTwo(5))

let aFive = Int("5") 
print(aFive)

let maybeTwoerAdder = OptMap(addTwo)
let result = maybeTwoerAdder(aFive)
print(result)

let result2 = maybeTwoerAdder(.none)
print(result2)

func ListPure<T>(_ x: T) -> [T] {
    [x]
}


func incrementValues(a: [Int]) -> [Int] { 
    return a.map { $0 + 1 } 
} 


//https://subscription.packtpub.com/book/application_development/9781787284500/6/ch06lvl1sec48/the-join-function
// This only does it for one list of fs, but I want apply as list of f and list of x
func ListApply<A,B>(_ fOpt: (Array<(A) -> (B)>)) -> (_ xOpt: Array<A>) -> (Array<B>) {
    { xOpt in
        fOpt.flatMap { 
            f in xOpt.map { x in f(x)}} 
    }
}

func ListMap<A,B>(_ fn: @escaping (A)->(B)) -> ((Array<A>) -> (Array<B>)) {
    ListApply(ListPure(fn))
}

let listAdder = ListMap(addTwo)

print(listAdder([1,2,3]))