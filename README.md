# Quim

An android quiz app. (that is poorly made, and not even finished yet)

## Usage
### Api
1. Create a supabase project. You can use the `database.sql` file for setting up the database.
2. Write your Supabase API key (anon) with the variable name ``` ANON ```.
3. Open a terminal in the ``` api ``` folder.
4. Run ``` npm run start ``` to start the api server. The server runs on port 3000.

### Application
1. In the file ``` lib/http_request.dart ``` change ``` apiUrl ``` to your api url.
2. Build the app using ``` flutter build apk ``` and install the apk on your android phone.
