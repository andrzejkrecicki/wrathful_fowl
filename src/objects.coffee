Objects = {}

class Objects.GameObject extends Kinetic.Group
    constructor: (@world, x, y, bodyDef, shape, density=1, friction=.5, restitution=.3) ->
        super
            x: x
            y: y

        @fixtureDef = new Box2D.Dynamics.b2FixtureDef
        @fixtureDef.density = density
        @fixtureDef.friction = friction
        @fixtureDef.restitution = restitution
        @fixtureDef.shape = shape

        @body = @world.CreateBody bodyDef
        @body.parent = this
        fixture = @body.CreateFixture @fixtureDef if shape

    handleHit: (impulse) ->
        return unless @life
        @life -= impulse


class Objects.Slingshot extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        @baseHeight = 132
        @baseWidth = 17

        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox @baseWidth / 2 / @world.scale, @baseHeight / 2 / @world.scale

        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
        bodyDef.position.x = (x) / @world.scale
        bodyDef.position.y = (y) / @world.scale
        bodyDef.angle = Math.PI * angle / 180
        super @world, x, y, bodyDef, shape

        @add new Kinetic.Image
            image: Utils.ImageResource DefaultLoader.resources.level1.images.slingshot
            x: 0
            y: 0
            width: 87
            height: 130
            offset: [43, 140]

    GetBirdPlacement: ->
        return x: @body.GetPosition().x, y: @body.GetPosition().y - @baseHeight / @world.scale


class Objects.Band extends Kinetic.Group
    constructor: (@world, @points) ->
        super
            x: 0
            y: 0

        @add @line = new Kinetic.Line
            points: @points
            stroke: '#000'
            strokeWidth: 10
            lineCap: 'round'
            lineJoin: 'round'

        @body =
            GetPosition: => x: @getX(), y: @getY()
            GetAngle: ->

    adjustPosition: (x, y) ->
        @line.setPoints [@points[0], @points[1], x, y]

    resetPosition: ->
        @line.setPoints @points


class Objects.Wood extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox 13 / @world.scale, 60 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 40
        @sprite = 1
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood1)
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood2)
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood3)
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood4)
        ]

        super @world, x, y, bodyDef, shape, 1.4, .4, .4

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 26
            height: 120
            offset: [13, 60]

    handleHit: (impulse) ->
        return if impulse < .3
        super impulse
        Utils.SoundResource(DefaultLoader.resources.level1.sounds.wood).play() if impulse > 1.5
        state = [40, 30, 20, 10].filter((x) => @life <= x).length
        if state != @sprite
            console.log "Life: #{@life}, state: #{state}"
            @removeChildren()
            @add new Kinetic.Image
                image: @sprites[++@sprite - 1]
                x: 0
                y: 0
                width: 26
                height: 120
                offset: [13, 60]


class Objects.StandardBird extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 23 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 30

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add new Kinetic.Image
            image: Utils.ImageResource DefaultLoader.resources.level1.images.bird1_1
            x: 0
            y: 0
            width: 57
            height: 54
            offset: [33, 31]


class Objects.DivingBird extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 0, -24 / @world.scale
            new Box2D.Common.Math.b2Vec2 26 / @world.scale, 15 / @world.scale
            new Box2D.Common.Math.b2Vec2 -25 / @world.scale, 15 / @world.scale
        ]
        shape.SetAsArray points, points.length

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 30
        @superPowerUsed = false

        super @world, x, y, bodyDef, shape, 1.1, .4, .1


        @sprite = 1
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level2.images.bird2_1)
            Utils.ImageResource(DefaultLoader.resources.level2.images.bird2_2)
            Utils.ImageResource(DefaultLoader.resources.level2.images.bird2_3)
        ]

        @add new Kinetic.Image
            image: @sprites[0]
            x: 0
            y: 0
            width: 77
            height: 54
            offset: [50, 33]

    superPower: ->
        return if @superPowerUsed
        @superPowerUsed = true
        @body.SetAngle Math.PI / 5
        @body.ApplyImpulse
            x: 20
            y: 20
        ,
            @body.GetWorldCenter()

        @removeChildren()
        @add new Kinetic.Image
            image: @sprites[1]
            x: 0
            y: 0
            width: 77
            height: 54
            offset: [50, 33]

        Utils.SoundResource(DefaultLoader.resources.level2.sounds.dive).play()

    handleHit: (impulse) ->
        if impulse > .5
            @superPowerUsed = true
        
            @removeChildren()
            @add new Kinetic.Image
                image: @sprites[2]
                x: 0
                y: 0
                width: 77
                height: 54
                offset: [50, 33]

        super


