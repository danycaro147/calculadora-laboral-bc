# Finiquito MX (Flutter · Android)

Una app de **BrainCode México Tech** — https://braincode.com.mx
© 2026 BrainCode México Tech. Todos los derechos reservados (ver `LICENSE`).

Calcula sueldo neto, aguinaldo, vacaciones, finiquito y liquidación conforme a la Ley Federal del
Trabajo, e incluye el texto completo de la ley con buscador, sin internet.

## Cómo se mantiene al día
- `tools/lft_to_json.py` descarga el PDF oficial de la Cámara de Diputados y lo convierte
  a `assets/lft/lft.json`. Corre en cada compilación y **cada mes** (GitHub Actions).
  Si la descarga o la validación fallan, se conserva la versión anterior.
- Salario mínimo y UMA: `lib/calc.dart` → `ValoresOficiales` (actualizar cada enero/febrero).
- Fórmulas con pruebas automáticas: `test/calc_test.dart`.

## Compilar
Cada push a `main` compila y publica el `.apk` y `.aab` en *Releases*.
Firma de Play Store: secretos `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.

## Protección legal incluida
Aviso obligatorio al primer uso, Términos de uso (`TERMINOS.md`), Privacidad
(`PRIVACIDAD.md`), aviso de "no es app del gobierno" con fuente oficial, aviso en cada
resultado con referencia a PROFEDET y licencia propietaria del código.
