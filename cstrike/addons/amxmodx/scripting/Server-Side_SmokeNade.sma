/**
 * Server-Side SmokeNade by Sergey Shorokhov
 *   06.10.2023
 *   https://github.com/wopox1337/
 *
 *
 * Description:
 *   Is an AMXModX plugin that enhances the smoke grenade effects in Counter-Strike 1.6 (and Counter-Strike Condition Zero).
 *
 *   This plugin recreates smoke grenade effects (puffs of smoke) on the server side,
 *   provides a more realistic look to smoke grenades in the game
 *   (as it was changed in later iterations of the game such as CS:S, CS:GO, CS2).
 *
 * Why is it needed:
 *   The default smoke sprite (`sprites/gas_puff_01.spr`) is too transparent
 *   and doesn't allow you to take advantage of the smoke grenade in gameplay.
 *
 * How it works:
 *   The plugin blocks the sending of the event to the game client
 *   and recreates smoke clubs using server-side entities,
 *   exactly repeating the shape and animation of the standard smoke.
 *
 * Important note:
 *   If the smoke effect is fully recreated (`amx_smokegren_replacemode` == 3), the load is increased 2x.
 *
 *   Using full smoke grenade recreation (3) is not recommended for servers
 *   that have more than 10 players online (e.g. servers with 32\32 players online).
 *
 *   Also be careful with setting the parameter `amx_smokegren_pieces`,
 *   it directly affects the shape and quality of the smoke grenade,
 *   affecting the server load when using smoke grenades.
 *
 *   In special cases it may be necessary to set a larger number of allocated edicts
 *   using the startup parameter `-num_edicts` (at least 2000).
 *
 * Calculations.
 *   With standard parameters:
 *     - amx_smokegren_replacemode 1
 *     - amx_smokegren_pieces 8
 *   One smoke cloud will create 17 entities.
 *
 *   At maximum parameters:
 *     - amx_smokegren_replacemode 3
 *     - amx_smokegren_pieces 10
 *   One smoke cloud will create 41 entities.
 *
 * Advantages over standard game smoke:
 *   - Improved transparency of the smoke cloud;
 *   - Fixed poor smoke density in 16-bit video game mode;
 *   - Smoke doesn't disappear on HLTV;
 *   - Smoke can't be abused by reconnecting to the server;
 *   - Smoke is always created (even if the client has a congested network channel);
 *   - Ability to change the visual look of the smoke cloud.
 *
 * Advantages to other similar plugins:
 *   - Ability to set any custom sprite to display smoke;
 *   - Client FPS doesn't drop much;
 *   - Server FPS doesn't drop much;
 *   - The server doesn't flood the client's network channel to display the smoke cloud;
 *   - Doesn't break compatibility with the game:
 *       - Bots understand where smoke is located;
 *       - Cannot see nickname through smoke (mp_playerid);
 *       - Hostages can react to smoke grenade;
 *       - Overview map can show smokes.
 *   - Easy to adjust the color, duration and performance of the smoke cloud;
 *   - No render bugs when positioning the smoke cloud on water;
 *   - Smoke cloud has a very close to the original visual appearance (authenticity);
 *   - Smoke cloud doesn't stay in a new round;
 *   - Cannot be abused with the client command `fastsprites`;
 *   - Smoke doesn't disappear before its lifetime expires;
 *   - Smoke doesn't disappear if the player's internet connection is poor;
 *   - Smoke doesn't disappear if you move away from it.
 *   - Smoke doesn't flicker.
 *
 * Acknowledgements:
 *   - ReGameDLL authors;
 *   - To everyone who has previously tried custom smoke and their code examples;
 *   - To the Counter-Strike developers (for their bugs, including);
 *   - Community https://Dev-CS.ru/ (the most friendly and experienced team of developers).
 *
 * TODO:
 *   - Correct the remaining visual inaccuracies.
 *   - Implement API;
 *   - Improve integration with GameDLL;
 *   - Optimize sprite;
 *
 * Known bugs:
 *   - If the smoke duration changes, the grenade entity may not match the smoke duration.
 *
 */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <xs>


