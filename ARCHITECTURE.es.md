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
| Navegación | `NavigationStack`, un `NavigationPath` y enums Codable por feature |
| Inyección | Constructor injection compuesta por factories de app y feature |
| Concurrencia | Modo Swift 6, aislamiento MainActor por defecto, async/await y task groups |
| Networking | URLSession tras un `APIClient`, endpoints e interceptores |
| Persistencia | Sin base de datos de dominio; solo rutas en `@SceneStorage` |
| Dependencias | Solo frameworks de Apple; sin paquetes Swift de terceros |

Los dos diagramas de presentación y sus alternativas textuales están en el README:

- [Composición y ciclos de vida](README.es.md#composición-y-ciclos-de-vida)
- [Flujo en ejecución](README.es.md#flujo-en-ejecución)

## Raíz de composición jerárquica

La composición se divide por ciclo de vida en lugar de concentrarse en un contenedor sobredimensionado.

| Responsable | Qué construye | Ciclo de vida |
| --- | --- | --- |
| [`ArquitecturaApp`](Arquitectura/ArquitecturaApp.swift) | `AppDependencies`, `AppRouterImpl`, splash y vista raíz | Aplicación |
| [`AppDependencies`](Arquitectura/App/Config/AppDependencies.swift) | Configuración de entorno y `APIClientImpl` | Aplicación |
| [`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) | `AppNavigationCoordinator` y resolvers | Escena/vista raíz |
| Factories de feature | Data Source, mapper, Repository, Use Case, Router, ViewModel y View | Pantalla/destino |

[`PokemonListFactory`](Arquitectura/Features/PokemonList/DI/PokemonListFactory.swift) es el ejemplo completo más claro. Recibe el cliente API y el router compartidos, crea los colaboradores del feature e inyecta el ViewModel resultante en la vista. No utiliza service locator ni un framework de DI.

El catálogo de arquitectura no necesita red, así que [`ArchitectureFactory`](Arquitectura/Features/Architecture/DI/ArchitectureFactory.swift) construye un grafo con datos estáticos. La factory del splash solo crea su ViewModel y su View. Cada factory mantiene un alcance proporcional al feature que compone.

La decisión y sus alternativas están en [ADR-0005](docs/decisions/0005-hierarchical-composition-roots.md).

## Capas lógicas y dirección de colaboración

La dirección pretendida es:

```text
App / UI del feature
        ↓
Presentación (ViewModel + mapper de presentación + Router de feature)
        ↓
Dominio (Use Case + modelo de dominio)
        ↓
Contrato e implementación de datos (Repository + mapper + Data Source)
        ↓
Infraestructura Core (APIClient / URLSession) o datos del bundle
```

Responsabilidades actuales:

- **App** contiene arranque, configuración compartida, estado de navegación, coordinación de deep links y dependencias de vida de aplicación.
- **Features** contiene vistas SwiftUI, estado explícito de UI, ViewModels, decorators/mappers de presentación, rutas tipadas y factories.
- **Domain** contiene modelos de feature y protocolos/implementaciones de casos de uso.
- **Data** contiene protocolos e implementaciones de repositorio, DTO, mappers y Data Sources.
- **Core** contiene networking, ayudas de seguridad, componentes SwiftUI compartidos, presentación de errores y tokens de diseño.

Está inspirada en Clean Architecture, pero no es Clean Architecture estricta. Los protocolos de repositorio están físicamente en `Data`; `DomainError.map` conoce `APIError` de networking; y `ErrorDecorator` está en `Core` aunque su función sea de presentación. Son deudas documentadas, no afirmaciones ocultas. Consulta [Limitaciones](docs/KNOWN-LIMITATIONS.es.md).

## Flujos completos

### Catálogo local de arquitectura

```text
ArchitectureView
→ ArchitectureViewModel
→ ArchitectureUseCaseImpl
→ ArchitectureRepositoryImpl
→ ArchitectureStaticDataSourceImpl
```

Al seleccionar una entrada se añade un `ArchitectureRoute.detail`. La factory de destino construye otro grafo que lee `architecture_details.json` una vez durante la inicialización de su Data Source y conserva los DTO decodificados durante la vida de ese grafo.

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

El Repository de listado usa un throwing task group para obtener detalles en paralelo y ordena por ID los resultados correctos. Los fallos individuales que no sean cancelación se registran y omiten; la cancelación se propaga. El Repository de detalle carga el detalle y la especie con `async let`: la especie es opcional y el detalle principal obligatorio.

Las respuestas de PokeAPI no se persisten localmente. Consulta [Avisos de terceros](THIRD_PARTY_NOTICES.md) para conocer atribución y alcance.

## Estado, errores y cancelación

Cada ViewModel posee un enum de estado explícito como `idle`, `loading`, `loaded` y `error`. Las vistas SwiftUI representan ese estado y envían intenciones al ViewModel; no crean repositorios ni modifican directamente el path global.

Los ViewModels impiden cargas duplicadas. Ante `CancellationError`, restauran el estado anterior para no dejar la pantalla bloqueada en loading. La paginación separa su carga y error recuperable del contenido ya cargado.

El recorrido implementado de errores es:

```text
APIError
→ DomainError.map(...) dentro del Use Case
→ ErrorDecorator.from(...) dentro del ViewModel
→ estado SwiftUI localizado
```

Así se evita mostrar payloads crudos del servidor. También se crea una dependencia hacia fuera desde el mapeo de errores de Domain hasta networking, registrada para revisión estructural posterior.

## Navegación tipada y restauración

[`AppRouterImpl`](Arquitectura/App/Navigation/AppRouterImpl.swift) posee un único `NavigationPath` observable. Cada flujo define valores de ruta Codable y Hashable y un protocolo Router pequeño. Los ViewModels expresan intenciones mediante esos protocolos; las implementaciones delegan en el router de app.

[`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) instala resolvers `navigationDestination` por feature. [`AppNavigationCoordinator`](Arquitectura/App/Navigation/AppNavigationCoordinator.swift) interpreta el esquema `arquitectura://` y codifica el path en `@SceneStorage` con debounce.

Esto saca la construcción de rutas de las vistas y admite destinos heterogéneos en un mismo stack. Todavía no demuestra una propiedad robusta por ventana ni todos los órdenes posibles de deep link en arranque frío. Consulta [ADR-0006](docs/decisions/0006-typed-feature-routing.md).

## Modelo de concurrencia Swift

El proyecto usa modo de lenguaje Swift 6 y `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` en los targets de app y tests.

- Vistas SwiftUI, ViewModels, routers, coordinadores y factories están aislados en MainActor explícitamente o por el ajuste del target.
- Los contratos async de Repository y Data Source conforman a `Sendable` cuando cruzan tareas.
- `APIClientImpl` utiliza `@unchecked Sendable`; su argumento de seguridad depende de colaboradores almacenados inmutables y un decoder nuevo por request.
- El listado Pokémon usa `withThrowingTaskGroup`; el detalle usa `async let`.
- La cancelación se trata aparte de los fallos de dominio en Use Cases, repositorios y ViewModels.

El aislamiento MainActor por defecto significa que el nombre de una carpeta no implica ejecución en background. La Data Source de JSON lee y decodifica síncronamente durante la construcción del feature. Si la muestra crece, el trabajo intensivo de CPU o disco deberá pasar a un servicio explícitamente no aislado.

## Entornos y seguridad de red

El proyecto contiene xcconfig de Development, Staging y Production con schemes compartidos equivalentes.

- **Development** es el único flujo público compilado y probado como parte de esta referencia. El pinning está desactivado y los valores de API interna son placeholders; PokeAPI usa su propia URL HTTPS.
- **Staging** es una plantilla ilustrativa con endpoint placeholder y pinning desactivado.
- **Production** es una plantilla ilustrativa. Una fase de protección rechaza builds release mientras el hash de certificado siga siendo el placeholder incluido.

La presencia de `SSLPinningDelegate`, interceptores, ayudas de Keychain o manifiesto de privacidad prueba que el código existe; no significa que la muestra esté lista para producción. Autenticación, secretos, certificados, observabilidad, respuesta a incidentes y revisión de privacidad específicos de un producto quedan fuera de este repositorio.

## Estrategia de tests

El `ArquitecturaTests.xctestplan` incluido ejecuta únicamente `ArquitecturaTests`. El snapshot del 04-08-2026 ejecutó 194 casos Swift Testing en 27 suites que cubren:

- endpoints e interceptores;
- mapping DTO → dominio y dominio → presentación;
- resultados de repositorios y Data Sources;
- ordenación, paginación, mapeo de errores y cancelación en casos de uso;
- transiciones de estado de ViewModels y delegación a Router;
- codificación/restauración de navegación y parsing de deep links;
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
| Última actualización | 2026-08-04 |
| Última verificación | 2026-08-04 |
| Estado | Verificado para el snapshot v2 |
| Revisión | Trimestral y con cada cambio arquitectónico |
| Etiquetas | `ios`, `swiftui`, `arquitectura`, `mvvm`, `routing`, `dependency-injection` |
