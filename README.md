# Dunnit2

Motivation:
We are currently living in a pandemic which has affected everyone’s lives. It is more important than ever to stay on top of things we do everyday: tasks, routines, jobs, school, etc.; time management is a big one as it helps us be efficient and productive at the same time. As college students, it is our responsibility to stay on top of classes and assignments while adapting to changes in how lesson plans are taught to us. By creating an app that replaces sticky notes, forgetful memories, and agendas, our tasks app allows for a quick and easy way to know what exactly needs to be done on a day to day basis; unlike other task tracking apps, ours is developed based on our experiences as students to design with everything we need and nothing we don’t need as we noticed that other task apps are bloated with too many features. Hence, we introduce Dunnit.  

Description: 
An iOS application that is intuitive and easy to use
Users can create multiple task lists when they logged in.
Lists of tasks can be shared to other users.
Implemented sorting and filtering system to view tasks according to certain criteria.
Setup a guest mode for new users to try the app
Enabled notifications, dark theme, and other advanced features.

Design:
Our product will be an iOS application where users will create an account to make tasks and lists as well as sharing with other users. To do this, we will be implementing a client-server model using Model-View-Controller design along with a database to contain user data and their interactions within tasks and lists. Clients will communicate to the server through API calls. The server will handle multiple clients making requests to the server to interface with the database. It will send response data back to the client to receive the updated information from the server based on the actions a user does. 

External APIs: 
We will need to integrate Facebook and Google Login so that users can easily sign in using those credentials.  
