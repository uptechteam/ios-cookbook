# Slack Application Setup for zip archive sending

In case QA on your project is asking you to send them ipa file alongside with deploying builds to TestFlight, you came to right place! Fastlane and GitHub actions can make this process automated. To achieve that, you will need to create Application for Slack, create channel in Slack where zip archive with ipa file will be sent to, add Application you created to this channel and update deploy workflows alongside with Fastfile. It might seem like a lot of work, but it really isn't, so lets break each step down:

### Step 1. Creating Slack Application

1. Open [Slack Application storage](https://api.slack.com/apps) and Sign In with your Uptech Slack account.
2. Create New App.
3. Fill out **Display Information** in **Basic Information** section.
4. Navigate to **Scopes** in **OAuth & Permissions** section and add two scopes:
* files:write
* incoming-webhook
5. Navigate to **Installed App Settings** section and make sure App is installed into Uptech Workspace.
6. While you are still in **Installed App Settings** section, grab Bot User OAuth Token. This token is needed for workflow to send messages. In [3-ci.md](/3-ci.md) this key corresponds to  SLACK_API_TOKEN secret.

### Step 2. Create channel in Slack

1. Open Slack as you normally do.
2. Tap on **Channels** -> **Create channel**.
3. Proceed with **Blank channel**.
4. Name it similar to your internal project channel name with "ios-builds" added at the end. This will help you and your team easilly find this channel.
5. Make it Private.
6. In **Apps** section tap **Add apps**.
7. Add app you created in previous step.
8. Navigate to Channel you created in this step.
9. Tap on Channel name on top to open modal window with settings for this channel.
10. Navigate to **Integrations** tab.
11. Tap **Add apps** and select app you created in previous step.
12. Navigate to **Members** tab and add QA and other team members that might need builds or information about deployment process finishing.
13. Navigate to **About** tab and copy **Channel ID**. This id is needed for post_zip lane in Fastfile. You can add it there or through GitHub secrets.

### Step 3. Update Fastfile and deployment workflows

1. There are two lines from [Fastfile-Advanced](/resources/Fastfile-Advanced) that should be added to your Fastfile:
* create_zip
* post_zip
2. During adding those lanes to your Fastfile depending on how you chose to handle **Channel ID** you might add it to Fastfile directly. If you chose to add it via Secrets, dont forget to add it as ENV variable in workflow file.
3. Add two steps to your deployments workflow files (from [deploy_(env).yml](/resources/deploy_(env).yml)). Names of those steps are:
* Create zip
* Send zip to Slack
4. Add SLACK_API_TOKEN secret to GitHub Action Secrets
5. If you chose to add **Channel ID** as GitHub Action Secrets, add it as environment value in **Send zip to Slack** step

### Step 4. Add helper script
1. Just add [custom_slack_upload.rb](/resources/custom_slack_upload.rb) to your fastlane directory. 

### Step 5. Test!

Try running your deployment workflow. After it finished, you should see message in Channel you created in Step 2 from Application you created in Step 1.
