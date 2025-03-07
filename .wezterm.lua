-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
-- local mux = wezterm.mux
-- This will hold the configuration.
local config = wezterm.config_builder()

-- [Suas configurações existentes permanecem aqui]
-- ...

-- Configuração básica original
config.front_end = "OpenGL"
config.max_fps = 144
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 1
config.cursor_blink_rate = 500
config.term = "xterm-256color" -- Set the terminal type

config.font = wezterm.font("Fira Code")
config.cell_width = 0.9
config.window_background_opacity = 0.9
config.prefer_egl = true
config.font_size = 14.0

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- tabs
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }


-- Adicionar configuração para autocompletion
-- Habilitar a funcionalidade de preenchimento automático
-- config.enable_autocomplete = true

-- Configurar o comportamento de autocompleção
-- config.autocomplete = {
--     -- Escolher a fonte de sugestões (history, words ou files)
--     source = "history",
    
--     -- Número máximo de sugestões para mostrar
--     max_items = 5,
    
--     -- Tamanho mínimo da palavra para começar a mostrar sugestões
--     min_word_len = 3,
    
--     -- Estilo visual para as sugestões
--     style = {
--         fg_color = "#bea3c7", -- Cor do texto das sugestões
--         bg_color = "#0c0b0f", -- Cor de fundo das sugestões
--         selected_fg_color = "#ffffff", -- Cor do texto da sugestão selecionada
--         selected_bg_color = "#3b224c", -- Cor de fundo da sugestão selecionada
--     }
-- }

-- Adicionar keybindings específicos para navegação de sugestões
-- local autocomplete_keys = {
--     -- Tab para aceitar a sugestão atual
--     { key = "Tab", mods = "", action = act.AcceptAutocomplete },
    
--     -- Setas para navegar pelas sugestões
--     { key = "DownArrow", mods = "", action = act.NextAutocompleteItem },
--     { key = "UpArrow", mods = "", action = act.PrevAutocompleteItem },
    
--     -- Escape para fechar a lista de sugestões
--     { key = "Escape", mods = "", action = act.CancelAutocomplete },
-- }

-- Manter suas configurações de teclas existentes
config.keys = {
	{
		key = "E",
		mods = "LEADER",
		action = wezterm.action.EmitEvent("toggle-colorscheme"),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Next"),
	},
	{
		key = "U",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "I",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "O",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "P",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{ key = "9", mods = "CTRL", action = act.PaneSelect },
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
	{
		key = "O",
		mods = "LEADER",
		-- toggling opacity
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			if overrides.window_background_opacity == 1.0 then
				overrides.window_background_opacity = 0.9
			else
				overrides.window_background_opacity = 1.0
			end
			window:set_config_overrides(overrides)
		end),
	},
}

-- Adicionar as novas teclas para autocompletar
-- for _, key in ipairs(autocomplete_keys) do
--     table.insert(config.keys, key)
-- end

-- For example, changing the color scheme:
config.color_scheme = "Cloud (terminal.sexy)"
config.colors = {
	background = "#0c0b0f", -- dark purple
	cursor_border = "#bea3c7",
	cursor_bg = "#bea3c7",

	tab_bar = {
		background = "#0c0b0f",
		active_tab = {
			bg_color = "#0c0b0f",
			fg_color = "#bea3c7",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = "#0c0b0f",
			fg_color = "#f8f2f5",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},

		new_tab = {
			bg_color = "#0c0b0f",
			fg_color = "white",
		},
	},
}

config.window_frame = {
	font = wezterm.font({ family = "Fira Code", weight = "Regular" }),
	active_titlebar_bg = "#0c0b0f",
}

config.window_decorations = "NONE | RESIZE"
config.default_prog = { "powershell.exe", "-NoLogo" }
config.initial_cols = 80

wezterm.on("gui-startup", function(cmd)
	local args = {}
	if cmd then
		args = cmd.args
	end

	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize() -- Força o WezTerm a abrir em tela cheia
end)

-- Evento para listar e mostrar sugestões com base no histórico de comandos
wezterm.on("update-right-status", function(window, pane)
    -- Obter o texto atual da linha de comando
    local text = pane:get_text_from_cursor_to_end()
    
    if text and #text >= 3 then
        -- Se estiver digitando algo com pelo menos 3 caracteres
        -- Buscar no histórico por comandos semelhantes
        wezterm.log_info("Buscando sugestões para: " .. text)
        
        -- Aqui você pode implementar lógica personalizada para mostrar sugestões
        -- baseadas no histórico ou em palavras-chave pré-definidas
    end
end)

-- and finally, return the configuration to wezterm
return config
