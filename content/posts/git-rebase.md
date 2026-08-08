---
layout: post
title: "Squashing Git Commits"
categories: blog
excerpt: "Let's say you have a bunch of commits in your git history..."
tags: [software,git]
date: 2020-04-28
---

Let's say you have a bunch of commits in your git history and you would like to collapse some of the recent ones into a single commit.
You can do this with `git rebase`; this is affectionately referred to as "squashing" commits.
To do so:

1. Determine either i.) the number of commits that you would like to squash into a single commit or ii.) the commit _before_ the commits that you want to squash.
2. * If you want to squash the last N commits to squash:
    ```
    git rebase -i HEAD~N
    ```
   * If you have the hash of the commit before the commits to squash:
    ```
    git rebase -i <commit-hash>
    ```
3. In the subsequent file that will open in your default editor, pick the commit(s) that you want to survive the rebase. 
In this case, we pick only the top commit (denoted `pick` in the leftmost column), and replace the other commits' `pick`'s with an `s` (for squash).
Save and exit the editor.
4. Rewrite the commit message and delete the old commits.

For a full worked out example, see [this post](https://www.internalpointers.com/post/squash-commits-into-one-git ).