public stock const PluginName[]        = "Server-Side SmokeNade"
public stock const PluginVersion[]     = "1.0.0-beta.1"
public stock const PluginAuthor[]      = "Sergey Shorokhov"
public stock const PluginURL[]         = "https://github.com/wopox1337/ServerSide_SmokeNade"
public stock const PluginDescription[] = "Replacing client smoke with Server-Side SmokeNade."


static const g_sprFile[]        = "sprites/gas_puff_02.spr"
// https://github.com/s1lentq/ReGameDLL_CS/blob/1e49d947927e7f6f2fd70d8398e4a9519a34450a/regamedll/dlls/subs.h#L31
static const g_baseClassname[]  = "info_null"
static const g_className[]      = "particle_smokegren"

enum _: CustomPEV {
    _pev_spawnInside    = pev_iuser1,
    _pev_popCreated     = pev_iuser2,

    _pev_scaleSpeed     = pev_fuser2,
    _pev_dieTime        = pev_fuser3,
    _pev_timeCreated    = pev_fuser4,
}

static        amx_smokegren_replacemode
static        amx_smokegren_fix_waterrender
static Float: amx_smokegren_pieces
static Float: amx_smokegren_color_r
static Float: amx_smokegren_color_g
static Float: amx_smokegren_color_b
static Float: amx_smokegren_color_a
static Float: amx_smokegren_lifetime

public plugin_precache() {
    #if (!defined PluginDescription)
        register_plugin(PluginName, PluginVersion, PluginAuthor)
    #endif

    StartupCheck()

    precache_model(g_sprFile)
}

public plugin_init() {
    register_event("HLTV", "CSGameRules_RestartRound", "a", "1=0", "2=0")

    register_forward(FM_PlaybackEvent, "EV_Playback", ._post = false)
    RegisterHam(Ham_Think, g_baseClassname, "CNullEntity_Think", .Post = false)

    Create_ConVars(.createConfigFile = true)

    if (amx_smokegren_fix_waterrender)
        ChangeRenderMode("func_water", kRenderNormal)
}

public EV_Playback(flags, invoker, eventIndex, Float: delay, Float: origin[3],
                    Float: angles[3], Float: fparam1, Float: fparam2,
                    iparam1, iparam2, bparam1, bparam2) {

    // https://github.com/s1lentq/ReGameDLL_CS/blob/1e49d947927e7f6f2fd70d8398e4a9519a34450a/regamedll/dlls/wpn_shared/wpn_smokegrenade.cpp#L34
    static m_usCreateSmoke
    if (!m_usCreateSmoke)
        m_usCreateSmoke = engfunc(EngFunc_PrecacheEvent, 1, "events/createsmoke.sc")

    if (eventIndex != m_usCreateSmoke)
        return FMRES_IGNORED

    new bool: isFirstSmoke = (iparam2 == 1)
    if (!isFirstSmoke)
        return FMRES_IGNORED

    new bool: isSmokeReplaced = EV_CreateSmoke(origin)
    return isSmokeReplaced ? FMRES_SUPERCEDE : FMRES_IGNORED
}

static bool: EV_CreateSmoke(const Float: origin[3]) {
    // https://github.com/s1lentq/ReGameDLL_CS/blob/1e49d947927e7f6f2fd70d8398e4a9519a34450a/regamedll/dlls/ggrenade.cpp#L603
    if (amx_smokegren_replacemode == 0)
        return false

    CreateGasInside(origin, GetColorArray(), amx_smokegren_color_a)

    if (amx_smokegren_replacemode == 3)
        CreateSmokePop(origin, GetColorArray(), amx_smokegren_color_a)

    if (amx_smokegren_replacemode >= 2)
        return true

    return false
}

public CNullEntity_Think(const entity) {
    static classname[32]
    pev(entity, pev_classname, classname, charsmax(classname))

    if (strcmp(classname, g_className) != 0)
        return

    CPartSmokeGrenade_Think(entity)
}

public CSGameRules_RestartRound() {
    new entity = MaxClients
    while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", g_className))) {
        set_pev(entity, pev_flags, pev(entity, pev_flags) | FL_KILLME)

        #if (defined DEBUG)
            entityCount(-1)
        #endif
    }
}

