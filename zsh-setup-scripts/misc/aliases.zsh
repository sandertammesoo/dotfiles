#!/usr/bin/env zsh

alias h="history"

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Stuff I never really use but cannot delete either because of http://xkcd.com/530/
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 7'"

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
if command -v xargs &> /dev/null; then
    log_success "xargs is installed, setting up aliases"
    alias map="xargs -n1"
else
    log_skip "xargs not found, skipping xargs aliases"
fi

# One of @janmoesen’s ProTip™s
# http://www.commandlinefu.com/commands/view/7136/use-lwp-request-to-make-http-requests-from-the-command-line
if command -v lwp-request &> /dev/null; then
    log_success "lwp-request is installed, setting up aliases"
    for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
        alias "$method"="lwp-request -m '$method'"
    done
else
    log_skip "lwp-request not found, skipping lwp-request aliases"
fi

# IP addresses
#alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip="curl --no-progress-meter ifconfig.me | cut -c -14"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# View HTTP traffic
if command -v ngrep &> /dev/null && command -v tcpdump &> /dev/null; then
    log_success "ngrep and tcpdump are installed, setting up aliases"
    alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
    alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
else
    log_skip "ngrep and/or tcpdump not found, skipping ngrep and tcpdump aliases"
fi


# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# mac OS shortcuts
#check if Visual Studio Code application is installed
if [ -d "/Applications/Visual Studio Code.app" ]; then
    log_success "Visual Studio Code is installed, setting up aliases"
    alias code="open -a 'Visual Studio Code'"
    #code() {
    #  command code --extensions-dir "$XDG_DATA_HOME/vscode/extensions" --user-data-dir "$XDG_DATA_HOME/vscode/settings" "$@"
    #}
else
    log_skip "Visual Studio Code not found, skipping Visual Studio Code aliases"
fi

