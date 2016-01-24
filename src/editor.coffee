class Editor
    constructor: ->
        @stage = new Kinetic.Stage
            width: 1280
            height: 720
            container: 'container'

        @layer = new Kinetic.Layer
        @stage.add @layer

        @loader = new DefaultLoader this
        @loadLevel 1

        that = this;

        scroll = $(".scroll")

        scroll.on "scroll", ->
            that.level.setOffset this.scrollLeft
            that.level.draw()

        $(".sidebar [params] input").keyup ->
            if that.active_object
                that.active_object["set" + @name] +$(this).val()
                that.level.draw()

        $(".sidebar div[object]").click ->
            that.level.addObject obj = new Objects[$(this).attr("object")](
                that.level.world,
                scroll.scrollLeft() + scroll.width() / 2,
                that.stage.getHeight() / 2,
                0
            )

            that.setActiveObject obj
            obj.setDraggable true
            obj.on "mouseup", =>
                that.setActiveObject obj
            that.level.draw()


    clearStage: ->
        @stage.removeChildren()
        @stage.add @layer = new Kinetic.Layer

    draw: ->
        @layer.draw()

    setActiveObject: (obj) ->
        @active_object = obj
        $(".sidebar [params] input[name=X]").val(obj.getX())
        $(".sidebar [params] input[name=Y]").val(obj.getY())
        $(".sidebar [params] input[name=RotationDeg]").val(obj.getRotationDeg())

    serialize: ->
        result =
            objects: []
            pigs: []
            birds: ["DivingBird", "StandardBird", "MultiBird"]
            panOffset: 1040

        for object in @level.objects.children
            if object instanceof Objects.GenericBlock
                list = "objects"
            else if object instanceof Objects.GenericPig
                list = "pigs"
            else
                continue

            result[list].push
                type: object.constructor.name
                x: object.getX()
                y: object.getY()
                angle: object.getRotationDeg()

        return JSON.stringify result

    loadLevel: (number) ->
        clearInterval @interval if @interval
        @loader.load "level#{number}", =>
            @clearStage()
            @level?.clear()
            # @loader["level#{number}"].loop.play()
            @layer.add @level = new Level @stage,
                layer1: @loader["level#{number}"].layer1
                layer2: @loader["level#{number}"].layer2
                layer3: @loader["level#{number}"].layer3
                objects: DefaultLoader.resources["level#{number}"].objects
                birds: []
                pigs: DefaultLoader.resources["level#{number}"].pigs
                panOffset: 0

            @level.process()
            @draw()

            for object in @level.objects.children
                do (object) =>
                    object.setDraggable true
                    object.on "mouseup", =>
                        @setActiveObject object
