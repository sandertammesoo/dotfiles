# Make vim the default editor
export EDITOR="vim";

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow}";

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# Always enable colored `grep` output
export GREP_OPTIONS="--color=auto";

#export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home/"
export ANDROID_HOME=/usr/local/opt/android-sdk
export GOPATH=$HOME/projects/go
export CPPUTEST_HOME=~/Documents/Dropbox/projects/cpputest
export JENV_ROOT=/usr/local/var/jenv

export HOMEBREW_GITHUB_API_TOKEN=f9b42aeeda3f07c316bd4b92b4dcce996a3b0790
