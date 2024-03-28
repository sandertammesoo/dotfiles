brew leaves shows you all top-level packages; packages that are not dependencies. This should be the most interesting if you are using the list to re-install packages.

To include formula descriptions, use
'brew leaves | xargs brew desc --eval-all'

To include cask descriptions, use:
'brew ls --casks | xargs brew desc --eval-all'

Only list leaves that were manually installed: 
'brew leaves --installed-on-request | xargs -n1 brew desc --eval-all'

It is possible to view the list of all the installed packages as a nicely formatted dependency tree. 
To view it, execute the following command:
'brew deps --tree --installed'

