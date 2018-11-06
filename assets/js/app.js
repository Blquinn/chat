// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import {Socket} from 'phoenix';
import $ from "jquery"

// let socket = new Socket("/socket", {params: {token: window.userToken}});
const socketEndpoint = '/socket';
var socket = null;

var base_url = 'http://' + window.location.host;
var auth_base = 'http://localhost:8000';
var user = {};
var room_id = "";
var channel = null;
var earliest_message = '';

$(document).ready(function() {

  if (getAuthData() !== null) {
    $('#login').hide();
    $('#chat').show();
  }

  $('#log-in-btn').click(function(e) {
    e.preventDefault();

    let email = $('#email-input').val();
    let password = $('#password-input').val();
    logIn(email, password);
  });

  $('#list-conversations-btn').click(function(e) {
    e.preventDefault();
    // console.log(authToken());
    $.ajax({
      url: base_url + "/api/rooms",
      headers: {
        "Authorization": "Bearer " + authToken()
      },
      success: function(res) {
        let html_string = '<ul>';
        user = res.user;
        res.data.forEach(function(room) {
          html_string += `
            <li><a class="chat-room-link" href="#" data-room-id="${room.id}">${room.name}</a></li>
          `;
        });
        html_string += '</ul>';
        $('#conversations').html(html_string);
      },
      error: function(error) {
        console.error(error);
        alert(JSON.stringify(error));
      }
    });
  });

  $('#room-entry-btn').click(function() {
    $.ajax({
      url: base_url + "/api/rooms",
      headers: {
        "Authorization": "Bearer " + authToken()
      },
      method: 'POST',
      data: {
        name: $('#room-entry-txt').val()
      },
      success: function(res) {
        console.log(res);
        $('#peer-entry-room').val(res.data.id);
      },
      error: function(error) {
        console.error(error);
        alert(JSON.stringify(error));
      }
    });
  });

  $('#peer-entry-btn').click(function() {
    $.ajax({
      url: base_url + "/api/subscriptions",
      headers: {
        "Authorization": "Bearer " + authToken()
      },
      method: 'POST',
      data: {
        chat_room_id: $('#peer-entry-room').val(),
        username: $('#peer-entry-username').val()
      },
      success: function(res) {
        console.log(res);
        alert("Successfully added user to room");
      },
      error: function(error) {
        console.error(error);
        alert(JSON.stringify(error));
      }
    });
  });

  $('#conversations').delegate("a", "click", function() {
    room_id = $(this).data("room-id");
    console.log("Joining room ", room_id);
    $('#chat-log').html('');

    channel = socket.channel("room:" + room_id, {Authorization: "Bearer " + authToken()});
    channel.join()
      .receive("ok", resp => {
        getMessages();
        console.log("Joined successfully", resp)
      })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on("new:msg", msg => {
      if (msg.body != 'ping') {
        console.log(msg);
        let div = createMessageDiv(msg);
        $('#chat-log').append(div);
        updateScroll();
      }
    })

    channel.on("user:entered", msg => {
      console.log(msg);
      $('#chat-log').append(`
        <div class="user-enter">
          <span class="user"><b>${msg.user}</b> hath sojourned into thine holy chapel</span>
        <div>
      `);
      updateScroll();
    })

    channel.on("user:left", msg => {
      $('#chat-log').append(`
        <div class="user-left">
          <span class="user">User left the room</span>
        <div>
      `);
      updateScroll();
    })

  });

  $('#send-button').click(function(e) {
    e.preventDefault();

    if (channel == null) {
      console.error("channel is null");
      return
    }

    let msg = $('#text-message').val();
    if (msg != '') {
      channel.push("new:msg", {user: user, body: msg, room_id: room_id});
      $('#text-message').val('');
    }
  });

  $('#chat-log').scroll(function() {
    if ($(this).scrollTop() === 0) {
      let msg = $(this).children(".message").first().children().first();
      let timestamp = msg.data("message-ts");
      console.log(timestamp);
      getMessages(timestamp);
    }
  });

  $('#logout').click(function() { logOut(); });

});

function updateScroll(){
  var element = document.getElementById("chat-log");
  element.scrollTop = element.scrollHeight;
}

