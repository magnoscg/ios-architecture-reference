# Arquitectura

**[English](ARCHITECTURE.md)** · **[README](README.es.md)** · **[Estructura](docs/PROJECT-STRUCTURE.es.md)** · **[Limitaciones](docs/KNOWN-LIMITATIONS.es.md)**

## Propósito y clasificación exacta

Este repositorio contiene una aplicación SwiftUI real de referencia. La descripción más precisa de su arquitectura es:

> Arquitectura con un único target de aplicación, organizada por capas y features, inspirada en Clean Architecture, con MVVM, routers tipados e inyección manual y jerárquica mediante factories.

La formulación es intencionada. `Domain`, `Data`, `Features`, `Core` y `App` son carpetas de código dentro de un target de aplicación, no módulos compilados de forma independiente. La organización mejora la lectura y la revisión, pero Xcode no impone la dirección de dependencias.

Es una referencia educativa, no una afirmación de que cualquier producto iOS necesite esta estructura. Muestra decisiones concretas y mantiene visibles sus desviaciones.

## Perfil arquitectónico

| Área | Implementación real |
| --- | --- |
| UI | SwiftUI, iOS 18+ |
| Presentación | ViewModels `@Observable` con enums de estado explícitos |
| Operaciones de dominio | Casos de uso y modelos de valor basados en protocolos |
| Acceso a datos | Datos estáticos, JSON en bundle y Data Sources remotas para PokeAPI |
| Navegación | `NavigationStack`, un `NavigationPath` por ventana y enums Codable por feature |
| Inyección | Constructor injection compuesta por factories de app y feature |
| Concurrencia | Modo Swift 6, aislamiento MainActor por defecto, async/await y task groups |
| Networking | URLSession tras un `APIClient`, endpoints e interceptores |
| Persistencia | Sin base de datos de dominio; solo rutas en `@SceneStorage` |
| Dependencias | Solo frameworks de Apple; sin paquetes Swift de terceros |

Los diagramas de presentación están en el README:

