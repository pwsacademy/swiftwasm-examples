# Strings and Codables

This example shows how you can pass Strings between Swift and JavaScript. This requires a workaround which relies on the shared memory exposed by a WebAssembly module. This workaround is required when using WASI Preview 1 and can also be applied to any Codable instance by converting it to JSON.

In this example, an instance of the Codable type `User` is passed between Swift and JavaScript, in both directions.

## Swift to JavaScript

To export a `User` from Swift to JavaScript, we first encode it to JSON:

```swift
let user = User(id: 1, name: "Steven")
let data = try! JSONEncoder().encode(user)
```

Next, we use `withUnsafeBytes` to access the underlying bytes:

```swift
return data.withUnsafeBytes { pointer in
    // ...
}
```

This `pointer` is only valid for the duration of the call to `withUnsafeBytes`, so we cannot return it from the closure. Instead, we call an imported JavaScript function to temporarily store the data, so it can be retrieved after `withUnsafeBytes` returns:

```swift
return data.withUnsafeBytes { pointer in
    storeStringData(pointer.baseAddress!, data.count)
}
```

`storeStringData` is implemented as follows:

```js
storeStringData: (pointer, count) => {
    const memory = new Uint8Array(instance.exports.memory.buffer);
    const data = memory.slice(pointer, pointer + count);
    return heap.store(data);
}
```

This function gets the bytes at `pointer` from the shared memory and stores them in a heap. `heap.store` then returns a reference to the data, which can be used to retrieve it later. This reference is just an `Int`, typealiased as `StringDataReference` in Swift.

The following declaration imports `storeStringData` into Swift:

```swift
@_extern(wasm, module: "runtime", name: "storeStringData")
@_extern(c)
func storeStringData(_ pointer: UnsafeRawPointer, _ count: Int) -> StringDataReference
```

Finally, here's the complete function to get the current user from Swift:

```swift
@_expose(wasm, "getCurrentUser")
@_cdecl("getCurrentUser")
func getCurrentUser() -> StringDataReference {
    let user = User(id: 1, name: "Steven")
    let data = try! JSONEncoder().encode(user)
    return data.withUnsafeBytes { pointer in
        storeStringData(pointer.baseAddress!, data.count)
    }
}
```

And here's how it is called from JavaScript:

```js
const reference = instance.exports.getCurrentUser();
const data = heap.get(reference);
const string = new TextDecoder().decode(data);
const user = JSON.parse(string);
console.log(`Current user is ${user.name} with ID ${user.id}`);
```

## JavaScript to Swift

To export a `User` from JavaScript to Swift, we first encode it to JSON:

```js
const newUser = {
    id: 2,
    name: "Jennefer"
};
const newString = JSON.stringify(newUser);
const newData = new TextEncoder().encode(newString);
```

We then store this data in the heap:

```js
const newReference = heap.store(newData);
```

Finally, we call into Swift, passing a reference to the data, along with its size:

```js
instance.exports.addNewUser(newReference, newData.length);
```

In Swift, `addNewUser` is implemented as follows:

```swift
@_expose(wasm, "addNewUser")
@_cdecl("addNewUser")
func addNewUser(reference: StringDataReference, byteCount: Int) {
    var data = Data(count: byteCount)
    data.withUnsafeMutableBytes { pointer in
        loadStringData(reference, pointer.baseAddress!)
    }
    let user = try! JSONDecoder().decode(User.self, from: data)
    print("Added user \(user.name) with ID \(user.id)")
}
```

Here, we first allocate a data buffer of the correct size, and get a pointer to access its bytes:

```swift
var data = Data(count: byteCount)
data.withUnsafeMutableBytes { pointer in
    // ...
}
```

Again, this `pointer` is only valid for the duration of the call to `withUnsafeMutableBytes`, so we call back into JavaScript to load the data into the buffer:

```swift
data.withUnsafeMutableBytes { pointer in
    loadStringData(reference, pointer.baseAddress!)
}
```

`loadStringData` gets the data from the heap, then stores it in the shared memory:

```js
loadStringData: (reference, target) => {
    const memory = new Uint8Array(instance.exports.memory.buffer);
    const data = heap.get(reference);
    memory.set(data, target);
}
```

Finally, with the data loaded, we can now decode the `User`:

```swift
let user = try! JSONDecoder().decode(User.self, from: data)
print("Added user \(user.name) with ID \(user.id)")
```

## Conclusion

As you can see, passing Strings and Codables requires a bit of back-and-forth between both languages. Fortunately, WASI Preview 2 no longer requires this workaround thanks to the [Component Model](https://component-model.bytecodealliance.org), which brings support for higher-level types.
