# sol-pb2b — Солбрайн на PB2, этапы 5–7

Герой `heroes:[1]`. Ветка `qa/sol-pb2b`. 2026-10-03.
BRIEF и skill godot применены. Быстрый обход — штатный вход каждой комнаты,
только обычные нажатия, без правки здоровья, позиции или объектов.
Меню: Start → Down → Start (оружие 8). Затем 30 кадров ожидания,
60 кадров движения со стрельбой и 40 кадров прыжка со стрельбой.
Направление — от стартового края к середине карты.
☐ означает: вход проверен, полное прохождение ещё не доказано.
Смерть в короткой попытке сама по себе не считается блокером.

## Быстрый обход входов

| Код | Статус | Запись | Тики | Результат / объекты |
|---|---|---|---:|---|
| p4.0 | ☐ | [ввод](../playthrough/p4.0-sol-SPB2-smoke/replay.json) | 135 | (617,103), HP 8, state $01; $13,$16 |
| p4.1 | ☐ | [ввод](../playthrough/p4.1-sol-SPB2-smoke/replay.json) | 135 | (105,615), HP 8, state $01; $0F,$47 |
| p4.2 | ☐ | [ввод](../playthrough/p4.2-sol-SPB2-smoke/replay.json) | 135 | (617,103), HP 7, state $01; $23,$38 |
| p4.3 | ☐ | [ввод](../playthrough/p4.3-sol-SPB2-smoke/replay.json) | 135 | (196,128), HP 8, state $00; $04,$0E |
| p4.4 | ☐ | [ввод](../playthrough/p4.4-sol-SPB2-smoke/replay.json) | 99 | TEAM DOWN - CHOOSE A LEVEL TO RETRY; $0F |
| p4.5 | ☐ | [ввод](../playthrough/p4.5-sol-SPB2-smoke/replay.json) | 135 | (105,80), HP 7, state $00; $13,$16,$23,$29,$2A |
| p4.6 | ☐ | [ввод](../playthrough/p4.6-sol-SPB2-smoke/replay.json) | 135 | (150,98), HP 8, state $01; $1D,$42 |
| p4.7 | ☐ | [ввод](../playthrough/p4.7-sol-SPB2-smoke/replay.json) | 135 | (121,395), HP 8, state $01; $08,$38,$42 |
| p4.8 | ☐ | [ввод](../playthrough/p4.8-sol-SPB2-smoke/replay.json) | 135 | (135,64), HP 8, state $00; $0A,$19,$1E,$1F |
| p4.9 | ☐ | [ввод](../playthrough/p4.9-sol-SPB2-smoke/replay.json) | 135 | (77,551), HP 8, state $01; $1A,$3C |
| p5.0 | ☐ | [ввод](../playthrough/p5.0-sol-SPB2-smoke/replay.json) | 135 | (135,808), HP 8, state $01;  |
| p5.1 | ☐ | [ввод](../playthrough/p5.1-sol-SPB2-smoke/replay.json) | 98 | TEAM DOWN - CHOOSE A LEVEL TO RETRY; $0D |
| p5.2 | ☐ | [ввод](../playthrough/p5.2-sol-SPB2-smoke/replay.json) | 135 | (161,96), HP 4, state $00; $34,$35,$36 |
| p5.3 | ☐ | [ввод](../playthrough/p5.3-sol-SPB2-smoke/replay.json) | 135 | (150,103), HP 8, state $01; $0F,$47 |
| p5.4 | ☐ | [ввод](../playthrough/p5.4-sol-SPB2-smoke/replay.json) | 135 | (150,96), HP 4, state $00; $34,$35,$36 |
| p5.5 | ☐ | [ввод](../playthrough/p5.5-sol-SPB2-smoke/replay.json) | 92 | TEAM DOWN - CHOOSE A LEVEL TO RETRY; $37 |
| p5.6 | ☐ | [ввод](../playthrough/p5.6-sol-SPB2-smoke/replay.json) | 135 | (105,144), HP 8, state $00; $04,$3A,$3B,$3C |
| p5.7 | ☐ | [ввод](../playthrough/p5.7-sol-SPB2-smoke/replay.json) | 92 | TEAM DOWN - CHOOSE A LEVEL TO RETRY; $04,$2F,$3E |
| p5.8 | ☐ | [ввод](../playthrough/p5.8-sol-SPB2-smoke/replay.json) | 135 | (121,144), HP 7, state $00; $02,$04,$20,$29,$2A |
| p5.9 | ☐ | [ввод](../playthrough/p5.9-sol-SPB2-smoke/replay.json) | 135 | (113,144), HP 8, state $00; $02,$04,$39,$42 |
| p5.10 | ☐ | [ввод](../playthrough/p5.10-sol-SPB2-smoke/replay.json) | 135 | (105,144), HP 7, state $00; $04,$1D,$40,$41,$43 |
| p5.11 | ☐ | [ввод](../playthrough/p5.11-sol-SPB2-smoke/replay.json) | 135 | (105,144), HP 5, state $00; $04,$20,$21,$38 |
| p5.12 | ☐ | [ввод](../playthrough/p5.12-sol-SPB2-smoke/replay.json) | 135 | (105,96), HP 6, state $00; $07,$0C,$20,$21 |
| p5.13 | ☐ | [ввод](../playthrough/p5.13-sol-SPB2-smoke/replay.json) | 92 | TEAM DOWN - CHOOSE A LEVEL TO RETRY; $21,$34,$35,$36 |
| p6.0 | ☐ | [ввод](../playthrough/p6.0-sol-SPB2-smoke/replay.json) | 135 | (150,119), HP 8, state $01; $05,$26,$48,$4F,$50 |
| p6.1 | ☐ | [ввод](../playthrough/p6.1-sol-SPB2-smoke/replay.json) | 135 | (142,51), HP 8, state $01; $05,$45,$51 |
| p6.2 | ☐ | [ввод](../playthrough/p6.2-sol-SPB2-smoke/replay.json) | 135 | (150,119), HP 6, state $01; $05,$4A,$52 |
| p6.3 | ☐ | [ввод](../playthrough/p6.3-sol-SPB2-smoke/replay.json) | 135 | (150,119), HP 6, state $01; $05,$53 |
| p6.4 | ☐ | [ввод](../playthrough/p6.4-sol-SPB2-smoke/replay.json) | 135 | (150,119), HP 6, state $01; $05,$4D,$54 |
| p6.5 | ☐ | [ввод](../playthrough/p6.5-sol-SPB2-smoke/replay.json) | 21 | TEAM DOWN - CHOOSE A LEVEL TO RETRY; $05,$55 |

## Полные прохождения

Пока не подтверждены.

## Баги

Обход продолжается; новых подтверждённых дефектов пока нет.

## Нужна анимация

Пока не обнаружено.
