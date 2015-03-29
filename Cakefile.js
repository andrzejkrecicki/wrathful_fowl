// Generated by CoffeeScript 1.9.1
var exec, files;

exec = require('child_process').exec;

files = ["src/utils.coffee", "src/objects.coffee", "src/widgets.coffee", "src/loader.coffee", "src/level.coffee", "src/game.coffee", "src/main.coffee"];

task("sbuild", "Build", function() {
  return exec(" coffee -c -j app.js -o lib/ " + files.join(" "), function(err, stdout, stderr) {
    if (err) {
      throw err;
    }
    return console.log(stdout + stderr);
  });
});
