class Level extends Kinetic.Group
    constructor: (options) ->
        super
            x: 0
            y: 0

        @add @layer3 = new Kinetic.Image
            image: options.layer3
            x: 0
            y: 0
            width: options.layer3.width
            height: options.layer3.height

        @add @layer2 = new Kinetic.Image
            image: options.layer2
            x: 0
            y: 0
            width: options.layer2.width
            height: options.layer2.height

        @add @layer1 = new Kinetic.Image
            image: options.layer1
            x: 0
            y: 720 - options.layer1.height
            width: options.layer1.width
            height: options.layer1.height

        @add @objects = new Kinetic.Group
            x: 0
            y: 0


        @state = Utils.GameStates.preview

        @desiredOffsets = []
        @panningSpeed = 0
        @breakingTime = 50
        setTimeout(
            =>
                @panTo(0)
            , 2000
        )
        @setOffset options.panOffset

        gravity = new Box2D.Common.Math.b2Vec2 0, 9.8
        @world = new Box2D.Dynamics.b2World gravity, true
        @world.scale = 30
        @world.timeStep = 1 / 50

        @addObject new Objects.Floor @world
        @addObject @slingshot = new Objects.Slingshot @world, 300, 610

        for object in options.objects
            @addObject new Objects[object.type] @world, object.x, object.y, object.angle

        birdX = 250
        @birds = []
        for birdType in options.birds
            @addObject bird = new Objects[birdType] @world, birdX, 550, 0
            @birds.push bird
            birdX -= bird.children[0].getWidth() + 10

        # @world.context = document.getElementById("debug").getContext("2d")
        # debugDraw = new Box2D.Dynamics.b2DebugDraw
        # debugDraw.SetSprite @world.context
        # debugDraw.SetDrawScale @world.scale
        # debugDraw.SetFillAlpha 1
        # debugDraw.SetLineThickness 3
        # debugDraw.SetFlags Box2D.Dynamics.b2DebugDraw.e_shapeBit or Box2D.Dynamics.b2DebugDraw.e_jointBit
        # @world.SetDebugDraw debugDraw

    addObject: (object) ->
        @objects.add object if object.children?

    process: ->
        for object in @objects.children
            {x, y} = object.body.GetPosition()
            object.setPosition x * @world.scale, y * @world.scale
            object.setRotation object.body.GetAngle()
        
        @handlePanning()
        @handleBirdLoad()

    panTo: (offset) ->
        @desiredOffsets = [offset]

    enquePanTo: (offset) ->
        @desiredOffsets.push offset

    setOffset: (@offset) ->
        @objects.setX -@offset
        @layer1.setX -@offset
        @layer2.setX -@offset/2
        @layer3.setX -@offset/4

    handlePanning: ->
        if @desiredOffsets.length
            mul = (@desiredOffsets[0] - @offset) / Math.abs(@desiredOffsets[0] - @offset) or 0
            if Math.abs(@desiredOffsets[0] - @offset) < @panningSpeed
                @panningSpeed = 0
                @breakingTime = 50
                @setOffset @desiredOffsets[0]
                @desiredOffsets.shift()
                if @state == Utils.GameStates.preview
                    @state = Utils.GameStates.previewEnded
            else
                if Math.abs(@desiredOffsets[0] - @offset) <= (.5 * @breakingTime**2) / 2
                    --@breakingTime
                    @panningSpeed -= mul * .5
                 else
                    @panningSpeed += mul * .5

                @panningSpeed = Math.min(Math.max(@panningSpeed, -25), 25)
                @setOffset @offset + @panningSpeed

    handleBirdLoad: ->
        if @state == Utils.GameStates.previewEnded
            @state = Utils.GameStates.loadBird

            vy = 9.8
            adjustedTime = Math.sqrt((2 * (.5 * 9.8 - @slingshot.baseHeight / @world.scale)) / 9.8)
            vx = ((@slingshot.body.GetPosition().x - @birds[0].body.GetPosition().x)) / (1 + adjustedTime)
            @birds[0].body.SetAwake true
            @birds[0].body.SetLinearVelocity x: vx, y: -vy

        if @state == Utils.GameStates.loadBird
            if Math.abs(@birds[0].body.GetPosition().x - @slingshot.body.GetPosition().x) < 1 / 30
                @state = Utils.GameStates.readyToFire
                @birds[0].body.SetLinearVelocity 0, 0
                @birds[0].body.SetAwake 0