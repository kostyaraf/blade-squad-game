# blade-squad-game

Объединённый порт Power Blade 2 и Tokkyuu Shirei Solbrain на Godot:
выбор персонажа, выбор уровня и локальная игра вдвоём. Онлайн-режим пока
не реализован. Полная проходимость всех уровней ещё проверяется.

## Запуск

Открыть `game/project.godot` в Godot 4.6.1 и запустить проект. На macOS:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --path game
```

## Документация

- [Текущее состояние](docs/status_ver3.md)
- [Спецификация](docs/ver3_spec.md)
- [История изменений](docs/changes/README.md)
- [Чек-лист прохождений](docs/qa/playthrough-checklist.md)
- [Нерешённые вопросы игровых правил](docs/pb3-gameplay-questions.md)
- [Правила работы с Godot и NES-проверками](.claude/skills/godot/SKILL.md)

## Проверки

```sh
python3 work/extract/verify_pb3_sol_exits.py
python3 work/extract/verify_pb3_playthrough.py
python3 work/extract/verify_all.py --list
```

Стенды используют путь к Godot, указанный выше. Диагностическая установка
героев у препятствия и непрерывное прохождение обычными нажатиями учитываются
отдельно; автоматическая проверка сама по себе не закрывает уровень.
