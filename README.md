📘 README — DemonFramework
# DemonFramework

Arquitectura modular profesional para el desarrollo de addons en World of Warcraft Retail (12.x).

DemonFramework es una base estructural diseñada para crear addons desacoplados, escalables y mantenibles, con soporte de perfiles, sistema formal de módulos y comunicación interna basada en eventos.

---

## 🎯 Objetivo del Proyecto

Construir un framework interno reutilizable que permita:

- Crear múltiples addons sobre una misma base.
- Separar lógica, UI y configuración.
- Gestionar perfiles por módulo.
- Resolver dependencias de forma determinista.
- Evitar APIs problemáticas o protegidas.
- Mantener una arquitectura limpia y extensible.

---

## 🏗 Arquitectura General

DemonFramework está compuesto por los siguientes subsistemas:


DemonFramework
│
├── Core
├── Module System
├── Config System
├── EventBus
├── Logger
└── State System


Cada componente cumple una responsabilidad clara.

---

## 🔹 1. Core (`DF_Core.lua`)

Responsable de:

- Inicialización global.
- Inyección de base de datos externa.
- Orquestación de módulos.
- Coordinación del lifecycle.

No contiene lógica de addons.

---

## 🔹 2. Sistema de Módulos (`DF_Module.lua`)

Permite registrar módulos desacoplados:

```lua
DF:RegisterModule("ModuleName", {
    dependencies = {},
    defaults = {},
    OnLoad = function(self) end,
    OnEnable = function(self) end,
    OnDisable = function(self) end,
    OnProfileChanged = function(self) end,
})
Características:

Resolución determinista de dependencias.

Detección de ciclos.

Validación de dependencias inexistentes.

Estados formales de módulo.

Lifecycle controlado.

Estados posibles:

REGISTERED → LOADED → ENABLED → DISABLED
🔹 3. Sistema de Configuración (DF_Config.lua)

Sistema de perfiles por módulo.

Estructura interna:
Database
│
├── profiles
│   ├── Default
│   │   └── modules
│   │       └── ModuleName
│   └── OtherProfile
│       └── modules
│           └── ModuleName
│
└── activeProfile
API principal:
Config:CreateProfile(name)
Config:SetActiveProfile(name)
Config:GetActiveProfile()
Config:GetModuleNamespace("ModuleName")

Características:

Defaults declarativos por módulo.

Namespace aislado por módulo.

Sin valores nil si defaults están definidos.

Evento automático PROFILE_CHANGED.

🔹 4. EventBus (DF_EventBus.lua)

Sistema publish-subscribe desacoplado.

Events:Subscribe(eventName, callback, owner)
Events:Publish(eventName, data)
Events:UnsubscribeOwner(owner)

Características:

Suscripción asociada a owner.

Limpieza automática al deshabilitar módulo.

Comunicación desacoplada entre módulos.

🔹 5. Logger (DF_Logger.lua)

Sistema de logging estructurado con contexto de módulo.

Ejemplo:

[DF] [INFO] [DemonBrain] Module enabled

Incluye:

Info

Warn

Error

Buffer interno opcional

🔹 6. State System (DF_State.lua)

Define estados formales para módulos, evitando estados ambiguos y permitiendo validaciones futuras.

📦 Integración de Addons

Cada addon que use el framework debe:

Declarar SavedVariables.

Llamar a DF:AttachDatabase() en ADDON_LOADED.

Registrar sus módulos.

Llamar a DemonFramework:Initialize() una sola vez.

Ejemplo real: DemonBrain

DemonBrain
├── DemonBrain (motor)
├── DemonBrainUI (depende de DemonBrain)
└── DemonBrainSettings (depende de DemonBrain)
🧠 Principios Arquitectónicos Aplicados

Separación de responsabilidades.

Inversión de dependencias.

Comunicación por eventos.

Configuración declarativa.

Determinismo en inicialización.

Control explícito de estados.

Desacoplamiento UI / lógica.

Escalabilidad multi-addon.

🚫 Lo que NO es este framework

No es una librería pública aún.

No es un plugin framework para terceros.

No incluye sistema de servicios avanzado.

No incluye sistema de hooks extensible.

Actualmente es una base interna sólida.

📌 Estado del Proyecto

Versión actual recomendada:

v1-internal

Framework estable listo para ser usado en addons reales y evolucionar basado en experiencia práctica.

🔮 Roadmap Futuro (Opcional)

Service Registry.

Hooks internos.

Middleware de eventos.

Documentación pública formal.

API estable para terceros.

📄 Licencia

(Definir según tu preferencia: MIT, GPL, uso privado, etc.)

Desarrollado por Darwin.