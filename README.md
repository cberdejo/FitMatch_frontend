# FitMatch Frontend

This repository contains the frontend code for a TFG which emulates a platform designed to allow users to track their workouts, allowing users to find the perfect match for their fitness goals.

## Table of Contents

- [Features](#features)
- [Design and User Experience](#design-and-user-experience)
  - [Adaptability to Devices](#adaptability-to-devices)
  - [Color Themes (Dark/Light Mode)](#color-themes-darklight-mode)
- [Screen Structure](#screen-structure)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Usage](#usage)
  - [Running the App](#running-the-app)

## Features

FitMatch is a *web platform for planning and monitoring sports training routines and diets, developed by **Christian Berdejo Sánchez* as a Final Degree Project (TFG) at the University of Málaga.

### Key Features

- *User-Friendly Interface*: Easy and intuitive navigation for all users.
- *Profile Creation and Management*: Ability to create and edit detailed profiles for both users seeking guidance and trainers offering services.  
- *Exercise Management*: Capability to add, view, and organize a catalog of exercises.  
- *Workout Creation and Sharing*: Tools to build personalized training routines and the option to share them with other users or clients.  
- *Notification System*: Receive important reminders and updates directly within the application.  

---

## Design and User Experience

FitMatch has been designed with a strong focus on *usability and accessibility*. The interface aims to be intuitive, facilitating smooth navigation for both users and trainers.

### Adaptability to Devices

The frontend platform is built with *Flutter*, which ensures a consistent user experience across different screen sizes. While the current README focuses on local execution, the codebase is prepared to adapt layouts for mobile devices, tablets, and desktops if compiled for those platforms—maintaining a functional and pleasant arrangement.


### Color Themes (Dark/Light Mode)


To enhance visual comfort and allow for personalization, the interface may include support for different *color themes*, such as light and dark mode. This allows users to choose their preferred appearance—reducing eye strain in low-light environments with dark mode or improving readability in bright settings with light mode.



---

## Screen Structure

Based on the implemented features, the frontend is structured into several main screens that allow users to interact with the platform:

- *Home Screen (Dashboard)*: The first screen after login, showing an overview of activities, recent notifications, or quick access to key sections.  
  (Screenshot suggestion: Main screen or dashboard)
- *Authentication Screens*: Login and registration screens for users and trainers.  
  (Screenshot suggestion: Login or registration screen)
- *Profile Screens*: Views for editing and displaying user or trainer profile information (including potentially viewing other profiles if a match feature exists).
- *Exercise Management Screens*: List of exercises, detailed view of a single exercise, and forms to add/edit exercises.
- *Workout Screens*: List of workouts, workout builder/editor, and detailed workout views.
- *Notification Screen*: List of all received notifications.


## Technologies Used

- *Flutter*: Framework for building cross-platform mobile applications
- *Dart*: Programming language optimized for building mobile, desktop, server, and web applications

## Installation

To get a local copy up and running, follow these simple steps:

1. Clone the repository:
    sh
    git clone https://github.com/cberdejo/FitMatch_frontend.git
    

2. Navigate to the project directory:
    sh
    cd FitMatch_frontend
    

3. Install dependencies:
    sh
    flutter pub get
    

4. Run the app:
    sh
    flutter run
    

## Usage

You need a back end. Here there is an example you can use:

https://github.com/cberdejo/FitMatch_backend




### Running the App

To run the app on a connected device or emulator:
```sh
flutter run
