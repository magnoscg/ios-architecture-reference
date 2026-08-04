# Limitaciones conocidas

**[English](KNOWN-LIMITATIONS.md)** · **[Arquitectura](../ARCHITECTURE.es.md)** · **[Estructura](PROJECT-STRUCTURE.es.md)**

## Por qué existe esta página

Este repositorio muestra una arquitectura real, incluidos sus compromisos. Los puntos siguientes separan lo que la muestra demuestra hoy de lo que podría exigir una arquitectura más estricta o específica de producción.

No se disfrazan como próximas features, ni significa que todo deba «corregirse». Un cambio estructural debería demostrar primero que el límite o abstracción adicional protege una necesidad real del producto.

## Límites de dependencias

### Un target de aplicación

Todo el código de producción se compila en `Arquitectura`. `App`, `Core`, `Domain`, `Data` y `Features` son carpetas lógicas, así que una referencia indebida entre capas no falla solo por dependencias de targets.

**Consecuencia:** revisión, tests y lint asumen una responsabilidad que módulos separados podrían imponer al compilar.

**Pregunta posterior:** modularizar únicamente cuando los límites de build, reutilización o equipos justifiquen el coste. Consulta [ADR-0004](decisions/0004-single-app-target-logical-boundaries.md).

### Los contratos Repository viven en Data

Los casos de uso de Domain dependen de protocolos Repository declarados físicamente en `Data/<Feature>/Repositories`.

**Consecuencia:** el árbol no representa la ubicación por inversión de dependencias que se espera de Clean Architecture estricta.

**Pregunta posterior:** mover los contratos a Domain y dejar en Data solo las implementaciones si el equipo elige esa propiedad estricta.

### El mapeo de errores cruza hacia fuera

`DomainError+Mapping.swift` conoce el `APIError` de networking en Core. `ErrorDecorator` está bajo Core aunque representa estado de presentación para el usuario.

**Consecuencia:** Domain no es independiente del transporte y Core contiene una responsabilidad de presentación.

**Pregunta posterior:** transformar transporte → dominio en el límite Data y mover la decoración UI a Features o una zona específica de presentación.

## Limitaciones de composición y navegación

### Conocimiento de rutas entre features

`ArchitectureDetailRouterImpl` añade directamente `PokemonListRoute.list` para demostrar el salto desde una entrada del catálogo al ejemplo PokeAPI.

**Consecuencia:** la implementación de navegación de un feature conoce el tipo de ruta concreto de otro.

**Pregunta posterior:** elevar esa intención a un contrato de ruta/coordinación de app si la propiedad independiente de features pasa a ser relevante.

### Un router de app con multiwindow habilitado

`ArquitecturaApp` posee un `AppRouterImpl`, mientras Info.plist permite múltiples escenas. `RootNavigationView` crea un coordinador de escena y persiste el path con `@SceneStorage`.

**Consecuencia:** la muestra no establece routers independientes para varias ventanas activas ni valida exhaustivamente el orden entre restauración en arranque frío y deep links entrantes.

**Pregunta posterior:** hacer que la propiedad del router sea explícitamente por escena y añadir escenarios cold launch/multiwindow antes de adoptar esta forma en un producto multiwindow.

### `NavigationPath` heterogéneo

Las rutas de los features comparten un `NavigationPath` type-erased. Los valores son Codable, pero restaurarlos exige que todas las rutas almacenadas sigan decodificando entre versiones.

**Consecuencia:** renombrar rutas o cambiar payloads necesita una estrategia de compatibilidad que esta referencia no incluye.

## Limitaciones de datos y concurrencia

### MainActor es el aislamiento por defecto

El target de app usa `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Los límites async y el nombre de una carpeta no mueven automáticamente el trabajo fuera del actor principal.

**Consecuencia:** no se puede afirmar que Domain o Data se ejecuten siempre en background.

### El JSON del bundle se decodifica síncronamente

`ArchitectureDetailJSONDataSourceImpl` lee y decodifica el catálogo durante la construcción del grafo de feature y lo conserva para esa vida de grafo.

**Consecuencia:** el archivo pequeño actual es aceptable para la referencia, pero este patrón ejecutaría archivos mayores y su decoding en el contexto de aislamiento del llamador.

**Pregunta posterior:** introducir un loader async con aislamiento explícito solo si el tamaño o una medición de navegación lo justifican.

### Caminos duplicados para el catálogo

El listado usa una Data Source estática, el detalle usa JSON en bundle y un `ArchitectureRemoteDataSource` permanece desconectado del grafo de producción.

**Consecuencia:** los datos pueden divergir y la ruta remota sin usar añade ruido.

**Pregunta posterior:** escoger una representación canónica y eliminar el camino desconectado durante la revisión estructural.

### Sin persistencia de dominio ni caché offline

Las respuestas de PokeAPI se obtienen en runtime y no se almacenan. `@SceneStorage` conserva datos de navegación; no es una capa de persistencia de dominio.

**Consecuencia:** el flujo PokeAPI no ofrece contenido offline y puede mostrar errores si el servicio no está disponible.

## Limitaciones de entrega y verificación

### Solo Development está validado

Los xcconfig y schemes de Staging/Production son ilustrativos. Sus endpoints son placeholders, Production conserva un hash de certificado placeholder y algunos ajustes del target sobreescriben valores de bundle/product de xcconfig.

**Consecuencia:** la configuración demuestra el mecanismo, pero no constituye entornos listos para distribuir. Un guard bloquea intencionadamente un release Production con ese hash.

### Sin cobertura UI Test

El proyecto contiene un target nominal `ArquitecturaUITests`, pero no hay directorio de fuentes y el test plan compartido ejecuta solo `ArquitecturaTests`.

**Consecuencia:** los 194 casos Swift Testing son evidencia unitaria/de integración, no prueba end-to-end de UI, accesibilidad o estabilidad visual.

### Dependencia externa en runtime

El flujo Pokémon depende de la disponibilidad y forma de PokeAPI y de los medios que referencia. El repositorio no controla ese servicio.

**Consecuencia:** las pantallas live pueden fallar o cambiar con independencia del snapshot. No se integra arte de Pokémon de terceros en el repositorio.

### El código de seguridad es ilustrativo

La muestra contiene infraestructura de SSL pinning, interceptores, ayudas de Keychain y manifiesto de privacidad, pero no autenticación real de producto, rotación de certificados, telemetría ni proceso de incidentes.

**Consecuencia:** son ejemplos de implementación revisables, no una certificación de seguridad de producción.

## Backlog de revisión estructural

La tarea posterior debería evaluar, por este orden:

1. límites de actor/aislamiento y trabajo síncrono con JSON;
2. navegación propiedad de escena, orden de deep links y compatibilidad de restauración;
3. valores efectivos de xcconfig y el target UI Test vacío;
4. ubicación de contratos Repository y mapping transporte → dominio;
5. navegación entre features y fuentes duplicadas del catálogo;
6. módulos solo si límites medibles de propiedad o build los justifican.

Ningún punto autoriza por sí solo un refactor. Cada cambio debe aportar tests, impacto de migración y un ADR cuando altere un contrato arquitectónico.

---

**Metadatos del documento**

| Campo | Valor |
| --- | --- |
| Autor / Responsable | magnoscg / OgamLabs |
| Creado | 2026-08-04 |
| Última actualización | 2026-08-04 |
| Última verificación | 2026-08-04 |
| Estado | Limitaciones aceptadas para publicar v2 |
| Revisión | Trimestral y antes de refactors estructurales |
| Etiquetas | `ios`, `arquitectura`, `deuda-técnica`, `limitaciones` |
