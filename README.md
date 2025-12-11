# Facebook Post to Page

The goal of this project is to show an example of Ruby code
that can create a Post on a Facebook Page that a user of your
code that has the required permission.

Use the code here to implement in any web-based Ruby code. I first implemented the code using Rails but I'm using Roda here to keep the code small.

Be aware that there are 2 "apps" here.
1. The "Facebook App" is a collection of configurations that live on the Facebook platform.
2. Your application that uses the credentials provided by Facebook to interact with their platform. For this project, it is the code in this repository.

Let me know if there's any confusion in this documentation between the two.

## Facebook Setup
**Verified on 2025-12-11**

This is one possible way to set up your app that will work with this code.
If you are a beginner, I suggest you stick to this script for your first Facebook app.

### Create the app
1. Create a developer account here: https://developers.facebook.com/
1. Visit https://developers.facebook.com/apps/
1. Click "Create App".
1. On the "App details" tab, give your app a name, audit your contact email address, and click Next.
1. On the "Use cases" tab, under "Filter by", select "Other", then select "Create an app without a use case", and click Next.
1. On the "Business" tab, select "I don't want to connect a business portfolio yet." and click Next.
1. On the "Requirements" tab, there should be nothing to do. Click Next.
1. On the "Overview" tab, review the settings and click "Go to dashboard".

### Add use cases
1. Click "+ Add use cases"
1. Under "Filter by", select "Content management"
1. Click "Manage everything on your page", click Save. An alert will appear notifying you of extra steps. "Facebook Login for Business" now appears on the left menu.
1. Once that use case appears on the list, click "Customize", ensure at least "pages_manage_engagement", "pages_manage_posts", and "pages_show_list" are added.

## App Setup
### Collect credentials
1. From the dashboard for your app, select "App settings" -> "Basic".
1. `cp sample.env.rb .env.rb`
1. Capture your "App ID" and "App secret" and edit `.env.rb` with those values.

### Install gems
1. `bundle install`

### Make it go
1. `rackup`
1. Visit `http://localhost:9292` in your browser.
1. Click "Login with Facebook".
1. Facebook will show you the requested permissions and allow you to accept or decline.
1. After authenticating, Facebook will redirect your browser back to the app.
1. The app will request a list of Pages you have access to and allow you to select one.
1. Select a Page from the dropdown and click Submit. You're now set to create a Post.

## Facebook responses

### Errors
* If Facebook shows "Invalid App ID", you have likely not set `ENV["FACEBOOK_APP_ID"]`
  correctly. Check `.env.rb` and try again.
* You may get a notice that you are required to identify yourself. You'll need to access
  the Page you have rights for, and confirm your identity there.
* Facebook automatically allows your redirect URL to route to `localhost`, but for use
  in a "real" app, you'll need to set allowed domains or redirect URIs.

