[Read in English](README.md)

<p align="center">
  <img src="docs/assets/banner.svg" alt="karate-api-testing: suite de API REST para la Makeup API pública con Gherkin guiado por datos, validación de esquema JSON y casos negativos en paralelo" width="100%">
</p>

## Explicado para un niño de 8 años

Imagina una tienda que contesta preguntas por computador en vez de por teléfono. Le pides "muéstrame productos Maybelline" y te devuelve una lista. Este proyecto es como un profesor que califica esa respuesta: revisa que la lista tenga todas las partes que debe tener (un nombre, un precio, una marca…) y que la marca sí sea Maybelline. También toca a propósito una puerta que no existe, para asegurarse de que la tienda diga "no encontrado".

### Un ejemplo real

- **Imagina que:** le pedimos a la Makeup API productos con `brand=maybelline`.
- **Qué debería pasar:** contesta "200, todo bien" con una lista, y la marca del primer producto es Maybelline.
- **Qué hace el proyecto:** Karate revisa el número de estado, compara la respuesta con una plantilla (`id` tiene que ser un número, `name` tiene que ser texto, …) y lee la marca.
- **Qué ganamos:** si la tienda cambiara la forma de sus respuestas o mandara otra marca, la prueba fallaría y el build completo se detendría. En CI pasaron los 30 escenarios.

<p align="center">
  <img src="docs/assets/explained.es.gif" alt="Historia ilustrada: un robot le pide a la Makeup API productos Maybelline, recibe una lista, revisa su forma con una lupa, toca una puerta equivocada y recibe el 404 esperado, y cinco ayudantes terminan 30 de 30 pruebas" width="960">
</p>

La misma animación en [MP4](docs/assets/explained.es.mp4).

### Palabras difíciles

| Palabra | Qué quiere decir |
|---|---|
| API | Una ventanilla para computadores: un programa pregunta y ella responde con datos |
| Código de estado | Un número que dice cómo le fue: 200 es OK, 404 es no encontrado |
| Esquema (schema) | La plantilla que tiene que seguir una respuesta, como las casillas de un formulario |
| Scenario Outline | Una prueba escrita una sola vez y jugada con varias filas de ejemplos |
| En paralelo | Varios ayudantes trabajando al mismo tiempo |
| CI | Un robot que corre todas las pruebas cada vez que alguien sube un cambio |

# Karate API Testing