function getMessages() {
  let url = `${base_url}/api/rooms/${room_id}/messages`
  if (earliest_message !== '') {
    url += `?older_than=${earliest_message}`
  }
  $.ajax({
    url: base_url + "/api/rooms/" + room_id + "/messages",
    headers: {
      "Authorization": "Bearer " + authToken()
    },
    success: function(res) {
      console.log(res);
      if (earliest_message !== '') {
        res.messages.reverse().forEach((message, i) => {
          let msg = createMessageDiv(message);
          $('#chat-log').prepend(msg);
          if (i === res.messages.length) {
            earliest_message = message.message.inserted_at;
          }
        });
      } else {
        res.messages.forEach((message, i) => {
          if (i === 0) {
            earliest_message = message.message.inserted_at;
          }
          let msg = createMessageDiv(message);
          // console.log(msg);
          $('#chat-log').append(msg);
        });
        updateScroll();
      }
      console.log(earliest_message);
    },
    error: function(error) {
      console.error(error);
      alert(JSON.stringify(error));
    }
  });
}

function createMessageDiv(msg) {
  let div = $('<div/>').attr('class', 'message');
  let inner = $('<div/>').data('message-id', msg.message.id).data('message-ts', msg.message.inserted_at);

  if (msg.message.message_type == "init_message") {
    inner.attr('class', 'center').text(msg.message.body);
  } else if (msg.user.id == user.id) {
    inner.attr('class', 'right').text(msg.message.body)
    let span = $('<span/>').attr('class', 'username').text(msg.user.username + ": ");
    inner.prepend(span);
  } else {
    inner.attr('class', 'left').text(msg.message.body);
    let span = $('<span/>').attr('class', 'username').text(msg.user.username + ": ")
    inner.prepend(span);
  }
  div.append(inner);
  return div
}

function logIn(email, password) {
  $.ajax({
    url: `${auth_base}/api/auth/o/token/`,
    data: {
      client_id: "hMWQSBydhhY3SrllPO879srur2wUUjKR09Vnydf5",
      grant_type: "password",
      email,
      password,
    },
    method: 'POST',
    headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    },
    success: function(res) {
      setAuthData(res);
      connectSocket();
      $('#chat').show();
      $('#login').hide();
      console.log(res);
    },
    error: function(error) {
      console.error(error);
      alert(error.responseJSON.error_description);
    }
  });
}

function logOut() {
  localStorage.removeItem('auth_data');
  window.location.reload();
}

function connectSocket() {
    socket = new Socket(socketEndpoint, {params: {token: authToken()}});
    socket.connect();
    console.log('Connected to websocket');
}

function refreshToken(refresh_token, callback) {
  $.ajax({
    url: `${auth_base}/api/auth/o/token/`,
    data: {
      client_id: "hMWQSBydhhY3SrllPO879srur2wUUjKR09Vnydf5",
      grant_type: "refresh_token",
      refresh_token
    },
    method: 'POST',
    headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    },
    success: function(res) {
      setAuthData(res);
      connectSocket();
      return callback(null, res)
    },
    error: function(error) {
      return callback(error, null);
    }
  });
}

function authToken() {
  let data = getAuthData();
  if (data !== null) {
    return data.access_token
  }
}

function setAuthData(data) {
  data.expires_at = Date.now() + data.expires_in - 5
  localStorage.setItem('auth_data', JSON.stringify(data));
}

function getAuthData() {
  let json = localStorage.getItem('auth_data');
  if (json !== null) {
    let data = JSON.parse(json);
    if (Date.now() < data.expires_at) {
      console.log("Auth token expired.");
      refreshToken(data.refresh_token, (err, res) => {
        if (err !== null) {
          return null
        }
        return res
      });
    }
    return data
  }
  return null
}

function onStart() {
  let json = localStorage.getItem("auth_data");
  if (json == null) {
    return;
  }

  let authData = JSON.parse(json);

  if (authData.expires_at > Date.now()) {
    return;
  }

  if (authData != null) {
    refreshToken(authData.refresh_token, (err, res) => {
      if (err != null) {
        console.error("Error while refreshing token", err);
        return;
      }

      setAuthData(res);
    });
  }
}

onStart();
