class DefaultLoader
    @resources =
        menu:
            images:
                splashScreen: "img/splash_screen.png"
                restart: "img/restart.png"
                cancel: "img/cancel.png"
                next: "img/next.png"
                star: "img/star.png"
                star_filled: "img/star_filled.png"
                pig_big: "img/pig_big.png"
            sounds:
                loop: "snd/menu.mp3"
        level1:
            images:
                layer1: "img/level1_layer1.png"
                layer2: "img/level1_layer2.png"
                layer3: "img/level1_layer3.png"
                slingshot: "img/slingshot.png"
                wood1: "img/wood1.png"
                wood2: "img/wood2.png"
                wood3: "img/wood3.png"
                wood4: "img/wood4.png"
                bird1_1: "img/bird1_1.png"
                pig1_1: "img/pig1_1.png"
                pig1_2: "img/pig1_2.png"
                pig1_3: "img/pig1_3.png"
            sounds:
                loop: "snd/level1.mp3"
            objects: [
                type: "Wood"
                x: 1700
                y: 660
                angle: 0
            ,
                type: "Wood"
                x: 1796
                y: 660
                angle: 0
            ,
                type: "Wood"
                x: 1747
                y: 586
                angle: 90
            ,
                type: "Wood"
                x: 1700
                y: 512
                angle: 0
            ,
                type: "Wood"
                x: 1796
                y: 512
                angle: 0
            ,
                type: "Wood"
                x: 1747
                y: 442
                angle: 90
            ,
            ]
            pigs: [
                type: "StandardPig"
                x: 1747
                y: 530
            ,
                type: "StandardPig"
                x: 1747
                y: 671
            ]
            birds: ["StandardBird", "StandardBird", "StandardBird"]
            panOffset: 1040
        level2:
            images:
                layer1: "img/level1_layer1.png"
                layer2: "img/level1_layer2.png"
                layer3: "img/level1_layer3.png"
            sounds:
                loop: "snd/level2.mp3"
            objects: [
                type: "Wood"
                x: 1700
                y: 660
                angle: 0
            ,
                type: "Wood"
                x: 1800
                y: 660
                angle: 0
            ,
                type: "Wood"
                x: 1900
                y: 660
                angle: 0
            ,
                type: "Wood"
                x: 2000
                y: 660
                angle: 0
            ,
                type: "Mountain"
                x: 2350
                y: 700
                angle: 230
            ,
                type: "Mountain"
                x: 1250
                y: 690
                angle: 0
            ]
            pigs: [
                type: "StandardPig"
                x: 1700
                y: 568
            ,
                type: "StandardPig"
                x: 1800
                y: 568
            ,
                type: "StandardPig"
                x: 1900
                y: 568
            ,
                type: "StandardPig"
                x: 2000
                y: 568
            ]
            birds: ["StandardBird", "StandardBird", "StandardBird"]
            panOffset: 1040


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
            fontFamily: 'AngryBirds'
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