Enum = ->
    result = {}
    result[attr] = i for attr, i in arguments
    result

Utils = 
    lighterColor: (rbg) ->
        return {
            r: Math.min 255, rgb.r*1.2
            g: Math.min 255, rgb.g*1.2
            b: Math.min 255, rgb.b*1.2
        }
    darkerColor: (rbg) ->
        return {
            r: rgb.r*.8
            g: rgb.g*.8
            b: rgb.b*.8
        }

    ImageResource: (src, onload=->) ->
        img = new Image
        img.onload = onload img
        img.src = src
        return img

    SoundResource: (src, onload=->) ->
        snd = new Audio
        snd.preload = "auto"
        snd.oncanplaythrough = onload snd
        snd.src = src
        # snd.play = ->
        return snd

    GameStates: Enum(
        "preview",
        "previewEnded",
        "loadBird",
        "readyToFire",
        "aiming",
        "birdFired",
        "gameOver",
        "levelComplete"
    )

    makeDynamicBodyDef: (scale, x, y, angle) ->
        bodyDef = new Box2D.Dynamics.b2BodyDef
        bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
        bodyDef.position.x = (x) / scale
        bodyDef.position.y = (y) / scale
        bodyDef.angle = Math.PI * angle / 180
        return bodyDef


    makeExplosion: (world, position, radius, impulse) ->
        world.level.drawables.add ex = new Objects.Explosion position.x * world.scale, position.y * world.scale
        ex.sprite.start()
        Utils.SoundResource(DefaultLoader.resources.level2.sounds.explosion).play()
        body = world.GetBodyList()
        while body
            if 0 < (distance = Box2D.Common.Math.b2Math.Distance(position, body.GetPosition())) < radius
                angle = Math.atan2 body.GetPosition().y - position.y, body.GetPosition().x - position.x
                body.ApplyImpulse({
                    x: impulse * (1 - distance / radius) * Math.cos angle
                    y: impulse * (1 - distance / radius) * Math.sin angle
                }, body.GetWorldCenter())
            body = body.m_next

    birdWidth: (birdType) ->
        return {
            StandardBird: 46
            DivingBird: 56
            BombingBird: 79
            BombBird: 63
            MultiBird: 29
            BoomerangBird: 96
        }[birdType]

    birdBottomOffset: (birdType) ->
        return {
            StandardBird: 32 - 23
            DivingBird: 32 - 20
            BombingBird: 32 - 30
            BombBird: 32 - 32
            MultiBird: 32 - 13
            BoomerangBird: 32 - 23
        }[birdType]