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
            @children[0].setImage @sprites[++@sprite - 1]


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

        @children[0].setImage @sprites[1]
        Utils.SoundResource(DefaultLoader.resources.level2.sounds.dive).play()

    handleHit: (impulse) ->
        if impulse > .5
            @superPowerUsed = true
            @children[0].setImage @sprites[2]

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
        @children[0].setImage @sprites[1]

        Utils.SoundResource(DefaultLoader.resources.level2.sounds.pop).play()

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
            Utils.makeExplosion @world, @body.GetPosition(), 12, 40
        super



class Objects.BombBird extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 32 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 30

        super @world, x, y, bodyDef, shape, .7, .4, 0

        @add @sprite = new Kinetic.Sprite
            x: 0
            y: 0
            width: 64
            height: 84
            offset: [32, 52]
            image: Utils.ImageResource DefaultLoader.resources.level2.images.bird4
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
                @remove()
                Utils.makeExplosion @world, @body.GetPosition(), 12, 60

    handleHit: (impulse) ->
        return if impulse < .8
        if @life == 30
            @sprite.start()
        super impulse




class Objects.MultiBird extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 13 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 30
        @superPowerUsed = false

        super @world, x, y, bodyDef, shape, 1.3, .4, 0

        @add new Kinetic.Image
            x: 0
            y: 0
            width: 30
            height: 29
            offset: [16, 15]
            image: Utils.ImageResource DefaultLoader.resources.level2.images.bird5_1

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


class Objects.BoomerangBird extends Objects.GameObject
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


        @life = 30
        @superPowerUsed = false

        @sprite = 0
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level1.images.bird6_1)
            Utils.ImageResource(DefaultLoader.resources.level1.images.bird6_2)
            Utils.ImageResource(DefaultLoader.resources.level1.images.bird6_3)
            Utils.ImageResource(DefaultLoader.resources.level1.images.bird6_4)
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

        Utils.SoundResource(DefaultLoader.resources.level2.sounds.dive).play()

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

class Objects.ExplosionWhite extends Kinetic.Group
    constructor: (x, y) ->
        super
            x: x
            y: y

        @add @sprite = new Kinetic.Sprite
            x: -128/2
            y: -128/2
            image: Utils.ImageResource(DefaultLoader.resources.level1.images.explosion_white)
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

class Objects.StandardPig extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 27.5 / @world.scale

        bodyDef = Utils.makeDynamicBodyDef @world.scale, x, y, angle

        @life = 15
        @sprite_index = 1

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add @sprite = new Kinetic.Sprite
            x: 0
            y: 0
            width: 56
            height: 64
            offset: [27, 36]
            image: Utils.ImageResource(DefaultLoader.resources.level1.images.pig1)
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


    animate: ->
        return if @sprite.anim.isRunning()
        @sprite.start()
        @sprite.afterFrame @sprite.getAnimations()[@sprite.getAnimation()].length - 1, =>
            @sprite.stop()

    handleHit: (impulse) ->
        super impulse
        state = [15, 10, 5].filter((x) => @life <= x).length
        if state != @sprite_index
            if @life > 0
                Utils.SoundResource(DefaultLoader.resources.level1.sounds.pig_grunt).play()

            console.log "Life: #{@life}, state: #{state}"
            @sprite.setAnimation ++@sprite_index - 1

    remove: (play=false) ->
        Utils.SoundResource(DefaultLoader.resources.level1.sounds.pig_dies).play() if play
        @world.level.addWhiteExplosion @getPosition()
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
