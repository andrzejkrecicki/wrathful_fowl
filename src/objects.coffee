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


    makeParticles: ->
        particles_spacing = @particles_spacing or 8
        if @children.length and @particle_types?
            {width, height} = @children[0].getSize()
            angle = @getRotation()
            for x in [0..Math.round(width / particles_spacing)]
                for y in [0..Math.round(height / particles_spacing)]
                    @world.level.drawables.add new Objects.Particle(@particle_types
                        @getX() + ((x*particles_spacing) - width / 2) * Math.cos(angle) - ((y*particles_spacing) - height / 2) * Math.sin(angle),
                        @getY() + ((x*particles_spacing) - width / 2) * Math.sin(angle) + ((y*particles_spacing) - height / 2) * Math.cos(angle)
                    )

    remove: ->
        if @score?
            @world.level.drawables.add new Objects.FloatingScore @getX(), @getY(), @score
            @world.level.score += @score.val

        @makeParticles()
        super




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
            image: game.loader.cache["img/slingshot_back.png"]
            x: 0
            y: 0
            width: 40
            height: 198
            offset: [43 - 32, 140 + 18]

    GetBirdPlacement: ->
        return x: @body.GetPosition().x, y: @body.GetPosition().y - @baseHeight / @world.scale

class Objects.SlingshotFront extends Kinetic.Group
    constructor: (x, y) ->
        super
            x: x
            y: y

        @add new Kinetic.Image
            image: game.loader.cache["img/slingshot_front.png"]
            x: -28
            y: -10
            width: 44
            height: 198
            offset: [43 - 32, 140 + 18]

        @body =
            GetPosition: => x: @getX(), y: @getY()
            GetAngle: ->
    setPosition: ->

class Objects.Band extends Kinetic.Group
    constructor: (@world, @points) ->
        super
            x: 0
            y: 0

        @add @line = new Kinetic.Line
            points: @points
            stroke: '#301708'
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

class Objects.GenericBlock extends Objects.GameObject
    handleHit: (impulse) ->
        return if impulse < .3
        super impulse
        @sound.play() if impulse > 1.5
        state = @lifeStates.filter((x) => @life <= x).length
        if state != @sprite
            console.log "#{@constructor.name + @_id}: #{@life}, state: #{state}"
            @children[0].setImage @sprites[++@sprite - 1]


class Objects.SlimWood extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox 73 / @world.scale, 8 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @sound = game.loader.cache["snd/wood.mp3"]
        @lifeStates = [30, 20, 10]
        @life = 30
        @score = { val: 50 }
        @sprite = 1
        @sprites = [
            game.loader.cache["img/wood1_1.png"]
            game.loader.cache["img/wood1_2.png"]
            game.loader.cache["img/wood1_3.png"]
        ]
        @particle_types = ["particle_wood1", "particle_wood2", "particle_wood3"]

        super @world, x, y, bodyDef, shape, 1.4, .4, .4

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 145
            height: 17
            offset: [72, 8]


class Objects.WideWood extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox 36 / @world.scale, 18 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @sound = game.loader.cache["snd/wood.mp3"]
        @lifeStates = [50, 33, 17]
        @life = 50
        @score = { val: 75 }
        @sprite = 1
        @sprites = [
            game.loader.cache["img/wood2_1.png"]
            game.loader.cache["img/wood2_2.png"]
            game.loader.cache["img/wood2_3.png"]
        ]
        @particle_types = ["particle_wood1", "particle_wood2", "particle_wood3"]

        super @world, x, y, bodyDef, shape, 1.4, .4, .4

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 72
            height: 36
            offset: [36, 18]

class Objects.SlimStone extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox 73 / @world.scale, 8 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @sound = game.loader.cache["snd/stone.mp3"]
        @lifeStates = [60, 45, 30, 15]
        @life = 60
        @score = { val: 100 }
        @sprite = 1
        @sprites = [
            game.loader.cache["img/stone1_1.png"]
            game.loader.cache["img/stone1_2.png"]
            game.loader.cache["img/stone1_3.png"]
            game.loader.cache["img/stone1_4.png"]
        ]
        @particle_types = ["particle_stone1", "particle_stone2", "particle_stone3"]

        super @world, x, y, bodyDef, shape, 2.4, .6, .15

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 145
            height: 17
            offset: [72, 8]


