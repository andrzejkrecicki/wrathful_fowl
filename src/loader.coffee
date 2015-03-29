class DefaultLoader
    @resources =
        menu:
            images:
                splashScreen: "img/splash_screen.png"
            sounds:
                loop: "snd/menu.mp3"
        level1:
            images:
                layer1: "img/level1_layer1.png"
                layer2: "img/level1_layer2.png"
                layer3: "img/level1_layer3.png"
                slingshot: "img/slingshot.png"
            sounds:
                loop: "snd/level1.mp3"

    constructor: (@game) ->
        @ready = true

    load: (group, @callback) ->
        throw Error "Loader ready" if not @ready

        @game.clearStage()
        @game.layer.add @loading_text = new Kinetic.Text
            x: @game.stage.getWidth() / 2 - 150
            y: @game.stage.getHeight() / 2
            width: 300
            text: "Loading 0%"
            fontSize: 30
            fontFamily: 'Helvetica'
            fill: '#555'
            align: 'center'

        @ready = false
        @total_elements = 0
        @loaded_elements = 0
        
        @progress 0

        for name, src of DefaultLoader.resources[group].images
            ++@total_elements
            img = new Utils.ImageResource src, (obj) => @element_loaded_handler(obj, name, group)

        for name, src of DefaultLoader.resources[group].sounds
            ++@total_elements
            snd = new Utils.SoundResource src, (obj) => @element_loaded_handler(obj, name, group)

    element_loaded_handler: (obj, name, group) ->
        =>
            console.log "Finished loading #{name}", obj
            @[group] or= {}
            @[group][name] = obj
            ++@loaded_elements
            @progress @loaded_elements / @total_elements
            if @total_elements == @loaded_elements
                @ready = true
                setTimeout @callback, 1000
    
    progress: (progress) ->
        @loading_text.setText "Loading #{Math.round progress*100 }%"
        @game.layer.draw()