# Estructura del proyecto

**[English](PROJECT-STRUCTURE.md)** · **[Arquitectura](../ARCHITECTURE.es.md)** · **[Limitaciones](KNOWN-LIMITATIONS.es.md)**

## Modelo de organización

El repositorio contiene un único target de aplicación iOS organizado mediante carpetas lógicas. En el primer nivel, `App`, `Core`, `Domain`, `Data` y `Features` expresan capas. Dentro de `Domain`, `Data` y `Features`, las carpetas se dividen por feature.

La estructura es **globalmente por capas y localmente por features**. Presentación es la zona más vertical: cada feature agrupa UI, ViewModel, mappers de presentación, navegación y factory de composición. No son módulos de feature independientes.

[ADR-0004](decisions/0004-single-app-target-logical-boundaries.md) explica por qué la referencia conserva un target de aplicación.

## Árbol del repositorio

```text
ios-architecture-reference/
├── Arquitectura.xcodeproj/
│   └── xcshareddata/xcschemes/
│       ├── Arquitectura-Dev.xcscheme
│       ├── Arquitectura-Stg.xcscheme
│       └── Arquitectura-Production.xcscheme
├── Arquitectura/
│   ├── ArquitecturaApp.swift
│   ├── Info.plist
│   ├── PrivacyInfo.xcprivacy
│   ├── App/
│   │   ├── Application/SplashScreen/
│   │   ├── Config/
│   │   │   └── Xcconfig/
│   │   └── Navigation/
│   ├── Core/
│   │   ├── Common/
│   │   ├── DesignSystem/
│   │   ├── Networking/
│   │   │   ├── PokeAPI/
│   │   │   └── Security/
│   │   └── Security/
│   ├── Domain/
│   │   ├── Architecture/
│   │   ├── ArchitectureDetail/
│   │   ├── PokemonList/
│   │   ├── PokemonDetail/
│   │   └── Common/
│   ├── Data/
│   │   ├── Architecture/
│   │   ├── ArchitectureDetail/
│   │   ├── PokemonList/
│   │   └── PokemonDetail/
│   ├── Features/
│   │   ├── Architecture/
│   │   ├── ArchitectureDetail/
│   │   ├── PokemonList/
│   │   └── PokemonDetail/
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Data/architecture_details.json
│       └── Strings/Localizable.xcstrings
├── ArquitecturaTests/
│   ├── ArquitecturaTests.xctestplan
│   ├── App/
│   ├── Core/
│   ├── Domain/
│   ├── Data/
│   ├── Features/
│   └── Mocks/
├── docs/
│   ├── decisions/
│   └── images/
├── scripts/
├── .swiftformat
├── .swiftlint.yml
└── Makefile
```

El árbol no muestra un directorio `ArquitecturaUITests/` porque no existe: el proyecto Xcode conserva un target nominal de UI tests, pero no hay fuentes UI Test rastreadas.

## Responsabilidad de cada zona

| Zona | Responsabilidad | Ejemplos |
| --- | --- | --- |
| `App` | Arranque, configuración compartida, raíz de navegación y composición de vida de app | `AppDependencies`, `RootNavigationView` |
| `Core` | Primitivas UI compartidas, tokens de diseño, networking y ayudas de seguridad | `APIClientImpl`, `AppColors` |
| `Domain` | Modelos de feature y contratos/implementaciones de Use Case | `PokemonListUseCaseImpl` |
| `Data` | Contratos/implementaciones de Repository, DTO, mappers y Data Sources | `PokemonListRepositoryImpl` |
| `Features` | Pantallas SwiftUI, estado, ViewModels, decorators, routers y factories | `PokemonListFactory` |
| `Resources` | Catálogo de assets propio, detalle local y localizaciones | `architecture_details.json` |
| `ArquitecturaTests` | Suites Swift Testing y dobles basados en protocolos | `MockPokemonListUseCase` |

La ubicación refleja la implementación actual. No debe interpretarse como una afirmación de que los protocolos Repository pertenezcan a `Data` en Clean Architecture estricta; esa desviación está en [Limitaciones](KNOWN-LIMITATIONS.es.md).

## Dentro de un feature

Los features de presentación usan esta forma real:

```text
Features/<Feature>/
├── DI/
│   └── <Feature>Factory.swift
├── Navigation/
│   ├── <Feature>Router.swift
│   └── <Feature>RouteResolver.swift     # cuando el feature posee destinos
├── Presentation/
│   ├── Mappers/
│   └── ViewModels/
└── UI/
    ├── Components/
    ├── <Feature>Decorator.swift
    ├── <Feature>State.swift
    └── <Feature>View.swift
```

No todos los features necesitan todos los archivos. El detalle Pokémon, por ejemplo, no tiene destinos propios; el listado posee casos list/detail y un resolver. Se evitan capas vacías creadas solo por simetría visual.

