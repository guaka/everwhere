



fb_fetch = (res, req, db) ->
  auth_fb = req.session.auth.facebook
  console.log "FB auth: " + req.session.auth.facebook
  FB.setAccessToken auth_fb.accessToken
  FB.api
    method: "fql.query"
    query: "SELECT uid, name, hometown_location, current_location FROM user WHERE uid IN " + "(SELECT uid2 FROM friend WHERE uid1=" + auth_fb.user.id + ")"
  , (data) ->
    db.collection "fb_locations", (err, col) ->
      i = 0

      while i < data.length

        # data[i].uid = parseInt(data[i].uid);
        if data[i].current_location
          data[i].location_name = data[i].current_location.name
        else data[i].location_name = data[i].hometown_location.name  if data[i].hometown_location

        #delete data[i].current_location;
        #delete data[i].hometown_location;
        col.update
          uid: data[i].uid
        , data[i],
          upsert: true
          multi: false
          safe: false

        i++


    # multi and upsert don't go hand in hand
    db.collection "fb_friends", (err, col) ->
      i = 0

      while i < data.length

        #console.log(data[i]);
        data[i].uid = parseInt(data[i].uid)
        col.update
          uid: data[i].uid
          ew_id: auth_fb.user.id
        ,
          uid: data[i].uid
          ew_id: auth_fb.user.id
        ,
          upsert: true
          multi: false
          safe: false

        i++
