#!/usr/bin/env python
"""Analyze unmatched papers"""

import yaml
import re

# Load citations data
with open('_data/citations.yml', 'r', encoding='utf-8') as f:
    citations_data = yaml.safe_load(f)

# Read papers.bib
with open('_bibliography/papers.bib', 'r', encoding='utf-8') as f:
    bib_content = f.read()

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
        papers_without_id.append((cite_key, title))

print(f'未匹配的论文: {len(papers_without_id)} 篇')
print('=' * 100)
print('\n无法自动匹配的论文:')
print('这些论文可能不在 Google Scholar 中或尚未被索引')
print('=' * 100)

for cite_key, title in papers_without_id:
    print(f'\n{cite_key}:')
    print(f'  {title}')

print(f'\n\n总结: {len(papers_without_id)} 篇论文在 Google Scholar 中未找到')
print('原因可能是:')
print('  1. 论文太新 (2025年)')
print('  2. 某些期刊/出版物 Google Scholar 还未收录')
print('  3. 会议论文或其他类型的出版物')
print('  4. 论文标题在 Scholar 中的格式不同')