# Makeup API Test Suite — Karate DSL

![Java](https://img.shields.io/badge/Java-11+-ED8B00?logo=openjdk&logoColor=white)
![Karate](https://img.shields.io/badge/Karate-DSL-1BA1F2?logo=java&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-Build-C71A36?logo=apache-maven&logoColor=white)

REST API test automation suite for the [Makeup API](http://makeup-api.herokuapp.com) built with **Karate DSL** and Maven. Validates product search and filtering endpoints across 6 feature modules with both happy-path and failure scenarios.

## Test Coverage

| Feature File | Endpoint Filter | Test Data | Tags |
|---|---|---|---|
| `producto.feature` | `?product_type` | eyeshadow, eyebrow, lipstick | `@successfull`, `@fail` |
| `marca.feature` | `?brand` | marcelle, milani, iman | `@successfull`, `@fail` |
| `marcaProduto.feature` | `?brand + product_type` | marcelle/eyeliner, milani/blush | `@successfull`, `@fail` |
| `productoMarca.feature` | `?product_type` | eyeshadow, eyebrow, lipstick | `@successfull`, `@fail` |
| `MarcaProductoTag.feature` | `?brand + product_type + tag` | marcelle/eyeliner/canadian | `@successfull`, `@fail` |
| `productoCategoria.feature` | `?product_type + product_category` | eyeliner/cream, lipstick/liquid | `@successfull`, `@fail` |

## Project Structure

```
src/test/
├── java/
│   ├── features/            # Karate .feature files
│   │   ├── marca.feature
│   │   ├── producto.feature
│   │   ├── productoMarca.feature
│   │   ├── marcaProduto.feature
│   │   ├── MarcaProductoTag.feature
│   │   └── productoCategoria.feature
│   └── runner/
│       └── TestParallel.java   # JUnit parallel runner
└── resources/
    └── schema_response/        # JSON schema fixtures for response validation
        ├── responseMarcaJson200.json
        └── responseProductoJson200.json
```

## Sample Scenario

```gherkin
Feature: Get products by brand

  Background:
    * url baseUrl

  @successfull
  Scenario Outline: Filter products by type
    Given params { product_type: "<product_type>" }
    When method get
    Then status 200
    And match response contains responseJson200
    And match response[0].product_type contains "<product_type>"

    Examples:
      | product_type |
      | eyeshadow    |
      | lipstick     |
```

## Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| Java | 11–17 | Runtime |
| Maven | 3.x | Build & dependency management |
| Karate DSL | 1.x | API test framework |
| JUnit | 4.x | Test runner integration |

## Getting Started

### Prerequisites
- Java 11+
- Maven 3.x

### Run All Tests

```bash
git clone https://github.com/criguex/test-APIS-kashio.git
cd test-APIS-kashio
mvn clean test
```

### Run by Tag

```bash
mvn clean test -Dkarate.options="--tags @successfull"
mvn clean test -Dkarate.options="--tags @fail"
```

### View Report

Karate generates an HTML report after execution:
```
target/surefire-reports/
target/cucumber-html-reports/
```

## License

MIT
