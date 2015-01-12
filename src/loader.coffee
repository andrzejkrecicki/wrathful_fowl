class DefaultLoader
    @resources =
        menu:
            images:
                splashScreen: "img/splash_screen.png"
            sounds:
                menuLoop: "snd/menu.mp3"

    constructor: ->
        @images = {}
        @sounds = {}
        @total_elements = 0
        @ready = true

    load: (group, @callback) ->
        throw Error "Loader ready" if not @ready
        @ready = false

        for name, src of DefaultLoader.resources[group].images
            ++@total_elements
            img = new Image
            img.onload = @handler img, name, "images"
            img.src = src

        for name, src of DefaultLoader.resources[group].sounds
            ++@total_elements
            snd = new Audio
            snd.preload = "auto"
            snd.oncanplaythrough = @handler snd, name, "sounds"
            snd.src = src


    loaded_handler: (name, obj) ->


    handler: (obj, name, subgroup) ->
        =>
            console.log "Finished loading #{name}", obj
            @[subgroup][name] = obj
            if --@total_elements == 0
                @ready = true
                @callback()
        