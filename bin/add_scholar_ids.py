#!/usr/bin/env python

import os
import yaml
import re
from difflib import SequenceMatcher

# Load citations data
with open('_data/citations.yml', 'r', encoding='utf-8') as f:
    citations_data = yaml.safe_load(f)

# Build a mapping of titles to scholar IDs
papers_map = {}
for pub_id, paper_info in citations_data['papers'].items():
    title = paper_info.get('title', '').lower().strip()
    if title:
        papers_map[title] = pub_id

# Read papers.bib
with open('_bibliography/papers.bib', 'r', encoding='utf-8') as f:
    bib_content = f.read()

# Function to find similar title match
def find_best_match(title, papers_map, threshold=0.8):
    title_lower = title.lower().strip()
    
    # Try exact match first
    if title_lower in papers_map:
        return papers_map[title_lower]
    
    # Try similarity matching
    best_match = None
    best_ratio = 0
    for scholar_title, pub_id in papers_map.items():
        ratio = SequenceMatcher(None, title_lower, scholar_title).ratio()
        if ratio > best_ratio and ratio >= threshold:
            best_ratio = ratio
            best_match = pub_id
    
    return best_match

# Parse BibTeX entries and add google_scholar_id
def add_scholar_ids(content, papers_map):
    # Pattern to match @article{...} blocks
    entry_pattern = r'(@article\{[^}]+?\n\})'
    
    def process_entry(match):
        entry = match.group(1)
        
        # Extract title
        title_match = re.search(r'title\s*=\s*\{([^}]+)\}', entry, re.IGNORECASE)
        if not title_match:
            return entry
        
        title = title_match.group(1).strip()
        
        # Find matching scholar ID
        scholar_id = find_best_match(title, papers_map)
        
        if scholar_id:
            # Check if google_scholar_id already exists
            if 'google_scholar_id' in entry:
                print(f'SKIP: {title[:50]}... (already has google_scholar_id)')
                return entry
            
            # Add google_scholar_id before the closing brace
            entry = entry.rstrip('}').rstrip() + f',\n  google_scholar_id = {{{scholar_id}}}\n}}'
            print(f'ADD: {title[:50]}... -> {scholar_id}')
            return entry
        else:
            print(f'NO MATCH: {title[:50]}...')
            return entry
    
    result = re.sub(entry_pattern, process_entry, content, flags=re.DOTALL)
    return result

# Process
updated_content = add_scholar_ids(bib_content, papers_map)

# Write back
with open('_bibliography/papers.bib', 'w', encoding='utf-8') as f:
    f.write(updated_content)

print('\nDone! google_scholar_id fields added to papers.bib')
