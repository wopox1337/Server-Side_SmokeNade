<p align="center">
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/bfa089b0-932b-4282-a4e6-9943265d0028"
        width="320"
        height="240" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/d079a782-31d8-4b69-8efc-d4db47a0b4c3"
        width="320"
        height="240" />
    <br>
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/f935dbd9-6870-4889-b618-ca1c7ccbfc38"
        width="320"
        height="240" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/d975b3d4-c69b-4a5b-a11c-fbca2fc7e310"
        width="320"
        height="240" />
    <br>
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/a5d361ff-349f-495e-a8a5-07106b0f45ef"
        width="128"
        height="96" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/a526d5cb-ea7f-4bbc-b422-03f73c7ab463"
        width="128"
        height="96" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/d24b6757-51c9-4729-a6c4-f68cca65bd76"
        width="128"
        height="96" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/d7d7e564-2a79-41d9-aa2f-fa2d3476e333"
        width="128"
        height="96" />
    <img
        src="https://github.com/wopox1337/Server-Side_SmokeNade/assets/18553678/0d8ac844-143e-4903-b304-af254279154c"
        width="128"
        height="96" />
    <br>    
    Видео-превью: <a href="https://youtu.be/R45oCX-7y3g">#1</a> | <a href="https://youtu.be/rxIxt0shDO0">#2</a>
</p>

<p align="center">
    Это плагин AMXModX, который улучшает эффекты дымовых гранат в <a href="https://store.steampowered.com/app/10/CounterStrike/">Counter-Strike 1.6</a> (и CS: Condition Zero).
</p>

<p align="center">
    <a href="https://github.com/wopox1337/ServerSide_SmokeNade/releases/latest">
        <img
            src="https://img.shields.io/github/downloads/wopox1337/ServerSide_SmokeNade/total?label=Скачать%40последняя версия&style=flat-square&logo=github&logoColor=white"
            alt="Статус сборки"
        >
    </a>
    <a href="https://github.com/wopox1337/ServerSide_SmokeNade/actions">
        <img
            src="https://img.shields.io/github/actions/workflow/status/wopox1337/ServerSide_SmokeNade/CI.yml?branch=master&style=flat-square&logo=github&logoColor=white"
            alt="Статус сборки"
        >
    </a>
    <a href="https://github.com/wopox1337/ServerSide_SmokeNade/releases">
        <img
            src="https://img.shields.io/github/v/release/wopox1337/ServerSide_SmokeNade?include_prereleases&style=flat-square&logo=github&logoColor=white"
            alt="Релиз"
        >
    </a>
    <a href="https://www.amxmodx.org/downloads-new.php">
        <img
            src="https://img.shields.io/badge/AMXModX-%3E%3D1.9.0-blue?style=flat-square"
            alt="Зависимость от AMXModX"
        >
        </a>
</p>

## О плагине
Этот плагин воссоздает эффекты дымовых гранат (облака дыма) на стороне сервера,
придавая более реалистичный вид дымовым гранатам в игре,
(как это было изменено в последующих версиях игры, таких как CS:S, CS:GO, CS2).

### Почему он нужен
Стандартный спрайт для дымовых гранат (`sprites/gas_puff_01.spr`) слишком прозрачен
и не позволяет вам использовать дымовые гранаты в игре.

### Преимущества перед стандартным дымом в игре
- Улучшенная прозрачность дымового облака;
- Исправлена низкая плотность дыма в 16-битном видео-режиме игры;
- Дым не исчезает на HLTV;
- Нельзя злоупотреблять дымом, переподключаясь к серверу;
- Дым всегда создается (даже если у клиента перегружен канал сети);
- Есть возможность изменять внешний вид дымового облака.

### Преимущества перед другими похожими плагинами:
- Возможность установить любой пользовательский спрайт для отображения дыма;
- Сильного падения кадров в секунду у клиента не происходит;
- Сильного падения кадров в секунду у сервера не происходит;
- Сервер не заливает сетевой канал клиента для отображения дымового облака;
- Не нарушает совместимость с игрой:
    - Боты понимают, где находится дым;
    - Нельзя увидеть никнейм через дым (mp_playerid);
    - Заложники могут реагировать на дымовые гранаты;
    - Обзорная карта может показывать дым.
- Легко настроить цвет, продолжительность и производительность дымового облака;
- Нет багов рендеринга при размещении дымового облака на воде;
- Дымовое облако имеет очень близкий к оригиналу внешний вид (аутентичность);
- Дымовое облако не остается в новом раунде;
- Нельзя злоупотреблять клиентской командой `fastsprites`;
- Дым не исчезает до истечения его времени жизни;
- Дым не исчезает, если интернет-соединение игрока плохое;
- Дым не исчезает, если вы отдаляетесь от него.
- Дым не мерцает.

### Как это работает
Плагин блокирует отправку события клиенту игры
и воссоздает дымовые облака с использованием серверных сущностей,
точно повторяя форму и анимацию стандартного дыма.

### Важное замечание
> Если эффект дыма полностью воссоздан (`amx_smokegren_replacemode` == `3`), нагрузка на сервер увеличивается в 2 раза.

> Использование полного воссоздания дымовой гранаты (3) не рекомендуется для серверов,
где более 10 игроков онлайн (например, серверы с 32\32 игроками онлайн).

> Также будьте осторожны с установкой параметра `amx_smokegren_pieces`,
он напрямую влияет на форму и качество дымовой гранаты,
влияя на нагрузку сервера при использовании дымовых гранат.

> В особых случаях может потребоваться установить большее количество выделенных edicts,
используя параметр запуска `-num_edicts` (по крайней мере, `2000`).

### Расчеты
С стандартными параметрами:
- amx_smokegren_replacemode `1`
- amx_smokegren_pieces `8`

Один дымовой облако создаст `17` сущностей.

При максимальных параметрах:
- amx_smokegren_replacemode `3`
- amx_smokegren_pieces `10`

Один дымовой облако создаст `41` сущность.

## Признательность:
- Авторам [ReGameDLL_CS](https://github.com/s1lentq/ReGameDLL_CS);
- Всем, кто ранее пробовал пользовательский дым и предоставил свои примеры кода;
- Разработчикам Counter-Strike (за их баги, включая);
- Сообществу https://Dev-CS.ru/ (самой дружелюбной и опытной команде разработчиков).

## Планы:
- Исправить оставшиеся визуальные неточности.
- Реализовать API;
- Улучшить интеграцию с GameDLL;
- Оптимизировать спрайт;

## Известные баги:
- Если продолжительность дыма меняется, сущность гранаты может не соответствовать продолжительности дыма.
- Скажите мне

## Загрузки
- [Готовые сборки](https://github.com/wopox1337/ServerSide_SmokeNade/releases)
- [Сборки для разработки](https://github.com/wopox1337/ServerSide_SmokeNade/actions/workflows/CI.yml)

## Контакты
- https://dev-cs.ru/members/4/