Las zonas equivalentes de datos y dominio son:

```text
Domain/<Feature>/
├── Models/
└── UseCases/

Data/<Feature>/
├── DataSources/
├── DTO/
├── Mappers/
└── Repositories/
```

## Dónde va un archivo nuevo

| Responsabilidad nueva | Ubicación actual |
| --- | --- |
| Pantalla SwiftUI o componente del feature | `Features/<Feature>/UI/` |
| Enum de estado de pantalla | `Features/<Feature>/UI/<Feature>State.swift` |
| ViewModel | `Features/<Feature>/Presentation/ViewModels/` |
| Mapping dominio → decorator UI | `Features/<Feature>/Presentation/Mappers/` |
| Ruta o protocolo Router del feature | `Features/<Feature>/Navigation/` |
| Construcción del grafo de pantalla | `Features/<Feature>/DI/<Feature>Factory.swift` |
| Modelo de dominio | `Domain/<Feature>/Models/` |
| Protocolo e implementación de Use Case | `Domain/<Feature>/UseCases/` |
| Protocolo e implementación de Repository | `Data/<Feature>/Repositories/` según la convención actual |
| Data Source remota o de bundle | `Data/<Feature>/DataSources/` |
| DTO o mapper DTO → dominio | `Data/<Feature>/DTO/` o `Data/<Feature>/Mappers/` |
| Capacidad HTTP transversal | `Core/Networking/` |
| Dependencia de vida de aplicación | `App/Config/AppDependencies.swift` y la factory que la use |
| Coordinación global de rutas | `App/Navigation/` |
| Doble de test | `ArquitecturaTests/Mocks/` |
| Test focalizado | Reflejar la capa de producción bajo `ArquitecturaTests/` |

Si una dependencia vive lo mismo que una pantalla, se construye en su factory. Solo se promueve a `AppDependencies` si varias pantallas deben compartir instancia o ciclo de vida.

## Targets, schemes y configuraciones

El proyecto Xcode define tres targets nominales:

- `Arquitectura`: único target de aplicación con todo el código de producción.
- `ArquitecturaTests`: target Swift Testing unitario/de integración incluido en el test plan.
- `ArquitecturaUITests`: target nominal vacío, fuera del test plan.

Los schemes compartidos enlazan configuraciones Debug/Release:

| Scheme | Configuraciones | Estado público |
| --- | --- | --- |
| `Arquitectura-Dev` | `Debug-Development`, `Release-Development` | Compilado y probado |
| `Arquitectura-Stg` | `Debug-Staging`, `Release-Staging` | Plantilla ilustrativa |
| `Arquitectura-Production` | `Debug-Production`, `Release-Production` | Ilustrativo; el guard rechaza el certificado placeholder |

Todas las configuraciones usan modo Swift 6 y deployment target iOS 18. El proyecto registra metadatos de formato Xcode 26.2, el snapshot se verificó localmente con Xcode 26.6 y compilador Swift 6.3.3, y CI usa el Xcode predeterminado de la imagen `macos-26` de GitHub.

Algunos ajustes de bundle/product del target sobreescriben hoy los valores declarados en xcconfig. No debe asumirse que los tres schemes sean identidades listas para distribución. Ese endurecimiento pertenece a la revisión estructural posterior.

## Fases de build y dependencias

- SwiftLint comprueba el estilo del código.
- SwiftFormat funciona en modo lint durante la verificación; solo `make format` reescribe fuentes.
- Un guard de release impide compilar Production mientras el hash del certificado sea el placeholder publicado.
- No hay generador de código ni fuentes generadas rastreadas.
- v2 no tiene `Package.swift` ni paquetes de terceros.

Desde la raíz se puede ejecutar `make build`, `make test`, `make lint`, `make validate` o el flujo completo `make ci`.

## Organización de tests

El árbol de tests refleja las zonas lógicas de la app, no módulos de feature compilados por separado. Las suites cubren navegación/splash de App, networking de Core, Use Cases de Domain, repositorios/mappers/Data Sources de Data, ViewModels/mappers de feature y mocks compartidos.

El test plan ejecuta solo `ArquitecturaTests`. Para añadir cobertura UI real habría que crear fuentes bajo `ArquitecturaUITests/` e incorporar el target al plan; un target vacío no prueba cobertura.

---

**Metadatos del documento**

| Campo | Valor |
| --- | --- |
| Autor / Responsable | magnoscg / OgamLabs |
| Creado | 2026-08-04 |
| Última actualización | 2026-08-04 |
| Última verificación | 2026-08-04 |
| Estado | Verificado para el snapshot v2 |
| Revisión | Con cada cambio estructural y trimestral |
| Etiquetas | `ios`, `swift`, `estructura`, `xcode` |
