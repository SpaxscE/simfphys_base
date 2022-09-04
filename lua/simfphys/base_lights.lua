local light_table = {
    L_HeadLampPos = Vector(-42, 148, 21.1),
    L_HeadLampAng = Angle(15, 90, 0),
    R_HeadLampPos = Vector(42, 148, 21.1),
    R_HeadLampAng = Angle(15, 90, 0),
    L_RearLampPos = Vector(45.6, -147, 27.2),
    L_RearLampAng = Angle(40, -90, 0),
    R_RearLampPos = Vector(-45.6, -147, 27.2),
    R_RearLampAng = Angle(40, -90, 0),
    Headlight_sprites = {Vector(-46.3, 145.6, 21.1), Vector(46.3, 145.6, 21.1)},
    Headlamp_sprites = {Vector(-37.6, 145.7, 21), Vector(37.6, 145.7, 21)},
    Rearlight_sprites = {Vector(45.6, -146.2, 27.2), Vector(-45.6, -146.2, 27.2)},
    Brakelight_sprites = {Vector(45.6, -146.2, 27.2), Vector(-45.6, -146.2, 27.2)}
}

list.Set("simfphys_lights", "conapc", light_table)

light_table = {
    L_HeadLampPos = Vector(32.7, 79.5, 29.0),
    L_HeadLampAng = Angle(15, 90, 0),
    R_HeadLampPos = Vector(-30.75, 79.5, 28.9),
    R_HeadLampAng = Angle(15, 90, 0),
    L_RearLampPos = Vector(15.9, -139.2, 53),
    L_RearLampAng = Angle(40, -90, 0),
    R_RearLampPos = Vector(-17.44, -139.2, 53),
    R_RearLampAng = Angle(40, -90, 0),
    Headlight_sprites = {Vector(-34.5, 77.5, 29), Vector(36.4, 77.5, 29.5), Vector(-27.1, 77.5, 29), Vector(29, 77.5, 29.5)},
    Headlamp_sprites = {
        {
            pos = Vector(-34.5, 77.5, 29),
            size = 60
        },
        {
            pos = Vector(36.4, 77.5, 29.5),
            size = 60
        },
        {
            pos = Vector(-27.1, 77.5, 29),
            size = 60
        },
        {
            pos = Vector(29, 77.5, 29.5),
            size = 60
        },
    },
    Rearlight_sprites = {Vector(25.8, -139.2, 53), Vector(24.28, -139.2, 53), Vector(22.76, -139.2, 53), Vector(21.24, -139.2, 53), Vector(19.72, -139.2, 53), Vector(18.2, -139.2, 53), Vector(16.68, -139.2, 53), Vector(15.16, -139.2, 53), Vector(13.64, -139.2, 53), Vector(12.12, -139.2, 53), Vector(10.6, -139.2, 53), Vector(9.08, -139.2, 53), Vector(7.56, -139.2, 53), Vector(6.04, -139.2, 53), Vector(-27.32, -139.2, 53), Vector(-25.8, -139.2, 53), Vector(-24.28, -139.2, 53), Vector(-22.76, -139.2, 53), Vector(-21.24, -139.2, 53), Vector(-19.72, -139.2, 53), Vector(-18.2, -139.2, 53), Vector(-16.68, -139.2, 53), Vector(-15.16, -139.2, 53), Vector(-13.64, -139.2, 53), Vector(-12.12, -139.2, 53), Vector(-10.6, -139.2, 53), Vector(-9.08, -139.2, 53), Vector(-7.56, -139.2, 53)},
    Brakelight_sprites = {Vector(25.8, -139.2, 53), Vector(24.28, -139.2, 53), Vector(22.76, -139.2, 53), Vector(21.24, -139.2, 53), Vector(19.72, -139.2, 53), Vector(18.2, -139.2, 53), Vector(16.68, -139.2, 53), Vector(15.16, -139.2, 53), Vector(13.64, -139.2, 53), Vector(12.12, -139.2, 53), Vector(10.6, -139.2, 53), Vector(9.08, -139.2, 53), Vector(7.56, -139.2, 53), Vector(6.04, -139.2, 53), Vector(-27.32, -139.2, 53), Vector(-25.8, -139.2, 53), Vector(-24.28, -139.2, 53), Vector(-22.76, -139.2, 53), Vector(-21.24, -139.2, 53), Vector(-19.72, -139.2, 53), Vector(-18.2, -139.2, 53), Vector(-16.68, -139.2, 53), Vector(-15.16, -139.2, 53), Vector(-13.64, -139.2, 53), Vector(-12.12, -139.2, 53), Vector(-10.6, -139.2, 53), Vector(-9.08, -139.2, 53), Vector(-7.56, -139.2, 53)},
    Turnsignal_sprites = {
        Left = {
            {
                pos = Vector(-34.5, 77.5, 29),
                size = 80,
                material = "sprites/light_ignorez",
                color = Color(255, 200, 0, 200)
            },
            {
                pos = Vector(-34.5, 77.5, 29),
                size = 40,
                color = Color(255, 200, 0, 200)
            },
            {
                pos = Vector(-34.73, -139.52, 52.38),
                material = "sprites/light_ignorez",
                size = 40,
                color = Color(255, 60, 0, 125)
            },
            {
                pos = Vector(-34.73, -139.52, 52.38),
                size = 80,
                color = Color(255, 0, 0, 90)
            },
        },
        Right = {
            {
                pos = Vector(36, 77.5, 29),
                size = 80,
                material = "sprites/light_ignorez",
                color = Color(255, 200, 0, 200)
            },
            {
                pos = Vector(36, 77.5, 29),
                size = 40,
                color = Color(255, 200, 0, 200)
            },
            {
                pos = Vector(33.23, -139.52, 52.38),
                material = "sprites/light_ignorez",
                size = 40,
                color = Color(255, 60, 0, 125)
            },
            {
                pos = Vector(33.23, -139.52, 52.38),
                size = 80,
                color = Color(255, 0, 0, 90)
            },
        },
    },
}

list.Set("simfphys_lights", "jalopy", light_table)

light_table = {
    L_HeadLampPos = Vector(-11, 55, 35),
    L_HeadLampAng = Angle(20, 90, 0),
    R_HeadLampPos = Vector(11, 55, 35),
    R_HeadLampAng = Angle(20, 90, 0),
    L_RearLampPos = Vector(-14.9, -99.9, 39.13),
    L_RearLampAng = Angle(40, -90, 0),
    Headlight_sprites = {Vector(-11, 57, 38.8), Vector(11, 57, 38.8)},
    Headlamp_sprites = {Vector(-11, 57, 38.8), Vector(11, 57, 38.8)},
    Rearlight_sprites = {Vector(-14.9, -101, 39.13)},
    Brakelight_sprites = {Vector(-14.9, -101, 39.1)},
}

list.Set("simfphys_lights", "jeep", light_table)