{exec} = require 'child_process'

files = [
        "src/utils.coffee",
        "src/objects.coffee",
        "src/widgets.coffee",
        "src/loader.coffee",
        "src/level.coffee",
        "src/game.coffee"
        "src/main.coffee"
    ]

task "sbuild", "Build", -> 
    exec " coffee -c -j app.js -o lib/ " + files.join(" "), (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        # exec " uglifyjs lib/app.js -o lib/app.js -c -m", (err, stdout, stderr) ->
        #     throw err if err
        #     console.log stdout + stderr
