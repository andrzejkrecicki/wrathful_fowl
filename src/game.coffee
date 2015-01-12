class Game
    constructor: ->
        @stage = new Kinetic.Stage
            width: 1280
            height: 720
            container: 'container'

        @layer = new Kinetic.Layer
        @stage.add @layer

        @loader = new DefaultLoader
        @loadMenu()

    loadMenu: ->
        @loader.load "menu", =>
            @loader.sounds.menuLoop.play()
            @layer.add new Kinetic.Circle
                x: @stage.getWidth() / 2
                y: @stage.getHeight() / 2
                radius: 100
                fill: 'red'
                stroke: '#52d'
                strokeWidth: 6
            @layer.batchDraw()