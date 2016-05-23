# Apic
![Cocoapods](https://img.shields.io/cocoapods/v/Apic.svg)
![Platform](https://img.shields.io/cocoapods/p/Apic.svg)
![License](https://img.shields.io/cocoapods/l/Apic.svg)


Apic communicates with **RESTful services**, parses the **JSON** HTTP response and delivers objects based on a model definition.

## The Model

Apic needs a model definition to convert JSON to objects, the models need to inherit from `AbstractModel`:

```swift
class Gist: AbstractModel {
    var id: String!
    var url: NSURL!
    var `public`: Bool = true
    var created_at: NSDate!
    var comments: Int = 0
    var user: User?
}
```

Apic uses the **class variables** to find the keys inside the JSON response and create an object.

Currently the model can parse values of type `String, [String], Int, [Int], Float, [Float], Double, [Double], Bool, [Bool], NSDate, NSDecimalNumber, NSURL, UIColor` the values of type `Int, Float, Double, Bool` are not recommended to be optional or implicitly unwrapped optional, instead you can declare them with a default value, the other types are ok to be optional or implicitly unwrapped optionals.

Properties can also be subclasses of `AbstractModel` as in the case of `user` above, `User` `User?`, `User!`, `[User]`, `[User]?`, `[User]!` are all valid types if you provide a `TypeResolver` for the model as described below.

#### TypeResolver

For some types that inherit from `AbstractModel`, as in the case of `User?` above, it is not possible to determine the model to use to initialise the object, the **Reflection** limitations of the language do not permit to know that the type `User` should be used to initialise the model from a type declared as `Optional<User>` in this case, For this cases a `TypeResolver` most be implemented.

A type resolver can be any class that implements the `TypeResolver` protocol, when a model finds a property that could be a subclass of `AbstractModel` the model calls the `resolveType:` method of the type resolver, this method must return the type to use to initialise the property or nil if the type is not recognised as in the following case:

```swift
class DefaultResolver: TypeResolver {
    
    static var sharedResolver = DefaultResolver()
    
    func resolveType(type: Any) -> Any? {
        if type is User?.Type || type is [User]?.Type { 
            return User.self 
        }
        return nil
    }
}
```

In this case, the protocol is implemented by the `DefaultResolver` class and can be used by the `Gist` model to initialise the user property.

```swift
class Gist: AbstractModel {
    // vars
    override class var resolver: TypeResolver? { 
        return DefaultResolver.sharedResolver
    }
}
```

#### Should Fail With Invalid Value?

If the model cannot find a valid value for a property inside the JSON the model is going to call `shouldFailWithInvalidValue:forProperty:` 
if that property is not permitted to have a nil value you should return true  

```swift
class Gist: AbstractModel {
    // vars
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["id", "url", "public", "created_at", "comments"].contains(property)
    }
}
```

You usually return true for **ImplicitlyUnwrappedOptional** properties to avoid having **nil** values and false for **Optional** properties if it is ok to have **nil**

You can also return false if you have a default value or change the value and assign it to the property.

## The Repository

The repository is an object that implements the logic to communicates with the services that provide the REST resources, basically a Repository has methods that correspond to endpoints in the backend, all repositories inherit from the generic class `AbstractRepository`:

```swift
class GistsRepository: AbstractRepository<String> {    
    func requestGistsOfUser(user: String, completion: (getGists: () throws -> [Gist]) -> Void) -> Request<[Gist]>? {
        return requestObjects(.GET, url: "https://api.github.com/users/\(user)/gists", completion: completion)
    }
}
```

This repository can now be used by a `ViewController` to request a user's gists.

```swift
class GistsController: UITableViewController {

	let gistsRepository = GistsRepository()
    var gists: [Gist]?
    var gistsRequest: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestGists()
    }
    
    func requestGists() {
        gistsRequest?.cancel()
    	gistsRequest = gistsRepository.requestGistsOfUser("UserName", completion: { [weak self] (getGists) -> Void in
    	    do {
    	    	self?.gists = try getGists()
    	    	self?.tableView.reloadData()
    	    }
    	    catch {
    	    	self?.handleError(error)
    	    }
    	})
    }
}
```

When the `GistsRepository` finishes calling the service and parsing the response it calls the completion closure that you provide sending you a closure, `getGists` in this case, this closure returns an object or list of objects of the appropiate type, `[Gist]` in this case. 