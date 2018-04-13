## Setting up application to run 

- In the application direction run ``pod install``
- Open **Search Nearby.xcworkspace** 
- Open **AppKeys.plist** file inside Search Nearby/Resources folder, and fill in the values for client_id and client_secret. 
- Run the app


*Note: This app logins to FourSquare using Oauth. The redirect uri for Oauth callback, is specific to this application. So, if you want to have different client\_id and client\_secret, make changes to url scheme as well.*
