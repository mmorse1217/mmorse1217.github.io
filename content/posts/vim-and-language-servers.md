---
layout: post
title: "Vim and Language Servers"
categories: blog
excerpt: Setting up autocomplete tools in Vim using Language Servers
tags: [software-eng,vim,docker,language-server,bash]
date: 2020-04-27
---

I spend the majority of my time on a computer using Vim in one form or another.
The most frequent criticism of this that I've heard is something to effect of: "There's no autocomplete/error-checking/smart-refactoring/something else in Vim! How can you program like this?!"

Although this isn't technically true (the built-in autocomplete features are actually [pretty good](https://stackoverflow.com/a/5169683)), it's a decent point. 
Autocomplete and its intelligent cousins, broadly referred to as "intellisense", are useful tools.
Unfortunately, the process of setting up and properly configuring plugins for these features can be a daunting task.
I've tried many times to do so; [YCM](https://github.com/ycm-core/YouCompleteMe) comes to mind.
However, I ultimately remove them out of frustration or dissatisfaction and return to the ever-faithful [supertab](https://github.com/ervandew/supertab), which is a text-based autocomplete plugin that is mildly smarter than the built-in ones.
I would lying if I said that I didn't miss these features, though.

## Microsoft to the rescue with Language Servers
Recently, I've been hearing a lot of praise for [VSCode](https://code.visualstudio.com/), a new(ish) editor from Microsoft. 
It seems that the secret sauce of VSCode is the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) (LSP), which is a standardized protocol introduced by Microsoft for communication between an editor and something called a Language Server.
From the [LSP webpage](https://microsoft.github.io/language-server-protocol/):
> A *Language Server* is meant to provide the language-specific smarts and communicate with development tools over a protocol that enables inter-process communication.

It's basically an interface layer between an editor and a language.
Instead of the editor directly calling `python` or `clang` to analyze the code, it makes a request to a Language Server to provide the information needed to support the smart feature.

Why is this abstraction useful?
Well, if there are $$m$$ editors and $$n$$ languages, full language support for all editors requires implementing $$m \cdot n$$ plugins for each editor-language pair.
Instead, the Language Server model requires each editor to interface with a Language Server via JSON and for each language to implement a Language Server, which is $$m$$ editor plugins and $$n$$ Language Servers.
Essentially, if you have a Language Server installed on your machine, each editor on your machine with an LSP plugin can use it. 
More importantly, because a Language Server is a real server, the source code and build system can live on a remote server and communicate with client editors remotely over TCP.
This also has the nice benefit of keeping your editor fast and snappy while the Language Server does the heavy lifting asynchronously.

This sounded great to me, so I decided to dive back into the wild world of Vim plugins and configurations to integrate this into my workflow.
My goals were:
* acquire the superpowers of smart code completion in Vim
* avoid cluttering up my local environment
* automate the setup process

After some preliminary research, it seemed that [coc.nvim](https://github.com/neoclide/coc.nvim) was far and away the best LSP-compliant plugin for Vim. 
Other popular alternatives were [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim) and [vim-lsp](https://github.com/prabirshrestha/vim-lsp), but I settled on coc.nvim because i.) it is extremely popular and ii.) the maintainers are unbelievably active. 
These are very promising signs for the future of an open-source project.
It seems that others have success with other plugins, so by all means try these out for yourself.

## Setting up Vim with Language Servers
I was pleasantly surprised by how painless this was to setup.
First, coc.nvim runs on `nodejs`, so I need to install it along with `yarn`:

```bash
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt update
sudo apt install -y nodejs yarn
```

Next, I have to install the Language Servers themselves.
I using Language Servers here that are easy to install, rather than the "best."
For Python, I'm using Palantir's [version](https://github.com/palantir/python-language-server), but Microsoft seems to [have their own](https://github.com/microsoft/python-language-server). 
I also need `pyflakes` for linting (you can choose your favorite linter later):
```bash
pip install python-language-server pyflakes
```

For C++, I'm using [clangd](https://clangd.llvm.org/). 
To minimize coc.nvim configuration, I updated the system default for `clangd` to use `clangd-9`:
```bash
sudo apt install -y clangd-9 
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100
```

Setting up Latex is a bit more involved.
There seemed to be two dominant Language Servers, [texlab](https://texlab.netlify.app/) and [digestif](https://github.com/astoff/digestif).
It wasn't immediately clear which option was better; both seemed about equally active, both supported most features I cared about, and both were implemented in languages that I had no experience in (Rust and Lua, respectively). 
I somewhat randomly picked `texlab`, which means that I need to install Rust, Latex and `texlab`:
```bash
# Explicitly install tzdata, required by texlab, by hand to allow for a scripted install, 
export DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime  
sudo apt-get install -y tzdata 
dpkg-reconfigure --frontend noninteractive tzdata   

# Install Latex
sudo apt install -y \
    texlive-latex-extra \
    texlive-science \
    curl

# Install dependencies for latex Language Server
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
~/.cargo/bin/cargo install --git https://github.com/latex-lsp/texlab.git
```
Next, I need to add the coc extensions for each language server I will use.
This can be done either by typing `:CocInstall <coc-extension>` from within Vim, or by specifying the `coc_global_extensions` variable in your `.vimrc`.
I've installed a few extras to provide extra code snippet functionality and json parsing:
```vim
let g:coc_global_extensions = [
            \ 'coc-json',
            \ 'coc-clangd',
            \ 'coc-python',
            \ 'coc-snippets',
            \ 'coc-ultisnips',
            \ 'coc-texlab',
            \ ]
```


The final step is writing the `coc-settings.json` configuration file.
This file should live in the `~/.vim` directory and contain a single JSON dictionary, with a key `languageserver`, whose value contains the configuration required for each Language Server. 
The [coc.nvim Github page](https://github.com/neoclide/coc.nvim/wiki/Language-servers) has a list of sample entries for some popular languages, which I shamelessly copied to build my own configuration file.
For Python, I was able to copy the entry as is.
For Latex, I needed to change the command field to point to `texlab`'s location.
Miraculously, C++ needed *no* configuration, which made me unreasonably happy.
My simple `coc-settings.json` is available [here](https://github.com/mmorse1217/dotfiles/blob/master/coc-settings.json) in case the formatting is unclear.

## Some downsides of coc.nvim
After setting up my Language Servers and playing around with my autocomplete, I noticed a several drawbacks of coc.nvim:

1. I felt slightly betrayed. 
I almost always have to install a "coc extension" for a particular language in order to use all of the features of coc.nvim.
This seems to defeat the purpose of installing a Language Server in the first place. 
I'm willing to overlook this since I'm only using Vim for development these days and VSCode also has this behavior. Moreover, it seems that they are truly extensions to a vanilla Language Server, which means that coc should work to some degree without them (although I haven't tried).

2. Language servers are yet another dependency slowly taking over my machine.
For Python and C++, installing [python-language-server](https://github.com/microsoft/python-language-server) and [clangd](https://clangd.llvm.org/) was painless, but each had a few more dependencies than I would like. 
But I drew the line at [texlab](https://github.com/latex-lsp/texlab), which had so many dependencies that it made me question whether I really wanted autocomplete at all. 
Beyond installing Rust, which I have no need for, the `cargo build` to install `texlab` command tried to install *338 Javascript libraries*. 
This made me feel both violently ill and as though someone just stole my wallet.

3. Continuing from the previous point, suppose that I have a large C++ project with many dependencies.
    Not only will I need to install the dependencies in order to compile the project, but I will also need them in order to use autocomplete.
    This may seem pedantic, but if the project already lives in a virtual environment, container, or on a remote machine, this defeats the purpose of the isolation. 
    The Language Server needs these dependencies locally as well, because [coc.nvim doesn't seem to support remote Language Servers over TCP](https://github.com/neoclide/coc.nvim/issues/761).

4. Installing a Language Server for each language that I need on each machine that I use is tedious. 
Compared to just starting Vim and calling `PlugInstall`, this is much more work and I'm extremely lazy.

There must be a better way to deal with this.

## Hiding the ugly bits 
Fortunately, there's a somewhat simple solution to my primary complaints.
I don't need these Language Servers at all times on my main machine, only when I'm programming.
Usually, `supertab` is sufficient (if not overkill) to edit anything else.
This means that I can put my code complete tools in the environment where I'm actually using them: inside of a project-specific Docker container.
This sandboxes the required dependencies and, as a bonus, automates the configuration of the Language Servers.

This requires `bash` scripting my Vim installation, building and installing the Language Servers, and installing other Vim plugins.
Since I have already [started automating my development environment](https://github.com/mmorse1217/terraform), I can reuse these scripts and dotfiles inside the Dockerfile without changes.
Here's a trimmed Dockerfile for a sample C++ project whose dependencies are first configured in `project-dependencies`, which is then extended with Vim and `clangd`:
```
FROM ubuntu:18.04 as project-dependencies
# Set up and install compilers and dependencies for project
RUN ...
...

CMD ["/bin/bash"]

# Make a new image based on the project dependency image
FROM project-dependencies as project-dev

# Specify some environment variables for:
#    1. enabling coc.nvim in our.vimrc
#    2. disabling any installation prompts
#    3. setting up the proper number of terminal colors inside the container
ENV VIM_DEV=1 DEBIAN_FRONTEND=noninteractive TERM=xterm-256color 

# Clone my repo of configuration scripts
RUN git clone https://github.com/mmorse1217/terraform --recursive
WORKDIR /terraform 

# Symlink dotfiles 
RUN bash dotfiles/setup.sh 

RUN apt-get upgrade -y && apt install -y sudo git vim

# Setup Language Servers for c++
# install nodejs + yarn for coc.nvim backend + clangd
RUN bash vim/lang-servers/setup.sh  
RUN bash vim/lang-servers/clangd.sh  

# install vim plugins, including coc.nvim
RUN bash vim/install_plugins.sh

CMD ["/bin/bash"]
```
I also tweaked my `.vimrc` plugin list to check for the `VIM_DEV` environment variable before loading coc.nvim:
```vim
call plug#begin('~/.vim/vim-plug')
if exists('$VIM_DEV')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
else
    Plug 'ervandew/supertab'
endif
" other plugins ...
call plug#end
```

Here's another Dockerfile to work on a general Latex project, with `texlab` and all of its dependencies:

```
FROM ubuntu:18.04 as vim

# update and install all packages
RUN apt-get update

# need this for fast fuzzy file seraching with vim
RUN apt install -y sudo silversearcher-ag 

# Clone environment configuration
RUN git clone https://github.com/mmorse1217/terraform.git --recursive
WORKDIR terraform

# Symlink dotfiles 
RUN bash dotfiles/setup.sh

# Same as above
ENV VIM_DEV=1 DEBIAN_FRONTEND=noninteractive TERM=xterm-256color 


# Compile one dependecy of texlab explicitly to avoid any 
# required terminal input on build
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime  && \
sudo apt-get install -y tzdata && \
dpkg-reconfigure --frontend noninteractive tzdata   

# build vim from source
RUN bash vim/build_from_source.sh  

# Setup Language Servers 
# install nodejs + yarn for coc.nvim backend
RUN bash vim/lang-servers/setup.sh  

# Install texlab + latex (takes a while...)
RUN bash vim/lang-servers/texlab.sh  

# install vim plugins, including coc.nvim
RUN bash vim/install_plugins.sh

CMD ["/bin/bash"]
```

Once we have these Dockerfiles, we can build images and create a container in the usual fashion: below is an example with the Latex + `texlab` Dockerfile above.
Note that here we mounting the local directory as a volume so that we can edit the code on the host machine from inside the container (and vice versa).

```
$ docker build -t vim-latex .
$ docker create -it -v`pwd`:/src --name latex-proj vim-latex
```

Then we can start the container and start a new `bash` session inside ...
```
$ docker start latex-proj
$ docker attach latex-proj
root@3160b1a2b8fb:~#
```
... and verify that we have code complete features working when we edit a `tex` file.
We can even compile the `tex` file inside the container and the pdf along with
the build artifacts will appear on the host machine (no X11 forwarding required).
Not only is this workflow is reproducible with a two commands, but it leaves the host machine free of dependencies once you are finished.

## Wrapping up
I'm fairly happy with Language Servers and coc.nvim so far. 
They finally are providing the level of quality that many plugins have promised before but failed to deliver on.

The only thing that I can imagine that would improve the situation is the ability to "concatenate" prebuilt Docker images.
The `project-dependencies` image is likely built during development, during continuous integration or pulled from Docker Hub (or both).
In an ideal world, one could prebuild `project-dependencies` and a `vim-clangd` image above, pull them from Docker Hub and add the layers from one image to another. 
This would require much less time and computation.
However, this seems to be a Pandora's Box due to the generality of containers and appears to [be a hot-button issue](https://github.com/moby/moby/issues/3378). 
For now, I'll settle for maximizing code reuse via bash scripts, concatenating Dockerfiles, and taking a coffee break.
