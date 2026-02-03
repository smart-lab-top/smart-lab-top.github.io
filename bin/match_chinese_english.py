#!/usr/bin/env python
"""Advanced Chinese-English title matching for unmatched papers"""

import yaml
import re
from difflib import SequenceMatcher

# Load citations
with open('_data/citations.yml', 'r', encoding='utf-8') as f:
    citations_data = yaml.safe_load(f)

# Read papers.bib
with open('_bibliography/papers.bib', 'r', encoding='utf-8') as f:
    bib_content = f.read()

# Function to extract key concepts from English titles
def extract_english_keywords(title):
    """Extract meaningful keywords from English title"""
    # Remove common words
    stop_words = {'of', 'the', 'a', 'and', 'or', 'in', 'on', 'at', 'to', 'for', 'with', 'by', 'as', 'is', 'based', 'using'}
    words = title.lower().split()
    keywords = [w for w in words if len(w) > 3 and w not in stop_words and w.isalpha()]
    return keywords

# Find papers without google_scholar_id
pattern = r'@article\{([^}]+)\n\s+title=\{([^}]+)\}'
matches = list(re.finditer(pattern, bib_content))

papers_without_id = []

for match in matches:
    cite_key = match.group(1)
    title = match.group(2).strip()
    
    # Check if this entry already has google_scholar_id
    entry_start = match.start()
    entry_end = bib_content.find('\n}', entry_start) + 2
    entry_text = bib_content[entry_start:entry_end]
    
    if 'google_scholar_id' not in entry_text:
        papers_without_id.append((cite_key, title, entry_text))

print('尝试进行中英文标题匹配...')
print('=' * 100)

matches_found = []

for cite_key, title, entry_text in papers_without_id:
    english_keywords = extract_english_keywords(title)
    
    # Extract year from title if exists
    year_match = re.search(r'\b(\d{4})\b', title)
    paper_year = year_match.group(1) if year_match else None
    
    # Look for Scholar papers with matching keywords and year
    best_match = None
    best_score = 0
    
    for pub_id, data in citations_data['papers'].items():
        scholar_title = data['title']
        scholar_year = str(data.get('year', ''))
        
        # Check year match first
        year_matches = (not paper_year) or (paper_year in scholar_year)
        
        if not year_matches:
            continue
        
        # Check keyword overlap
        scholar_lower = scholar_title.lower()
        keyword_matches = sum(1 for kw in english_keywords if kw in scholar_lower)
        
        # Calculate score based on keyword overlap
        if english_keywords:
            score = keyword_matches / len(english_keywords)
        else:
            score = 0
        
        if score >= 0.5 and score > best_score:
            best_score = score
            best_match = (pub_id.split(':')[1], scholar_title, score)
    
    if best_match:
        scholar_id, scholar_title, score = best_match
        matches_found.append({
            'cite_key': cite_key,
            'title': title,
            'scholar_id': scholar_id,
            'scholar_title': scholar_title,
            'score': score,
            'entry_text': entry_text
        })
        print(f'\n✓ {cite_key}')
        print(f'  本地: {title[:60]}')
        print(f'  Scholar: {scholar_title[:60]}')
        print(f'  匹配度: {score:.0%}')

if matches_found:
    print(f'\n\n找到 {len(matches_found)} 个可能的匹配')
    print('=' * 100)
    
    # Update papers.bib
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
    
    print(f'\n✓ 已更新 {len(matches_found)} 篇论文')
else:
    print('\n无法找到匹配的论文')
