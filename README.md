# Apic
![Cocoapods](https://img.shields.io/cocoapods/v/Apic.svg)
![Platform](https://img.shields.io/cocoapods/p/Apic.svg)
![License](https://img.shields.io/cocoapods/l/Apic.svg)


Apic communicates with **RESTful services**, parses the **JSON** HTTP response and delivers objects based on a model definition.

## Installation
### CocoaPods
####  Swift < 2.3:
  pod 'Apic' '~> 2.2.4'
####  Swift 3.x :
   pod 'Apic' '~> 3.9.6'

## Models

The model definition is part of the model class itself, if you declare a stored property, when a new object is initialized from a JSON dictionary, the model is going to search for a key with the same name of the variable in that dictionary and assign the value to the property, all your model classes have to inherit from `AbstractModel`:

```swift
class Gist: AbstractModel {
    var id: String = ""
    var url: URL!
    var created_at: Date!
    var comments: Int = 0
    var user: User?
}
```

New instances of a model class are created with the `init(dictionary: [String: Any]) throws` initializer,
in this case, when the object is initialized, the model searches for the keys id, url, created_at and user in the dictionary and assign the values to the properties.

Currently the model can parse values of type `String, [String], Int, [Int], Float, [Float], Double, [Double], Bool, [Bool], Date, NSDecimalNumber, URL, UIColor` the values of type `Int, Float, Double, Bool` are not recommended to be optional or implicitly unwrapped optional, instead you can declare them with a default value, the other types are ok to be optional or implicitly unwrapped optionals.

Properties can also be subclasses of `AbstractModel` as in the case of `user` above, `User` `User?`, `User!`, `[User]`, `[User]?`, `[User]!` are all valid types if you provide a `TypeResolver` for the model as described below.

#### Type Resolution

A type resolver can be any class that implements the `TypeResolver` protocol:

```swift
public protocol TypeResolver {
    func resolve(type: Any) -> Any?
    func resolve(typeForName typeName: String) -> Any?
}
```

when a model finds a property that could be a subclass of `AbstractModel` the model calls the `resolve(type:)` method of the type resolver, this method must return the type to use to initialize the property or nil if the type is not recognized as in the following case:

```swift
class DefaultResolver: TypeResolver {

    static var shared = DefaultResolver()

    func resolve(type: Any) -> Any? {
        if type is User?.Type || type is [User]?.Type {
            return User.self
        }
        return nil
    }
}
```

In this case, the protocol is implemented by the `DefaultResolver` class and can be used by the `Gist` model to initialize the user property.

```swift
class Gist: AbstractModel {
    // vars
    override class var resolver: TypeResolver? {
        return DefaultResolver.shared
    }
}
```

#### Should Fail With Invalid Value?

If the model cannot find a valid value for a property inside the JSON dictionary the model is going to call `shouldFail(withInvalidValue:forProperty:)`, this happens when the value in the dictionary is nil or cannot be converted to an appropriate type, when this method is called you have the opportunity to decide if the value is really invalid or ignore it if the value is nil and the property is optional for example.

```swift
class Gist: AbstractModel {
    // vars
    open override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["id", "url", "created_at"].contains(property)
    }
}
```

You usually return true for **ImplicitlyUnwrappedOptional** properties to avoid having **nil** values and false for **Optional** properties if it is ok to have **nil**

You can also return false if you have a default value or change the value and assign it to the property.

### Assign value

Values of some types cannot be automatically assigned to properties, this include enums, structs, Int?, Float?, Double? and Bool?, values of this types still can be created and assigned to properties, for this types you have to implement `assign(undefinedValue:forProperty:)` and make the assignment, for example:

```swift
enum Status: IntInitializable {
   case online, away, busy

   init?(rawValue: Int) {
     switch rawValue {
      case 0: self = .online
      case 1: self = .away
      case 2: self = .busy
      default: return nil
     }
   }
}

class User: AbstractModel {
  var status: Status!

  override open func assign(undefinedValue: Any, forProperty   property: String) throws {
   if property == "status" {
      status = undefinedValue as! Status
   } else {
     try super.assign(undefinedValue: value, forProperty: property)
   }
 }
}
```

### Other considerations

You can ignore certain properties if you override the class var `ignoredProperties`:
```swift
open class var ignoredProperties: [String] { return ["ignored"] }
```

You can also declare the date formats that the model is going to use to create dates:
```swift
open class var dateFormats: [String] { return Configuration.dateFormats + ["y/MM/dd HH:mm:ss Z"] }
```

## Repositories

The repository is a class that implements the logic to communicate with the services that provide the REST resources, basically a Repository has methods that correspond to endpoints in the backend, all repositories inherit from the generic class `AbstractRepository`:

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

When the `GistsRepository` finishes calling the service and parsing the response it calls the completion closure that you provide sending you a closure, `getGists` in this case, this closure returns an object or list of objects of the appropriate type, `[Gist]` in this case.
