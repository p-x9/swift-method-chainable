# ModifierGen
Generates chainable method code from Swift methods.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/swift-method-chainable)](https://github.com/p-x9/swift-method-chainable/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/swift-method-chainable)](https://github.com/p-x9/swift-method-chainable/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/swift-method-chainable)](https://github.com/p-x9/swift-method-chainable/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/swift-method-chainable)](https://github.com/p-x9/swift-method-chainable/)

![image](https://github.com/p-x9/swift-method-chainable/assets/50244599/c5677286-fea1-4db5-b822-8de03b1371e1)
## Usage
You can download it from [Release](https://github.com/p-x9/swift-method-chainable/releases)

```sh
USAGE: swchaingen --input-dir <input-dir> --output-dir <output-dir> [--overwrite]

OPTIONS:
  --input-dir <input-dir> input dir path
  --output-dir <output-dir>
                          output dir path for generated files
  --overwrite             overwrite files
  -h, --help              Show help information.
```

## Example
If you have a code like the following,
```swift
struct Item {
    struct SubItem {
        var name: String
        var description: String

        public mutating func update(name: String) {
            self.name = name
        }
    }

    var name: String
    var description: String
    var subItems: [SubItem]

    mutating func update(name: String) {
        self.name = name
    }

    mutating func update(description: String) {
        self.description = description
    }
}
```
This tool is capable of generating the following code

```swift
extension Item {
    @_disfavoredOverload
    func update(name: String) -> Self {
        var new = self
        new.update(name: name)
        return new
    }

    @_disfavoredOverload
    func update(description: String) -> Self {
        var new = self
        new.update(description: description)
        return new
    }
}

extension Item.SubItem {
    @_disfavoredOverload
    public
    func update(name: String) -> Self {
        var new = self
        new.update(name: name)
        return new
    }
}
```

Then you can connect and call the methods as follows
```swift
let item = Item(name: "Hello", description: "hello", subItems: [])
        .update(name: "こんにちは")
        .update(description: "こんにちは")
```

## License
flipper-plugin-control-ui is released under the MIT License. See [LICENSE](./LICENSE)
