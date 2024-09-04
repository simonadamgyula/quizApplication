# Quim

![Screenshot 1](https://github.com/simonadamgyula/quizApplication/blob/1eba4c4d50771f8b817d8edbd74379c7c3219d7c/screenshots/Screenshot_2024-07-29-22-27-22-471_com.example.quiz_app-edit.jpg) | ![Screenshot 2](https://github.com/simonadamgyula/quizApplication/blob/1eba4c4d50771f8b817d8edbd74379c7c3219d7c/screenshots/Screenshot_2024-07-29-22-28-03-843_com.example.quiz_app-edit.jpg) | ![Screenshot 3](https://github.com/simonadamgyula/quizApplication/blob/1eba4c4d50771f8b817d8edbd74379c7c3219d7c/screenshots/Screenshot_2024-07-29-22-28-45-786_com.example.quiz_app-edit.jpg)
:------------------------------------------------:|:-------------------------------------------------:|:--------------------------------------------------------------:

An android quiz app made in flutter. Unfortunately I cannot host the api, so if you want to try it you have to run it yourself.

## Installation
### Api
1. Create a supabase project. You can use the `database.sql` file for setting up the database.
2. Write your Supabase API key (anon) with the variable name ``` ANON ```.
3. Open a terminal in the ``` api ``` folder.
4. Run ``` npm run start ``` to start the api server. The server runs on port 3000.

### Application
1. In the file ``` lib/http_request.dart ``` change ``` apiUrl ``` to your api url.
2. Build the app using ``` flutter build apk ``` and install the apk on your android phone.
