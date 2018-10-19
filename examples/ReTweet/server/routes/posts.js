var faker = require("faker");
var express = require("express");
var router = express.Router();

const userAvatar = "https://i.imgur.com/DihF6bx.png";

var messages = Array.from(new Array(1000), (x, i) => {
  return {
    username: faker.name.findName(),
    text: faker.lorem.sentences(3),
    avatar: faker.image.avatar(),
    date: faker.date.recent(),
    likes: faker.random.number(100),
    clientID: faker.random.uuid()
  };
}).sort((first, second) => {
  a = new Date(first.date);
  b = new Date(second.date);
  return a > b ? -1 : a < b ? 1 : 0;
});

router.get("/", function(req, res, next) {
  const offset = Number(req.query.offset);
  const limit = Number(req.query.limit);

  if (offset != undefined && limit != undefined) {
    const messagesSlice = messages.slice(offset, offset + limit);
    res.send(messagesSlice);
  } else {
    res.send(messages);
  }
});

router.post("/", function(req, res, next) {
  setTimeout(function() {
    let newMessage = req.body;
    newMessage.date = new Date();
    newMessage.likes = 0;
    newMessage.avatar = userAvatar;
    messages.unshift(newMessage);
    res.send(newMessage);
  }, 5000);
});

module.exports = router;
