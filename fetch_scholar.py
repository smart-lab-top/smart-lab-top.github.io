from scholarly import scholarly
import sys

SCHOLAR_USER_ID = 'IEfV3ZYAAAAJ'

try:
    print(f"Fetching author data for {SCHOLAR_USER_ID}...")
    author = scholarly.search_author_id(SCHOLAR_USER_ID)
    author_data = scholarly.fill(author, sections=['publications'])
    
    print("Title | Year | Citations | ID")
    print("---|---|---|---")
    for pub in author_data['publications']:
        title = pub.get('bib', {}).get('title', 'Unknown')
        year = pub.get('bib', {}).get('pub_year', 'Unknown')
        citations = pub.get('num_citations', 0)
        pub_id = pub.get('author_pub_id', 'Unknown')
        print(f"{title} | {year} | {citations} | {pub_id}")
except Exception as e:
    print(f"Error: {e}")
