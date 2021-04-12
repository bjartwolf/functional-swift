
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
//print(aFive)

// So we can use it with an optional number with a value
let result = maybeTwoerAdder(aFive)
//print(result)

// And it works for for the .none types too 
let result2 = maybeTwoerAdder(Int("Five"))
//print(result2)

// We can now use the same function on lists by lifting it to lists
let listAdder = ListMap(addTwo)

//print(listAdder([1,2,3]))


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

// So we can instead make a simple function that does it (a world crossing one)
func parseNumber (_ nr: String) -> Optional<Int> {
    return Int(nr)
}

// and just lift the function to work on lists
let parseNumbers2 = ListMap(parseNumber)

let someNumbers = ["2", "To", "-4", "Fire"]
// These are the same, but List.map takes care of making the parseNumber 
print(parseNumbers(someNumbers))
print(parseNumbers2(someNumbers))

// We also made a function that we lifted from summing numbers to summing optional numbers. We can lift that one to work on lists as well
let maybeTwoerListerAdder = ListMap(maybeTwoerAdder) 
//print(maybeTwoerListerAdder(parseNumbers2(someNumbers)))

// for some more world crossing
func OrderQty (_ qty: Int) -> Optional<Int> {
    if qty >= 0 { return qty }
    else { return .none }
}


// if we try to map this we get optional optionals.
let mappedOrderQty = ListMap(OptMap(OrderQty))
//print(mappedOrderQty(parseNumbers2(someNumbers)))

// nested optionals sucks. me should bind those... (we can also bind them with id I think for later)
let boundOrderQty = ListMap(OptBind(OrderQty))
//print(boundOrderQty(parseNumbers2(someNumbers)))


// Found these here, works like a charm. Not sure if I should implement backwards pipe or not.
// https://medium.com/dev-genius/forward-pipe-or-pipe-forward-in-swift-3a6da6f9c000
precedencegroup ForwardPipe {
     associativity: left
}

infix operator |> : ForwardPipe

func |> <T, U>(value: T, function: ((T) -> U)) -> U {
     return function(value)
}

class Future<Value> {
    typealias Result = Swift.Result<Value, Error>

    fileprivate var result: Result? {
        // Observe whenever a result is assigned, and report it:
        didSet { result.map(report) }
    }
    private var callbacks = [(Result) -> Void]()

    func observe(using callback: @escaping (Result) -> Void) {
        // If a result has already been set, call the callback directly:
        if let result = result {
            return callback(result)
        }

        callbacks.append(callback)
    }

    private func report(result: Result) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }

    public static func fromValue<T>(_ value: T) -> Future<T>{
        let future = Future<T>()
        future.result = .success(value)
        return future
    }

    public static func fromError<T>(_ error: Error) -> Future<T>{
        let future = Future<T>()
        future.result = .failure(error)
        return future
    }
}

func FuturePure<T>(_ x: T) -> Future<T> {
    Future<T>.fromValue(x)
}

FuturePure(3)

class Promise<Value>: Future<Value> {
    init(value: Value? = nil) {
        super.init()

        // If the value was already known at the time the promise
        // was constructed, we can report it directly:
        result = value.map(Result.success)
    }

    func resolve(with value: Value) {
        result = .success(value)
    }

    func reject(with error: Error) {
        result = .failure(error)
    }
}

extension Future {
    func chained<T>(
        using closure: @escaping (Value) throws -> Future<T>
    ) -> Future<T> {
        // We'll start by constructing a "wrapper" promise that will be
        // returned from this method:
        let promise = Promise<T>()

        // Observe the current future:
        observe { result in
            switch result {
            case .success(let value):
                do {
                    // Attempt to construct a new future using the value
                    // returned from the first one:
                    let future = try closure(value)

                    // Observe the "nested" future, and once it
                    // completes, resolve/reject the "wrapper" future:
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }

        return promise
    }
}


func FutureApply<A,B>(_ fFut: (Future<(A) -> (B)>)) -> (Future<A>) -> (Future<B>)
{
    { (xFut: Future<A>) in
        let p = Promise<B>()
        fFut.observe { (result) in
            switch result {
            case .failure(let error):
                p.reject(with: error)
            case .success(let fRes):
                xFut.observe(using: { x in
                    switch x {
                    case .failure(let xerr):
                        p.reject(with: xerr)
                    case .success(let xval):
                        p.resolve(with: fRes(xval))                    }
                })
            }
        }
        return p
    }
}

func FutureMap<A,B>(_ fn: @escaping (A)->(B)) -> ((Future<A>) -> (Future<B>)) {
    FutureApply(FuturePure(fn))
}
// Promise er ern applicaktiv funktor

let p = Promise<Int>()
		

let futureAddTwo = FutureMap(addTwo)

let futureNumber = futureAddTwo(p)
p.resolve(with: 4)

print(futureNumber.result)
