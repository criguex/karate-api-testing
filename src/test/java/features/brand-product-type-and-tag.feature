Feature: Filter products by brand, product type and tag

  Background:
    * url baseUrl
    * print  baseUrl
    * def responseJson200 = read("classpath:../schema_response/responseProductoJson200.json")
    * print responseJson200

  @positive
  Scenario Outline:
    Given params {brand:"<brand>", product_type:"<product_type>", product_tags:"<product_tags>"}
    When method get
    * def jsonResponse = response

    * print jsonResponse
    Then status 200
    And match jsonResponse contains responseJson200
    And match jsonResponse[0].product_type contains "<product_type>"
    #And match jsonResponse[0].category contains "<product_category>"

    Examples:
      | brand      |product_type|product_tags    |
      | marcelle   |eyeliner    |canadian        |
      | marcelle   |blush       |canadian        |
      | marienatie |lipstick    |certclean       |


  @negative
  Scenario Outline:
    Given url 'http://makeup-api.herokuapp.com/'
    And path 'api/<path>/' + 'products.json?'
    And params { brand: "<brand>", product_type:"<product_type>" }
    When method get
    * def jsonResponse = response

    * print jsonResponse
    Then status 404
    And match responseType == "string"
    And match response contains "<html>"

    Examples:
      | brand      |product_type|product_tags    | path |
      | marcelle   |eyeliner    |canadian        |233ss |
      | marcelle   |blush       |canadian        |32dd  |
      | marienatie |lipstick    |certclean       |      |