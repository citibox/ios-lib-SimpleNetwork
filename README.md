# SimpleNetwork

Una librería Swift ligera para realizar peticiones HTTP de forma sencilla. Soporta tanto async/await como callbacks, con manejo de headers, parámetros y respuestas tipadas.

## Requisitos

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Instalación

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/citibox/ios-lib-SimpleNetwork.git", from: "1.0.0")
]
```

## Uso básico

### Inicialización

```swift
import SimpleNetwork

// Con URL base
let network = SimpleNetworkManager(base: URL(string: "https://api.example.com")!)

// Sin URL base (usar URLs completas en cada request)
let network = SimpleNetworkManager()
```

### Petición GET con async/await

```swift
struct User: Decodable {
    let id: Int
    let name: String
}

let request = SNRequest(path: "/users/1")
let response: SNResponse<User> = await network.request(request)

switch response.result {
case .success(let user):
    print("Usuario: \(user?.name ?? "N/A")")
case .failure(let error):
    print("Error: \(error)")
}
```

### Petición GET con callback

```swift
network.request(request) { (response: SNResponse<User>) in
    switch response.result {
    case .success(let user):
        print("Usuario: \(user?.name ?? "N/A")")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Petición POST con parámetros

```swift
let request = SNRequest(
    path: "/users",
    method: .post,
    parameters: ["name": "John", "email": "john@example.com"]
)

let response: SNResponse<User> = await network.request(request)
```

### Headers personalizados

```swift
let request = SNRequest(
    path: "/protected",
    headers: [
        .authorization(bearerToken: "tu-token-aqui"),
        .contentType("application/json")
    ]
)
```

### Respuesta vacía (204 No Content)

```swift
let request = SNRequest(path: "/logout", method: .post)
let response: SNResponse<SNEmpty> = await network.request(request)
```

## SNRequest

Configuración de peticiones:

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `path` | `String` | Ruta del endpoint |
| `method` | `SNMethod` | `.get`, `.post`, `.put`, `.delete`, `.patch`, `.head` |
| `headers` | `[SNHeader]` | Headers HTTP personalizados |
| `parameters` | `SNParameters?` | Parámetros para query (GET) o body (POST/PUT) |
| `body` | `Data?` | Body raw para peticiones |
| `ignoreBase` | `Bool` | Ignora la URL base si es `true` |

## SNResponse

Respuesta tipada con:

- `url: URL?` - URL de la petición
- `result: Result<Object?, SNError>` - Resultado tipado
- `status: Int` - Código HTTP
- `headers: [SNHeader]` - Headers de respuesta
- `data: Data?` - Datos raw de la respuesta

## SNError

Errores posibles:

- `.unknown` - Error desconocido
- `.connectionLost` - Conexión perdida
- `.timeout` - Tiempo de espera agotado
- `.noInternet` - Sin conexión a internet
- `.cannotDecode` - Error decodificando la respuesta
- `.invalidStatus(Int)` - Código HTTP no válido (fuera del rango 2xx o personalizado)

## SNHeader

Headers predefinidos disponibles:

```swift
.accept("application/json")
.acceptCharset("utf-8")
.acceptLanguage("es-ES")
.acceptEncoding("gzip")
.authorization(username: "user", password: "pass")
.authorization(bearerToken: "token")
.authorization("Basic xxx")
.contentType("application/json")
.userAgent("MiApp/1.0")

// Headers por defecto (se añaden automáticamente)
.defaultAcceptEncoding  // br, gzip, deflate
.defaultAcceptLanguage  // Idiomas preferidos del sistema
.defaultUserAgent       // Información de la app y sistema
```

## Debug

Activa el modo debug para ver logs en consola:

```swift
let network = SimpleNetworkManager(base: URL(string: "https://api.example.com")!)
network.debug = true
```

## Retry automático

Puedes configurar reintentos automáticos para errores de red (timeout, sin conexión, etc.):

```swift
// Reintentar hasta 3 veces con 1 segundo de delay entre intentos
let response: SNResponse<User> = await network.request(
    request,
    retryCount: 3,
    retryDelay: 1.0
)
```

## Validación de status personalizada

Por defecto, solo los códigos 2xx (200-299) se consideran exitosos. Puedes personalizar esto:

```swift
// Aceptar también códigos 404 como válidos
let network = SimpleNetworkManager(
    base: URL(string: "https://api.example.com")!,
    validateStatus: { (200..<300).contains($0) || $0 == 404 }
)
```

## Inyección de URLSession

Para testing o configuraciones avanzadas, puedes inyectar tu propia URLSession:

```swift
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30
let session = URLSession(configuration: config)

let network = SimpleNetworkManager(
    base: URL(string: "https://api.example.com")!,
    session: session
)
```

## Ejemplo completo

```swift
import SimpleNetwork

final class UserService {
    private let network = SimpleNetworkManager(
        base: URL(string: "https://api.example.com")!
    )
    
    func fetchUser(id: Int) async -> User? {
        let request = SNRequest(
            path: "/users/\(id)",
            headers: [.authorization(bearerToken: getToken())]
        )
        
        let response: SNResponse<User> = await network.request(request)
        
        switch response.result {
        case .success(let user):
            return user
        case .failure(let error):
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func createUser(name: String, email: String) async -> Bool {
        let request = SNRequest(
            path: "/users",
            method: .post,
            headers: [
                .authorization(bearerToken: getToken()),
                .contentType("application/json")
            ],
            parameters: ["name": name, "email": email]
        )
        
        let response: SNResponse<User> = await network.request(request)
        return response.status == 201
    }
}
```

## Licencia

Copyright © 2024 Citibox. Todos los derechos reservados.
