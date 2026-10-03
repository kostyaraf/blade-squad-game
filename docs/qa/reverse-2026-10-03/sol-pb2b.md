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

## Полные прохождения

Пока не подтверждены.

## Баги

Обход продолжается; новых подтверждённых дефектов пока нет.

## Нужна анимация

Пока не обнаружено.