class Objects.BombingBird extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle
        
        super @world, x, y, bodyDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape 30 / @world.scale
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        
        points = [
            new Box2D.Common.Math.b2Vec2 (26 - 48) / @world.scale, (38 - 60) / @world.scale
            new Box2D.Common.Math.b2Vec2 (43 - 48) / @world.scale, (22 - 60) / @world.scale
            new Box2D.Common.Math.b2Vec2 (40 - 48) / @world.scale, (29 - 60) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef

        points = [
            new Box2D.Common.Math.b2Vec2 (70 - 48) / @world.scale, (38 - 60) / @world.scale
            new Box2D.Common.Math.b2Vec2 (56 - 48) / @world.scale, (22 - 60) / @world.scale
            new Box2D.Common.Math.b2Vec2 (59 - 48) / @world.scale, (29 - 60) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape 10 / @world.scale
        @fixtureDef.shape.m_p = new Box2D.Common.Math.b2Vec2 (49 - 48) / @world.scale, (30 - 60) / @world.scale
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef



        @life = 30
        @superPowerUsed = false

        @sprite = 1
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level2.images.bird3_1)
            Utils.ImageResource(DefaultLoader.resources.level2.images.bird3_2)
            Utils.ImageResource(DefaultLoader.resources.level2.images.bird3_3)
        ]

        @add new Kinetic.Image
            image: @sprites[0]
            x: 0
            y: 0
            width: 80
            height: 93
            offset: [47, 60]

    superPower: ->
        return if @superPowerUsed

        @superPowerUsed = true
        @body.SetAngle 0
        @body.SetAngularVelocity 0
        @body.SetLinearVelocity({ x: 15, y: -20 }, @body.GetWorldCenter())

        @world.level.addObject egg = new Objects.Egg @world, @body.GetPosition().x * @world.scale, @body.GetPosition().y * @world.scale , 0
        egg.body.ApplyImpulse({ x: 0, y: 10 }, egg.body.GetWorldCenter())

        @world.level.stopPanning()

        @removeChildren()
        @add new Kinetic.Image
            image: @sprites[1]
            x: 0
            y: 0
            width: 80
            height: 93
            offset: [47, 60]

        Utils.SoundResource(DefaultLoader.resources.level2.sounds.pop).play()

    handleHit: (impulse) ->
        if impulse > 1.3 and !@superPowerUsed
            @superPowerUsed = true
            @removeChildren()
            @add new Kinetic.Image
                image: @sprites[2]
                x: 0
                y: 0
                width: 80
                height: 93
                offset: [47, 60]

        super


class Objects.Egg extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle
        super @world, x, y, bodyDef, undefined, .7, .4, 0

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape 22 / @world.scale
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef


        @fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape 15 / @world.scale
        @fixtureDef.shape.m_p = new Box2D.Common.Math.b2Vec2 0 / @world.scale, -18 / @world.scale
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef

        @life = 100

        @fallSound = Utils.SoundResource(DefaultLoader.resources.level2.sounds.fall_scream)
        @fallSound.play()

        @add new Kinetic.Image
            image: Utils.ImageResource(DefaultLoader.resources.level2.images.egg)
            x: 0
            y: 0
            width: 44
            height: 57
            offset: [22, 35]

    handleHit: ->
        if @life > 0
            @life = 0
            @fallSound.pause()
            snd = Utils.SoundResource(DefaultLoader.resources.level2.sounds.explosion)
            snd.play()
            Utils.makeExplosion @world, @body.GetPosition(), 12, 40
            console.log "egg hit"
        super


class Objects.Explosion extends Kinetic.Group
    constructor: (x, y) ->
        super
            x: x
            y: y

        @add @sprite = new Kinetic.Sprite
            x: -144/2
            y: -137/2
            image: Utils.ImageResource(DefaultLoader.resources.level2.images.explosion)
            animation: 'explosion'
            animations:
                explosion: [
                    { x: 144 * 0, y: 0, width: 144, height: 137 }
                    { x: 144 * 1, y: 0, width: 144, height: 137 }
                    { x: 144 * 2, y: 0, width: 144, height: 137 }
                    { x: 144 * 3, y: 0, width: 144, height: 137 }
                    { x: 144 * 4, y: 0, width: 144, height: 137 }
                    { x: 144 * 5, y: 0, width: 144, height: 137 }
                ]
            frameRate: 20
            index: 0

        @sprite.on "indexChange", ({oldVal, newVal}) =>
            if newVal == 0
                @sprite.stop()
                @remove()

class Objects.StandardPig extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 27.5 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 15
        @sprite = 1
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level1.images.pig1_1)
            Utils.ImageResource(DefaultLoader.resources.level1.images.pig1_2)
            Utils.ImageResource(DefaultLoader.resources.level1.images.pig1_3)
        ]


        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 55
            height: 64
            offset: [27, 36]


    handleHit: (impulse) ->
        super impulse
        state = [15, 10, 5].filter((x) => @life <= x).length
        if state != @sprite
            if @life > 0
                Utils.SoundResource(DefaultLoader.resources.level1.sounds.pig_grunt).play()

            console.log "Life: #{@life}, state: #{state}"
            @removeChildren()
            @add new Kinetic.Image
                image: @sprites[++@sprite - 1]
                x: 0
                y: 0
                width: 55
                height: 64
                offset: [27, 36]

    remove: (play=false) ->
        Utils.SoundResource(DefaultLoader.resources.level1.sounds.pig_dies).play() if play
        super


class Objects.Mountain extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 0, 0
            new Box2D.Common.Math.b2Vec2 120 / @world.scale, -200 / @world.scale
            new Box2D.Common.Math.b2Vec2 280 / @world.scale, -170 / @world.scale
            new Box2D.Common.Math.b2Vec2 300 / @world.scale, 0 / @world.scale
        ]
        shape.SetAsArray points, points.length

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add @shape = new Kinetic.Polygon
            points: [0, 0, 120, -200, 280, -170, 300, 0]
            stroke: '#666'
            fill: '#999'
            strokeWidth: 10
            lineCap: 'round'
            lineJoin: 'round'



class Objects.Floor extends Objects.GameObject
    constructor: (@world, x=1500, y=730) ->
        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
        bodyDef.position.x = x / @world.scale
        bodyDef.position.y = y / @world.scale

        fixtureDef = new Box2D.Dynamics.b2FixtureDef
        fixtureDef.density = 1
        fixtureDef.friction = .5
        fixtureDef.restitution = .2

        fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        fixtureDef.shape.SetAsBox 3000 / @world.scale, 10 / @world.scale

        @body = @world.CreateBody bodyDef
        @body.parent = this
        fixture = @body.CreateFixture fixtureDef
