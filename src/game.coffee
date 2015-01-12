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

    clearStage: ->
        @stage.add @layer = new Kinetic.Layer

    loadMenu: ->
        @layer.add loading_text = new Kinetic.Text
            x: @stage.getWidth() / 2 - 150
            y: @stage.getHeight() / 2
            width: 300
            text: "Loading 0%"
            fontSize: 30
            fontFamily: 'Calibri'
            fill: '#555'
            align: 'center'

        @loader.progress = (progress) =>
            loading_text.setText "Loading #{Math.round progress*100 }%"
            @layer.draw()

        @loader.load "menu", =>
            @clearStage()
            @loader.sounds.menuLoop.play()
            @layer.add new Kinetic.Image
                x: 0
                y: 0
                image: @loader.images.splashScreen
                width: 1280
                height: 720

            @layer.add new UI.Button
                x: @stage.getWidth() / 2
                y: @stage.getHeight() / 2 - 100
                text: "Play!"
                center: true
                onclick: -> console.log "clicked"

            @layer.batchDraw()