class Objects.WideStone extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox 36 / @world.scale, 18 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @sound = game.loader.cache["snd/stone.mp3"]
        @lifeStates = [100, 75, 50, 25]
        @life = 100
        @score = { val: 125 }
        @sprite = 1
        @sprites = [
            game.loader.cache["img/stone2_1.png"]
            game.loader.cache["img/stone2_2.png"]
            game.loader.cache["img/stone2_3.png"]
            game.loader.cache["img/stone2_4.png"]
        ]
        @particle_types = ["particle_stone1", "particle_stone2", "particle_stone3"]

        super @world, x, y, bodyDef, shape, 2.4, .6, .15

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 72
            height: 36
            offset: [36, 18]

class Objects.BigRock extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 (14 - 32) / @world.scale, (4 - 32) / @world.scale
            new Box2D.Common.Math.b2Vec2 (39 - 32) / @world.scale, (0 - 32) / @world.scale
            new Box2D.Common.Math.b2Vec2 (64 - 32) / @world.scale, (25 - 32) / @world.scale
            new Box2D.Common.Math.b2Vec2 (62 - 32) / @world.scale, (47 - 32) / @world.scale
            new Box2D.Common.Math.b2Vec2 (42 - 32) / @world.scale, (62 - 32) / @world.scale
            new Box2D.Common.Math.b2Vec2 (9 - 32) / @world.scale, (56 - 32) / @world.scale
            new Box2D.Common.Math.b2Vec2 (1 - 32) / @world.scale, (31 - 32) / @world.scale
        ]
        shape.SetAsArray points, points.length

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @sound = game.loader.cache["snd/stone.mp3"]
        @lifeStates = [140, 105, 70, 35]
        @life = 140
        @score = { val: 200 }
        @sprite = 1
        @sprites = [
            game.loader.cache["img/stone3_1.png"]
            game.loader.cache["img/stone3_2.png"]
            game.loader.cache["img/stone3_3.png"]
            game.loader.cache["img/stone3_4.png"]
        ]
        @particle_types = ["particle_stone1", "particle_stone2", "particle_stone3"]

        super @world, x, y, bodyDef, shape, 2.4, .6, .15

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 65
            height: 64
            offset: [32, 32]


class Objects.SmallRock extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 (8 - 16) / @world.scale, (1 - 16) / @world.scale
            new Box2D.Common.Math.b2Vec2 (22 - 16) / @world.scale, (1 - 16) / @world.scale
            new Box2D.Common.Math.b2Vec2 (32 - 16) / @world.scale, (12 - 16) / @world.scale
            new Box2D.Common.Math.b2Vec2 (31 - 16) / @world.scale, (23 - 16) / @world.scale
            new Box2D.Common.Math.b2Vec2 (22 - 16) / @world.scale, (32 - 16) / @world.scale
            new Box2D.Common.Math.b2Vec2 (4 - 16) / @world.scale, (29 - 16) / @world.scale
            new Box2D.Common.Math.b2Vec2 (0 - 16) / @world.scale, (16 - 16) / @world.scale
        ]
        shape.SetAsArray points, points.length

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @sound = game.loader.cache["snd/stone.mp3"]
        @lifeStates = [40, 30, 20, 10]
        @life = 40
        @score = { val: 50 }
        @sprite = 1
        @sprites = [
            game.loader.cache["img/stone4_1.png"]
            game.loader.cache["img/stone4_2.png"]
            game.loader.cache["img/stone4_3.png"]
            game.loader.cache["img/stone4_4.png"]
        ]
        @particle_types = ["particle_stone1", "particle_stone2", "particle_stone3"]

        super @world, x, y, bodyDef, shape, 2.4, .6, .15

        @add new Kinetic.Image
            image: @sprites[@sprite - 1]
            x: 0
            y: 0
            width: 33
            height: 33
            offset: [16, 16]


