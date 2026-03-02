DemonFramework — Architecture Design Specification
1. Introducción
1.1 Propósito

DemonFramework es una arquitectura modular diseñada para el desarrollo estructurado de addons en World of Warcraft Retail.

El objetivo principal es proporcionar una base:

Determinista

Desacoplada

Escalable

Multi-addon

Profile-aware

Lifecycle-safe

1.2 Alcance

Este documento describe:

Arquitectura interna

Modelo de módulos

Sistema de configuración

Sistema de eventos

Gestión de estado

Principios de diseño

No cubre detalles específicos de addons individuales.

2. Arquitectura General

DemonFramework está compuesto por 6 subsistemas principales:

Core
Module System
Config System
EventBus
Logger
State System
``` id="c2r0al"

Cada subsistema tiene responsabilidades estrictamente delimitadas.

---

# 3. Core Layer

Archivo: `DF_Core.lua`

## 3.1 Responsabilidad

El Core es el orquestador del sistema.

Responsable de:

- Inyectar base de datos.
- Inicializar sistema.
- Delegar resolución de módulos.
- Coordinar arranque global.

No contiene lógica de negocio.

---

## 3.2 Flujo de Inicialización

1. Addon ejecuta `AttachDatabase(db)`
2. Addon registra módulos.
3. Se ejecuta `Initialize()`
4. Core delega en Module System.
5. Módulos pasan por lifecycle.

---

# 4. Module System

Archivo: `DF_Module.lua`

## 4.1 Objetivo

Gestionar módulos desacoplados con dependencias explícitas y lifecycle formal.

---

## 4.2 Modelo de Registro

```lua
DF:RegisterModule(name, {
    dependencies = {},
    defaults = {},
    OnLoad = function(self) end,
    OnEnable = function(self) end,
    OnDisable = function(self) end,
    OnProfileChanged = function(self) end,
})
4.3 Resolución de Dependencias

El sistema:

Construye grafo dirigido.

Aplica orden topológico.

Detecta ciclos.

Detecta dependencias inexistentes.

Genera orden determinista.

Esto evita dependencia del orden en .toc.

4.4 Lifecycle

Estados formales:

REGISTERED
LOADED
ENABLED
DISABLED
``` id="r6kqwb"

Transiciones válidas:


REGISTERED → LOADED
LOADED → ENABLED
ENABLED → DISABLED
DISABLED → ENABLED


Transiciones inválidas generan error.

---

# 5. Config System

Archivo: `DF_Config.lua`

## 5.1 Modelo Conceptual

Cada perfil contiene un namespace por módulo.


Profile
│
└── modules
└── ModuleName
├── key1
├── key2
└── ...


---

## 5.2 Principios

- Configuración declarativa por módulo.
- Defaults obligatorios.
- No se permiten valores implícitos.
- Namespace aislado.
- Perfil activo único global.

---

## 5.3 Cambio de Perfil

Al ejecutar:


SetActiveProfile(name)


El sistema:

1. Cambia referencia activa.
2. Garantiza namespace para cada módulo.
3. Publica `PROFILE_CHANGED`.
4. Notifica módulos.

---

# 6. EventBus

Archivo: `DF_EventBus.lua`

## 6.1 Modelo

Sistema publish-subscribe desacoplado.

No existen referencias directas entre módulos.

---

## 6.2 API


Subscribe(eventName, callback, owner)
Publish(eventName, data)
UnsubscribeOwner(owner)


---

## 6.3 Características

- Suscripciones ligadas a owner.
- Limpieza automática en DisableModule.
- No dependencia circular.
- Comunicación asincrónica.

---

# 7. Logger

Archivo: `DF_Logger.lua`

## 7.1 Objetivo

Proveer sistema de logging estructurado sin contaminar global.

---

## 7.2 Formato


[DF] [LEVEL] [ModuleName] Message


---

# 8. State System

Archivo: `DF_State.lua`

Define estados formales para evitar:

- Ambigüedad.
- Ejecución en estados inválidos.
- Bugs por transiciones incorrectas.

---

# 9. Integración Multi-Addon

Cada addon:

1. Declara SavedVariables.
2. Llama AttachDatabase.
3. Registra módulos.
4. Llama Initialize una sola vez.

El framework no depende de ningún addon específico.

---

# 10. Principios de Diseño Aplicados

- Single Responsibility
- Dependency Inversion
- Explicit Lifecycle
- Deterministic Initialization
- Event-Driven Communication
- Declarative Configuration
- Internal Namespacing
- Defensive Programming

---

# 11. Limitaciones Actuales

- No Service Registry.
- No sistema de hooks extensible.
- No API pública estable.
- No versionado semántico formal.
- No validación de esquema de config.

---

# 12. Estado Actual

Framework estable para uso interno.

Recomendación de versión:


v1-internal


---

# 13. Evolución Futura Potencial

- Service Registry
- Hook system
- Middleware de eventos
- Validación de schema de defaults
- API pública formal

---

Este documento define la arquitectura actual y sirve como referencia para futuras evoluciones.

---