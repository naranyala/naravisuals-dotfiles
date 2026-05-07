#!/usr/bin/env bash
set -euo pipefail

# Find qdbus command (Plasma 6 tends to use qdbus6)
QDBUS=""
for c in qdbus6 qdbus qdbus-qt5; do
  if command -v "$c" >/dev/null 2>&1; then
    QDBUS="$c"; break
  fi
done

if [[ -z "$QDBUS" ]]; then
  echo "qdbus not found. Install qttools (qt5 or qt6) for your distro, then re-run." >&2
  exit 1
fi

# JavaScript for plasmashell
read -r -d '' JS <<'EOS'
function firstBottomPanelOrDefault() {
    var p = panels.length ? panels[0] : null;
    for (var i = 0; i < panels.length; ++i) {
        if (panels[i].location === "bottom") { return panels[i]; }
    }
    return p;
}

var panel = firstBottomPanelOrDefault();
if (panel && panel.location === "bottom") {
    panel.location = "top";
}

// Make the app launcher minimal: replace Kickoff/Dashboard/SimpleMenu with Kicker (cascading)
function makeMinimalLauncher(p) {
    if (!p) return;

    var widgets = p.widgets();
    var kickoffLike = null;
    for (var i = 0; i < widgets.length; ++i) {
        var t = widgets[i].type;
        if (t === "org.kde.plasma.kicker") {
            // Already minimal, nothing to do
            return;
        }
        if (t === "org.kde.plasma.kickoff" ||
            t === "org.kde.plasma.kickerdash" ||
            t === "org.kde.plasma.simplemenu") {
            kickoffLike = widgets[i];
            break;
        }
    }

    if (kickoffLike) {
        // Try to remember approximate position using panel.widgetIds
        var ids = p.widgetIds;
        var pos = ids.indexOf(kickoffLike.id);
        kickoffLike.remove();
        var newW = p.addWidget("org.kde.plasma.kicker");
        // Best-effort reposition: newly added widget is usually appended.
        // Not all Plasma versions expose a move API here; user can fine-tune manually if needed.
    } else {
        // If no launcher present, add a minimal one
        p.addWidget("org.kde.plasma.kicker");
    }
}

makeMinimalLauncher(panel);
EOS

"$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$JS"

echo "Done. If you don't see changes immediately, try restarting the shell:"
echo "  kquitapp5 plasmashell 2>/dev/null || kquitapp6 plasmashell 2>/dev/null"
echo "  kstart5 plasmashell    2>/dev/null || kstart6 plasmashell    2>/dev/null"

