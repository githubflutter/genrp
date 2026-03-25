# Apps: AIWork, AIBook, AICodex, AIStudio

Combined documentation for the app entry points under `lib/app/` and the shared orchestration layer.

---

## 1. Overview

GenRP is built as a single Flutter project with dedicated app-specific targets that share the same `core` substrate:

- **AIWork** — [lib/app/aiwork/aiwork.dart](lib/app/aiwork/aiwork.dart) (Desktop/Tablet Workflow)
- **AIBook** — [lib/app/aibook/aibook.dart](lib/app/aibook/aibook.dart) (Mobile Consumption)
- **AICodex** — [lib/app/aicodex/aicodex.dart](lib/app/aicodex/aicodex.dart) (Data Model/Schema Admin)
- **AIStudio** — [lib/app/aistudio/aistudio.dart](lib/app/aistudio/aistudio.dart) (UX/Spec Authoring)

### Core Engineering Principles
- **Centralized Orchestration**: `Autopilot` in `lib/core/agent/` owns the global stores (`DataSet`, `StateSet`) and coordinates state and data changes.
- **Thin Coordinator Pattern**: Autopilot is a `ChangeNotifier` that delegates specialized logic to `CopilotData` and `CopilotUx`.
- **Numeric First**: Transport and runtime contracts prefer integer identifiers for everything (Type, Source, Widget, Slot) to keep the runtime fast and compact.
- **Direct Binding**: The "Action Trio" experiment was purged. All UI elements bind directly to `Autopilot` state or data via `UwStateBindingSpec` in `mixins.dart`.

---

## 2. App Roles & Domains

| App | Focus | UX Style |
|---|---|---|
| **AIWork** | Business Workspaces | Desktop/Tablet: `pworkspace` + `tworkspace` |
| **AIBook** | Content/Data Reader | Mobile: `psheet` / `preport` |
| **AIStudio** | UX/Spec Designer | AdminHome Shell: `preview` mode priority |
| **AICodex** | Data Architect | AdminHome Shell: `schema` mode priority |

### Semantic Boundaries
- **AIWork** and **AIBook** are **client-facing**. They consume local or remote specs through `AppRuntimeFlow` and render them via `GenUx`. They are **NOT** authoring tools.
- **AIStudio** and **AICodex** are **design-facing**. They are focused on CRUD for specs and schemas. They use a shared **convergent shell** (`AdminHome`) to minimize UI duplication and learning curves.
- **AICodex** owns the source of truth for the **Data Model** (Entities, Fields, Tables, Functions).
- **AIStudio** owns the source of truth for the **UX Specs** (Routes, Papers, Templates).

---

## 3. Data & Transport Contract

GenRP prefers a compact, numeric-first transport layer over human-readable JSON property maps for business data.

### The X Hierarchy (`lib/core/base/x.dart`)
- **X**: Base transport wrapper holding a `v` list (slot-addressable payload).
- **Xi**: Adds integer identifier `i`.
- **Xia**: Adds active boolean `a`.
- **Xiad**: Adds date identifier `d` (int53 UTC epoch ms).
- **Xiade**: Adds editor identifier `e` (int4 reference).

### Identification Rule
- New authoring drafts in `base`, `bschema`, and `uschema` use `i = 0`.
- Saving a draft is what allocates the real ID via `max(i) + 1` (on the admin side).
- **Business IDs** follow the epoch-ms-plus-suffix rule for better distribution and safety.

### Backend Contract (Planned)
- Single `POST` endpoint in a C# ASP.NET Core Minimal Web API.
- Request shape: `{ "a": <funId>, "u": "<usr>", "p": "<pass>", "data": <payload> }`.
- Functional flow: No direct `INSERT`/`UPDATE` endpoints. Business logic is wrapped in **functions** (e.g., `invoke_business_function`).

---

## 4. Convergent Shell (`AdminHome`)

AIStudio and AICodex converge on a single structural shell defined in `lib/core/gen/adminhome.dart`:

- **Split Pane**: Left Explorer (`UExplorer`) + Mode-driven Detail Area.
- **Admin Modes**: `schema`, `preview`, `compare`.
- **Toolbar Overlay**: Centralized mode cycling and app-specific actions.
- **Shared Style**: Unified Material 3 theme, consistent toolbar height (`36`), and status-bar height (`32`).

---

## 5. Vocabulary

| Term | Meaning |
|---|---|
| **Paper** | Top-level route container (e.g., `pzero` to `pfour`). |
| **Template** | Workflow layout inside a paper (e.g., `tworkspace`, `tform`). |
| **Uwidget** | Reusable primitive (e.g., `uwlist`, `uwfield`). |
| **UwField** | Advanced multimode input with 21 specialized field types. |
| **Slot** | Index into the `X.v[]` list for binding resolution. |
| **Source** | 0=State, 1=DataSource, 2=DataSet (binding targets). |
| **UschemaRuntime** | Service that compiles and caches `UxSpec` into `UschemaCompiled`. |
