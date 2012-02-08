#Oauth 2.0 Content API POC  
=============================

#Facts on the internet - security issues

40% of twitter users have more than one account. 
Facebook only what you to have one account, for the entire web. 
95% of private homes has one shared computer profile to more than one user. 
100% thinks that phones is a personal device, and you don't have to login. 
There is a direct correlation between password strength and resuse. 
The most common password, by far, is 123456 and it is used for 6 websites per user.


#Aspect

This POC describes how to publish an REST based Content API to the outside world by implementing OAuth 2.0 as authorization service.

#Disclaimer

OAuth 2.0 is not a complete specification and several companies have implemented their own interpretation. OAuth specify a method to perform the "Authorization" but is often used as a mechanism to "Authentication" (see definition below)

* Authorization = to give permission (OAuth2.0)
* Authentication = to ensure identity (SAML - OpenID - SSO)

OAuth 2.0 requires that any resource can be accessed via HTTPS

The OAuth 2.0 Authorization Protocol: http://tools.ietf.org/html/draft-ietf-oauth-v2-22

This POC is includes two type of OAuth flow - Two legged access token and tree legged access token. 

This means that it is possible to login via a system or for example a Javascript client.

Access tokens are credentials used to access protected resources. An access token is a string representing an authorization issued to the client. The string is usually opaque to the client. Tokens represent specific scopes and durations of access, granted by the resource owner, and enforced by the resource service and authorization service.


#What is OAuth 2.0
===================

OAuth 2.0 is a standard that describes how clients can share a resource, without sharing your username and password. OAuth allows users to distribute token's (tokens) instead of credentials to their service provider. Each token allows access to specific resources such as a websevice or album in a defined period eg, the next 2 hours. This allows the user to a third party application access to data stored at another service provider without sharing sensitive information.


## Protocol flow
    
    ------------------------  
    |       Client         |  
    |      Customer        |  
    |                      |  
    ------------------------  
           |    ^
           A    H
           |    |
    ------------------------               ---------------------
    |                      |  ---- F ----> |                   |
    |   OAuth 2.0 Client   |               |  Resource Service |
    | Web app/agent-based  |  <--- I ----- |                   |
    |    confidential      |               |                   |
    ------------------------               ---------------------
           |    ^                                |    ^
           B    E                                G    H
           |    |                                |    |
    -------------------------              ---------------------
    |                       |  <-- D ----  |                   |
    |    Authorization      |              |   OAuth Service   |
    |       Service         |  --- C --->  |                   |
    |                       |              |                   |
    -------------------------              ---------------------          
    

Thist flow illustrated describes the interaction between roles in the following steps:

 + A. a client invokes a call to a webapplication or user-agent based client application
 + B. the clint is been send to authorization endpoint
 + C. the authorization service login the user and requests a access_token
 + D. the OAuth validates OAuth application registration and the saves the authorizated user
 + E. the authorisation serve a OAuth access_token to the client application 
 + F. the client application invokes an resource with the access_token
 + G. the resource validates access_token in the OAuth resource
 + H. the acccess_token can be valid or invalid
 + I. the resource service serves data on specific user 
 + J. the client application presents data

A confidential Web application or an agent-based application is one who has done a conducted a successful registration with the authorization service and is been validated by a personal moderator intervention. 


## Roles   

 * Resource Service - An entity capable of granting access to a protected resource. 
 * OAuth 2.0 Client - An application making protected resource requests on behalf of the authorised client.
 * OAuth Service - An service for passing and validating the access_token.
 * Authorization Service - The service issuing access tokens to the client after successfully authenticating. 
   - Moderator proces" - An service to allow registration of applications and endpoints. (confidential)


#Authorization Provider 


Authorization Provider consists of The "Authorization Service" and the "OAuth 2.0 Service", wicth is responsible for exposing authorization and OAuth 2.0 protected resources. 
The configuration involves establishing the OAuth 2.0 clients that can access its protected resources on behalf of a user. The provider does this by managing and verifying the OAuth 2.0 tokens that can be used to access the protected resources. Where applicable, the provider must also supply an interface for the user to confirm that a client can be granted access to the protected resources (i.e. a confirmation page).


##Managing OAuth 2.0 Clients

The entry URI point to managing oauth clients is in the companys custom authorization proces '/company/authorize'
All client details is pulled from 


##Managing Tokens

The entry URI point to managing oauth tokens is in the OAuth Service proces '/oauth/access_token'

* When an access token is created, the authentication must be stored so that the subsequent access token can reference it. 
* The access token is used to load the authentication that was used to authorize its creation.


#Authorization Provider Implementation

The provider role in OAuth 2.0 is split between the Authorization Service and the Resource Service. The requests for the tokens and access to protected resources are handled by Clojure compojure wrapper or Servlet web.xml filter, 



### Authorization Service

