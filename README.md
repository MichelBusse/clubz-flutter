# Clubz - Flutter App

Clubz - A Cross Platform Social Network App for Events - Flutter Frontend

## Notes

This repository contains the [Flutter](https://flutter.dev/) project for the frontend of the [Clubz App](https://github.com/MichelBusse/clubz). The app supports Android, iOS and web.

To view more information like screenshots and backend code and to discover the live version of the app, go to the [main repo page](https://github.com/MichelBusse/clubz).

## Getting started

1. Install Flutter
2. Clone this repository
3. Rename the `.env.samle` file to `.env` and set all environment variables
4. Run the app with Flutter for android, iOS or web

## Features

### Profiles
- Users can create a profile and follow other users.
- Profiles can be public or private, depending on who should see the profile activity
- Private profiles first have to accept follow requests, while public profiles accept them automatically and are visible to every user by default
- Users can upload a custom profile picture, choose a unique username and set a display name
- Profile pages display all profile information, including a follower count, a count of created events, a score for app usage and the profiles upcoming and past events 
- Users can view the created and attended events of the profiles they follow (and public profiles)

### Events
- Users can create events and share them with their  followers or other social media
- Various information can be added to events, including  name, image, start and end time, location, description and highlighted key information like dress code, ticket prices and age policy
- Users can choose to list their created events in their profile, while listed events by public profiles are visible to all users of the app
- Users can express their interest by attending or saving events, which can then be viewed by their followers 

### Feed
- Users get a personalized view of relevant events in their feed, depending on their location, the current time and the profiles they follow
- The feed can be filtered by city and radius

## App Security
- Permissions and rules for individual users (like which profiles and events a user can view and query) are managed by custom row level security rules for Supabase and Postgres