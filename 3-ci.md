# CI/CD

Continous Integration is an important part of our development process. It allows us to move fast and be confident in our code. We tend to use [fastlane](https://fastlane.tools) and [CircleCI](https://circleci.com) for the continuous integration.

## Workflow

Usually, we have three types of application configurations: Development, Staging, and Production.

- we use a Development configuration when we build locally on our machines;
- we deploy a Staging build on every merge to the `develop` branch;
- we deploy a Production build on every merge to the `master` branch.

## How to setup CI/CD for your project

### 1. Purchase the CircleCI [**SEED**](https://circleci.com/pricing/#build-os-x) plan. 
This will be enough for the project with 1-2 devs working on it.


### 2. Setup fastlane for your project.

fastlane is a shortcut for day-to-day developers tasks. It saves our time by automating the boring things like building and deploying the app or adding a device to the developer profile.

fastlane scripts are written in Ruby. The main file is called **Fastfile**. Usually Fastfile consists of several **lanes**. Lane is just a sequence of **actions**, such as `build_ios_app`, `hockey` or `slack`. For more information refer to the [docs](https://docs.fastlane.tools). 

##### Basic Setup

The [basic Fastfile](resources/Fastfile-Basic) contains the minimalistic set of lanes, needed to build and deploy a project on a CircleCI. Lane `test` just builds the project and runs the tests suite. Usually, this lane is run on every push to any branch. Lane `deploy` is a bit more complicated as it has more steps:

1. Retrieve certificates using `match`.
2. Build the app.
3. Deploy an app to the HockeyApp
4. Send a message to the slack channel.

`deploy` lane is run on every merge to the `develop` branch.

##### Advanced Setup

Usually, basic setup is not enough, as we have several application configurations and we deserve to have nice things. In the [advanced Fastfile example](resources/Fastfile-Advanced) you can check typical fastlane configuration used in our projects. There are lanes for running tests, deploying Staging and Production builds, helper lanes for syncing provisioning profiles and adding a new iOS device to the developer profile.

Whoa, a lot of Ruby code! Don't be afraid, it's pretty easy to follow. In addition, setting up the fastlane on the project makes you feel like a cool dev-ops 😎 

Code signing part is described in the [code signing chapter](2-code-signing.md). If you use match there will be no problems, just grant your CI machine SSH access to the certificates repo.

### 3. Configure the CircleCI

CircleCI uses `yml` files for configuration. `config.yml` consists of the **jobs**. Their role is to setup the CI machine before running the fastlane. 

Here is a basic configuration file example - [config.yml](resources/circle-config.yml). It consists of three jobs: `build-and-test`, `deploy_staging` and `deploy_production`. As you can see, "jobs" are just list of instructions, such as pre-install dependencies, restore cache or select the Xcode version.

At the very bottom of config.yml lays description of our `build-test-and-deploy` workflow. It states, that we will run `build-and-test` job on push to every branch **except** `develop` or `master`; we will run `deploy_staging` job on every push to the `develop` only and finally we will run `deploy_production` on the push to the `master` only.

Please, refer to the [config.yml documentation](https://circleci.com/docs/2.0/) for more information about the structure of the configuration file.

### 4. PROFIT 🚀

- we automated part of our workflow;
- our code is always buildable and tests are green;
- the latest executable build is always available to download.
