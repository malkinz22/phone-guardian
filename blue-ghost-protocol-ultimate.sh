#!/data/data/com.termux/files/usr/bin/bash
# blue-ghost-protocol.sh
# Original ASCII fox/creature-mask emblem, blue-toned terminal theme.
# Original angular design - not a reproduction of any copyrighted logo.

NICK_FILE="$HOME/.bgp_nickname"

# --- Color palette (256-color, blue family + accents) ---
B1='\033[38;5;27m'    # deep blue
B2='\033[38;5;33m'    # medium blue
B3='\033[38;5;39m'    # bright blue
B4='\033[38;5;45m'    # cyan-blue
ICE='\033[38;5;51m'   # icy cyan highlight
RED_ACCENT='\033[38;5;196m'
GOLD='\033[38;5;220m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

# ============================================================
# BLUE GHOST PROTOCOL — AUTO INSTALL
# Installs this script's banner into ~/.bashrc or ~/.zshrc.
# The block is marked so repeated runs do not create duplicates.
# ============================================================

BGP_SCRIPT="$HOME/.blue-ghost-protocol.sh"
BGP_MARK_START="# >>> BLUE GHOST PROTOCOL >>>"
BGP_MARK_END="# <<< BLUE GHOST PROTOCOL <<<"

# Copy this script into the home directory so the shell can load it.
if [ -f "$0" ]; then
    cp "$0" "$BGP_SCRIPT" 2>/dev/null
    chmod +x "$BGP_SCRIPT" 2>/dev/null
fi

# Install the original startup sound and banner image when they are placed
# beside this installer.
if [ -f "$(dirname "$0")/blue-ghost-startup.wav" ]; then
    cp "$(dirname "$0")/blue-ghost-startup.wav" "$HOME/blue-ghost-startup.wav" 2>/dev/null
fi
if [ -f "$(dirname "$0")/blue-ghost-banner.png" ]; then
    cp "$(dirname "$0")/blue-ghost-banner.png" "$HOME/blue-ghost-banner.png" 2>/dev/null
fi

# Select the active shell startup file.
if [ -n "${ZSH_VERSION:-}" ]; then
    BGP_RC="$HOME/.zshrc"
else
    BGP_RC="$HOME/.bashrc"
fi

# Create the startup file if it does not exist.
touch "$BGP_RC"

# Remove an older Blue Ghost Protocol installation block, if present.
if grep -qF "$BGP_MARK_START" "$BGP_RC" 2>/dev/null; then
    sed -i "/$BGP_MARK_START/,/$BGP_MARK_END/d" "$BGP_RC"
fi

# Install the banner launcher.
{
    echo "$BGP_MARK_START"
    echo '[ -f "$HOME/.blue-ghost-protocol.sh" ] && source "$HOME/.blue-ghost-protocol.sh"'
    echo "$BGP_MARK_END"
} >> "$BGP_RC"

# ============================================================
# BLUE GHOST PROTOCOL — AUDIO / NOTIFICATION / TELEGRAM
# ============================================================

BGP_HOME="$HOME/.blue-ghost-protocol"
BGP_SOUND="$BGP_HOME/blue-ghost-startup.wav"
BGP_IMAGE="$BGP_HOME/blue-ghost-banner.png"

# Optional Telegram configuration.
# Set these once in your shell, or replace the placeholders below.
#   export BGP_TELEGRAM_BOT_TOKEN="123456:ABC..."
#   export BGP_TELEGRAM_CHAT_ID="123456789"
BGP_TELEGRAM_BOT_TOKEN="${BGP_TELEGRAM_BOT_TOKEN:-}"
BGP_TELEGRAM_CHAT_ID="${BGP_TELEGRAM_CHAT_ID:-}"

mkdir -p "$BGP_HOME"

# The installer copies the companion files next to this script when available.
if [ -f "$HOME/blue-ghost-startup.wav" ]; then
    cp "$HOME/blue-ghost-startup.wav" "$BGP_SOUND" 2>/dev/null
fi
if [ -f "$HOME/blue-ghost-banner.png" ]; then
    cp "$HOME/blue-ghost-banner.png" "$BGP_IMAGE" 2>/dev/null
fi

# --- Startup sound ---
if command -v termux-media-player >/dev/null 2>&1 && [ -f "$BGP_SOUND" ]; then
    termux-media-player stop >/dev/null 2>&1
    termux-media-player play "$BGP_SOUND" >/dev/null 2>&1 &
elif command -v play >/dev/null 2>&1 && [ -f "$BGP_SOUND" ]; then
    play -q "$BGP_SOUND" >/dev/null 2>&1 &
elif command -v termux-tts-speak >/dev/null 2>&1; then
    termux-tts-speak "Blue Ghost Protocol online" >/dev/null 2>&1 &
fi

# --- Android notification ---
if command -v termux-notification >/dev/null 2>&1; then
    termux-notification \
        --id blue-ghost-protocol \
        --title "BLUE GHOST PROTOCOL" \
        --content "System online • Watch active • Trace null • Node local" \
        --priority high \
        --sound default >/dev/null 2>&1
fi

