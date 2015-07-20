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

        @add @restartButton = new UI.IconButton
            x: 10
            y: 10
            image: Utils.ImageResource DefaultLoader.resources.menu.images.restart

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

        contact_listener = new Box2D.Dynamics.b2ContactListener
        contact_listener.PostSolve = (contact, impulse) ->
            body1 = contact.GetFixtureA().GetBody()
            body2 = contact.GetFixtureB().GetBody()

            impulseNormal = impulse.normalImpulses[0]
            return if impulseNormal < 1.2
            body1.parent.handleHit impulseNormal / 10
            body2.parent.handleHit impulseNormal / 10

        @world.SetContactListener contact_listener

        @addObject new Objects.Floor @world
        @addObject @slingshot = new Objects.Slingshot @world, 300, 640

        @addObject @band1 = new Objects.Band @world, [305, 590, 305, 590]
        @addObject @band2 = new Objects.Band @world, [381, 590, 305, 590]


        for object in options.objects
            @addObject new Objects[object.type] @world, object.x, object.y, object.angle


        @pigs = []
        for pigDef in options.pigs
            @addObject pig = new Objects[pigDef.type] @world, pigDef.x, pigDef.y, 0
            @pigs.push pig

        birdX = 250
        @birds = []
        for birdType in options.birds
            @addObject bird = new Objects[birdType] @world, birdX, 680, 0
            @birds.push bird
            birdX -= bird.children[0].getWidth() + 10

        @totalBirds = @birds.length

        @band2.setZIndex 200

        @on "click", =>
            if @state == Utils.GameStates.birdFired
                @birds[0]?.superPower?()

        # @world.context = document.getElementById("debug").getContext("2d")
        # debugDraw = new Box2D.Dynamics.b2DebugDraw
        # debugDraw.SetSprite @world.context
        # debugDraw.SetDrawScale @world.scale
        # debugDraw.SetFillAlpha .3
        # debugDraw.SetLineThickness 3
        # debugDraw.SetFlags Box2D.Dynamics.b2DebugDraw.e_shapeBit or Box2D.Dynamics.b2DebugDraw.e_jointBit
        # @world.SetDebugDraw debugDraw

    addObject: (object) ->
        @objects.add object if object.children?

    process: ->
        for object in @objects.getChildren()
            continue unless object?
            {x, y} = object.body.GetPosition()
            object.setPosition x * @world.scale, y * @world.scale
            object.setRotation object.body.GetAngle()

            if object.life? and object.life <= 0
                @world.DestroyBody object.body
                object.remove true
        
        @handlePanning()
        @handleBirdLoad()
        @handleBandSwing()

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
            if Math.abs(@desiredOffsets[0] - @offset) <= @panningSpeed
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

        if @state == Utils.GameStates.birdFired
            if @offset + @parent.parent.getWidth() / 2 < @birds[0].body.GetPosition().x * @world.scale
                @setOffset @birds[0].body.GetPosition().x * @world.scale - @parent.parent.getWidth() / 2


    handleBirdLoad: ->
        if @state == Utils.GameStates.previewEnded and @birds.length
            @state = Utils.GameStates.loadBird

            Utils.SoundResource(DefaultLoader.resources.level1.sounds.chirp).play()
            vy = 9.8
            adjustedTime = Math.sqrt((2 * (.5 * 9.8 - (@slingshot.baseHeight - 27) / @world.scale)) / 9.8)
            vx = ((@slingshot.body.GetPosition().x - @birds[0].body.GetPosition().x)) / (1 + adjustedTime)
            @birds[0].body.SetAwake true
            @birds[0].body.SetLinearVelocity x: vx, y: -vy


        if @state == Utils.GameStates.loadBird
            if Math.abs(@birds[0].body.GetPosition().x - @slingshot.body.GetPosition().x) < 1 / @world.scale
                @state = Utils.GameStates.readyToFire
                @birds[0].body.SetLinearVelocity 0, 0
                @birds[0].body.SetAwake 0

                @birds[0].on "mousedown", =>
                    Utils.SoundResource(DefaultLoader.resources.level1.sounds.stretch).play()
                    @on "mousemove", (e) =>
                        angle = Math.atan2(
                            @slingshot.GetBirdPlacement().y - e.layerY / @world.scale,
                            @slingshot.body.GetPosition().x - e.layerX / @world.scale
                        )
                        if Box2D.Common.Math.b2Math.Distance(
                                { x: e.layerX / @world.scale, y: e.layerY / @world.scale }, @slingshot.GetBirdPlacement()
                            ) < 3.5
                            @birds[0].body.SetPosition x: e.layerX / @world.scale, y: e.layerY / @world.scale

                            @band1.adjustPosition e.layerX - Math.cos(angle) * 25, e.layerY - Math.sin(angle) * 25
                            @band2.adjustPosition e.layerX - Math.cos(angle) * 25, e.layerY - Math.sin(angle) * 25
                        else
                            @birds[0].body.SetPosition
                                x: @slingshot.body.GetPosition().x - 3.5 * Math.cos(angle)
                                y: Math.min(@slingshot.GetBirdPlacement().y - 3.5 * Math.sin(angle), 22 * @world.scale)

                            @band1.adjustPosition(
                                (@slingshot.GetBirdPlacement().x - 4.3 * Math.cos(angle)) * @world.scale,
                                (@slingshot.GetBirdPlacement().y - 4.3 * Math.sin(angle)) * @world.scale
                            )
                            @band2.adjustPosition(
                                (@slingshot.GetBirdPlacement().x - 4.3 * Math.cos(angle)) * @world.scale,
                                (@slingshot.GetBirdPlacement().y - 4.3 * Math.sin(angle)) * @world.scale
                            )


                        @birds[0].body.SetAwake 0
                        @birds[0].body.SetAngle angle

                    @on "mouseup", (e) =>
                        Utils.SoundResource(DefaultLoader.resources.level1.sounds.swoosh).play()
                        @state = Utils.GameStates.birdFired
                        setTimeout =>
                            @birds.shift()

                            @state = Utils.GameStates.preview
                            @panTo(0)
                        , 10000

                        @birds[0].body.ApplyImpulse
                            x: (@slingshot.body.GetPosition().x - @birds[0].body.GetPosition().x) * 10
                            y: (@slingshot.GetBirdPlacement().y - @birds[0].body.GetPosition().y) * 10
                        ,
                            @birds[0].body.GetWorldCenter()

                        @birds[0].body.SetAngularVelocity .5
                        @slingshot.retreatSpeed = (@birds[0].body.GetLinearVelocity().Length() / 50) * @world.scale

                        @birds[0].off "mousedown"
                        @off "mouseup"
                        @off "mousemove"

    handleBandSwing: ->
        if @state == Utils.GameStates.birdFired and @slingshot.retreatSpeed?
            distance = Math.sqrt(
                (@slingshot.GetBirdPlacement().x * @world.scale - @band1.line.getPoints()[1].x) ** 2 + 
                (@slingshot.GetBirdPlacement().y * @world.scale - @band1.line.getPoints()[1].y) ** 2
            )
            if distance <= @slingshot.retreatSpeed
                @band1.resetPosition()
                @band2.resetPosition()
                @slingshot.retreatSpeed = undefined
            else
                angle = Math.atan2(
                    @band1.line.getPoints()[1].y - @slingshot.GetBirdPlacement().y * @world.scale,
                    @band1.line.getPoints()[1].x - @slingshot.GetBirdPlacement().x * @world.scale
                )

                @band1.adjustPosition(
                    @band1.line.getPoints()[1].x - @slingshot.retreatSpeed * Math.cos(angle),
                    @band1.line.getPoints()[1].y - @slingshot.retreatSpeed * Math.sin(angle)
                )

                @band2.adjustPosition(
                    @band2.line.getPoints()[1].x - @slingshot.retreatSpeed * Math.cos(angle),
                    @band2.line.getPoints()[1].y - @slingshot.retreatSpeed * Math.sin(angle)
                )

        if @state == Utils.GameStates.preview
            @band1.resetPosition()
            @band2.resetPosition()