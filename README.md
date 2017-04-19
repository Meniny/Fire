
## Requirements

* iOS 7.0+
* Xcode 8 with Swift 3 [v2.x]

## Installation

#### CocoaPods

```ruby
pod 'Fire'
```

## Basic Usage Sample

```swift
import UIKit
import Fire

class ViewController: UIViewController {

    let BASEURL = "http://yourdomain.com/"
    let GETURL = "http://yourdomain.com/get.php"
    let POSTURL = "http://yourdomain.com/post.php"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func get() {
        Fire.build(HTTPMethod: .GET, url: GETURL)
            .addParams(["l": "zh"])
            .onNetworkError { (error) in
                print(error)
            }
            .responseJSON { (json, resp) in
                print(json.RAWValue)
        }
    }

    func post() {
        Fire.build(HTTPMethod: .POST, url: POSTURL, params: ["l": "zh"], timeout: 0)
            .onNetworkError { (error) in
                print(error)
            }
            .responseJSON { (json, resp) in
                print(json.RAWValue)
        }
    }

    func header() {
        Fire.build(HTTPMethod: .GET, url: GETURL)
            .setHTTPHeaders(["Agent": "Chrome"])
            .addParams(["l": "zh"])
            .onNetworkError { (error) in
                print(error)
            }
            .responseJSON { (json, resp) in
                print(json.RAWValue)
        }
    }

    func simple() {
        Fire.get(GETURL, params: ["l": "zh"], timeout: 0, callback: { (json, resp) in
            print(json.RAWValue)
        }) { (error) in
            print(error)
        }
    }

    func fireAPI() {
        FireAPI.baseURL = BASEURL
        let api = FireAPI(appending: "get.php", HTTPMethod: .GET, successCode: .success)
        Fire.requestAPI(api, params: [:], timeout: 0, callback: { (json, resp) in
            if resp != nil && resp?.statusCode == api.successCode.rawValue {
                print(json.RAWValue)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
```
