---
layout: page
title: Blog
excerpt: "An archive of blog posts sorted by date."
search_omit: true
---

This is an attempt to keep helpful bits of information that I've come across in one place.
If you notice mistakes or bugs, please get in touch, or submit a pull request on [Github](https://github.com/mmorse1217/mmorse1217.github.com) directly if you like.
<ul class="post-list">
{% for post in site.categories.blog %} 
  <li><article><a href="{{ site.url }}{{ post.url }}">{{ post.title }} <span class="entry-date"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %d, %Y" }}</time></span>{% if post.excerpt %} <span class="excerpt">{{ post.excerpt | remove: '\[ ... \]' | remove: '\( ... \)' | markdownify | strip_html | strip_newlines | escape_once }}</span>{% endif %}</a></article></li>
{% endfor %}
</ul>
