---
layout: post
title: "Export Inkscape SVG to PDF from command line"
categories: blog
excerpt: Inkscape comes with a command line interface for scripting various commands...
tags: [inkscape]
date: 2019-10-14
---

Inkscape comes with a command line interface for scripting various commands.
To export an Inkscape SVG file `image.svg` to a PDF `image.pdf`, we can use the
following command
```
inkscape --file=image.svg --without-gui --export-pdf=image.pdf
```
Check the man page for alternative file types. 
By default, this renders all drawn elements in the SVG to the PDF, rather than
the selected page area. To render only the page selected in Inkscape, add the flag `--export-area-page`.

[Original SE answer](https://graphicdesign.stackexchange.com/questions/5880/how-to-export-an-inkscape-svg-file-to-a-pdf-and-maintain-the-integrity-of-the-im)
