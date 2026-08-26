###-begin-opencode-completions-###
#
# yargs command completion script for fish
#
# Installation: 
#   mkdir -p ~/.config/fish/completions
#   opencode completion > ~/.config/fish/completions/opencode.fish
#
function _opencode_yargs_completions
    # Get the commandline arguments up to the cursor (tokenized)
    set -l args (commandline -opc)

    # Get the current word the cursor is on
    set -l current_word (commandline -t)

    # Ask yargs to generate completions
    opencode --get-yargs-completions $args $current_word
end

# Register the completion function to the 'opencode' command.
# Omitting the '-f' flag allows Fish to naturally fall back to 
# filename completion if yargs returns no matches.
complete -c opencode -a '(_opencode_yargs_completions)'
###-end-opencode-completions-###
