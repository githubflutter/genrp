# CopilotState Refactoring Plan

## Vision and Objective
Your vision is to create a perfectly symmetrical interface architecture for the `Autopilot` orchestrator:
*   **CopilotData**: Handles business data reading/writing recursively over `DataSet`.
*   **CopilotState**: Replaces `CopilotUX`. It specifically manages transient UI state (chrome, screens, components) by proxying all operations to `StateSet`.

Both `DataSet` and `StateSet` belong to `Autopilot`. The `Copilot` classes are merely specialized facades you instantiate to interact cleanly with them.

---

## Step-by-Step Execution

### Step 1: File and Class Renaming
*   Rename `lib/core/agent/copilot_ux.dart` to `lib/core/agent/copilot_state.dart`.
*   Inside the new file, rename the class `CopilotUX` to `CopilotState`.

### Step 2: Expand `CopilotState` API
The current `CopilotUX` only exposes simple `getValue` and `setValue`, which misses the 3-tier capability embedded in `StateSet`. 
I will expand `CopilotState` to explicitly provide operations for all three state granularities:
1.  **Chrome**: `getChrome(key)`, `setChrome(key, value)`, `clearChrome()`
2.  **Paper**: `getPaper(scope, key)`, `setPaper(scope, key, value)`, `clearPaper(scope)`
3.  **Template**: `getTemplate(scope, key)`, `setTemplate(scope, key, value)`, `clearTemplate(scope)`

### Step 3: Verify and Align `CopilotData`
*   Open `lib/core/agent/copilot_data.dart`.
*   Ensure it cleanly handles array/object mapping over `DataSet`. 
*   Confirm it uses `autopilot.publishChange()` correctly.

### Step 4: Documentation Update
*   Update `docs/project_deep_analysis.md` to change all references of `CopilotUX` / `copilot_ux.dart` to `CopilotState` / `copilot_state.dart`. 
*   Adjust architectural diagrams to reflect the symmetry between `CopilotData` -> `DataSet` and `CopilotState` -> `StateSet`.

---

## Why this is safe
Currently, `CopilotUX` and `CopilotData` act as standalone definition classes in our `lib` directory and are not strongly coupled or instantiated deep within the widget tree. Therefore, this rename and structural expansion carries **zero risk** of breaking the active runtime.

Is this plan aligned with your expectations? I am ready to execute the steps when you approve.
