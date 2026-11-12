# heic2png

Конвертер HEIC → PNG / JPEG / HEIC для macOS с выбором качества: минималистичное окно (drag & drop) и CLI. Без внешних зависимостей, всё собирается из консоли.

## Быстрый старт
```
make test      # 18 тестов (XCTest)
make run       # собрать и открыть build/HEIC2PNG.app
make install   # CLI в ~/.local/bin/heic2png
```
CLI: `heic2png <файл|папка>... [-f png|jpeg|heic] [-q 1-100] [-o папка] [-r] [--overwrite]`

## Форматы и качество
| Формат | Сжатие | Качество |
|---|---|---|
| PNG (по умолчанию) | без потерь | не настраивается |
| JPEG | с потерями | 10–100 % (в окне), 1–100 (CLI), прозрачность заменяется белым фоном |
| HEIC | с потерями | 10–100 % (в окне), 1–100 (CLI) |

Если результат совпал бы с исходником (HEIC → HEIC рядом), файл сохраняется как `имя-compressed.heic`, исходник не трогается.

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
- Выбор формата (PNG/JPEG/HEIC) и качества сжатия в окне и CLI
- Тесты: конвертация, форматы и качество, ошибки, перезапись, сканер, пакетный запуск

## Лицензия
MIT, см. [LICENSE](LICENSE).
