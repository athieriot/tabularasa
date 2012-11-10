if Meteor.isClient
    Achievements = new Meteor.Collection("achievements")

    Meteor.autosubscribe () ->
      Meteor.subscribe 'userachievements', Session.get("username")
    
    Template.badges.achievements = Achievements.find()

    Template.input.events {
       'keyup #username': _.debounce (event, template) -> 
            Session.set "username", template.find("#username").value
          , 300
       }

if Meteor.isServer
  Meteor.startup () ->
    Achievements = new Meteor.Collection("achievements")

    Meteor.publish "userachievements", (username) ->
        Achievements.remove {}
        coderwall(username)
        Achievements.find {}

    coderwall = (username) ->
        Meteor.http.get "https://coderwall.com/" + username + ".json", {},
            (error, result) ->
                if result.statusCode is 200
                  for badge in  result.data.badges
                     do (badge) ->
                        Achievements.insert(badge)
