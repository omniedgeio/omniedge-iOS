# Tattoo

## What is Tattoo
Tattoo is a lightweight runtime dependency injection library written for Swift, it allows you to separate the abstractions and implementations in order to follow the Inversion of Control principle of Clean Architecture.

## Features
- Singleton
- Factory
- Quanifier
- Scope

## Example
### Declare
You can simplify register your services by using the `singleton` or `factory` method.
```
class AuthDataStoreImpl: AuthDataStore {
}

factory(AuthDataStore.self, mainScope) { (scope) -> AnyObject in
    return AuthDataStoreImpl()
}
```
### Inject class with constructor
The LoginViewModel requires an instance of AuthDataStore.
```
class LoginViewModel: ObservableObject {

    private let dataStore: AuthDataStore
    
    init(dataStore: AuthDataStore) {
        self.dataStore = dataStore
    }
}
```
Instances will be resolved in the factory closure.
```
factory(LoginViewModel.self, mainScope) { (scope) -> AnyObject in
    return LoginViewModel(dataStore: get(AuthDataStore.self, scope))
}
```
### Inject
We only allow one way to inject the instances, below code directly retrieves the instance immediately.
```
public struct LoginView: View {
    private let viewModel: LoginViewModel = get(LoginViewModel.self)
}
```
## Scope
Scope restricts a set of objects to only exist for a specific purpose and time, by default, all the scope will fallback to mainScope in order to retrieve the instance.
### Decalre a scope
```
let loginABTestScope = Scope()
```
### Usage
```
factory(AuthDataStore.self, mainScope) { (scope) -> AnyObject in
    return AuthDataStoreImpl()
}

factory(AuthDataStore.self, loginABTestScope) { (scope) -> AnyObject in
    return ABTestAuthDataStoreImpl()
}
```
Then in your class you could find different instance by using:
```
let viewModel: LoginViewModel

if isEnableABTest {
    viewModel = get(LoginViewModel.self, loginABTestScope)
} else {
    viewModel = get(LoginViewModel.self, mainScope)
}
```

