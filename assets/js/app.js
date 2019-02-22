import css from "../css/app.css";

import "phoenix_html";

import { Socket } from "phoenix";
let socket = new Socket("/socket");
socket.connect();
let channel = socket.channel("room:0,0", {});

channel
  .join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });

var data = {
  position: { x: "0", y: "0" },
  messages: [],
  currentRoom: "0,0",
  rooms: {
    "0,0": {
      title: "space help desk",
      description:
        "here, at {0,0}, always ready to help - your space help desk! <3"
    }
  },
  users: {},
  input: "",
  crumbs: {
    room_count: 0,
    user_count: 0
  }
};

var submit = function(event) {
  var text = event.target.value;

  if (0 < text.length && text.length < 999) {
    const position = {
      x: vm.position.x.toString(),
      y: vm.position.y.toString()
    };

    channel.push("new_msg", {
      body: JSON.stringify({
        position,
        posted: new Date(),
        id: vm.messages.length + 1,
        user: { name: "signalnerve" },
        text: text
      })
    });
  }

  vm.input = "";
};

function move(x, y) {
  vm.position.x = `${parseInt(vm.position.x) + x}`;
  vm.position.y = `${parseInt(vm.position.y) + y}`;
  vm.currentRoom = [vm.position.x, vm.position.y].join(",");
  vm.messages = [];
}

var vm = new Vue({
  el: "#app",
  data: data,
  methods: {
    move: move,
    submit: submit
  }
});

// Log messages from the server
channel.on("new_msg", payload => {
  var message = JSON.parse(payload.body);
  console.log(message);
  if (
    vm.position.x != message.position.x ||
    vm.position.y != message.position.y
  ) {
    return;
  }

  var messages = [].concat(vm.messages, message);
  vm.messages = messages;

  setTimeout(function() {
    var current = document.documentElement.scrollTop;
    var height = document.body.scrollHeight;

    if (current / height < 0.9) {
      window.scrollTo(0, height + 100);
    }
  }, 1100);
});