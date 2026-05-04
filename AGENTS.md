# AGENTS.md

## Project
Verso — a minimalist iOS article reader app. Currently in **design/discovery phase**.

## Linear
Issues: https://linear.app/fabiosasseron/project/verso-095ee52ef44b/issues

## Figma
File: https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
- 🧩 Components: node-id=13:201
- 📱 Home screen: node-id=30:41
- 📖 Reading view: node-id=31:1701
- ⚙️ Settings screen: node-id=34:2877

## Implementation Entry Point

**Before starting any implementation task, read `docs/HANDOFF.md` first.** It is the authoritative entry point — inline essentials for the design system, screens, and services, plus a doc map that tells you which file to fetch for each domain (components, tokens, error states, animations, accessibility, copy, user flows).

## Architecture (from PRD)

- **File-first**: Articles saved as Markdown files to user-selected iCloud Drive folder. No proprietary database.
- **Core Data**: Used only as local read cache, rebuilt from files — never the source of truth
- **Bundle ID**: `com.fabiosasseron.verso`
- **Tech Stack**: SwiftUI, iOS 16+, iCloud Drive
- **Share Extension**: Separate entry point for saving articles from other apps
- **Design system code**: 5 Swift files in `Verso/Sources/Design/` (Colors, Typography, Spacing, Radius, ThemeManager)

## Key Design Decisions

- Single NavigationStack (no tab bar)
- Article status: Unread → Reading → Read (auto-tracked on scroll)
- Filter chips: All / Unread / Reading / Read
- MVP has title search only, no full-text search in body

## Running Commands

The Xcode project is generated via XcodeGen. To regenerate: `cd Verso && xcodegen generate`.

To build from CLI:
```bash
cd Verso && xcodebuild -project Verso.xcodeproj -scheme Verso -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Figma & Linear Tool Status

### Critical Finding
⚠️ Most Figma REST API tools don't exist - they only exist as `figma-console_*` versions requiring the Desktop Bridge plugin.

### Model Limitations
| Limitation | Affected Tools | Workaround |
|------------|-----------------|------------|
| Most Figma tools only as figma-console_* | See table below | Requires Desktop Bridge |
| Model cannot analyze images | figma-console_figma_capture_screenshot, figma-console_figma_get_component_image | SKIP |

### Figma REST API Tools (Limited)
| Tool | Status | Notes |
|------|--------|-------|
| figma_get_design_context | ❌ | Returns error on use |
| figma_get_variable_defs | ✅ | Returns color values |
| figma_get_metadata | ✅ | Returns canvas tree |
| figma_create_design_system_rules | ⚠️ | Wrong tool - generates code |

## Tools Not Tested / Failed

### Untested (need testing)
- linear_save_issue
- linear_create_attachment
- figma-console_figma_set_text
- figma-console_figma_create_child
- figma-console_figma_setup_design_tokens

### Tools DON'T EXIST (Use figma-console_* versions)
| Tool | Notes |
|------|-------|
| figma_get_component | Only figma-console version |
| figma_get_component_for_development | Only figma-console version |
| figma_get_styles | Only figma-console version |
| figma_get_variables | Only figma-console version |
| figma_get_file_data | Only figma-console version |
| figma_get_design_system_kit | Only figma-console version |
| figma_get_comments | Only figma-console version (requires scope) |
| figma_get_screenshot | DOES NOT EXIST |

### Figma Plugin/Console Tools (require Desktop Bridge)
| Tool | Status | Notes |
|------|--------|-------|
| figma-console_figma_get_file_data | ✅ | Works |
| figma-console_figma_get_variables | ✅ | Works - 24 variables |
| figma-console_figma_get_component | ✅ | Works |
| figma-console_figma_get_component_for_development | ✅ | Works |
| figma-console_figma_get_component_for_development_deep | ✅ | Works |
| figma-console_figma_analyze_component_set | ✅ | Works |
| figma-console_figma_get_file_for_plugin | ✅ | Works |
| figma-console_figma_get_text_styles | ✅ | Works - 30 styles |
| figma-console_figma_lint_design | ✅ | Works |
| figma-console_figma_audit_component_accessibility | ✅ | Works |
| figma-console_figma_get_design_system_kit | ⚠️ | Input validation error (include param) |
| figma-console_figma_execute | ✅ | Works |
| figma-console_figma_get_comments | ❌ | Missing scope (403) |
| figma-console_figma_capture_screenshot | ❌ SKIP | Model can't analyze images |
| figma-console_figma_get_component_image | ❌ SKIP | Model can't analyze images |

Write/Manipulation Tools: (Tested)
| Tool | Status | Notes |
|------|--------|-------|
| figma-console_figma_resize_node | ✅ | Works |
| figma-console_figma_move_node | ✅ | Works |
| figma-console_figma_set_fills | ✅ | Works |
| figma-console_figma_clone_node | ✅ | Works |
| figma-console_figma_rename_node | ✅ | Works |
| figma-console_figma_set_text | ✅ | Works |
| figma-console_figma_create_child | ✅ | Works |

Variable Management:
| Tool | Status | Notes |
|------|--------|-------|
| figma-console_figma_create_variable_collection | ✅ | Works |
| figma-console_figma_add_mode | ✅ | Works |
| figma-console_figma_create_variable | ✅ | Works |
| figma-console_figma_update_variable | ✅ | Works |
| figma-console_figma_batch_create_variables | ✅ | Works |
| figma-console_figma_setup_design_tokens | ✅ | Works |

### Linear Tools (Full Support)
| Tool | Status | Notes |
|------|--------|-------|
| linear_get_issue | ✅ | Works |
| linear_list_issues | ✅ | Works |
| linear_save_issue | ✅ | Works |
| linear_list_issue_statuses | ✅ | Works |
| linear_get_issue_status | ✅ | Works |
| linear_list_issue_labels | ✅ | Works |
| linear_create_issue_label | ✅ | Works |
| linear_list_projects | ✅ | Works |
| linear_get_project | ✅ | Works |
| linear_save_project | ✅ | Works |
| linear_list_project_labels | ✅ | Works |
| linear_list_milestones | ✅ | Works |
| linear_get_milestone | ✅ | Works |
| linear_save_milestone | ✅ | Works |
| linear_list_teams | ✅ | Works |
| linear_get_team | ✅ | Works |
| linear_list_users | ✅ | Works |
| linear_get_user | ✅ | Works |
| linear_list_comments | ✅ | Works |
| linear_save_comment | ✅ | Works |
| linear_delete_comment | ✅ | Works |
| linear_get_document | ✅ | Works |
| linear_list_documents | ✅ | Works |
| linear_save_document | ✅ | Works |
| linear_get_attachment | ✅ | Works |
| linear_create_attachment | ✅ | Works |
| linear_delete_attachment | ✅ | Works |
| linear_list_cycles | ✅ | Works |
| linear_search_documentation | ✅ | Works |