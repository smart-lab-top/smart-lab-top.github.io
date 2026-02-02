#!/usr/bin/env python
"""Batch add google_scholar_id to papers.bib based on title matching with citations.yml"""

import yaml
import re
from difflib import SequenceMatcher

# Load citations data
with open('_data/citations.yml', 'r', encoding='utf-8') as f:
    citations_data = yaml.safe_load(f)

# Create a title -> scholar_id mapping
title_to_id = {}
for pub_id, data in citations_data['papers'].items():
    title = data['title'].lower().strip()
    scholar_id = pub_id.split(':')[1]  # Extract ID after the colon
    title_to_id[title] = scholar_id

# Read papers.bib
with open('_bibliography/papers.bib', 'r', encoding='utf-8') as f:
    bib_content = f.read()

matches_found = []

# Find papers without google_scholar_id
pattern = r'@article\{([^}]+)\n\s+title=\{([^}]+)\}'
matches = re.finditer(pattern, bib_content)

for match in matches:
    cite_key = match.group(1)
    title = match.group(2).lower().strip()
    
    # Check if this entry already has google_scholar_id
    entry_start = match.start()
    entry_end = bib_content.find('\n}', entry_start) + 2
    entry_text = bib_content[entry_start:entry_end]
    
    if 'google_scholar_id' in entry_text:
        continue
    
    # Find best matching title
    best_match = None
    best_score = 0
    for cit_title, scholar_id in title_to_id.items():
        score = SequenceMatcher(None, title, cit_title).ratio()
        if score > best_score and score >= 0.75:
            best_score = score
            best_match = scholar_id
    
    if best_match:
        matches_found.append({
            'cite_key': cite_key,
            'title': title,
            'scholar_id': best_match,
            'score': best_score,
            'entry_text': entry_text
        })

# Add google_scholar_id to each matched paper
for match in matches_found:
    old_entry = match['entry_text']
    # Find the closing brace and add google_scholar_id before it
    new_entry = old_entry.rstrip()
    if new_entry.endswith('}'):
        new_entry = new_entry[:-1] + f',\n  google_scholar_id={{{match["scholar_id"]}}}\n}}'
        bib_content = bib_content.replace(old_entry, new_entry, 1)

# Write back to file
with open('_bibliography/papers.bib', 'w', encoding='utf-8') as f:
    f.write(bib_content)

print(f'Added google_scholar_id to {len(matches_found)} papers:')
for match in matches_found:
    print(f'  - {match["cite_key"]}: {match["scholar_id"]} ({match["score"]:.1%} match)')

print(f'\nTotal: {len(matches_found)} papers updated')
