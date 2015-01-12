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
        @ready = true

    load: (group, @callback) ->
        throw Error "Loader ready" if not @ready
        @ready = false
        @total_elements = 0
        @loaded_elements = 0

        for name, src of DefaultLoader.resources[group].images
            ++@total_elements
            img = new Image
            img.onload = @element_loaded_handler img, name, "images"
            img.src = src

        for name, src of DefaultLoader.resources[group].sounds
            ++@total_elements
            snd = new Audio
            snd.preload = "auto"
            snd.oncanplaythrough = @element_loaded_handler snd, name, "sounds"
            snd.src = src

    element_loaded_handler: (obj, name, subgroup) ->
        =>
            console.log "Finished loading #{name}", obj
            @[subgroup][name] = obj
            ++@loaded_elements
            @progress @loaded_elements / @total_elements
            if @total_elements == @loaded_elements
                @ready = true
                @callback()
                @progress = ->
    
    progress: ->