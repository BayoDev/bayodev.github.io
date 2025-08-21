#!/bin/bash

# Update index
pandoc index.md -o index.html --standalone --toc \
		-H components/style.html

# Update all posts
for file in md_posts/*.md; do
    filename=$(basename "$file" .md)
    pandoc "$file" -o "html_posts/$filename.html" --standalone --toc \
			-H components/style.html \
			-B components/header.html \
			-A components/footer.html
done