# Recipedia

# Overview
A Flutter app with Supabase authentication built from scratch. This app serves as a starter project for learning Flutter and integrating backend services using Supabase. Users can sign up, log in, and be routed to a home screen that welcomes them and allows logout. The app uses email/password authentication, auth-aware routing, and is designed to run on Android and web. To get started, install Flutter (>=3.4.0), clone the repository, run `flutter pub get`, and then `flutter run`. In `main.dart`, replace the Supabase credentials with your own from the Supabase dashboard, and ensure email authentication is enabled. The codebase is structured with clear separation between authentication logic and UI pages for easier learning and scalability.

# Running
 - For the backend run the following in the terminal:
    cd backend
    ./run.sh
 - For the frontend run the following in the terminal:
    cd frontend
    flutter run
    2

# Enviornment Variables
 - Add the following enviorment variables to the .env file
    SUPABASE_URL
    SUPABASE_ANON_KEY
    FLASK_BACKEND_URL
    PEXELS_API_KEY
test
