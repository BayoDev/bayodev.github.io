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

BASE_URL="https://bayo.dev"

SITEMAP="sitemap.xml"

echo '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' > "$SITEMAP"

echo "  <url><loc>${BASE_URL}/</loc></url>" >> "$SITEMAP"

# Add URLs for each HTML file in html_posts
for file in html_posts/*.html; do
    filename=$(basename "$file")
    echo "  <url><loc>${BASE_URL}/html_posts/${filename}</loc></url>" >> "$SITEMAP"
done

echo '</urlset>' >> "$SITEMAP"
