# Apic
![Cocoapods](https://img.shields.io/cocoapods/v/Apic.svg)
![Platform](https://img.shields.io/cocoapods/p/Apic.svg)
![License](https://img.shields.io/cocoapods/l/Apic.svg)


Apic communicates with **RESTful services**, parses the **JSON** HTTP response and delivers objects.

## Installation
### CocoaPods
####  Swift < 2.3:
  pod 'Apic' '~> 2.2.4'
####  Swift 3.x :
   pod 'Apic' '~> 3.9.6'
#### Swift 4
  pod 'Apic' '~> 4.0.0'


## Repositories

The repository is a class that implements the logic to communicate with the services that provide the REST resources, basically a Repository has methods that correspond to endpoints in the backend, all repositories inherit from the generic class `AbstractRepository`, or `MultipartRepository`:

```swift
class GistsRepository: AbstractRepository {
    func requestGistsOfUser(_ user: String, completion: ([Gist]) -> Void) -> Request<[Gist]> {
        return requestArray(route: .get("https://api.github.com/users/\(user)/gists"), completion: completion)
    }
}
```
The only requirement is that `Gist` implements `Decodable`

This repository can now be used by a `ViewController` to request a user's gists.

```swift
class GistsController: UITableViewController {

	let gistsRepository = GistsRepository()
    var gists: [Gist]?
    var gistsRequest: Request<[Gist]>?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestGists()
    }

    func requestGists() {
        gistsRequest?.cancel()
        gistsRequest = gistsRepository.requestGistsOfUser("UserName", completion: { [weak self] gists in
            self?.gists = gists
        }).fail { [weak self] error in
            self?.handleError(error)
        }.finished { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
```

When the `GistsRepository` finishes calling the service and parsing the response it calls the completion closure that you provide sending you an array of `[Gist]` in this case.
