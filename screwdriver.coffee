if Meteor.isClient
    Accounts.ui.config {
        requestPermissions: {
            github: ['user', 'repo']
        },
        passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'
    }

    Meteor.autosubscribe () ->
      Meteor.subscribe 'userachievements', Session.get("username")

    Achievements = new Meteor.Collection("achievements")
    
    Template.badges.achievements = Achievements.find()

    Template.input.events {
       'submit #userform': (event, template) ->
          Session.set "username", template.find("#username").value
          false
       }

if Meteor.isServer
  Meteor.startup () ->
    Achievements = new Meteor.Collection("achievements")

    coderwall = (username) ->
        Meteor.http.get "https://coderwall.com/" + username + ".json", {},
            (error, result) ->
                if result.statusCode is 200
                  for badge in  result.data.badges
                     do (badge) ->
                        Achievements.insert(badge)

    Meteor.publish "userachievements", (username) ->
        Achievements.remove {}
        coderwall(username)
        Achievements.find {}
