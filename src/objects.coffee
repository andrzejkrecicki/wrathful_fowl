Objects = {}

class Objects.GameObject extends Kinetic.Group
    constructor: (@world, x, y, bodyDef, shape, density=1, friction=.5, restitution=.3) ->
        super
            x: x
            y: y

        fixtureDef = new Box2D.Dynamics.b2FixtureDef
        fixtureDef.density = density
        fixtureDef.friction = friction
        fixtureDef.restitution = restitution
        fixtureDef.shape = shape

        @body = @world.CreateBody bodyDef
        @body.parent = this
        fixture = @body.CreateFixture fixtureDef

    handleHit: (impulse) ->
        return unless @life
        @life -= impulse


class Objects.Slingshot extends Objects.GameObject
    constructor: (@world, x, y) ->
        @baseHeight = 105
        @baseWidth = 17

        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox @baseWidth / 2 / @world.scale, @baseHeight / 2 / @world.scale

        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
        bodyDef.position.x = (x + 42) / @world.scale
        bodyDef.position.y = (y + 58) / @world.scale

        super @world, x, y, bodyDef, shape

        @add new Kinetic.Image
            image: Utils.ImageResource DefaultLoader.resources.level1.images.slingshot, -> return 0
            x: 0
            y: 0
            width: 80
            height: 80
            offset: [40, 60]

    GetBirdPlacement: ->
        return x: @body.GetPosition().x, y: @body.GetPosition().y - @baseHeight / @world.scale


class Objects.Wood extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2PolygonShape
        shape.SetAsBox 13 / @world.scale, 60 / @world.scale

        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
        bodyDef.position.x = (x) / @world.scale
        bodyDef.position.y = (y) / @world.scale
        bodyDef.angle = Math.PI * angle / 180

        @life = 75
        @sprite = 1
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood1, -> return 0)
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood2, -> return 0)
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood3, -> return 0)
            Utils.ImageResource(DefaultLoader.resources.level1.images.wood4, -> return 0)
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
        super impulse
        state = [75, 56.25, 37.5, 18.75].filter((x) => @life <= x).length
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

        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
        bodyDef.position.x = (x) / @world.scale
        bodyDef.position.y = (y) / @world.scale
        bodyDef.angle = Math.PI * angle / 180

        @life = 30

        super @world, x, y, bodyDef, shape, .7, .4, .4

        @add new Kinetic.Image
            image: Utils.ImageResource DefaultLoader.resources.level1.images.bird1_1, -> return 0
            x: 0
            y: 0
            width: 57
            height: 54
            offset: [33, 31]


class Objects.StandardPig extends Objects.GameObject
    constructor: (@world, x, y, angle=0) ->
        shape = new Box2D.Collision.Shapes.b2CircleShape 27.5 / @world.scale

        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
        bodyDef.position.x = (x) / @world.scale
        bodyDef.position.y = (y) / @world.scale
        bodyDef.angle = Math.PI * angle / 180

        @life = 15
        @sprite = 1
        @sprites = [
            Utils.ImageResource(DefaultLoader.resources.level1.images.pig1_1, -> return 0)
            Utils.ImageResource(DefaultLoader.resources.level1.images.pig1_2, -> return 0)
            Utils.ImageResource(DefaultLoader.resources.level1.images.pig1_3, -> return 0)
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
            console.log "Life: #{@life}, state: #{state}"
            @removeChildren()
            @add new Kinetic.Image
                image: @sprites[++@sprite - 1]
                x: 0
                y: 0
                width: 55
                height: 64
                offset: [27, 36]


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
