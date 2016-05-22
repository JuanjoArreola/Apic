# Apic

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
