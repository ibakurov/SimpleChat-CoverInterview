# Cover Interview Assignment

## What have changed

1. The project has been converted to Swift 4
2. The project folder structrure has been updated
3. Project has been updated to use MVC model
4. Unit tests and Integration tests were aded to the project
5. No other third-party libraries were introduced
6. All View controllers were rewritten with the appropriate use of extensions for decoupling the Viewcontroller class to allow more developer to work on multiple features inside of one ViewController at the same time
7. Camera integration was added to the ChatViewController


## Architecture

All View Controllers were separated from the model and API layers.

Protocols were introduced for API implementation. Every API implementation class implements the according protocol. This defines what kind of backend architecture is needed to support the project, and if the decision is made to replace Firebase  with other backend system, no rewrite of View Controllers is required. All API objects are singletons, because they should not exist in different versions through out the app.

ChannelListViewController has been decoupled from the CreateChannelCell by removing a direct button interaction. Create channel button interaction has been moved to CreateChannelCell, and delegate is introduced to let the ViewController know when it should create a new channel. CreateChannelCell does not make any direct calls to a backend, only ChannelListViewController does.

ChatViewController has been rewritten to decouple backend logic and UI, as well as simplify code and improve readability. Support for taking pictures with camera was added as well. It can only be used on a real device.

There was one model introduced: Profile. It is a singleton, because we have only one user in the app at one time, and it holds the user id and user name. It was created to pass necessary information to the ViewControllers, so that the ViewControllers don't communicate with Firebase API directly. This is especially useful, if Firebase API will be replaced at any point in the future, the ViewControllers won't need to be rewritten.

## Testing

There were three types of tests introduced. Unit tests to test the protocol level of the API, Integration tests to test Firebase integration into the project, and UI tests to test UI error handling and transitions.

For Unit testing there were stub API implementations generated, to mock the connection with a backend and callbacks from a backend. The test classes cover most of the possible success and failure situations that may occur when communicating with a backend.

For Integration testing the Firebase API implementation from the project was used directly to test authentication of the user, creation of channels, sending of messages and typing status changes. Both Database and Storage integrations are tested by the Integration tests.

For UI testing the defualt Xcode UI testing tool was used, where the interaction with the UI elements is recorded.

To run tests from the CLI use this command while being in the project's root folder:
```
xcodebuild -scheme ChatChat -workspace ChatChat.xcworkspace/ -destination 'platform=iOS Simulator,name=iPhone 8,OS=11.2' test
```
Because there are UI tests, it requires to actually run through them on the simulator, so this command will launch simulator.

## Project Targets

I duplicated ChatChat target to create ChatChatDEV. ChatChatDEV has an Active Compilation Conditions flag set to ENVDEV. I also use Tests targets against ChatChatDEV. All test targets have ENVDEV flag as well. This allows me to create a separate dev table in Firebase for Integration testing purposes, without touching the PROD data.

## Task

For your take home assignment, you're going to be taking an existing code case (https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2) and refactoring it to produce greater modularity, separation of concerns and testability.


1. Read through the tutorial (https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2) and get the app running locally. You'll need to set up a firebase account and project for this. If you need a swift 4 version of the codebase, it can be found here: https://github.com/CoverFinancial/Firebase-Tutorial-Real-time-Chat
2. We want to make the Firebase backend swappable with our own custom backend. To do this, you'll need to introduce protocols that break the concrete dependency on Firebase
3. Introduce an application architecture that you think is best suited for this project (MVVM, MVP, VIPER etc.)
4. Write any unit tests and UI tests that make you confident in the code (hint: you may want to create an in-memory implementation of the protocol(s) you introduced in step 2)
5. Update this readme to explain your architecture, refactoring and testing decisions.

## Notes

* Feel free to introduce any third-party libraries that may be helpful to you. Please explain why you chose them in this readme.
* Add a script to run all the tests from the command line

## What we're looking at

1. Can you read and understand an unfamiliar code base?
2. Can you implement an easy to follow, decoupled architecture?
3. How, if at all, do you leverage third party libraries?
4. Is your code easy to understand and co-worker friendly?
5. Is your code sufficiently tested?
6. Can you clean up and refactor existing code?
