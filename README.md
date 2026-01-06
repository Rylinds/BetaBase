NOTE: The app’s route data is sourced from github: OpenBeta/climbing-data. This data was
cleaned and imported into firestore using python scripts to have 5,000 routes available to be
searched for in the app.
Function:
This app, BetaBase, functions as a climbing database where users can create an
account, search climbs, mark them as done (ticked), and/or save them to a to-do list.
Routes have information regarding their type, difficulty, location, and description that can
help users learn more about climbs.
Dependencies:
App build dependencies:
- Xcode version: 16.4
- Swift language version: Swift 5
- Dependencies: FirebaseAuth, FirebaseFirestore
Usage Info:
The app has a minimum deployment of iOS 18.5 and only operates in portrait mode
(app was tested with an iPhone 16 pro). Firestore is populated with imported data for
the route search function, so new users can create accounts and populate their climbing
lists.
However, this account is not necessary to get the full experience of the app. New users
can make equivalent climbing lists if desired. Please note that the userID requires the
input to be an email (ex: @email.com), not just a user name (there are also some
simple character length requirements for the password).
For notifications, a user will get a congrats message for every 5 climbs they tick. The
notification has an 8 second delay to give testers a chance to see it on the home
screen. These notifications can be toggled on and off from the settings view. Notification
permissions are only requested upon the initial launch of the app. This means that
permissions are not unique to the user, only to the iPhone it’s installed on. The toggle
‘mutes’ the notification.
