# TODO

## zshrc

### Issues
- [x] Completion colors do nothing: `$LS_COLORS` is empty, so `list-colors` has no data. Run `dircolors` first.
- [x] Vi mode Esc lags 0.4s (`KEYTIMEOUT=40`). Set `KEYTIMEOUT=1`.
- [x] `ls` alias uses `--color=always`, leaking escape codes into pipes and files. Use `--color=auto`.
- [x] `untar` (`tar xzf`) only handles gzip. Use `tar xf` to auto-detect.

### Cleanups
- [x] Drop the manual zoxide `compdef` from the zinit `atinit`: zinit's `compdef` stub records zoxide's call and `zicdreplay` replays it.
- [x] Drop redundant `appendhistory` (implied by `sharehistory`) and `hist_ignore_dups` (covered by `hist_ignore_all_dups`).
- [x] Deduplicate `PATH` with `typeset -U path` and move it to `.zprofile`.
- [x] `pacup` errors with "no targets specified" when there are no orphans. Check first.
- [x] `bye`: use `systemctl poweroff` (no sudo needed).
- [x] Use `${ZINIT_HOME:h}` instead of `$(dirname $ZINIT_HOME)`.
