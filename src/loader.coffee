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
                wood1_1: "img/wood1_1.png"
                wood1_2: "img/wood1_2.png"
                wood1_3: "img/wood1_3.png"
                bird1_1: "img/bird1_1.png"
                pig1: "img/pig1.png"
                explosion_white: "img/explosion_white.png"
            sounds:
                loop: "snd/level1.mp3"
                stretch: "snd/stretch.mp3"
                swoosh: "snd/swoosh.mp3"
                wood: "snd/wood.mp3"
                pig_grunt: "snd/pig_grunt.mp3"
                pig_dies: "snd/pig_dies.mp3"
                chirp: "snd/chirp.mp3"
                crash: "snd/crash.mp3"
                ding: "snd/ding.mp3"
            objects: [
                type: "Wood"
                x: 1700
                y: 646
                angle: 90
            ,
                type: "Wood"
                x: 1828
                y: 646
                angle: 90
            ,
                type: "Wood"
                x: 1765
                y: 565
                angle: 0
            ,
                type: "Wood"
                x: 1700
                y: 482
                angle: 90
            ,
                type: "Wood"
                x: 1828
                y: 482
                angle: 90
            ,
                type: "Wood"
                x: 1765
                y: 402
                angle: 0
            ,
            ]
            pigs: [
                type: "StandardPig"
                x: 1764
                y: 527
            ,
                type: "StandardPig"
                x: 1764
                y: 691
            ]
            birds: ["StandardBird", "StandardBird", "StandardBird"]
            panOffset: 1040
        level2:
            images:
                bird2_1: "img/bird2_1.png"
                bird2_2: "img/bird2_2.png"
                bird2_3: "img/bird2_3.png"
                bird3_1: "img/bird3_1.png"
                bird3_2: "img/bird3_2.png"
                bird3_3: "img/bird3_3.png"
                bird4: "img/bird4.png"
                bird5_1: "img/bird5_1.png"
                egg: "img/egg.png"
                explosion: "img/explosion.png"
                layer1: "img/level2_layer1.png"
                layer2: "img/level2_layer2.png"
                layer3: "img/level2_layer3.png"
            sounds:
                loop: "snd/level2.mp3"
                dive: "snd/dive.mp3"
                pop: "snd/pop.mp3"
                fall_scream: "snd/fall_scream.mp3"
                explosion: "snd/explosion.mp3"
            objects: [
                type: "Wood"
                x: 1700
                y: 645
                angle: 90
            ,
                type: "Wood"
                x: 1800
                y: 645
                angle: 90
            ,
                type: "Wood"
                x: 1900
                y: 645
                angle: 90
            ,
                type: "Wood"
                x: 2000
                y: 645
                angle: 90
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
                y: 545
            ,
                type: "StandardPig"
                x: 1800
                y: 545
            ,
                type: "StandardPig"
                x: 1900
                y: 545
            ,
                type: "StandardPig"
                x: 2000
                y: 545
            ]
            birds: ["BomgingBird", "DivingBird", "MultiBird"]
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