Suite de pruebas de API REST hecha con Karate DSL y Maven contra la [Makeup API](http://makeup-api.herokuapp.com/) pública: escenarios guiados por datos, validación del esquema de la respuesta y casos negativos, ejecutados en paralelo y en CI.

[![CI](https://github.com/criguex/karate-api-testing/actions/workflows/ci.yml/badge.svg)](https://github.com/criguex/karate-api-testing/actions/workflows/ci.yml)
![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)
![Karate](https://img.shields.io/badge/Karate-1.3-1BA1F2)
![Maven](https://img.shields.io/badge/Maven-3.x-C71A36?logo=apachemaven&logoColor=white)

## Cómo funciona

<p align="center">
  <img src="docs/assets/how-it-works.svg" alt="Cinco features corren con un solo runner de JUnit 5 en cinco hilos; los escenarios positivos llaman /api/v1/products.json y validan el esquema, los negativos llaman una ruta errada y esperan una página 404 en HTML; el build falla si algún escenario falla" width="100%">
</p>

1. Cada feature es un `Scenario Outline` con tres filas de ejemplos, marcado `@positive` o `@negative`.
2. `karate-config.js` define `baseUrl` y timeouts de conexión y lectura de 5 s; `ApiSuiteTest` corre todos los features con `Runner.path("classpath:features").parallel(5)`.
3. Los escenarios `@positive` llaman `GET /api/v1/products.json` con los filtros del ejemplo, esperan `200`, comparan el cuerpo contra `schema_response/*.json` y revisan el campo filtrado.
4. Los escenarios `@negative` usan los mismos filtros sobre una ruta errada y esperan `404` con cuerpo HTML.
5. El runner exige `results.getFailCount() == 0`, así que cualquier escenario fallido tumba el build de Maven.

<p align="center">
  <img src="docs/assets/how-it-works.gif" alt="Animación: el flujo se ilumina paso a paso mientras se reproduce el log real de CI del run 36095563876, que termina con 30 escenarios pasados y BUILD SUCCESS" width="960">
</p>

La animación reproduce el log real del run de CI [36095563876](https://github.com/criguex/karate-api-testing/actions/runs/36095563876) (también en [MP4](docs/assets/how-it-works.mp4)).

## Qué prueba

Endpoint bajo prueba: `GET /api/v1/products.json` con filtros en el query string.

| Feature | Filtros | Escenario `@positive` | Escenario `@negative` |
|---|---|---|---|
| `brand.feature` | `brand` | 200, esquema válido, la marca del primer ítem coincide | ruta errada devuelve 404 con cuerpo HTML |
| `product-type.feature` | `product_type` | 200, esquema válido, el tipo de producto coincide | ruta errada devuelve 404 con cuerpo HTML |
| `brand-and-product-type.feature` | `brand`, `product_type` | 200, esquema válido, marca y tipo de producto coinciden | ruta errada devuelve 404 con cuerpo HTML |
| `brand-product-type-and-tag.feature` | `brand`, `product_type`, `product_tags` | 200, esquema válido, el tipo de producto coincide | ruta errada o vacía devuelve 404 con cuerpo HTML |
| `product-type-and-category.feature` | `product_type`, `product_category` | 200, esquema válido, tipo de producto y categoría coinciden | ruta errada o vacía devuelve 404 con cuerpo HTML |

Cada escenario es un `Scenario Outline` con tres filas de ejemplos: 5 features, 30 escenarios.

**Último resultado de CI en `main`** (run 36095563876, 2026-09-25), del resumen de Karate:

```text
Karate version: 1.3.1
elapsed:   3.57 | threads:    5 | thread time: 7.38
features:     5 | skipped:    0 | efficiency: 0.41
scenarios:   30 | passed:    30 | failed: 0
[INFO] BUILD SUCCESS
```

## Arquitectura

- **Karate DSL**: llamadas HTTP, aserciones y comparación de JSON escritas en Gherkin, sin código de pegamento.
- **Validación de esquema**: la forma esperada de la respuesta vive en `schema_response/*.json` con los marcadores difusos de Karate (`#number`, `#string`, `#array`, `#present`) y se aplica con `match response contains`.
- **Configuración**: `karate-config.js` define `baseUrl` y los timeouts de conexión y lectura (5 s cada uno).
- **Runner**: una sola prueba de JUnit 5 (`runner/ApiSuiteTest`) corre todos los features con 5 hilos en paralelo y hace fallar el build si algún escenario falla.

## Cómo correrlo

Requiere JDK 17 y Maven 3.x.

```bash
git clone https://github.com/criguex/karate-api-testing.git
cd karate-api-testing
mvn clean test

mvn test -Dkarate.options="--tags @positive"
mvn test -Dkarate.options="--tags @negative"
```

## Estructura del proyecto

```
.
├── .github/workflows/ci.yml
├── docs/
│   ├── assets/        banner.svg, how-it-works.*, explained.* (animación para niños, EN + .es)
│   └── scenes/        how-it-works.html, explained.html + sus scripts de export
├── pom.xml
└── src/test/java/
    ├── features/
    │   ├── brand.feature
    │   ├── product-type.feature
    │   ├── brand-and-product-type.feature
    │   ├── brand-product-type-and-tag.feature
    │   └── product-type-and-category.feature
    ├── runner/ApiSuiteTest.java
    ├── schema_response/
    │   ├── responseMarcaJson200.json
    │   └── responseProductoJson200.json
    ├── karate-config.js
    └── logback-test.xml
```

## Reportes

- Reporte HTML de Karate: `target/karate-reports/karate-summary.html`, con una página por feature que incluye los logs de petición y respuesta.
- Cucumber JSON en `target/karate-reports/` para otras herramientas; XML de Surefire en `target/surefire-reports/`.
- En CI, `target/karate-reports/` se sube como artefacto del build.

## CI

GitHub Actions (`.github/workflows/ci.yml`) corre `mvn -B test` con Temurin JDK 17 en cada push y pull request a `main`. La suite depende de que la Makeup API pública esté disponible.

## Límites

- Todos los escenarios llaman a la Makeup API pública de un tercero, así que su disponibilidad y sus datos deciden el resultado; no hay mock.
- Los casos negativos cubren rutas erradas (404 con cuerpo HTML); no se prueban valores inválidos en los filtros.

## Regenerar la animación

`docs/scenes/how-it-works.html` dibuja cada cuadro a partir de `?t=<segundos>`; `docs/scenes/export.sh` captura los cuadros con Chrome headless y arma `how-it-works.gif` y `how-it-works.mp4` con ffmpeg. `docs/scenes/explained.html` (`?t=<segundos>&lang=en|es`) y `docs/scenes/export-explained.sh` hacen lo mismo con la animación para niños.

---

Cristian Guerra · Senior SDET · [linkedin.com/in/criguex](https://www.linkedin.com/in/criguex)
