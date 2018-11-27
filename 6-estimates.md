# How to make Estimations

Estimations is an essential part of the sales process and usually to make a precise estimate the help of a developer is needed. 
The main difficulties are: 
- overestimation may cause the lost of the potential client
- underestimations may bring hard times during the development
- each developer has own development speed

## Guide on how to make Estimates

### Gather requirements and inputs

#### 1. Get to know your client and project 💼.
a. make a quick research or ask the sales representative about the company, their business, missions (read why in [Communication Tips](#communicationtips) section); 
b. their audience since it might be people who may require Accessibility features in the app;
c. review information about the project;
d. ask for required iOS versions, devices needs to be supported (both iPhone and iPad), orientations.

#### 2. Get features list 📜.
The features can be one or more from the list:
1. Written:
* user stories or features list
* detailed specification
2. Visual:
* wireframes
* finished designs
* interactive designs

### Estimate

The result of the estimations is a table with columns: feature, min, avg, max. Where:
+ Feature - is a feature name / user story
+ Min / Max - minimum / maximum estimated time for a feature
+ Avg - average is arithmetic mean of min and max 

#### Step 1. Define and pick a feature
Define the feature that is not relatively big but rather small and can't be broken to a smaller piece. 
For example, a screen like this: 

![](resources/estimates_screenshots/login.png)

can be broken into the following parts:
1. Login using credentials
2. Facebook login
3. Additional Facebook integration (optional depending on existence of other facebook related features)

Note: "Forgot password" feature will most likely have a separate screen for it.

Sometimes it's not possible to break down a relatively big feature, for example implementing a chat or video streaming. In this case the feature can be picked as is.

Finally, after breaking down to smaller features, choose one feature and move to the next step.

#### Step 2. Estimate the feature 

First, define the **complexity** of the feature: easy, 
+ **Easy**: Login, forgot password, FAQ, help screens. Usually, static or dynamic screens, without too complex design, often without networking.
+ **Normal**: Home screen, registration, tables, collections, custom controls. Usual screens with networking, or custom controls.
+ **Hard**: Third-party API integration, audio/video recording, photo capturing, streaming, chatting, custom gestures, synchronization, offline mode.
+ **Extreme**: Usually they’re unclear and huge features. It’s better to divide them into smaller ones.

Use complexity to define the difference between min/max values: the more complex it is the bigger difference.
Why: the effect of different programming speed and seniority level is more visible on bigger features. 

One more thing before giving a final min/max number pay attention to custom things like: animations, sliders, android like [tabs](https://material.io/design/components/tabs.html).

**Estimation time unit**. 
+ hours (Int) - preferred unit for estimations
+ days (Double)

#### Step 3. Include additional hours

**QA/Tests/Fixes.**

Include QA/Tests/Fixes/Management if agreed with client.
Usually QA is 20%, management - 10%, Tests - 20% of total development time.

### Cheat sheets and tips

**Important note**: use this cheat sheet only for rough estimates during sales process, which means - we are not committing to this budget/timeline, but just giving the client general price range. Also, don’t make it too high, since we need to sell it too :) 

Cheat sheet for complexity and min/max hour values:

| Complexity | Min | Max |
| ---------- | --- | --- |
| easy       | 2   | 12  |
| normal     | 8   | 24  |
| hard       | 24  | 100 |
| extreme    | 50  | 300 |

Cheat sheet for common features:

| Feature                                                               | Min | Max | Comments                                           |
| --------------------------------------------------------------------- | --- | --- | -------------------------------------------------- |
| CI setup                                                              | 8   | 16  | might be not initial setup but through the project |
| Project setup                                                         | 4   | 16  | might be not initial setup but through the project |
| Chat (no lib)                                                         | 80  | 120 | of course it also depends on chat features         |
| Chat (with our lib)                                                   | 20  | 40  | of course it also depends on chat features         |
| Social network login / sharing                                        | 4   | 8   | per each feature                                   |
| Payments system integration                                           | 8   | 24  | a lot of time goes to communication / researching  |
| Image picker (default)                                                | 2   | 4   | n/a                                                |
| Image picker (custom)                                                 | 16  | 24  | n/a                                                |
| Image cropper ([lib](https://github.com/ruslanskorb/RSKImageCropper)) | 4   | 8   | n/a                                                |
| Image cropper (custom)                                                | 24  | 40  | n/a                                                |
| Internatialization                                                    | 8   | 16  | can be more if it's ؁ؓؑ  ؐ  ؕ  (arabic)            |
| Photo Camera (custom)                                                 | 24  | 40  | capture, focus, zoom                               |
| Video Camera (custom)                                                 | 40  | 60  | simple video shooting                              |
| Video Camera (lib)                                                    | 16  | 32  | simple video shooting                              |
| Video Player (custom)                                                 | 24  | 32  | for a player with controls like default has        |
| Simple networking using our [lib](https://github.com/Moya/Moya)       | 4   | 8   | n/a                                                |
| Complex networking w multipart requests and/or websockets             | 16  | 24  | n/a                                                |

###  Beware of pitfalls

When you are trying to make a precise estimate make sure to think of different small details that in total may result in a very time consuming feature.
As an example, a table view that usually takes place on almost every screen can be not just a simple list but also have such pitfalls:
+ Design cells (which can contain a lot of information and extra buttons and have flexible content depending on height).
+ Loading data (send requests to the server, parse response, create data models)
+ Loading more, pull-down-to-refresh.
+ Showing loading, empty, and error states (like connection errors).
+ Adding/removing items from the table. In my experience, removing items from the table can be very tricky—many apps crash due to data inconsistency.
+ Merging content. Sometimes you will need to merge local content with data from the server.
+ User interaction when tapping on the cell itself or on a button on the cell (usually the background changes to indicate the selected state and a new screen opens).
+ Image caching for pictures in cells (if any).
+ Nice animation when cells appear on the screen while scrolling (image fading or light bouncing, depending on the project style).

More examples [here](https://github.com/stanfy/ios-components-bikeshedding)

### Special cases

**We do include supporting dev services:**
- CI setup
- Crashlytics
- Analytics services
 
**Consider Localization.**
Often times clients don't mention if they need to support multiple languages.

**Consider reusability (optional).**
If you see that there are 5 screens with the same UI but different data, make sure to separate one feature to be "Generic/reusable table" which for example may take  10 hours, but screens will take much less than if they would be done from scratch. This also shows the quality and proficiency of the developer to the client (client can also be a tech person). 

**Hardware ⌚️ and IOT.**
In case the hardware is involved we should carefully do the research and see if there are documentation (in English) available, how popular hardware is, if community used it and discussed before. 

**R&D features.**
Some projects have features that we can't evaluate easily and require additional research. And it is normal to add R&D time into the feature estimation or break it down into 2 separate features: "research on feature implementation" and "feature implementation". R&D is crucial to make a right decision that later in time won't require re-coding a feature or changing the tech approach. Examples of such features can be: integration with not very well documented / popular library or API, implementing a just announced API by Apple.

### Example

Here is an example of one of the estimates of iOS app:
![](resources/estimates_screenshots/estimates_example.png "Estimates Example")


## Communication Tips 📝 <a id="communicationtips"></a>

Sometimes we tend to underestimate the estimation stage of the sales process. This stage is one of the stages where a developer can be actively involved to: 
+ suggest better solutions using professional knowledge (e.g. use tab bar instead of a slider menu)
+ upsell some feature (e.g. biometric authentication)
+ show attentiveness and involvement by asking questions (e.g. "should there be screen_name screen, since it's seems we are missing it as a part of Signup flow?")
+ show expertise

Doing so can dramatically influence the sales impact and client's opinion on who we are and whether to work with us. Since it shows that we are proactive, attentive, smart, experts and so on 🤓.

## Summary ⛳️
Estimations is an important stage at which we can show the potential client who we are. And yet it's a fun experience to live through the app in an hour or two and get to know some interesting business idea or future hyped startup 🚀.
