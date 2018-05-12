# TryingNewFlutterProject

A try for a [Flutter](https://flutter.io/) project.

Trying to apply Clean Architecture as I could.
It was a small experiment using [OpenWeatherMap](https://openweathermap.org/) API


## What it demonstrate:

 - The functional nature of Flutter, you _*Create A NEW WIDGET EVERY STATE CHANGE*_ , but it couldn't be called fully functional, because the change of the state itself is in place.
 - A simple, one file, Dart applicable, application of Clean Architecture
 - Using checking instead of `try/catch`
 
## TODO:

 - Use Async and Await mechanism of Dart, still didn't try it in a Flutter app.
 - Try to make a list view (no real application is just text and label).
 - Unit Testing.
 - Use dependency injection to inject Repository into the Presenter.
 - Improve design (graphical).
 - Privatise some variables and functions, the functions and variables in Dart are made by just an underscore before the name,  somewhat like Objective-C.
 - Use another JSON deserializer, and maybe another TextField `TextFormField`.
 
# DISCLAIMER:

I DON'T CLAIM THAT THIS IS A GOOD EXAMPLE OF USING FLUTTER, IT MAY HAVE A LOT OF FLUTTER FLAWS, AND THERE IS MORE THAN ONE KNOWN ARCHITECTURE ISSUE.
