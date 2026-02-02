#!/usr/bin/env python
"""Advanced matching for remaining papers using lower similarity threshold and multi-criteria"""

import yaml
import re
from difflib import SequenceMatcher

# Load citations data
with open('_data/citations.yml', 'r', encoding='utf-8') as f:
    citations_data = yaml.safe_load(f)

# Create a title -> scholar_id mapping
citations_by_title = {}
for pub_id, data in citations_data['papers'].items():
    title = data['title'].strip()
    scholar_id = pub_id.split(':')[1]
    citations_by_title[title] = scholar_id

# Read papers.bib
with open('_bibliography/papers.bib', 'r', encoding='utf-8') as f:
    bib_content = f.read()

# Find papers without google_scholar_id
pattern = r'@article\{([^}]+)\n\s+title=\{([^}]+)\}'
matches = re.finditer(pattern, bib_content)

papers_to_update = []

for match in matches:
    cite_key = match.group(1)
    title = match.group(2).strip()
    
    # Check if this entry already has google_scholar_id
    entry_start = match.start()
    entry_end = bib_content.find('\n}', entry_start) + 2
    entry_text = bib_content[entry_start:entry_end]
    
    if 'google_scholar_id' in entry_text:
        continue
    
    # Find best matching title with lower threshold (0.65)
    best_match = None
    best_score = 0
    best_cite_title = None
    
    for cite_title, scholar_id in citations_by_title.items():
        # Try both lowercase and original case
        score = max(
            SequenceMatcher(None, title.lower(), cite_title.lower()).ratio(),
            SequenceMatcher(None, title, cite_title).ratio()
        )
        
        if score > best_score and score >= 0.65:
            best_score = score
            best_match = scholar_id
            best_cite_title = cite_title
    
    if best_match:
        papers_to_update.append({
            'cite_key': cite_key,
            'title': title,
            'scholar_id': best_match,
            'score': best_score,
            'cite_title': best_cite_title,
            'entry_text': entry_text
        })

# Display potential matches
print(f'找到 {len(papers_to_update)} 篇可能的匹配论文:')
print('=' * 100)
for paper in papers_to_update:
    print(f"\nBibTeX Key: {paper['cite_key']}")
    print(f"本地标题:   {paper['title'][:70]}")
    print(f"Scholar标题: {paper['cite_title'][:70]}")
    print(f"相似度:     {paper['score']:.1%}")
    print(f"Scholar ID: {paper['scholar_id']}")

# Add google_scholar_id to each matched paper
print('\n' + '=' * 100)
print(f'正在添加 {len(papers_to_update)} 篇论文的 google_scholar_id...')

for paper in papers_to_update:
    old_entry = paper['entry_text']
    # Find the closing brace and add google_scholar_id before it
    new_entry = old_entry.rstrip()
    if new_entry.endswith('}'):
        new_entry = new_entry[:-1] + f',\n  google_scholar_id={{{paper["scholar_id"]}}}\n}}'
        bib_content = bib_content.replace(old_entry, new_entry, 1)

# Write back to file
with open('_bibliography/papers.bib', 'w', encoding='utf-8') as f:
    f.write(bib_content)

print(f'\n✓ 成功添加 {len(papers_to_update)} 篇论文的 google_scholar_id')
