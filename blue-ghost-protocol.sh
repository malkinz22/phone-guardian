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

clear

# --- Fox/creature mask emblem (ears + angular face, original design) ---
echo -e "${B1}"
cat << "EOF"
        \\                                                   //
         \\\                                               ///
          \\\\                                           ////
EOF
echo -e "${B2}"
cat << "EOF"
           \\\\\                                       /////
            \\\\\\                                   //////
             \\\\\\\                               ///////
EOF
echo -e "${B3}"
cat << "EOF"
              \\\\\\\\                          ////////
               \\\\\\\\\                      /////////
EOF
echo -e "${RED_ACCENT}"
cat << "EOF"
                \\\\\\\\\\        *        //////////
EOF
echo -e "${B4}"
cat << "EOF"
                 \\\\\\\\\\      / \      //////////
                  \\\\\\\\\    /   \    //////////
EOF
echo -e "${ICE}"
cat << "EOF"
                   \\\\\\\  ▄▄▄▄▄▄▄▄▄▄▄  ///////
                    \\\\  █           █  //////
EOF
echo -e "${B3}"
cat << "EOF"
                     \\  █  ◆     ◆  █  /////
                        █             █
                         █▄▄       ▄▄█
EOF
echo -e "${B2}"
cat << "EOF"
                           █▄▄▄▄▄▄▄█
                            ▀▀▀▀▀▀▀
EOF
echo -e "${RESET}"

# --- Title ---
echo -e "${B3}"
cat << "EOF"
██████╗ ███████╗ █████╗ ███████╗████████╗    ██╗  ██╗
██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝    ╚██╗██╔╝
██████╔╝█████╗  ███████║███████╗   ██║        ╚███╔╝
██╔══██╗██╔══╝  ██╔══██║╚════██║   ██║        ██╔██╗
██████╔╝███████╗██║  ██║███████║   ██║       ██╔╝ ██╗
╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝  ╚═╝
EOF
echo -e "${ICE}"
cat << "EOF"
   ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗
  ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
  ██║  ███╗███████║██║   ██║███████╗   ██║
  ██║   ██║██╔══██║██║   ██║╚════██║   ██║
  ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║
   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝
EOF
echo -e "${B4}"
cat << "EOF"
██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗
██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║
██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║
██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║
██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝
EOF
echo -e "${RESET}"

echo -e "${DIM}${B1}   ────────────────────────────────────────────────────────${RESET}"
echo -e "${RED_ACCENT}[${WHITE} ARMED${RED_ACCENT}]${RESET}  ${GOLD}[${WHITE} WATCH: ACTIVE${GOLD}]${RESET}  ${B3}[${WHITE} TRACE: NULL${B3}]${RESET}  ${ICE}[${WHITE} NODE: LOCAL${ICE}]${RESET}"
echo -e "${DIM}${B1}   ────────────────────────────────────────────────────────${RESET}"
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
