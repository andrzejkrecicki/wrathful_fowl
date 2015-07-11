UI = {}

class UI.Button extends Kinetic.Group
    constructor: (options) ->
        @complexText = new Kinetic.Text
            text: options.text
            fontSize: options.fontSize or 18
            fontFamily: 'AngryBirds'
            fill: '#555'
            width: options.width or 150
            padding: 20
            align: 'center'

        @rect = new Kinetic.Rect
          stroke: '#555'
          strokeWidth: 5
          fill: '#ddd'
          width: options.width or 150
          height: @complexText.getHeight()
          cornerRadius: 10

        offset = x: 0, y: 0
        if options.center
            offset.x = -(options.width or 150) / 2

        super 
            x: options.x + offset.x
            y: options.y + offset.y
        @add @rect
        @add @complexText
        @onclick = options.onclick if options.onclick?

        @on "mouseover", =>
            document.body.style.cursor = "pointer"
            @rect.setFill '#ccc'
            @draw()
            @onmouseover()

        @on "mouseout", =>
            document.body.style.cursor = "default"
            @rect.setFill '#ddd'
            @draw()
            @onmouseover()

        @on "mousedown", =>
            @rect.setStroke '#666'
            @draw()

        @on "mouseup", =>
            @rect.setStroke '#555'
            @draw()
            @onclick()

    remove: ->
        document.body.style.cursor = "default"
        super

    onmouseover: ->
    onmouseout: ->
    onclick: ->

class UI.IconButton extends Kinetic.Group
    constructor: (options) ->
        super 
            x: options.x
            y: options.y

        @add @circle = new Kinetic.Circle
            x: 30
            y: 30
            radius: 30
            fill: '#f60'
            stroke: '#a40'
            strokeWidth: 2

        @add new Kinetic.Image
            image: options.image
            x: (@circle.getRadius() * 2 - options.image.width) / 2
            y: (@circle.getRadius() * 2 - options.image.width) / 2
            width: options.image.width
            height: options.image.width

        @onclick = options.onclick if options.onclick?

        @on "mouseover", =>
            document.body.style.cursor = "pointer"
            @circle.setFill '#f82'
            @draw()
            @onmouseover()

        @on "mouseout", =>
            document.body.style.cursor = "default"
            @circle.setFill '#f60'
            @draw()
            @onmouseover()

        @on "mousedown", =>
            @circle.setStroke '#c62'
            @draw()

        @on "mouseup", =>
            @circle.setStroke '#a40'
            @draw()
            @onclick()

    remove: ->
        document.body.style.cursor = "default"
        super

    onmouseover: ->
    onmouseout: ->
    onclick: ->


class UI.GameOverPane extends Kinetic.Group
    constructor: (options) ->
        super 
            x: options.x
            y: options.y

        @add new Kinetic.Rect
            x: 0
            y: 0
            fill: '#000'
            opacity: .7
            width: 600
            height: 470


        @add new Kinetic.Text
            text: "Level failed!"
            fontSize: 60
            fontFamily: 'AngryBirds'
            fill: '#fff'
            width: 600
            x: 0
            y: 100
            align: 'center'

        img = Utils.ImageResource DefaultLoader.resources.menu.images.pig_big, -> return 0
        @add new Kinetic.Image
            image: img
            x: 300 - img.width / 2
            y: 180
            width: 98
            height: 96

        @add @restartButton = new UI.IconButton
            x: 201
            y: 300
            image: Utils.ImageResource DefaultLoader.resources.menu.images.restart, ->
            onclick: options.onrestart

        @add @cancelButton = new UI.IconButton
            x: 339
            y: 300
            image: Utils.ImageResource DefaultLoader.resources.menu.images.cancel, ->
            onclick: options.oncancel



class UI.LevelCompletePane extends Kinetic.Group
    constructor: (options) ->
        super 
            x: options.x
            y: options.y

        @add new Kinetic.Rect
            x: 0
            y: 0
            fill: '#000'
            opacity: .7
            width: 600
            height: 470


        @add new Kinetic.Text
            text: "Level complete!"
            fontSize: 60
            fontFamily: 'AngryBirds'
            fill: '#fff'
            width: 600
            x: 0
            y: 100
            align: 'center'

        @add @nextButton = new UI.IconButton
            x: 201
            y: 300
            image: Utils.ImageResource DefaultLoader.resources.menu.images.next, ->
            onclick: options.onnext

        @add @cancelButton = new UI.IconButton
            x: 339
            y: 300
            image: Utils.ImageResource DefaultLoader.resources.menu.images.cancel, ->
            onclick: options.oncancel

        for i in [0..4]
            @add new Kinetic.Image
                image: Utils.ImageResource DefaultLoader.resources.menu.images.star, ->
                x: 150 + i * 60
                y: 200
                width: 50
                height: 50

        for i in [0..Math.min(5, Math.round(options.score * 6.25))]
            setTimeout (do (i) => =>
                @add star = new Kinetic.Image
                    image: Utils.ImageResource DefaultLoader.resources.menu.images.star_filled, ->
                    x: 150 + i * 60
                    y: 200
                    width: 50
                    height: 50
                star.draw()
            ), (i + 1) * 400