# --- Telegram image + status message ---
if command -v curl >/dev/null 2>&1 \
   && [ -n "$BGP_TELEGRAM_BOT_TOKEN" ] \
   && [ -n "$BGP_TELEGRAM_CHAT_ID" ] \
   && [ -f "$BGP_IMAGE" ]; then

    curl -sS -X POST \
        "https://api.telegram.org/bot${BGP_TELEGRAM_BOT_TOKEN}/sendPhoto" \
        -F "chat_id=${BGP_TELEGRAM_CHAT_ID}" \
        -F "photo=@${BGP_IMAGE}" \
        -F "caption=👻 BLUE GHOST PROTOCOL ONLINE%0A%0A[ ARMED ]  [ WATCH: ACTIVE ]  [ TRACE: NULL ]  [ NODE: LOCAL ]" \
        >/dev/null 2>&1 &
fi

clear

# ============================================================
# BLUE GHOST PROTOCOL — TERMUX BANNER
# ============================================================

# Color palette
B1='\033[38;5;27m'
B2='\033[38;5;33m'
B3='\033[38;5;39m'
B4='\033[38;5;45m'
ICE='\033[38;5;51m'
RED_ACCENT='\033[38;5;196m'
GOLD='\033[38;5;220m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

# --- Ghost emblem ---
echo -e "${B3}"
cat << "EOF"
                         /\                         /\
                        /██\                       /██\
                       /████\                     /████\
                      /██████\                   /██████\
                     /██/\████\                 /████/\██\
                    /██/  \████\               /████/  \██\
                   /██/    \████\             /████/    \██\
                  /██/      \████\           /████/      \██\
                 /██/        \████\         /████/        \██\
                /██/          \████\       /████/          \██\
               /██/            \████\     /████/            \██\
              /██/              \████\   /████/              \██\
             /██/                \████\ /████/                \██\
            /██/                  \████████/                  \██\
           /██/                    \████/                    \██\
          /██/                     /████\                     \██\
         /██/                    /██    ██\                    \██\
        /██/                   /██        ██\                   \██\
       /██/                  _/██    /\    ██\_                  \██\
      /██/                 _/██     /  \     ██\_                 \██\
     /██/                _/██      / /\ \      ██\_                \██\
    /██/________________/██_______/ /  \ \_______██\________________\██\
    \████████████████████████████/  /\  \████████████████████████████/
                         /██\      /  \      /██\
                        /████\____/ /\ \____/████\
                       /████████__/____\__████████\
                         \██\      \____/      /██/
                          \██\___  /    \  ___/██/
                           \████\_/      \_/████/
                            \███\          /███/
                             \██\________/██/
                              \████████████/
                                 \██  ██/
                                  \████/
                                   \██/
EOF

# Red energy marks
echo -e "${RED_ACCENT}"
cat << "EOF"
                            >>>  GHOST  <<<
EOF

# Version/date mark
echo -e "${B3}                    11${RESET}${RED_ACCENT} / 16${RESET}"
echo ""

# --- Main title ---
echo -e "${B3}"
cat << "EOF"
 ██████╗ ██╗   ██╗███████╗    ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗
 ██╔══██╗██║   ██║██╔════╝    ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
 ██████╔╝██║   ██║█████╗      ██║  ███╗███████║██║   ██║███████╗   ██║
 ██╔══██╗██║   ██║██╔══╝      ██║   ██║██╔══██║██║   ██║╚════██║   ██║
 ██████╔╝╚██████╔╝███████╗    ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║
 ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝
EOF

echo -e "${ICE}"
cat << "EOF"
 ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗
 ██╔══██╗██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
 ██████╔╝███████║██║   ██║███████╗   ██║
 ██╔══██╗██╔══██║██║   ██║╚════██║   ██║
 ██████╔╝██║  ██║╚██████╔╝███████║   ██║
 ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝
EOF

echo -e "${B4}"
cat << "EOF"
 ██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██╗
 ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝ ██║
 ██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║      ██║
 ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║      ██║
 ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗ ███████╗
 ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
EOF
echo -e "${RESET}"

# --- Status bar ---
echo -e "${DIM}${B1}══════════════════════════════════════════════════════════════════${RESET}"
echo -e "${RED_ACCENT}[${WHITE} ARMED ${RED_ACCENT}]${RESET}  ${GOLD}[${WHITE} WATCH: ACTIVE ${GOLD}]${RESET}  ${B3}[${WHITE} TRACE: NULL ${B3}]${RESET}  ${ICE}[${WHITE} NODE: LOCAL ${ICE}]${RESET}"
echo -e "${DIM}${B1}══════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- One-time nickname prompt ---
if [ ! -f "$NICK_FILE" ]; then
    echo -e "${GOLD}Enter your operator nickname:${RESET}"
    read -r nickname
    if [ -z "$nickname" ]; then
        nickname="operator"
    fi
    echo "$nickname" > "$NICK_FILE"
fi

NICKNAME=$(cat "$NICK_FILE")

echo -e "${B3}Welcome back, ${WHITE}${NICKNAME}${RESET}"
echo -e "${ICE}$(date)${RESET}"
echo ""

# --- Custom colorful prompt: bypass@nickname:path$ with alternating colors ---
export PS1="\[\033[38;5;196m\]bypass\[\033[0m\]@\[\033[38;5;220m\]${NICKNAME}\[\033[0m\]:\[\033[38;5;39m\]\w\[\033[38;5;51m\]\$\[\033[0m\] "

# --- Colorful ls output and prompt extras ---
alias ls='ls --color=auto'
export LS_COLORS='di=1;34:ln=1;36:ex=1;31'