static CPartSmokeGrenade_Create(const Float: origin[3], const Float: velocity[3],
                        const model[], const Float: scale,
                        const Float: color[3] = { 175.0, 175.0, 175.0 }, const Float: brightness = 190.0) {

    new entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, g_baseClassname))
    set_pev(entity, pev_classname, g_className)

    engfunc(EngFunc_SetModel, entity, model)
    engfunc(EngFunc_SetOrigin, entity, origin)
    set_pev(entity, pev_velocity, velocity)
    set_pev(entity, pev_movetype, MOVETYPE_NOCLIP)
    set_pev(entity, pev_gravity, 0.0)
    set_pev(entity, pev_scale, scale)

    set_pev(entity, pev_rendermode, kRenderTransAlpha)
    set_pev(entity, pev_rendercolor, color)
    set_pev(entity, pev_renderamt, brightness)

    #if (defined DEBUG)
        client_print(0, print_center, "Smoke puffs entity count: `%i`", entityCount(1))
    #endif

    return entity
}

static CPartSmokeGrenade_Think(const entity) {
    if (!pev(entity, _pev_popCreated)) {
        set_pev(entity, _pev_popCreated, true)

        static Float: velocity[3]
        pev(entity, pev_velocity, velocity)
        xs_vec_mul_scalar(velocity, 0.035, velocity)

        set_pev(entity, pev_velocity, velocity, sizeof(velocity))
    }

    // Main smoke part time
    new Float: gametime = get_gametime()

    new Float: remainingTime = pev(entity, _pev_dieTime) - gametime
    static Float: brightness
    pev(entity, pev_renderamt, brightness)

    if (brightness >= 255.0 && remainingTime < 3.0) {
        set_pev(entity, _pev_scaleSpeed, 0.0)
        set_pev(entity, _pev_timeCreated, gametime)
        set_pev(entity, pev_avelocity, Float: {0.0, 0.0, 0.0})
    }

    if (remainingTime < 5.0) {
        if (brightness > 0.0) {
            brightness -= (gametime - pev(entity, _pev_timeCreated)) * 0.1
            set_pev(entity, pev_renderamt, brightness)
        }

        if (brightness < 0.0) {
            brightness = 0.0
            set_pev(entity, pev_renderamt, brightness)

            set_pev(entity, _pev_dieTime, gametime)
        }
    }

    static Float: scale
    pev(entity, pev_scale, scale)
    scale += pev(entity, _pev_scaleSpeed)
    set_pev(entity, pev_scale, scale)

    const Float: thinkFreq = 0.05
    if (pev(entity, _pev_dieTime) > gametime) {
        set_pev(entity, pev_nextthink, gametime + thinkFreq)

        return
    }

    // Dissapear part
    const Float: divider = 2.5

    static Float: renderAmt
    pev(entity, pev_renderamt, renderAmt)
    renderAmt = floatmax(0.0, renderAmt - (renderAmt / divider))
    set_pev(entity, pev_renderamt, renderAmt)

    pev(entity, pev_scale, scale)
    scale = floatmax(0.0, scale - (scale / divider))
    set_pev(entity, pev_scale, scale)

    if (renderAmt > 1.0) {
        const Float: fadeSpeed = 0.05
        set_pev(entity, pev_nextthink, gametime + fadeSpeed)

        return
    }

    // Kill particle
    set_pev(entity, pev_effects, EF_NODRAW)
    set_pev(entity, pev_flags, pev(entity, pev_flags) | FL_KILLME)

    #if (defined DEBUG)
        entityCount(-1)
    #endif
}

static CreateGasSmoke(const Float: origin[3], const Float: velocity[3],
                    const Float: color[3],
                    Float: brightness, bool: insideCloud) {

    new entity = CPartSmokeGrenade_Create(
        .origin = origin,
        .velocity = velocity,
        .model = g_sprFile,
        .scale = random_float(2.5, 4.0),
        .color = color,
        .brightness = brightness
    )

    static Float: avelocity[3]
    new Float: gametime = get_gametime()
    new Float: dieTime = gametime + amx_smokegren_lifetime

    const Float: scaleFactor = 1.42
    const Float: maxRotateVelocity = 10.0
    const Float: scaleSpeed = 0.1

    if (insideCloud) {
        avelocity[2] = random_float(-(maxRotateVelocity / scaleFactor), (maxRotateVelocity / scaleFactor))
        set_pev(entity, _pev_scaleSpeed, scaleSpeed / scaleFactor)
        set_pev(entity, _pev_dieTime, dieTime)
    } else {
        avelocity[2] = random_float(-maxRotateVelocity, maxRotateVelocity)
        set_pev(entity, _pev_scaleSpeed, scaleSpeed)
        set_pev(entity, _pev_dieTime, dieTime - (amx_smokegren_lifetime / 3.0))
    }

    set_pev(entity, _pev_spawnInside, insideCloud)
    set_pev(entity, pev_avelocity, avelocity)
    set_pev(entity, pev_nextthink, gametime + 0.15)

    return entity
}

