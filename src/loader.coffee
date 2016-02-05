class DefaultLoader
    @dependencies =
        BigPig:
            images: ["pig2", "explosion_white"]
            sounds: ["pig_dies", "pig_grunt"]
        StandardPig:
            images: ["pig1", "explosion_white"]
            sounds: ["pig_dies", "pig_grunt"]
        TinyPig:
            images: ["pig3", "explosion_white"]
            sounds: ["pig_dies", "pig_grunt"]
        BombBird:
            images: ["bird4", "feather_black", "explosion"]
            sounds: ["explosion"]
        BombingBird:
            images: ["bird3_1", "bird3_2", "bird3_3", "egg", "feather_white", "explosion"]
            sounds: ["pop", "fall_scream", "explosion"]
        BoomerangBird:
            images: ["bird6_1", "bird6_2", "bird6_3", "bird6_4", "feather_green", "explosion"]
            sounds: ["dive"]
        DivingBird:
            images: ["bird2_1", "bird2_2", "bird2_3", "feather_yellow", "explosion"]
            sounds: ["dive"]
        MultiBird:
            images: ["bird5_1", "explosion"]
            sounds: []
        StandardBird:
            images: ["bird1_1", "feather_red", "explosion"]
            sounds: []
        SlimWood:
            images: ["wood1_1", "wood1_2", "wood1_3", "particle_wood1", "particle_wood2", "particle_wood3"]
            sounds: ["wood"]
        WideWood:
            images: ["wood2_1", "wood2_2", "wood2_3", "particle_wood1", "particle_wood2", "particle_wood3"]
            sounds: ["wood"]
        SlimStone:
            images: ["stone1_1", "stone1_2", "stone1_3", "stone1_4", "particle_stone1", "particle_stone2", "particle_stone3"]
            sounds: ["stone"]
        WideStone:
            images: ["stone2_1", "stone2_2", "stone2_3", "stone2_4", "particle_stone1", "particle_stone2", "particle_stone3"]
            sounds: ["stone"]
        BigRock:
            images: ["stone3_1", "stone3_2", "stone3_3", "stone3_4", "particle_stone1", "particle_stone2", "particle_stone3"]
            sounds: ["stone"]
        SmallRock:
            images: ["stone4_1", "stone4_2", "stone4_3", "stone4_4", "particle_stone1", "particle_stone2", "particle_stone3"]
            sounds: ["stone"]
        TNT:
            images: ["tnt", "explosion"]
            sounds: ["explosion"]



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
                slingshot_front: "img/slingshot_front.png"
                slingshot_back: "img/slingshot_back.png"
            sounds:
                loop: "snd/menu.mp3"
                stretch: "snd/stretch.mp3"
                swoosh: "snd/swoosh.mp3"
                chirp: "snd/chirp.mp3"
                crash: "snd/crash.mp3"
                ding: "snd/ding.mp3"


    constructor: (@game) ->
        @ready = true
        @cache = {}


    initialize_loading_screen: ->
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

    load: (group, @callback) ->
        if DefaultLoader.resources[group]?
            @inner_load(group, @callback)
        else
            $.getJSON
                url: "async/#{group}.json"
                success: (data) =>
                    DefaultLoader.resources[group] = data
                    @inner_load group, @callback

    inner_load: (group, @callback) ->
        @initialize_loading_screen()

        for name, src of DefaultLoader.resources[group].images
            ++@total_elements
            img = new Utils.ImageResource src, (obj) => @element_loaded_handler(obj, src, group)

        for name, src of DefaultLoader.resources[group].sounds
            ++@total_elements
            snd = new Utils.SoundResource src, (obj) => @element_loaded_handler(obj, src, group)

        if num = group.match(/level(\d+)/)?[1]
            @total_elements += 4

            new Utils.ImageResource "img/level#{num}_layer1.png", (obj) => @element_loaded_handler(obj, "img/level#{num}_layer1.png", group)
            new Utils.ImageResource "img/level#{num}_layer2.png", (obj) => @element_loaded_handler(obj, "img/level#{num}_layer2.png", group)
            new Utils.ImageResource "img/level#{num}_layer3.png", (obj) => @element_loaded_handler(obj, "img/level#{num}_layer3.png", group)

            new Utils.SoundResource "snd/level#{num}.mp3", (obj) => @element_loaded_handler(obj, "snd/level#{num}.mp3", group)

        for list in [DefaultLoader.resources[group]?.objects, DefaultLoader.resources[group]?.pigs, DefaultLoader.resources[group]?.birds]
            for object in list or []
                type = object.type || object
                if DefaultLoader.dependencies[type]
                    for name in DefaultLoader.dependencies[type].sounds
                        if not @cache["snd/" + name + ".mp3"]?
                            @cache["snd/" + name + ".mp3"] = {}
                            ++@total_elements
                            snd = new Utils.SoundResource "snd/" + name + ".mp3", (obj) => @element_loaded_handler(obj, "snd/" + name + ".mp3", group)

                    for name in DefaultLoader.dependencies[type].images
                        if not @cache["img/" + name + ".png"]?
                            @cache["img/" + name + ".png"] = {}
                            ++@total_elements
                            img = new Utils.ImageResource "img/" + name + ".png", (obj) => @element_loaded_handler(obj, "img/" + name + ".png", group)



    element_loaded_handler: (obj, name, group) ->
        =>
            console.count "Finished loading #{name}"
            @cache[name] = obj
            ++@loaded_elements
            @progress @loaded_elements / @total_elements
            if @total_elements == @loaded_elements
                @ready = true
                setTimeout @callback, 1000
    
    progress: (progress) ->
        @loading_text.setText "Loading #{Math.round progress*100 }%"
        @game.layer.draw()


class EditorLoader extends DefaultLoader
    constructor: (@game, @callback) ->
        super
        @preload_dependencies()

    preload_dependencies: ->
        @initialize_loading_screen()
        for name, dependency of DefaultLoader.dependencies
            for name in dependency.sounds
                if not @cache["snd/" + name + ".mp3"]?
                    @cache["snd/" + name + ".mp3"] = {}
                    ++@total_elements
                    snd = new Utils.SoundResource "snd/" + name + ".mp3", (obj) => @element_loaded_handler(obj, "snd/" + name + ".mp3")

            for name in dependency.images
                if not @cache["img/" + name + ".png"]?
                    @cache["img/" + name + ".png"] = {}
                    ++@total_elements
                    img = new Utils.ImageResource "img/" + name + ".png", (obj) => @element_loaded_handler(obj, "img/" + name + ".png")

        @total_elements += 2
        new Utils.ImageResource "img/slingshot_front.png", (obj) => @element_loaded_handler(obj, "img/slingshot_front.png")
        new Utils.ImageResource "img/slingshot_back.png", (obj) => @element_loaded_handler(obj, "img/slingshot_back.png")
        return
    
    inner_load: (group, @callback) ->
        @initialize_loading_screen()
        if num = group.match(/level(\d+)/)?[1]
            @total_elements += 4

            new Utils.ImageResource "img/level#{num}_layer1.png", (obj) => @element_loaded_handler(obj, "img/level#{num}_layer1.png", group)
            new Utils.ImageResource "img/level#{num}_layer2.png", (obj) => @element_loaded_handler(obj, "img/level#{num}_layer2.png", group)
            new Utils.ImageResource "img/level#{num}_layer3.png", (obj) => @element_loaded_handler(obj, "img/level#{num}_layer3.png", group)

            new Utils.SoundResource "snd/level#{num}.mp3", (obj) => @element_loaded_handler(obj, "snd/level#{num}.mp3", group)
        return
