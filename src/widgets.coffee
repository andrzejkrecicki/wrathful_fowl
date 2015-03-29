UI = {}

class UI.Button extends Kinetic.Group
    constructor: (options) ->
        @complexText = new Kinetic.Text
            text: options.text
            fontSize: options.fontSize or 18
            fontFamily: 'Helvetica'
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