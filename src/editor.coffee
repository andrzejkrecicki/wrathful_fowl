class Editor
    constructor: ->
        @stage = new Kinetic.Stage
            width: 1280
            height: 720
            container: 'container'

        @layer = new Kinetic.Layer
        @stage.add @layer

        @birds = []
        @number = 1
        @loader = new EditorLoader this, => @loadLevel @number

        that = this;

        scroll = $(".scroll")

        scroll.on "scroll", ->
            that.level.setOffset this.scrollLeft
            that.level.draw()

        $(".sidebar [params] input").keyup ->
            if that.active_object
                that.active_object["set" + @name] Math.round +$(this).val()
                that.level.draw()

        $(".sidebar #objects div[object]").click ->
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

        $(".sidebar #birds [birds] div[object]").click ->
            that.birds.push $(this).attr("object")
            that.setBirds()

        $("body").delegate ".sidebar #birds [chosen-birds] div[object]", "click", ->
            that.birds.splice($(this).index(), 1)
            that.setBirds()

        $("#save").click ->
            @href = URL.createObjectURL(new Blob([that.serialize()], {type: "json"}));
            @download = "level#{that.number}.json";

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
        $(".sidebar [params] input[name=type]").val(obj.constructor.name)

    setBirds: () ->
        $("[chosen-birds]").html("")
        $.each @birds, (i, name) ->
            src = $("[birds] [object=#{name}] img")[0].src
            $("[chosen-birds]").append "<div object=\"#{name}\"><div><img src=\"#{src}\"></div></div>"

    serialize: ->
        result =
            objects: []
            pigs: []
            birds: DefaultLoader.resources["level#{@number}"].birds
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

        return JSON.stringify result, null, 2

    loadLevel: (number) ->
        clearInterval @interval if @interval
        @loader.load "level#{number}", =>
            @clearStage()
            @level?.clear()
            # @loader["level#{number}"].loop.play()
            @layer.add @level = new Level @stage,
                layer1: @loader.cache["img/level#{number}_layer1.png"]
                layer2: @loader.cache["img/level#{number}_layer2.png"]
                layer3: @loader.cache["img/level#{number}_layer3.png"]
                objects: DefaultLoader.resources["level#{number}"].objects
                birds: []
                pigs: DefaultLoader.resources["level#{number}"].pigs
                panOffset: 0

            @level.process()
            @draw()

            @birds = @loader.constructor.resources["level#{number}"].birds
            @setBirds()

            for object in @level.objects.children
                do (object) =>
                    object.setDraggable true
                    object.on "mouseup", =>
                        @setActiveObject object
