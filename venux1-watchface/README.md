# Info Face — циферблат для Garmin Venu X1

Время, дата, шаги, пульс, батарея, калории. Чёрный фон под AMOLED.

## Сборка
1. Установить VS Code + расширение **Monkey C**, в нём `Monkey C: Verify Installation`,
   затем через SDK Manager скачать последний Connect IQ SDK и устройство **Venu X1**.
2. `Monkey C: Generate a Developer Key` (один раз).
3. Открыть папку `venux1-watchface`, `Monkey C: Build Current Project` → устройство `venux1`.
4. Симулятор: F5. На часы: скопировать `bin/*.prg` в `GARMIN/APPS` по USB.
