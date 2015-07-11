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

        @levelNumber = 1

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

            @layer.add new Kinetic.Text
                text: "Wrathful fowL"
                fontSize: 100
                fontFamily: 'AngryBirds'
                fill: '#fff'
                stroke: '#000'
                strokeWidth: 2
                width: @stage.getWidth()
                x: 0
                y: @stage.getHeight() / 2 - 150
                align: 'center'

            @layer.add new UI.Button
                x: @stage.getWidth() / 2
                y: @stage.getHeight() / 2
                text: "Play!"
                center: true
                onclick: =>
                    @loader.menu.loop.pause()
                    @loadLevel @levelNumber

            @layer.batchDraw()

    draw: ->
        @level.world.Step @level.world.timeStep, 8, 3
        
        @level.world.ClearForces()
        @level.world.DrawDebugData()

        @level.process()
        @checkLevelEnd()
        @layer.draw()
        # @level.batchDraw()


    checkLevelEnd: ->
        if @level.state != Utils.GameStates.gameOver and @level.birds.length == 0
            @level.state = Utils.GameStates.gameOver
            clearInterval @interval if @interval
            @level.restartButton.remove()
            @layer.add new UI.GameOverPane
                x: (@stage.getWidth() - 600) / 2
                y: (@stage.getHeight() - 470) / 2
                onrestart: => @loadLevel @levelNumber
                oncancel: => @loadMenu()



    loadLevel: (number) ->
        clearInterval @interval if @interval
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
                pigs: DefaultLoader.resources["level#{number}"].pigs
                panOffset: DefaultLoader.resources["level#{number}"].panOffset
            
            @level.restartButton.onclick = => @loadLevel @levelNumber

            clearInterval @interval if @interval
            @interval = setInterval =>
                @draw()
            , 20