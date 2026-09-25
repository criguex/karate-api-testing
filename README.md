# Karate API Testing

REST API test suite built with Karate DSL and Maven against the public [Makeup API](http://makeup-api.herokuapp.com/): data-driven scenarios, response schema matching and negative cases, executed in parallel and on CI.

[![CI](https://github.com/criguex/karate-api-testing/actions/workflows/ci.yml/badge.svg)](https://github.com/criguex/karate-api-testing/actions/workflows/ci.yml)
![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)
![Karate](https://img.shields.io/badge/Karate-1.3-1BA1F2)
![Maven](https://img.shields.io/badge/Maven-3.x-C71A36?logo=apachemaven&logoColor=white)

## What it tests

Endpoint under test: `GET /api/v1/products.json` with query-string filters.

| Feature | Filters | `@positive` scenario | `@negative` scenario |
|---|---|---|---|
| `brand.feature` | `brand` | 200, schema match, first item's brand matches | wrong path returns 404 with an HTML body |
| `product-type.feature` | `product_type` | 200, schema match, product type matches | wrong path returns 404 with an HTML body |
| `brand-and-product-type.feature` | `brand`, `product_type` | 200, schema match, brand and product type match | wrong path returns 404 with an HTML body |
| `brand-product-type-and-tag.feature` | `brand`, `product_type`, `product_tags` | 200, schema match, product type matches | wrong or empty path returns 404 with an HTML body |
| `product-type-and-category.feature` | `product_type`, `product_category` | 200, schema match, product type and category match | wrong or empty path returns 404 with an HTML body |

Every scenario is a `Scenario Outline` with three example rows: 5 features, 30 scenarios.

## Architecture

- **Karate DSL**: HTTP calls, assertions and JSON matching written in Gherkin, no glue code.
- **Schema matching**: expected response shapes live in `schema_response/*.json` using Karate fuzzy markers (`#number`, `#string`, `#array`, `#present`) and are applied with `match response contains`.
- **Configuration**: `karate-config.js` defines `baseUrl` and connect/read timeouts (5 s each).
- **Runner**: a single JUnit 5 test (`runner/ApiSuiteTest`) executes all features with 5 parallel threads and fails the build on any scenario failure.

## How to run

Requires JDK 17 and Maven 3.x.

```bash
git clone https://github.com/criguex/karate-api-testing.git
cd karate-api-testing
mvn clean test

mvn test -Dkarate.options="--tags @positive"
mvn test -Dkarate.options="--tags @negative"
```

## Project structure

```
.
├── .github/workflows/ci.yml
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

## Reporting

- Karate HTML report: `target/karate-reports/karate-summary.html`, with a page per feature including request and response logs.
- Cucumber JSON in `target/karate-reports/` for downstream tooling; Surefire XML in `target/surefire-reports/`.
- On CI `target/karate-reports/` is uploaded as a build artifact.

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs `mvn -B test` with Temurin JDK 17 on every push and pull request to `main`. The suite depends on the public Makeup API being available.

---

Cristian Guerra · Senior SDET · [linkedin.com/in/criguex](https://www.linkedin.com/in/criguex)
