# Sending dSYM files to Sentry

If you are using Sentry on your project sending dSYM files can be really helpful. Doing this allows to see more information about crashes and see project code Stack Traces. Sending those files with each new build makes a lot of sense and it can be automated with Fastlane and GitHub Actions! To do that you will need to add sentry plugin to fastlane, add one lane to fastfile, add one step to deployment workflows alongside with SENTRY_AUTH_TOKEN. It might seem like a lot of work, but it really isn't, so lets break each step down:

### Step 1. Add sentry plugin for Fastlane
1. Open Pluginfile in fastlane directory and add one line:

`gem 'fastlane-plugin-sentry'`

2. Run `fastlane install_plugins` in your project main directory.

### Step 2. Get SENTRY_AUTH_TOKEN
1. Open [Sentry Documentation](https://docs.sentry.io/cli/configuration) and Sign in into your account.
2. Sentry allows to generate this token right from documentation, which is really cool. Just scroll down to **To Authenticate Manually:** section and tap on **Click to generate token (DO NOT commit)** in any of examples. You might need to select organization after that, but thats all!
3. Copy SENTRY_AUTH_TOKEN value and add it to your GitHub Action Secrets.

### Step 3. Update Fastfile and deployment workflows
1. There is one line from [Fastfile-Advanced](/resources/Fastfile-Advanced) that should be added to your Fastfile:
* sendDSYM
2. Make sure lane sendDSYM is called at the end of deploy lane.
3. Configure **org_slug** and **project_slug**. You have two options:
* GitHub Actions Secrect (preferred)
* Directly in Fastfile
4. In your deploy workflow file add ENV variables (SENTRY_AUTH_TOKEN, SENTRY_ORG_SLUG, SENTRY_PROJECT_SLUG) to **Build and deploy (env)** step from your secrets (example in [deploy_(env).yml](/resources/deploy_(env).yml)).

### Step 4. Test!
Try running your deployment workflow. After it finished your dSYM files should appear in **Debug Information Files** section in Sentry. URL usually looks like this: https://{org_slug}.sentry.io/settings/projects/{project_slug}/debug-symbols/. 