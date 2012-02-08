Feature: OAuth 2.0 Client Usage 

  This feature is plaing an OAuth 2.0 Client 
  The client application has to use a protected
  resource on behalf of a known customer

  In order to use an protected resource 
  As a creator of an third party application 
  I want to authenticate my oauth enabled client-app

Scenario: registering my web application 
  Given the following user record
    | key                   | value | 
    | appname               | OAuth 2.0 Demo application | 
    | email                 | fv@frankvilhelmsen.com |
    | siteuri               | http://oauth.frankvilhelmsen.com/authenticated |    
  And I am logged in as "known" with "customer"
  When the uri is "/company/apps/registering" posting
  Then the status code is 201
  And the content should contain "pending"
  And the content should contain "Waiting for verification"
  And the content should contain "OAuth 2.0 Demo application"

Scenario: call the resource service without credentials
  Given the uri is "/protected/resource"
  And the status code is 401
  Then the content should contain "OAuth Exception"
  And  the content should contain "An active access token is mandatory"

Scenario: obtain a access token
  Given the following user record
    | id                     | /proceted/resource |
    | grant type             | client_credentials |
    | client-id              | 19837i4376916044 |
    | client-secret          | 37258968804049145bea92056ddae960 |
    | access-token-uri       | /oauth/access_token |
    | user-authorization-uri | /company/authorize |
  And I am logged in as "known" with "customer"
  And the uri is "/oauth/access_token?client_id=19837i4376916044&client_secret=37258968804049145bea92056ddae960&grant_type=client_credentials"
  Then the status code is 200
  And the content should be "access_token=198374376916044|8GZsF8FkGsmDaKVkUB3E2HbrP_M"

Scenario: call the resource service with the oauth credentials token
  Given the following user record
    | access_token           | MTk4Mzc0Mzc2OTE2MDQ0fDhHWnNGOEZrR3NtRGFLVmtVQjNFMkhiclBfTQ== |
  And the uri is "/protected/resource?access_token=MTk4Mzc0Mzc2OTE2MDQ0fDhHWnNGOEZrR3NtRGFLVmtVQjNFMkhiclBfTQ=="
  Then the status code is 200
  Then the content should contain "name"
  Then the content should contain "frank vilhelmsen"
 
