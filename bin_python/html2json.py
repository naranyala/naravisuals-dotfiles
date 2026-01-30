
import argparse
import requests
from bs4 import BeautifulSoup
import json
import os

def scrape_to_json(url: str):
    response = requests.get(url)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    data = {
        "url": url,
        "title": soup.title.string if soup.title else None,
        "meta": {
            meta.get("name") or meta.get("property"): meta.get("content")
            for meta in soup.find_all("meta")
            if meta.get("name") or meta.get("property")
        },
        "headings": {
            "h1": [h.get_text(strip=True) for h in soup.find_all("h1")],
            "h2": [h.get_text(strip=True) for h in soup.find_all("h2")],
            "h3": [h.get_text(strip=True) for h in soup.find_all("h3")],
            "h4": [h.get_text(strip=True) for h in soup.find_all("h4")],
            "h5": [h.get_text(strip=True) for h in soup.find_all("h5")],
            "h6": [h.get_text(strip=True) for h in soup.find_all("h6")],
        },
        "paragraphs": [p.get_text(strip=True) for p in soup.find_all("p")],
        "links": [
            {"text": a.get_text(strip=True), "href": a.get("href")}
            for a in soup.find_all("a", href=True)
        ],
        "images": [
            {"alt": img.get("alt"), "src": img.get("src")}
            for img in soup.find_all("img")
        ],
    }

    return data

def main():
    parser = argparse.ArgumentParser(
        description="Scrape a webpage into structured JSON",
        epilog="""Examples:
  python html2json.py https://example.com
  python html2json.py https://example.com --out results/output.json
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("url", help="URL of the webpage to scrape")
    parser.add_argument("--out", help="Output file to save JSON", required=False)
    args = parser.parse_args()

    result = scrape_to_json(args.url)

    if args.out:
        # Ensure parent directories exist
        os.makedirs(os.path.dirname(args.out), exist_ok=True)

        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
        print(f"JSON saved to {args.out}")
    else:
        print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
