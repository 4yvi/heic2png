# heic2png

Конвертер HEIC → PNG для macOS: минималистичное окно (drag & drop) и CLI. Без внешних зависимостей, всё собирается из консоли.

## Быстрый старт
```
make test      # 10 тестов (XCTest)
make run       # собрать и открыть build/HEIC2PNG.app
make install   # CLI в ~/.local/bin/heic2png
```
CLI: `heic2png <файл|папка>... [-o папка] [-r] [--overwrite]`

## Архитектура
```
 HEIC2PNG.app (SwiftUI)   heic2png (CLI)
        \                  /
         HEICConverterKit  ── FileScanner / Converter / BatchRunner
                 |
      ImageIO + UniformTypeIdentifiers (системные)
```

## Версии
| Компонент | Версия |
|---|---|
| macOS (сборка) | 15.6.1 |
| Swift | 5.7.2 |
| swift-tools-version | 5.7 |
| Минимум для запуска | macOS 13 |
| Внешние зависимости | 0 |

## Что сделано
- Библиотека с конвертацией (учёт EXIF-ориентации), сканером папок и пакетным запуском
- CLI и SwiftUI-окно поверх неё
- `Scripts/make-app.sh` собирает .app с Info.plist и ad-hoc подписью без Xcode GUI
- Тесты: конвертация, ошибки, перезапись, сканер, пакетный запуск

## Лицензия
MIT, см. [LICENSE](LICENSE).