class Objects.TNT extends Objects.GenericBlock
    constructor: (@world, x, y, angle=0) ->
        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle
        super @world, x, y, bodyDef, undefined, .7, .4, 0

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        @fixtureDef.shape.SetAsBox 18 / @world.scale, 18 / @world.scale
        @body.CreateFixture @fixtureDef

        @life = 100
        @score = { val: 250 }

        @add new Kinetic.Image
            image: game.loader.cache["img/tnt.png"]
            x: 0
            y: 0
            width: 36
            height: 36
            offset: [18, 18]

    handleHit: (impulse) ->
        return unless impulse > .7

        if @life > 0
            @life = 0
            Utils.makeExplosion @world, @body.GetPosition(), 12, 30


class Objects.GenericBird extends Objects.GameObject
    constructor: ->
        @particles_spacing = 16
        super

    handleHit: (impulse) ->
        super
        if impulse > 1.5 and @life > 0 and !@suppress_particles_on_hit
            @makeParticles()

    remove: ->
        @world.level.addWhiteExplosion @getPosition() unless @suppress_final_explosion
        super

    radius: ->
        return 25

class Objects.StandardBird extends Objects.GenericBird
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 23 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 8
        @particle_types = ["feather_red"]

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add new Kinetic.Image
            image: game.loader.cache["img/bird1_1.png"]
            x: 0
            y: 0
            width: 57
            height: 54
            offset: [33, 31]


