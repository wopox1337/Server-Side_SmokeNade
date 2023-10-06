<p align="center">
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/bfa089b0-932b-4282-a4e6-9943265d0028"
        width="320"
        height="240" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/d079a782-31d8-4b69-8efc-d4db47a0b4c3"
        width="320"
        height="240" /><br>
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/f935dbd9-6870-4889-b618-ca1c7ccbfc38"
        width="320"
        height="240" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/d975b3d4-c69b-4a5b-a11c-fbca2fc7e310"
        width="320"
        height="240" />
</p>


<p align="center">
    Is an AMXModX plugin that enhances the smoke grenade effects in <a href="https://store.steampowered.com/app/10/CounterStrike/">Counter-Strike 1.6</a> (and CS: Condition Zero).
</p>

<p align="center">
    <a href="https://github.com/wopox1337/ServerSide_SmokeNade/releases/latest">
        <img
            src="https://img.shields.io/github/downloads/wopox1337/ServerSide_SmokeNade/total?label=Download%40latest&style=flat-square&logo=github&logoColor=white"
            alt="Build status"
        >
    </a>
    <a href="https://github.com/wopox1337/ServerSide_SmokeNade/actions">
        <img
            src="https://img.shields.io/github/actions/workflow/status/wopox1337/ServerSide_SmokeNade/CI.yml?branch=master&style=flat-square&logo=github&logoColor=white"
            alt="Build status"
        >
    </a>
    <a href="https://github.com/wopox1337/ServerSide_SmokeNade/releases">
        <img
            src="https://img.shields.io/github/v/release/wopox1337/ServerSide_SmokeNade?include_prereleases&style=flat-square&logo=github&logoColor=white"
            alt="Release"
        >
    </a>
    <a href="https://www.amxmodx.org/downloads-new.php">
        <img
            src="https://img.shields.io/badge/AMXModX-%3E%3D1.9.0-blue?style=flat-square"
            alt="AMXModX dependency"
        >
        </a>
</p>

## About
This plugin recreates smoke grenade effects (puffs of smoke) on the server side,
provides a more realistic look to smoke grenades in the game
(as it was changed in later iterations of the game such as CS:S, CS:GO, CS2).

### Why is it needed
The default smoke sprite (`sprites/gas_puff_01.spr`) is too transparent
and doesn't allow you to take advantage of the smoke grenade in gameplay.

### Advantages over standard game smoke
- Improved transparency of the smoke cloud;
- Fixed poor smoke density in 16-bit video game mode;
- Smoke doesn't disappear on HLTV;
- Smoke can't be abused by reconnecting to the server;
- Smoke is always created (even if the client has a congested network channel);
- Ability to change the visual look of the smoke cloud.

### Advantages to other similar plugins:
- Ability to set any custom sprite to display smoke;
- Client FPS doesn't drop much;
- Server FPS doesn't drop much;
- The server doesn't flood the client's network channel to display the smoke cloud;
- Doesn't break compatibility with the game:
    - Bots understand where smoke is located;
    - Cannot see nickname through smoke (mp_playerid);
    - Hostages can react to smoke grenade;
    - Overview map can show smokes.
- Easy to adjust the color, duration and performance of the smoke cloud;
- No render bugs when positioning the smoke cloud on water;
- Smoke cloud has a very close to the original visual appearance (authenticity);
- Smoke cloud doesn't stay in a new round;
- Cannot be abused with the client command `fastsprites`;
- Smoke doesn't disappear before its lifetime expires;
- Smoke doesn't disappear if the player's internet connection is poor;
- Smoke doesn't disappear if you move away from it.
- Smoke doesn't flicker.

### How it works
The plugin blocks the sending of the event to the game client
and recreates smoke clubs using server-side entities,
exactly repeating the shape and animation of the standard smoke.

### Important note
> If the smoke effect is fully recreated (`amx_smokegren_replacemode` == `3`), the server load is increased 2x.

> Using full smoke grenade recreation (3) is not recommended for servers
that have more than 10 players online (e.g. servers with 32\32 players online).

> Also be careful with setting the parameter `amx_smokegren_pieces`,
it directly affects the shape and quality of the smoke grenade,
affecting the server load when using smoke grenades.

> In special cases it may be necessary to set a larger number of allocated edicts
using the startup parameter `-num_edicts` (at least `2000`).

### Calculations
With standard parameters:
- amx_smokegren_replacemode `1`
- amx_smokegren_pieces `8`

One smoke cloud will create `17` entities.

At maximum parameters:
- amx_smokegren_replacemode `3`
- amx_smokegren_pieces `10`

One smoke cloud will create `41` entities.

## Acknowledgements:
- [ReGameDLL_CS](https://github.com/s1lentq/ReGameDLL_CS) authors;
- To everyone who has previously tried custom smoke and their code examples;
- To the Counter-Strike developers (for their bugs, including);
- Community https://Dev-CS.ru/ (the most friendly and experienced team of developers).

## TODO:
- Correct the remaining visual inaccuracies.
- Implement API;
- Improve integration with GameDLL;
- Optimize sprite;

## Known bugs:
- If the smoke duration changes, the grenade entity may not match the smoke duration.
- Tell me

## Downloads
- [Release builds](https://github.com/wopox1337/ServerSide_SmokeNade/releases)
- [Dev builds](https://github.com/wopox1337/ServerSide_SmokeNade/actions/workflows/CI.yml)

## Contacts
- https://dev-cs.ru/members/4/
