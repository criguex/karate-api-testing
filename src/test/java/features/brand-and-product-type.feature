Feature: Filter products by brand and product type

  Background:
    * url baseUrl
    * print  baseUrl
    * def responseJson200 = read("classpath:../schema_response/responseMarcaJson200.json")
    * print responseJson200

  @positive
  Scenario Outline:
    Given params { brand: "<brand>", product_type:"<product_type>"}
    When method get
    * def jsonResponse = response
    * print jsonResponse
    Then status 200
    And match jsonResponse contains responseJson200
    And match jsonResponse[0].brand contains "<brand>"
    And match jsonResponse[0].product_type contains "<product_type>"

    Examples:
      | brand      |product_type|
      | marcelle   |eyeliner    |
      | milani     |blush       |
      | iman       |mascara     |


  @negative
  Scenario Outline:
    Given url 'http://makeup-api.herokuapp.com/'
    And path 'api/ddd/' + 'products.json?'
    And params { brand: "<brand>", product_type:"<product_type>" }
    When method get
    * def jsonResponse = response

    * print jsonResponse
    Then status 404
    And match responseType == "string"
    And match response contains "<html>"

    Examples:
      | brand      |product_type|
      | marcelle   |eyeliner    |
      | fenty      |blush       |
      | iman       |mascara     |