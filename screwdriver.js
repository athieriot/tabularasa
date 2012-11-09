if (Meteor.isClient) {
    Accounts.ui.config({
        requestPermissions: {
            github: ['user', 'repo']
        },
        passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'
    });

    Meteor.autosubscribe(function () {
      Meteor.subscribe('allachievements', Session.get("username"));
    });

    Achievements = new Meteor.Collection("achievements");
    
    Template.badges.achievements = Achievements.find();

    Template.input.events({
       'submit #userform': function(event, template) {
          Session.set("username", template.find("#username").value);
          return false;
       }
    });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    Achievements = new Meteor.Collection("achievements");

    var coderwall = function(username) {
        Meteor.http.get("https://coderwall.com/" + username + ".json", {},
            function (error, result) {
                if (result.statusCode === 200) {
                  _.each(result.data.badges, function(badge) {
                     console.log(badge);
                     Achievements.insert(badge);
                  })
                }
            }
        );
    }

    Meteor.publish("allachievements", function (username) {
        Achievements.remove({});
        coderwall(username);
        return Achievements.find({});
    });
  });
}
