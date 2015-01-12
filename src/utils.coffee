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