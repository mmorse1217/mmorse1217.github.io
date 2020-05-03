---
layout: post
title: "Fixing some hiccups in org mode"
categories: blog
excerpt: A list of subtle tweaks to use fix some parts of org-mode for Emacs 26.3
tags: [org,emacs]
date: 2020-05-02
---

In a clean installation of Emacs 26.3 with Spacemacs, I have two glaring bugs that mess up my workflow:

1. Archiving a `TODO` with `C-c C-x C-a` produces an error:
`org-copy-subtree: Invalid function: org-preserve-local-variables`.
I have also seen this error also when using `org-refile`.

2. Performing an `org-agenda` tag filter via `C-c a m` for any tag causes Emacs to hang indefinitely.

It seems that both of these are addressed by explicitly deleting packages in `.emacs.d/elpa`, which forces Emacs to reinstall them. 
To address 1., run ([source](https://github.com/syl20bnr/spacemacs/issues/11801)):
```bash
cd ~/.emacs.d/elpa/
find org*/*.elc -print0 | xargs -0 rm
```


To address 2., run ([source](https://emacs.stackexchange.com/questions/48505/help-debugging-org-mode-hangs-on-agenda-tag-search) ) :
```bash
rm -rf ~/.emacs.d/elpa/*
```

I'm not an Emacs expert, so it's not immediately clear to me why this works. 
More mysteriously, it seems that the command to solve problem 2. does not solve problem 1.
A `.elc` file a compiled Elisp file, so this seems to force a recompile of `org` packages themselves.