static CreateSmokePop(const Float: origin[3], Float: color[3], Float: brightness) {
    new Float: step = 360.0 / amx_smokegren_pieces

    static Float: angles[3]
    static Float: vForward[3], Float: vRight[3], Float: vUp[3]

    for (new Float: angleStep = 0.0; angleStep < 360.0; angleStep += step) {
        angles[XS_YAW] += angleStep

        engfunc(EngFunc_AngleVectors, angles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        static Float: velocity[3]
        for (new i; i < sizeof(velocity); i++) {
            velocity[i] = (vForward[i] * 375) + (vUp[i] * 165)
        }

        CreateGasSmoke(origin, velocity, color, brightness, .insideCloud = false)
    }

    for (new Float: angleStep = 0.0; angleStep < 360.0; angleStep += step) {
        angles[XS_YAW] += angleStep

        engfunc(EngFunc_AngleVectors, angles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        new Float: velocity[3]
        for (new i; i < sizeof(velocity); i++) {
            velocity[i] = (vForward[i] * 375) + (vUp[i] * 265)
        }

        CreateGasSmoke(origin, velocity, color, brightness, .insideCloud = false)
    }

    #if (defined CLIENT_WIERD_CODE_DONT_USE_THIS)
    {
        angles[XS_YAW] = 45.0

        engfunc(EngFunc_AngleVectors, angles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        static Float: velocity[3]
        for (new i; i < sizeof(velocity); i++) {
            velocity[i] = (vForward[i] * 375) + (vUp[i] * 120)
        }

        CreateGasSmoke(origin , velocity, color, brightness, .insideCloud = false)

        angles[XS_YAW] = 270.0
        engfunc(EngFunc_AngleVectors, angles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        for (new i; i < sizeof(velocity); i++) {
            velocity[i] = (vForward[i] * 375) + (vUp[i] * 120)
        }

        CreateGasSmoke(origin, velocity, color, brightness, .insideCloud = false)
    }
    #endif
}

static CreateGasInside(const Float: origin[3], Float: color[3], const Float: brightness) {
    new Float: step = 360.0 / amx_smokegren_pieces

    static Float: vAngles[3]
    static Float: vForward[3], Float: vRight[3], Float: vUp[3]

    for (new Float: fAngleStep = 0.0; fAngleStep < 360.0; fAngleStep += step) {
        vAngles[XS_YAW] += fAngleStep

        engfunc(EngFunc_AngleVectors, vAngles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        new Float: _origin[3]
        for (new i; i < sizeof(_origin); i++) {
            _origin[i] = origin[i] + (vForward[i] * random_num(90, 110)) + (vUp[i] * 45)
        }

        CreateGasSmoke(
            _origin,
            Float: {0.0, 0.0, 0.0},
            color,
            brightness,
            .insideCloud = true
        )
    }

    for (new Float: fAngleStep = 0.0; fAngleStep < 360.0; fAngleStep += step) {
        vAngles[XS_YAW] += fAngleStep

        engfunc(EngFunc_AngleVectors, vAngles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        new Float: _origin[3]
        for (new i; i < sizeof(_origin); i++) {
            _origin[i] = origin[i] + (vForward[i] * 90) + (vUp[i] * 60)
        }

        CreateGasSmoke(
            _origin,
            Float: {0.0, 0.0, 0.0},
            color,
            brightness,
            .insideCloud = true
        )
    }

    CreateGasSmoke(
        origin,
        Float: {0.0, 0.0, 0.0},
        color,
        brightness,
        .insideCloud = false
    )

    #if (defined CLIENT_WIERD_CODE_DONT_USE_THIS)
    {
        vAngles[XS_YAW] = 45.0

        engfunc(EngFunc_AngleVectors, vAngles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        static Float: _origin[3]
        for (new i; i < sizeof(_origin); i++) {
            _origin[i] = origin[i] + (vForward[i] * 45) + (vUp[i] * 55)
        }

        CreateGasSmoke(
            _origin,
            Float: {0.0, 0.0, 0.0},
            color,
            brightness,
            .insideCloud = false
        )

        _origin = Float: {0.0, 0.0, 0.0}

        vAngles[XS_YAW] = 270.0

        engfunc(EngFunc_AngleVectors, vAngles, vForward, vRight, vUp)
        xs_vec_normalize(vForward, vForward)

        for (new i; i < sizeof(_origin); i++) {
            _origin[i] = origin[i] + (vForward[i] * 45) + (vUp[i] * 55)
        }

        CreateGasSmoke(
            _origin,
            Float: {0.0, 0.0, 0.0},
            color,
            brightness,
            .insideCloud = false
        )
    }
    #endif
}

static Create_ConVars(const bool: createConfigFile = true) {
    bind_pcvar_num(
        create_cvar(
            "amx_smokegren_replacemode", "1",
            .has_min = true, .min_val = 0.0,
            .has_max = true, .max_val = 3.0,
            .description = "0 - disabled (don't change client smoke); ^n\
                            1 - main cloud over default smoke cloud; ^n\
                            2 - main cloud only (optimization*); ^n\
                            3 - fully recreation (2x load)."
        ),
        amx_smokegren_replacemode
    )

    bind_pcvar_num(
        create_cvar(
            "amx_smokegren_fix_waterrender", "1",
            .has_min = true, .min_val = 0.0,
            .has_max = true, .max_val = 1.0,
            .description = "Fix the rendering of smoke cloud in water."
        ),
        amx_smokegren_fix_waterrender
    )

    bind_pcvar_float(
        create_cvar(
            "amx_smokegren_pieces", "8",
            .has_min = true, .min_val = 2.0,
            .has_max = true, .max_val = 10.0,
            .description = "Number of smoke particles for one smoke cloud."
        ),
        amx_smokegren_pieces
    )

    bind_pcvar_float(
        create_cvar(
            "amx_smokegren_color_r", "175",
            .has_min = true, .min_val = 1.0,
            .has_max = true, .max_val = 255.0,
            .description = "Red component of cloud color."
        ),
        amx_smokegren_color_r
    )

    bind_pcvar_float(
        create_cvar(
            "amx_smokegren_color_g", "175",
            .has_min = true, .min_val = 1.0,
            .has_max = true, .max_val = 255.0,
            .description = "Green component of cloud color."
        ),
        amx_smokegren_color_g
    )

    bind_pcvar_float(
        create_cvar(
            "amx_smokegren_color_b", "175.0",
            .has_min = true, .min_val = 1.0,
            .has_max = true, .max_val = 255.0,
            .description = "Blue component of cloud color."
        ),
        amx_smokegren_color_b
    )

    bind_pcvar_float(
        create_cvar(
            "amx_smokegren_color_a", "190.0",
            .has_min = true, .min_val = 0.0,
            .has_max = true, .max_val = 255.0,
            .description = "Alpha (transparency) component of cloud color. Client default is 190."
        ),
        amx_smokegren_color_a
    )

    bind_pcvar_float(
        create_cvar(
            "amx_smokegren_lifetime", "29.5",
            .has_min = true, .min_val = 6.0,
            .has_max = true, .max_val = 60.0,
            .description = "Smoke cloud lifetime (in seconds)."
        ),
        amx_smokegren_lifetime
    )

    if (createConfigFile) {
        AutoExecConfig()
    }
}

static Float: GetColorArray() {
    new Float: color[3]
    color[0] = amx_smokegren_color_r
    color[1] = amx_smokegren_color_g
    color[2] = amx_smokegren_color_b

    return color
}

static ChangeRenderMode(const classname[], const mode = kRenderNormal) {
    new entity = MaxClients
    while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname))) {
        set_pev(entity, pev_rendermode, mode)
    }
}

static StartupCheck() {
    if (!cstrike_running())
        set_fail_state("Plugin work is supported only for Counter-Strike mod!")

    if (!file_exists(g_sprFile))
        set_fail_state("The file `%s` is missing!", g_sprFile)
}

static stock entityCount(const add = 0) {
    static count
    count += add

    return count
}
