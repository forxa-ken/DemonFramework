📘 Auditoría Técnica — DemonBrain v1
1️⃣ Evaluación General
Estado actual

DemonBrain es:

✔ Estable

✔ Retail-safe

✔ Sin APIs problemáticas

✔ Sin taint

✔ Sin IsUsableSpell

✔ Sin cooldown API peligrosa

✔ Con tracking manual

✔ Configurable

✔ Modularizado correctamente

Pero…

Todavía es un motor de prioridad básico bien estructurado, no un motor inteligente avanzado.

Eso no es malo. Es una base sólida.

2️⃣ Análisis del Motor de Prioridad
🔹 Actual comportamiento

La lógica es esencialmente:

Evitar sobrecap de shards.

Usar Demonbolt con Núcleo activo.

Preparar Tirano si listo.

Mantener Dread.

Filler.

Es funcional.

Pero es reactivo, no predictivo.

3️⃣ Problemas Potenciales en Juego Real
⚠ 1. Tirano demasiado binario

Actualmente:

if activeDemons < threshold then
   preparar
else
   lanzar
end

Problema:

No considera:

Tiempo restante de demonios.

Si Dread está a punto de estar ready.

Si shards están bajos.

Si Hand acaba de salir.

Si estás en boss o trash.

Es decisión rígida.

⚠ 2. No hay ventana de preparación inteligente

Ejemplo real:

Tienes 5 demonios activos.
Threshold = 6.
Dread estará listo en 1.2 segundos.

El sistema actual puede sugerir Tirano demasiado pronto.

Un jugador avanzado esperaría 1 segundo.

⚠ 3. No hay gestión de duración de demonios

Tu tracking solo cuenta cantidad:

activeDemons = total

Pero no sabes:

Cuántos expiran en 2 segundos.

Cuántos están frescos.

Cuántos están en su último tick.

Eso afecta directamente al valor real de Tirano.

⚠ 4. No hay contexto de combate

No distingue:

Boss vs trash.

Pull vs mid-fight.

Dungeon vs raid.

Target HP.

Podrías lanzar Tirano en un target que muere en 4 segundos.

⚠ 5. No hay optimización de shard flow

No calcula:

Velocidad de generación.

Si Hand generará más demonios pronto.

Si Demonbolt está generando.

Es prioridad estática.

4️⃣ Fortalezas Reales del Motor

✔ Núcleo Demoníaco detection es sólida.
✔ Tracking manual evita dependencia API.
✔ CD manual evita taint.
✔ Arquitectura limpia permite mejorar fácilmente.
✔ No hay spaghetti code.

Eso es muy importante.

5️⃣ Nivel Actual del Addon

Lo clasificaría como:

“Helper estructural estable”.

No como:

“Optimización avanzada de Demonology”.

6️⃣ Evolución Recomendada (Por Orden Correcto)

No empieces por UI.

Empieza por inteligencia.

🚀 Fase 1 — Ventana Inteligente de Tirano

Implementar:

Tiempo mínimo restante de demonios.

Esperar Dread si falta poco.

Evitar lanzar si demonios están a punto de expirar.

Pequeña ventana de paciencia (1–2 segundos).

Eso solo ya aumenta mucho la calidad.

🚀 Fase 2 — Predicción Ligera

Sin usar API peligrosa:

Calcular expiración promedio.

Calcular “demon health window”.

Estimar si vale la pena esperar 1 GCD.

🚀 Fase 3 — Context Awareness

Sin API protegida puedes usar:

UnitClassification("target")
UnitHealth("target")
UnitLevel("target")

Para:

Detectar boss.

Detectar élite.

Evitar burst en target que muere.

🚀 Fase 4 — Modo avanzado opcional

Perfil con:

Raid mode

M+ mode

Aggressive mode

Sin tocar framework.

Solo lógica interna.

7️⃣ Evaluación de UI

UI es correcta.
No es problema ahora.

No la toques.

8️⃣ Evaluación de Rendimiento

No usas OnUpdate.

Usas eventos.

No haces loops pesados.

No haces scanning excesivo.

Muy bien.

9️⃣ Mi Recomendación Exacta

El siguiente paso correcto es:

👉 Mejorar inteligencia de Tirano.

No añadir features.
No añadir más estructura.

Mejorar decisión.