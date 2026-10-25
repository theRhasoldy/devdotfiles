-- Editor-only type declarations for plugins that ship no config class.
-- LuaLS indexes this file; nothing requires it at runtime.

---@class MiniAiConfig
---@field n_lines? integer Lines searched around the cursor for a textobject.

---@class MiniSurroundMappings
---@field add? string
---@field delete? string
---@field find? string
---@field find_left? string
---@field highlight? string
---@field replace? string
---@field suffix_last? string
---@field suffix_next? string

---@class MiniSurroundConfig
---@field custom_surroundings? table<string, table>
---@field highlight_duration? integer
---@field mappings? MiniSurroundMappings
---@field n_lines? integer Lines searched around the cursor for a surrounding.
---@field respect_selection_type? boolean
---@field search_method? "cover"|"cover_or_next"|"cover_or_prev"|"cover_or_nearest"|"next"|"prev"|"nearest"
---@field silent? boolean

-- nvim-ts-autotag ships no config class.
---@class AutotagFiletypeConfig
---@field enable_close? boolean
---@field enable_rename? boolean
---@field enable_close_on_slash? boolean

---@class AutotagConfig
---@field opts? AutotagFiletypeConfig
---@field per_filetype? table<string, AutotagFiletypeConfig>
---@field aliases? table<string, string>

---@class MiniPickWindowConfig
---@field width integer
---@field height integer

---@class MiniPickConfig
---@field window? { config?: fun(): MiniPickWindowConfig }

---@class MiniFilesOptions
---@field use_as_default_explorer? boolean
---@field permanent_delete? boolean

---@class MiniFilesWindows
---@field preview? boolean
---@field max_number? integer
---@field width_focus? integer
---@field width_nofocus? integer
---@field width_preview? integer

---@class MiniFilesContent
---@field sort? fun(entries: table[]): table[]

---@class MiniFilesConfig
---@field options? MiniFilesOptions
---@field windows? MiniFilesWindows
---@field content? MiniFilesContent

---@class MiniStatuslineContent
---@field active? fun(): string
---@field inactive? fun(): string

---@class MiniStatuslineConfig
---@field use_icons? boolean
---@field content? MiniStatuslineContent

---@class MiniClueEntry
---@field mode? string|string[]
---@field keys? string
---@field desc? string

---@class MiniClueConfig
---@field triggers? MiniClueEntry[]
---@field window? { delay?: integer }
---@field clues? MiniClueEntry[]

---@class MiniAnimatePart
---@field enable? boolean
---@field timing? fun(total: integer, count: integer): number

---@class MiniAnimateConfig
---@field cursor? MiniAnimatePart
---@field scroll? MiniAnimatePart
---@field resize? MiniAnimatePart
---@field open? MiniAnimatePart
---@field close? MiniAnimatePart

---@class MiniHipatternsConfig
---@field highlighters? table<string, table>

---@class CendreConfig
---@field background? "hard"|"medium"|"soft"
---@field transparent? boolean
---@field italic_virtual_text? boolean

-- nvim-lint configures itself through module fields, not setup().
---@class LintConfig
---@field linters_by_ft? table<string, string[]>
---@field linters? table<string, table>
