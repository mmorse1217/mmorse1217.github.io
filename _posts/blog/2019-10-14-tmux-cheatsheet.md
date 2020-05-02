---
layout: post
title: "Tmux cheatsheet"
categories: blog
excerpt: A minimal tmux cheatsheet.
tags: [tmux]
date: 2019-10-14
---

I check Daniel Miessler's [Tactical tmux](https://danielmiessler.com/study/tmux/) constantly, so I decided to make a more condensed cheatsheet specific to check locally.
This isn't a tutorial so much as a list of reference commands and related configurations for good measure. 
I'm by no means a power-user, so I'll be updating this as I accumulate
`tmux`-related knowledge.

### Bash interface
* `tmux new -s session` start a new `tmux` session with name `session`
* `tmux deatch` detach from current session
* `tmux ls` list current sessions
* `tmux a -t session` attach to the session with name `session`
* `tmux kill-session -t session` kill the session with name `session`
### Commands
All commands are prefixed by `ctrl-b`.
* `d` detach from the current session 
* `c` create a new window
* `%` split window horizontally 
* `"` split window vertically
* `n` change to next window
* `p` change to previous window

* `:resize-pane -L 5` Expand the size of the current pane by 5 columns to the
    _left_
* `:resize-pane -R 5` Expand the size of the current pane by 5 columns to the
    _right_
* `:respawn-pane -k` kill command running in current pane and respawn pane

### `.tmux.conf`
```
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

### `.vimrc`
Add the following lines to your `.vimrc` to allow for tmux to share the color
scheme as your terminal:
```
if $TERM == 'screen'
    set t_Co=256
endif
```
[Original SE link](https://unix.stackexchange.com/a/201793)
