local wezterm = require 'wezterm';

-- Format window title
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	local zoomed = ""
	if tab.active_pane.is_zoomed then
		zoomed = "[Z] "
	end

	local index = ""
	if #tabs > 1 then
		index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
	end

	return "(wezterm) " .. zoomed .. index .. tab.active_pane.title
end)

return {
	enable_wayland = true,
	color_scheme = "Brogrammer",
	exit_behavior = "Close",
	font = wezterm.font_with_fallback({
			"IBM Plex Mono",
			"Fira Code Nerd Font",
			"Noto Sans Symbols2",
	}),
	enable_scroll_bar = true,
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
	keys = {
		{key="Enter", mods="ALT", action="DisableDefaultAssignment"}
	},
}

