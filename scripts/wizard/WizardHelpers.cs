namespace DotfilesWizard;

/// <summary>RGB color value for scheme consistency checks.</summary>
public readonly record struct Rgb(int R, int G, int B);

/// <summary>Color constants shared between schemes. Hover must match Active.</summary>
public static class ThemeColors
{
    public static readonly Rgb Background = new(58, 58, 58);
    public static readonly Rgb Foreground = new(255, 255, 255);
    public static readonly Rgb Accent = new(0, 255, 255);
    public static readonly Rgb ActiveBackground = new(0, 0, 215);

    // Hover highlight uses the same colors as Active
    public static readonly Rgb HoverForeground = Accent;
    public static readonly Rgb HoverBackground = ActiveBackground;
}

public static class WizardHelpers
{
    public static string FormatRadioItem(string label, bool selected)
    {
        return selected ? $" (*) {label}" : $" ( ) {label}";
    }

    public static bool SetEqual(List<string> a, List<string> b) =>
        a.Count == b.Count && new HashSet<string>(a).SetEquals(b);

    public static bool IsMcpDependentSetting(string key) => key switch
    {
        "azure_devops_org" => true,
        _ => false,
    };

    public static Dictionary<string, string> ParseChezmoiToml(string configPath)
    {
        var data = new Dictionary<string, string>();
        if (!File.Exists(configPath))
            return data;

        foreach (var line in File.ReadAllLines(configPath))
        {
            var trimmed = line.Trim();
            var eqIndex = trimmed.IndexOf('=');
            if (eqIndex <= 0) continue;
            var key = trimmed[..eqIndex].Trim();
            var value = trimmed[(eqIndex + 1)..].Trim().Trim('"');
            data[key] = value;
        }
        return data;
    }

    public static bool SelectionMatchesProfile(PackProfile profile, WizardState state)
    {
        var sel = profile.Selection;
        return SetEqual(sel.Mcps.Enabled, state.EnabledMcps)
            && SetEqual(sel.Skills.Enabled, state.EnabledSkills)
            && SetEqual(sel.Agents.Enabled, state.EnabledAgents)
            && SetEqual(sel.Rules.Enabled, state.EnabledRules)
            && SetEqual(sel.Permissions.Enabled, state.EnabledPermissions);
    }

    public static void PreFillSettingsFromChezmoi(
        WizardState state, Dictionary<string, string> chezmoiData)
    {
        var profileFields = new[] { "user_name", "user_role_summary", "user_stack_summary" };
        foreach (var key in profileFields)
        {
            if (!state.Settings.ContainsKey(key) || string.IsNullOrEmpty(state.Settings.GetValueOrDefault(key)))
            {
                if (chezmoiData.TryGetValue(key, out var val) && !string.IsNullOrEmpty(val))
                    state.Settings[key] = val;
            }
        }

        var settingsKeys = new[]
        {
            "obsidian_vault_path", "azure_devops_org", "memory_provider",
            "content_workspace", "research_workspace"
        };
        foreach (var key in settingsKeys)
        {
            if (!state.Settings.ContainsKey(key) || string.IsNullOrEmpty(state.Settings.GetValueOrDefault(key)))
            {
                if (chezmoiData.TryGetValue(key, out var val) && !string.IsNullOrEmpty(val))
                    state.Settings[key] = val;
            }
        }
    }

    public static string GetSummaryText(WizardState state, string packLabel)
    {
        var profileLine = state.ProfileMode == "preset"
            ? state.ProfileSelected
            : $"custom (from {state.ProfileSelected})";
        return $"Pack: {packLabel} | Profile: {profileLine} | " +
               $"MCPs: {state.EnabledMcps.Count} | Skills: {state.EnabledSkills.Count} | " +
               $"Agents: {state.EnabledAgents.Count} | Rules: {state.EnabledRules.Count}";
    }
}
