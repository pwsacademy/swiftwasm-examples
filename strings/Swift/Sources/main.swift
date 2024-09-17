import Foundation

typealias StringDataReference = Int

@_extern(wasm, module: "runtime", name: "storeStringData")
@_extern(c)
func storeStringData(_ pointer: UnsafeRawPointer, _ count: Int) -> StringDataReference

@_extern(wasm, module: "runtime", name: "loadStringData")
@_extern(c)
func loadStringData(_ reference: StringDataReference, _ target: UnsafeMutableRawPointer)

@_expose(wasm, "getCurrentUser")
@_cdecl("getCurrentUser")
func getCurrentUser() -> StringDataReference {
    let user = User(id: 1, name: "Steven")
    let data = try! JSONEncoder().encode(user)
    return data.withUnsafeBytes { pointer in
        storeStringData(pointer.baseAddress!, data.count)
    }
}

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