class Objects.DivingBird extends Objects.GenericBird
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 0, -24 / @world.scale
            new Box2D.Common.Math.b2Vec2 26 / @world.scale, 15 / @world.scale
            new Box2D.Common.Math.b2Vec2 -25 / @world.scale, 15 / @world.scale
        ]
        shape.SetAsArray points, points.length

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 8
        @particle_types = ["feather_yellow"]

        @superPowerUsed = false

        super @world, x, y, bodyDef, shape, 1.1, .4, .1


        @sprite = 1
        @sprites = [
            game.loader.cache["img/bird2_1.png"]
            game.loader.cache["img/bird2_2.png"]
            game.loader.cache["img/bird2_3.png"]
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

        @children[0].setImage @sprites[1]
        game.loader.cache["snd/dive.mp3"].play()

    handleHit: (impulse) ->
        if impulse > .5
            @superPowerUsed = true
            @children[0].setImage @sprites[2]

        super


class Objects.BombingBird extends Objects.GenericBird
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
            new Box2D.Common.Math.b2Vec2 (53 - 48) / @world.scale, (22 - 60) / @world.scale
            new Box2D.Common.Math.b2Vec2 (56 - 48) / @world.scale, (29 - 60) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape 10 / @world.scale
        @fixtureDef.shape.m_p = new Box2D.Common.Math.b2Vec2 0, (30 - 60) / @world.scale
        @fixtureDef.filter.groupIndex = -1
        @body.CreateFixture @fixtureDef



        @life = 15
        @particle_types = ["feather_white"]
        @superPowerUsed = false

        @sprite = 1
        @sprites = [
            game.loader.cache["img/bird3_1.png"]
            game.loader.cache["img/bird3_2.png"]
            game.loader.cache["img/bird3_3.png"]
        ]

        @add new Kinetic.Image
            image: @sprites[0]
            x: 0
            y: 0
            width: 80
            height: 93
            offset: [47, 60]

    radius: ->
        return 30

    superPower: ->
        return if @superPowerUsed

        @superPowerUsed = true
        @body.SetAngle 0
        @body.SetAngularVelocity 0
        @body.SetLinearVelocity({ x: 15, y: -20 }, @body.GetWorldCenter())

        @world.level.addObject egg = new Objects.Egg @world, @body.GetPosition().x * @world.scale, @body.GetPosition().y * @world.scale , 0
        egg.body.ApplyImpulse({ x: 0, y: 10 }, egg.body.GetWorldCenter())

        @world.level.stopPanning()
        @children[0].setImage @sprites[1]

        game.loader.cache["snd/pop.mp3"].play()

    handleHit: (impulse) ->
        if impulse > 1.3 and !@superPowerUsed
            @superPowerUsed = true
            @children[0].setImage @sprites[2]

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

        @fallSound = game.loader.cache["snd/fall_scream.mp3"]
        @fallSound.play()

        @add new Kinetic.Image
            image: game.loader.cache["img/egg.png"]
            x: 0
            y: 0
            width: 44
            height: 57
            offset: [22, 35]

    handleHit: ->
        if @life > 0
            @life = 0
            @fallSound.pause()
            Utils.makeExplosion @world, @body.GetPosition(), 12, 40
        super



class Objects.BombBird extends Objects.GenericBird
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 32 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 30
        @particle_types = ["feather_black"]
        @suppress_final_explosion = true
        @suppress_particles_on_hit = true

        super @world, x, y, bodyDef, shape, .7, .4, 0

        @add @sprite = new Kinetic.Sprite
            x: 0
            y: 0
            width: 64
            height: 84
            offset: [32, 52]
            image: game.loader.cache["img/bird4.png"]
            animation: 'boiling'
            animations:
                boiling: [
                    { x: 64 * 0, y: 0, width: 64, height: 84 }
                    { x: 64 * 1, y: 0, width: 64, height: 84 }
                    { x: 64 * 2, y: 0, width: 64, height: 84 }
                    { x: 64 * 3, y: 0, width: 64, height: 84 }
                ]
            frameRate: 15
            index: 0

        @sprite.on "indexChange", ({oldVal, newVal}) =>
            if newVal == 0
                @sprite.stop()
                @life = 0
                Utils.makeExplosion @world, @body.GetPosition(), 12, 60

    handleHit: (impulse) ->
        return if impulse < .8
        if @life == 30
            @sprite.start()
        super impulse




class Objects.MultiBird extends Objects.GenericBird
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 13 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 10
        @superPowerUsed = false

        super @world, x, y, bodyDef, shape, 1.3, .4, 0

        @add new Kinetic.Image
            x: 0
            y: 0
            width: 30
            height: 29
            offset: [16, 15]
            image: game.loader.cache["img/bird5_1.png"]

    radius: ->
        return 11

    superPower: ->
        return if @superPowerUsed
        @superPowerUsed = true

        {x, y} = @body.GetPosition()
        vc = @body.GetLinearVelocity()
        vc = new Box2D.Common.Math.b2Vec2(vc.x, vc.y)
        worldCenter = @body.GetWorldCenter()
        worldCenter = new Box2D.Common.Math.b2Vec2 worldCenter.x, worldCenter.y

        @world.level.addObject bird = new Objects.MultiBird @world, x * @world.scale, y * @world.scale + 27, @body.GetAngle()
        bird.body.SetLinearVelocity(new Box2D.Common.Math.b2Vec2(vc.x, vc.y + 3), new Box2D.Common.Math.b2Vec2(worldCenter.x, worldCenter.y + 1))

        @world.level.addObject bird = new Objects.MultiBird @world, x * @world.scale, y * @world.scale - 27, @body.GetAngle()
        bird.body.SetLinearVelocity(new Box2D.Common.Math.b2Vec2(vc.x, vc.y - 3), new Box2D.Common.Math.b2Vec2(worldCenter.x, worldCenter.y - 1))


class Objects.BoomerangBird extends Objects.GenericBird
    constructor: (@world, x, y, angle=0) ->
        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle
        
        super @world, x, y, bodyDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape 23 / @world.scale
        @body.CreateFixture @fixtureDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 (52 - 36) / @world.scale, (21 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (71 - 36) / @world.scale, (17 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (88 - 36) / @world.scale, (22 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (95 - 36) / @world.scale, (31 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (95 - 36) / @world.scale, (40 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (89 - 36) / @world.scale, (46 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (76 - 36) / @world.scale, (50 - 37) / @world.scale
            new Box2D.Common.Math.b2Vec2 (56 - 36) / @world.scale, (46 - 37) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @nose = @body.CreateFixture @fixtureDef


        @life = 15
        @particle_types = ["feather_green"]
        @superPowerUsed = false

        @sprite = 0
        @sprites = [
            game.loader.cache["img/bird6_1.png"]
            game.loader.cache["img/bird6_2.png"]
            game.loader.cache["img/bird6_3.png"]
            game.loader.cache["img/bird6_4.png"]
        ]

        @add new Kinetic.Image
            image: @sprites[@sprite]
            x: 0
            y: 0
            width: 97
            height: 90
            offset: [36, 51]

    superPower: ->
        return if @superPowerUsed
        @superPowerUsed = true

        @children[0].setImage @sprites[@sprite = 1]

        @body.DestroyFixture @nose

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 (39 - 36) / @world.scale, (27 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (48 - 36) / @world.scale, (11 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (63 - 36) / @world.scale, (1 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (73 - 36) / @world.scale, (1 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (82 - 36) / @world.scale, (7 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (51 - 36) / @world.scale, (37 - 51) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @body.CreateFixture @fixtureDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 (57 - 36) / @world.scale, (32 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (49 - 36) / @world.scale, (48 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (50 - 36) / @world.scale, (37 - 51) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @body.CreateFixture @fixtureDef

        @fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape
        points = [
            new Box2D.Common.Math.b2Vec2 (49 - 36) / @world.scale, (48 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (70 - 36) / @world.scale, (69 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (80 - 36) / @world.scale, (86 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (68 - 36) / @world.scale, (88 - 51) / @world.scale
            new Box2D.Common.Math.b2Vec2 (49 - 36) / @world.scale, (70 - 51) / @world.scale
        ]
        @fixtureDef.shape.SetAsArray points, points.length
        @body.CreateFixture @fixtureDef

        @body.SetAngularVelocity 8
        @body.ApplyForce
            x: -2000 * @body.GetMass()
            y: 0
        ,
            @body.GetWorldCenter()

        game.loader.cache["snd/dive.mp3"].play()

    handleHit: (impulse) ->
        if impulse > 1.5
            @superPowerUsed = true

            if @sprite in [0, 1]
                if @sprite == 1
                    @children[0].setImage @sprites[@sprite = 2]
                else
                    @children[0].setImage @sprites[@sprite = 3]

        super






class Objects.Explosion extends Kinetic.Group
    constructor: (x, y) ->
        super
            x: x
            y: y

        @add @sprite = new Kinetic.Sprite
            x: -144/2
            y: -137/2
            image: game.loader.cache["img/explosion.png"]
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

class Objects.ExplosionWhite extends Kinetic.Group
    constructor: (x, y) ->
        super
            x: x
            y: y

        @add @sprite = new Kinetic.Sprite
            x: -128/2
            y: -128/2
            image: game.loader.cache["img/explosion_white.png"]
            animation: 'explosion'
            animations:
                explosion: [
                    { x: 128 * 0, y: 0, width: 128, height: 128 }
                    { x: 128 * 1, y: 0, width: 128, height: 128 }
                    { x: 128 * 2, y: 0, width: 128, height: 128 }
                    { x: 128 * 3, y: 0, width: 128, height: 128 }
                    { x: 128 * 4, y: 0, width: 128, height: 128 }
                ]
            frameRate: 15
            index: 0

        @sprite.on "indexChange", ({oldVal, newVal}) =>
            if newVal == 0
                @sprite.stop()
                @remove()


class Objects.FloatingScore extends Kinetic.Group
    constructor: (x, y, score) ->
        super
            x: x
            y: y

        @text = new Kinetic.Text
            x: 0
            y: 0
            text: score.val
            align: 'center'
            width: 300
            fontFamily: 'AngryBirds'
            fontSize: 0
            fill: score.color || '#fff'
            stroke: score.stroke || '#000'
            strokeWidth: 2

        @text.setX -@text.getWidth() / 2
        @text.setY -@text.getHeight() / 2
        @add @text

        @delta = 0

        @anim = new Kinetic.Animation (frame) =>
            @delta += frame.timeDiff
            @text.setFontSize Math.sin(@delta / 200) * (score.size || 60)
            @text.setY -(@delta / 10 + Math.sin(@delta / 200) * (score.size || 60) / 2)
            if (@delta / 200) > Math.PI
                @anim.stop()
                @remove()

        @anim.start()


class Objects.Particle extends Kinetic.Group
    constructor: (type, x, y) ->
        super
            x: x
            y: y

        @add @image = new Kinetic.Image
            image: game.loader.cache["img/" + Utils.randChoice(type) + ".png"]

        @image.setOffset @image.getWidth() / 2, @image.getHeight() / 2
        @image.setRotation @initial_rotation = Math.random() * Math.PI * 2

        @delta = 0
        @direction = Math.random() * Math.PI * 2
        @rotation_modifier = Math.random() * 2 - 1

        @anim = new Kinetic.Animation (frame) =>
            @delta += frame.timeDiff
            @image.setRotation @initial_rotation + @rotation_modifier * @delta / 200
            @image.move Math.sin(@direction) * frame.timeDiff / 10, (1 - Math.cos(@direction)) * frame.timeDiff / 10
            @image.setScale .5 + Math.sin(@delta / 200) / 2
            if (@delta / 200) > Math.PI * 1.5
                @anim.stop()
                @remove()

        @anim.start()



class Objects.GenericPig extends Objects.GameObject
    animate: ->
        return if @sprite.anim.isRunning()
        @sprite.start()
        @sprite.afterFrame @sprite.getAnimations()[@sprite.getAnimation()].length - 1, =>
            @sprite.stop()

    handleHit: (impulse) ->
        super impulse
        state = @lifeStates.filter((x) => @life <= x).length
        if state != @sprite_index
            if @life > 0
                game.loader.cache["snd/pig_grunt.mp3"].play()

            console.log "Life: #{@life}, state: #{state}"
            @sprite.setAnimation ++@sprite_index - 1

    remove: (play=false) ->
        game.loader.cache["snd/pig_dies.mp3"].play() if play
        @world.level.addWhiteExplosion @getPosition()
        super



class Objects.StandardPig extends Objects.GenericPig
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 27.5 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 15
        @lifeStates = [15, 10, 5]
        @sprite_index = 1

        @score =
            val: 2500
            size: 80
            color: '#6DE249'
            stroke: '#0D8209'

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add @sprite = new Kinetic.Sprite
            x: 0
            y: 0
            width: 56
            height: 64
            offset: [27, 36]
            image: game.loader.cache["img/pig1.png"]
            animation: "0"
            animations:
                "0": [
                    { x: 56 * 0, y: 0, width: 56, height: 64 }
                    { x: 56 * 1, y: 0, width: 56, height: 64 }
                ]
                "1": [
                    { x: 56 * 2, y: 0, width: 56, height: 64 }
                    { x: 56 * 3, y: 0, width: 56, height: 64 }
                ]
                "2": [
                    { x: 56 * 4, y: 0, width: 56, height: 64 }
                    { x: 56 * 5, y: 0, width: 56, height: 64 }
                ]
            frameRate: 4
            index: 0


class Objects.BigPig extends Objects.GenericPig
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 41 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 45
        @lifeStates = [45, 30, 15]
        @sprite_index = 1

        @score =
            val: 5000
            size: 80
            color: '#6DE249'
            stroke: '#0D8209'

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add @sprite = new Kinetic.Sprite
            x: 0
            y: 0
            width: 82
            height: 85
            offset: [41, 43]
            image: game.loader.cache["img/pig2.png"]
            animation: "0"
            animations:
                "0": [
                    { x: 82 * 0, y: 0, width: 82, height: 85 }
                    { x: 82 * 1, y: 0, width: 82, height: 85 }
                ]
                "1": [
                    { x: 82 * 2, y: 0, width: 82, height: 85 }
                    { x: 82 * 3, y: 0, width: 82, height: 85 }
                ]
                "2": [
                    { x: 82 * 4, y: 0, width: 82, height: 85 }
                    { x: 82 * 5, y: 0, width: 82, height: 85 }
                ]
            frameRate: 4
            index: 0

class Objects.TinyPig extends Objects.GenericPig
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 20 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 8
        @lifeStates = [8, 5, 2]
        @sprite_index = 1

        @score =
            val: 1000
            size: 80
            color: '#6DE249'
            stroke: '#0D8209'

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add @sprite = new Kinetic.Sprite
            x: 0
            y: 0
            width: 42
            height: 46
            offset: [21, 26]
            image: game.loader.cache["img/pig3.png"]
            animation: "0"
            animations:
                "0": [
                    { x: 42 * 0, y: 0, width: 42, height: 46 }
                    { x: 42 * 1, y: 0, width: 42, height: 46 }
                ]
                "1": [
                    { x: 42 * 2, y: 0, width: 42, height: 46 }
                    { x: 42 * 3, y: 0, width: 42, height: 46 }
                ]
                "2": [
                    { x: 42 * 4, y: 0, width: 42, height: 46 }
                    { x: 42 * 5, y: 0, width: 42, height: 46 }
                ]
            frameRate: 4
            index: 0



class Objects.Mountain extends Objects.GenericBlock
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

    handleHit: ->

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
