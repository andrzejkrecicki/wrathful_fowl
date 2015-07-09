class Game
    constructor: ->
        @stage = new Kinetic.Stage
            width: 1280
            height: 720
            container: 'container'

        @layer = new Kinetic.Layer
        @stage.add @layer

        @loader = new DefaultLoader this
        @loadMenu()

    clearStage: ->
        @stage.removeChildren()
        @stage.add @layer = new Kinetic.Layer

    loadMenu: ->
        @loader.load "menu", =>
            @clearStage()
            @loader.menu.loop.play()
            @layer.add new Kinetic.Image
                x: 0
                y: 0
                image: @loader.menu.splashScreen
                width: 1280
                height: 720

            @layer.add new UI.Button
                x: @stage.getWidth() / 2
                y: @stage.getHeight() / 2 - 100
                text: "Play!"
                center: true
                onclick: =>
                    @loader.menu.loop.pause()
                    @loadLevel 1

            @layer.batchDraw()

    draw: ->
        @level.world.Step @level.world.timeStep, 8, 3
        
        @level.world.ClearForces()
        @level.world.DrawDebugData()

        @level.process()
        @layer.draw()
        # @level.batchDraw()



    loadLevel: (number) ->
        @loader.load "level#{number}", =>
            console.log "level #{number} ready"
            @clearStage()
            @loader["level#{number}"].loop.play()
            @layer.add @level = new Level
                layer1: @loader["level#{number}"].layer1
                layer2: @loader["level#{number}"].layer2
                layer3: @loader["level#{number}"].layer3
                objects: DefaultLoader.resources["level#{number}"].objects
                birds: DefaultLoader.resources["level#{number}"].birds
                panOffset: DefaultLoader.resources["level#{number}"].panOffset
            
            clearInterval @interval if @interval
            @interval = setInterval =>
                @draw()
            , 20