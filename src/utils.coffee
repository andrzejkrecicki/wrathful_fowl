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

    ImageResource: (src, onload) ->
        img = new Image
        img.onload = onload img
        img.src = src
        return img

    SoundResource: (src, onload) ->
        snd = new Audio
        snd.preload = "auto"
        snd.oncanplaythrough = onload snd
        snd.src = src
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
