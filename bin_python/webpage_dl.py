
import os
import argparse
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

def download_file(url, folder):
    local_filename = os.path.join(folder, os.path.basename(urlparse(url).path))
    try:
        r = requests.get(url, stream=True, timeout=10)
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
        return local_filename
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return None

def scrape_page(url, out_folder):
    os.makedirs(out_folder, exist_ok=True)

    # Download main HTML
    response = requests.get(url)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    # Collect assets
    assets = []
    for tag, attr in [("img", "src"), ("script", "src"), ("link", "href")]:
        for element in soup.find_all(tag):
            src = element.get(attr)
            if src:
                full_url = urljoin(url, src)
                assets.append((element, attr, full_url))

    # Download assets and rewrite references
    for element, attr, full_url in assets:
        local_path = download_file(full_url, out_folder)
        if local_path:
            element[attr] = os.path.basename(local_path)

    # Save modified HTML
    html_path = os.path.join(out_folder, "index.html")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(str(soup.prettify()))

    print(f"Page and assets saved in folder: {out_folder}")

def main():
    parser = argparse.ArgumentParser(
        description="Download entire webpage with assets into a folder",
        epilog="""Examples:
  python downloader.py https://example.com --out site_copy
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("url", help="URL of the webpage to download")
    parser.add_argument("--out", help="Output folder to store page and assets", required=True)
    args = parser.parse_args()

    scrape_page(args.url, args.out)

if __name__ == "__main__":
    main()
