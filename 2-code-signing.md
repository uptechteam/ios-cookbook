# Code Signing with `match`

When we want to distribute the application build, usually we have two options which development account to use:

- use client development account if he has one;
- use our own copmany-wide development account otherwise.

![](https://codesigning.guide/assets/img/cs-the-problem.png)

In both cases we have a bunch of problems:

- we have have separate code signing identities for every member. This results in dozens of profiles including a lot of duplicates;
- maximum amount of distribution certificates are limited by 3;
- we need to manually renew and download lates provisioning profile every time we add a new device or certificate expires;
- setting up a CI machine requires spending a lot of time.


### *match* to the resque!

[*match*](https://docs.fastlane.tools/actions/match/) is an awesome tool from fastlane suite that makes our life 10x easier. *match* can generate, store and install actuall valid development certificates with one command. To start using it you'll need an access to the development account and access to our certificates repository.  

*Please ping me (@arthur) in Slack if you don't have access to any of those.*

### Basics

Install *match* with

```
[sudo] gem install fastlane -NV
```

To integrate *match* into a new project

```
fastlane match init
```

To generate or download valid certificates and provisioning profiles

```
fastlane match development
fastlane match adhoc
fastlane match appstore
```

If you don't want *match* to generate any new certificates or revoke previous ones run those command with flag `readonly`.

After that, you can select match-generated provisioning profiles for signing in Xcode. Usually they have prefix `match`.

### Things to consider:

- If the app contains several targets, you can generate certificates for all of them at once after setting all of the `app_identifier`s in the `Matchfile`
- Don’t set the provisioning profile in your Xcode project to Automatic, as it doesn’t always select the correct profile.

### Matchfile example

```
git_url "url_of_our_cerfificates_repo"
app_identifier ["com.uptech.App", "com.uptech.AppDevelopment", "com.uptech.AppStaging"]
username "name_of_company_used_account@uptech.team"
```