- [Capas y dirección de dependencias](README.es.md#-arquitectura)
- [Vida de una petición](README.es.md#-vida-de-una-petición)
- [Composición y ciclos de vida](README.es.md#-dentro-de-una-feature)

## Raíz de composición jerárquica

La composición se divide por ciclo de vida en lugar de concentrarse en un contenedor sobredimensionado.

| Responsable | Qué construye | Ciclo de vida |
| --- | --- | --- |
| [`ArquitecturaApp`](Arquitectura/ArquitecturaApp.swift) | `AppDependencies`, el estado de arranque y un `AppRootView` por ventana | Aplicación |
| [`AppDependencies`](Arquitectura/App/Config/AppDependencies.swift) | Configuración de entorno y `APIClientImpl` | Aplicación |
| [`AppRootView`](Arquitectura/App/Application/AppRootView.swift) | `AppRouterImpl`, `AppNavigationCoordinator`, splash o navegación raíz y `.onOpenURL` | Ventana |
| [`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) | `NavigationStack`, restauración del path y resolvers | Ventana |
| Factories de feature | Data Source, mapper, Repository, Use Case, Router, ViewModel y View | Pantalla/destino |

[`PokemonListFactory`](Arquitectura/Features/PokemonList/DI/PokemonListFactory.swift) es el ejemplo completo más claro. Recibe el cliente API compartido y el router de su ventana, crea los colaboradores del feature e inyecta el ViewModel resultante en la vista. No utiliza service locator ni un framework de DI.

El catálogo de arquitectura no necesita red, así que [`ArchitectureFactory`](Arquitectura/Features/Architecture/DI/ArchitectureFactory.swift) construye un grafo con datos estáticos. La factory del splash solo crea su ViewModel y su View. Cada factory mantiene un alcance proporcional al feature que compone.

La decisión y sus alternativas están en [ADR-0005](docs/decisions/0005-hierarchical-composition-roots.md).

## Capas lógicas y dirección de colaboración

La dirección pretendida es:

```text
App / UI del feature
        ↓
Presentación (ViewModel + mapper de presentación + Router de feature)
        ↓
Dominio (Use Case + modelo de dominio + protocolo Repository)
        ↓
Implementación de datos (Repository Impl + mapper + Data Source + mapeo de errores)
        ↓
Infraestructura Core (APIClient / URLSession) o datos del bundle
```

Responsabilidades actuales:

- **App** contiene arranque, configuración compartida, estado de navegación por ventana, coordinación de deep links y dependencias de vida de aplicación.
- **Features** contiene vistas SwiftUI, estado explícito de UI, ViewModels, decorators/mappers de presentación, rutas tipadas y factories.
- **Domain** se organiza por concepto de dominio (`Domain/Pokemon` sirve a las dos pantallas Pokémon) y contiene modelos, protocolos/implementaciones de casos de uso, protocolos de repositorio y `DomainError`.
- **Data** replica esos conceptos y contiene implementaciones de repositorio, DTO, mappers, Data Sources y la traducción de errores de infraestructura a `DomainError`.
- **Core** contiene networking, ayudas de seguridad, componentes SwiftUI compartidos, presentación de errores y tokens de diseño.

Está inspirada en Clean Architecture, pero no es Clean Architecture estricta. Domain posee sus contratos de repositorio y no conoce ningún tipo de networking, pero las capas son carpetas de un único target, así que el compilador no impone la dirección, y `ErrorDecorator` está en `Core` aunque su función sea de presentación porque lo comparten todas las features. Son decisiones documentadas, no afirmaciones ocultas. Consulta [Limitaciones](docs/KNOWN-LIMITATIONS.es.md).

## Flujos completos

### Catálogo local de arquitectura

```text
ArchitectureView
→ ArchitectureViewModel
→ ArchitectureUseCaseImpl
→ ArchitectureRepositoryImpl
→ ArchitectureStaticDataSourceImpl
```

Al seleccionar una entrada se añade un `ArchitectureRoute.detail`. La factory de destino construye otro grafo cuya Data Source no hace I/O al crearse: lee y decodifica `architecture_details.json` en una función `@concurrent`, fuera del main actor, cuando se pide el detalle, y un archivo ausente o inválido se lanza como error en lugar de presentarse como un catálogo vacío.

El catálogo es documentación dentro de la app. Sus 19 entradas actuales están respaldadas por implementación de este repositorio; las afirmaciones sin soporte sobre SwiftData y background executor se eliminaron del snapshot público.

### Listado y detalle de PokeAPI

```text
PokemonListView
→ PokemonListViewModel
→ PokemonListUseCaseImpl
→ PokemonListRepositoryImpl
→ PokemonListRemoteDataSourceImpl
→ APIClientImpl
→ PokeAPIEndpoint
```

El Repository de listado usa un throwing task group para obtener detalles en paralelo y ordena por ID los resultados correctos. Los fallos individuales que no sean cancelación se registran y omiten, pero si fallan todos los detalles se lanza el primer error, así que una carga fallida nunca se convierte en una página vacía; la cancelación se propaga. El Repository de detalle carga el detalle y la especie con `async let`: la especie es opcional y el detalle principal obligatorio.

Las respuestas de PokeAPI no se persisten localmente. Consulta [Avisos de terceros](THIRD_PARTY_NOTICES.md) para conocer atribución y alcance.

## Estado, errores y cancelación

Cada ViewModel posee un enum de estado explícito como `idle`, `loading`, `loaded` y `error`. Las vistas SwiftUI representan ese estado y envían intenciones al ViewModel; no crean repositorios ni modifican directamente el path global.

Los ViewModels impiden cargas duplicadas. Ante `CancellationError`, restauran el estado anterior para no dejar la pantalla bloqueada en loading. La paginación separa su carga y error recuperable del contenido ya cargado.

El recorrido implementado de errores es:

```text
APIError lanzado por una Data Source
→ DomainError.catching { ... } dentro del Repository
→ DomainError que el Use Case deja pasar
→ ErrorDecorator.from(...) dentro del ViewModel
→ estado SwiftUI localizado
```

Así se evita mostrar payloads crudos del servidor y Domain queda libre de tipos de networking: la traducción vive en [`DomainError+Mapping.swift`](Arquitectura/Data/Common/DomainError+Mapping.swift). `DomainError.catching` relanza `CancellationError`, trata como cancelación cualquier fallo que llegue después de cancelar la tarea y mapea todo lo demás.

## Navegación tipada y restauración

El `AppRootView` de cada ventana posee un [`AppRouterImpl`](Arquitectura/App/Navigation/AppRouterImpl.swift) con un `NavigationPath` observable, así que las ventanas de iPad navegan y se restauran de forma independiente. El protocolo `AppRouter` solo ofrece `push`, `pop` y `popToRoot`; solo la capa App lee o reemplaza el path completo. Cada flujo define valores de ruta Codable y Hashable y un protocolo Router pequeño. Los ViewModels expresan intenciones mediante esos protocolos; las implementaciones delegan en el router de app.

[`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) instala resolvers `navigationDestination` por feature. [`AppNavigationCoordinator`](Arquitectura/App/Navigation/AppNavigationCoordinator.swift) interpreta el esquema `arquitectura://` y codifica el path en `@SceneStorage` con debounce; si la codificación falla no escribe nada y conserva el último estado válido. Un deep link válido reemplaza el stack en lugar de apilar encima. Un enlace recibido antes de restaurar, como la URL que lanzó la app, se retiene y se aplica justo después de restaurar, así que el resultado no depende de si `.onOpenURL` o la tarea de restauración se ejecuta primero.

Esto saca la construcción de rutas de las vistas y admite destinos heterogéneos en un mismo stack. Los tests unitarios cubren los órdenes de arranque; los flujos multiventana y de arranque en frío no tienen cobertura de UI tests. Consulta [ADR-0006](docs/decisions/0006-typed-feature-routing.md).

## Modelo de concurrencia Swift

El proyecto usa modo de lenguaje Swift 6 y `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` en los targets de app y tests.

- Vistas SwiftUI, ViewModels, routers, coordinadores y factories están aislados en MainActor explícitamente o por el ajuste del target.
- Los contratos async de Repository y Data Source conforman a `Sendable` cuando cruzan tareas.
- `APIClientImpl` utiliza `@unchecked Sendable`; su argumento de seguridad depende de colaboradores almacenados inmutables y un decoder nuevo por request.
- El listado Pokémon usa `withThrowingTaskGroup`; el detalle usa `async let`.
- La cancelación se trata aparte de los fallos de dominio en `APIClientImpl`, el interceptor de reintentos, los repositorios y los ViewModels. `APIClientImpl` convierte `URLError.cancelled` en `CancellationError` solo si la tarea se canceló, así que un challenge de pinning rechazado sigue siendo un error de red.
- El interceptor de reintentos solo reenvía métodos idempotentes o peticiones con la cabecera `Idempotency-Key`.

El aislamiento MainActor por defecto significa que el nombre de una carpeta no implica ejecución en background. El trabajo que debe salir del main actor se marca explícitamente: la Data Source de JSON decodifica en una función `@concurrent` y los mappers de DTO son `nonisolated` para poder ejecutarse dentro de las tareas hijas de un task group.

## Entornos y seguridad de red

El proyecto contiene xcconfig de Development, Staging y Production con schemes compartidos equivalentes.

- **Development** es el único flujo público compilado y probado como parte de esta referencia. El pinning está desactivado y los valores de API interna son placeholders; PokeAPI usa su propia URL HTTPS.
- **Staging** es una plantilla ilustrativa con endpoint placeholder y pinning desactivado.
- **Production** es una plantilla ilustrativa. Una fase de protección rechaza builds release mientras el hash de certificado siga siendo el placeholder incluido.

La presencia de `SSLPinningDelegate`, interceptores, ayudas de Keychain o manifiesto de privacidad prueba que el código existe; no significa que la muestra esté lista para producción. Autenticación, secretos, certificados, observabilidad, respuesta a incidentes y revisión de privacidad específicos de un producto quedan fuera de este repositorio.

## Estrategia de tests

El `ArquitecturaTests.xctestplan` incluido ejecuta únicamente `ArquitecturaTests`. El snapshot del 03-11-2026 declara 226 casos Swift Testing en 30 suites que cubren:

- endpoints e interceptores, incluidos idempotencia de reintentos y cancelación;
- mapping DTO → dominio y dominio → presentación;
- resultados de repositorios y Data Sources, incluido el mapeo a `DomainError` en Data;
- ordenación, paginación, paso de errores y cancelación en casos de uso;
- transiciones de estado de ViewModels y delegación a Router;
- codificación/restauración de navegación, parsing de deep links y orden de arranque;
- comportamiento del splash.

El proyecto Xcode contiene un target nominal `ArquitecturaUITests`, pero no hay fuentes UI Test y el target no forma parte del test plan. Por eso la documentación no afirma que existan UI tests.

`make ci` ejecuta las comprobaciones públicas con un simulador iPhone elegido dinámicamente, sin firma de código, lint no mutante, validación de la frontera pública y una comprobación final de que verificar no cambia archivos rastreados.

## Índice de decisiones

- Históricas v1: [ADR-0001](docs/decisions/0001-protect-dependency-direction.md), [ADR-0002](docs/decisions/0002-mainactor-observable-state.md), [ADR-0003](docs/decisions/0003-explicit-composition-root.md)
- Vigentes v2: [ADR-0004](docs/decisions/0004-single-app-target-logical-boundaries.md), [ADR-0005](docs/decisions/0005-hierarchical-composition-roots.md), [ADR-0006](docs/decisions/0006-typed-feature-routing.md)

---

**Metadatos del documento**

| Campo | Valor |
| --- | --- |
| Autor / Responsable | magnoscg / OgamLabs |
| Creado | 2026-08-04 |
| Última actualización | 2026-11-03 |
| Última verificación | 2026-11-03 |
| Estado | Verificado para el snapshot v2 |
| Revisión | Trimestral y con cada cambio arquitectónico |
| Etiquetas | `ios`, `swiftui`, `arquitectura`, `mvvm`, `routing`, `dependency-injection` |