POST curl -i "http://known:customer@10.73.21.82:4567/company/apps/registering
{
  "appname":"OAuth 2.0 Demo application",
  "email":"fv@frankvilhelmsen.com",
  "siteuri":"http://oauth.frankvilhelmsen.com/authenticated"
}

>HTTP/1.1 401 Unauthorized

> Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
  {
   Oauth Authentication: Application
   Pending    : Waiting for verification
   Email      : fv@frankvilhelmsen.com 
   App ID     : 198374376916044 (reqeust_id)
   App Secret : 37258968804049145bea92056ddae960 (request_secret)
   App URI    : http://frankvilhelmsen.com/authenticated (request_uri)
   UserId     : User bind ident
   Roles      : {custom company profile}
}

The authorization Service is holder of OAuth 2.0 Clients datasets and with a moderator process to approve each OAuth 2.0 client request. 

The anthorisation service calls the oauth 2.0 service to obtain the access token and to place the company's customer profile so it is possible to access a personal profile when the service validate the access token authenticity. It is also possible to extract profile data, fx role on the basis of the access token. The lifespan on the access token and the personal profile is the same in the OAuth 2.0 Service.  


### OAuth Service

GET curl -i "http://known:customer@10.73.21.82:4567/oauth/access_token?client_id=19837i4376916044&client_secret=37258968804049145bea92056ddae960&grant_type=client_credentials"
< HTTP/1.1 200 OK 
< Content-Type: text/html;charset=utf-8
  access_token=198374376916044|8GZsF8FkGsmDaKVkUB3E2HbrP_M


### Resource Service

GET curl -i 10.73.21.82:4567/protected/resource?access_token=MTk4Mzc0Mzc2OTE2MDQ0fDhHWnNGOEZrR3NtRGFLVmtVQjNFMkhiclBfTQ==
>HTTP/1.1 200 OK

If the commercial service need to pick specific customer related data it is possible to load the customer profile from the authentication proces and save a temporary copy in the OAuth component. With respect to scaling there will excite a copy on each physical JVM in a clusted environment.

note: that the access_token handel is not the same token witch can be validated positive in the resource service. A access token key can be divided into several regions and are separated by more (|) signs which can't be enclosed in a uri. Therefore, the client application, has to base64 encode before inserted. 


#OAuth 2.0 Client

Confidential OAuth 2.0 Client in the sense that OAuth 2.0 Client is known in the authorization service. 
The OAuth 2.0 client application is responsible for access the OAuth 2.0 protected resources on various servers. 
The configuration involves establishing the relevant protected resources to which users might have access. 
The client application needs a mechanisms for storing authorization codes etc. [Link to the spec]


##Managing Protected Resources 

The entry point URI to resources is '/protected/*' defined by the Resource Service. Look into the Content API dokcmentation for details.
The OAuth 2.0 Client service has to obtain and manage OAuth 2.0 tokens for specific users. To access the OAuth 2.0 Service you must has permission by authorization service. 


##Client Configuration

OAuth 2.0 client configuration mandatory parameters to obtain an access_token. 

Two legged token    ['client_id', 'redirect_uri','response_type' ]
Tree legged token   ['client_id', 'client_secret', 'grant_type']

##Protected Resource Configuration

Protected resources should be defined i the client application: 

* id: The id of the resource. The id is only used by the client to lookup the resource; it's never used in the OAuth protocol. 
* type: The type (i.e. "grant type") of the resource. This is used to specify how an access token is to be obtained for this resource. 
  - Valid values include "authorization_code", "password", and "assertion". Default value is "authorization_code".

* client-id: The OAuth client id. This is the id by with the OAuth provider is to identify your client.
* client-secret: The secret associated with the resource. By default, no secret will be supplied for access to the resource.
* access-token-uri: The URI of the provider OAuth endpoint that provides the access token.
* user-authorization-uri: The uri to which the user will be redirected if the user is ever needed to authorize access to the resource. 
  - Note that this is not always required, depending on which OAuth 2 profiles are supported.


##Accessing Protected Resources

Once you've supplied all the configuration for the resources, you can now access those resources.


#Considerations

Design takes into account several factors. Listed here is some properties used for relative weighting design principles. 

* Framing. Often the customer validation a time consuming process, hence the focus on "protecting systems"
* Scalable. Often the customer segment an unpredictable factor, hence the focus on "individual and scalable processes"
* Security. Often, permission to systems is complex, hence the focus on "simplicity in application layout"
* Usability. Often the user experience reduced when new functionality is added, therefore the focus is "only necessary steps".


#OAuth 2.0 Client code

Tree legged token (see features/features.feature) 
Two legged token (see views/index.erb )


#Running and testing the POC

Requirements
------------
Ruby and Cucumber

Testing
-------
$> cucumber 

Running
--------
$> ruby run-app.rb



