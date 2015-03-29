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


        gravity = new Box2D.Common.Math.b2Vec2 0, 9.8
        @world = new Box2D.Dynamics.b2World gravity, true
        @world.scale = 30
        @world.timeStep = 1 / 50

        @addObject new Objects.Floor @world
        @addObject new Objects.Slingshot @world, 300, 610

        @world.context = document.getElementById("debug").getContext("2d")
        debugDraw = new Box2D.Dynamics.b2DebugDraw
        debugDraw.SetSprite @world.context
        debugDraw.SetDrawScale @world.scale
        debugDraw.SetFillAlpha .3
        debugDraw.SetLineThickness 1
        debugDraw.SetFlags Box2D.Dynamics.b2DebugDraw.e_shapeBit or Box2D.Dynamics.b2DebugDraw.e_jointBit

        @world.SetDebugDraw debugDraw

    addObject: (object) ->
        @objects.add object if object.children?

    process: ->
        @objects.setX(@objects.getX() - 5)
        @layer1.setX(@layer1.getX() - 5)
        @layer2.setX(@layer2.getX() - 2.5)
        @layer3.setX(@layer3.getX() - 1.25)
