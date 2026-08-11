#!/usr/bin/env python3
"""Download food/restaurant images from Unsplash for Green Park seed content.

For each slot we try candidate photo ids in priority order and keep the first
that downloads successfully, saving it to /tmp/greenpark-imgs/<slot>.jpg
"""
import os
import subprocess
import sys

OUT = "/tmp/greenpark-imgs"
os.makedirs(OUT, exist_ok=True)

# slot -> candidate unsplash photo ids (in priority order)
SLOTS = {
    # menu
    "biryani": ["1585937421612-70a008356fbe", "1563379926898-05f4575a45d8", "1512058564366-18510be2db19", "1512621776951-a57141f2eefd"],
    "biryani-mutton": ["1633945274405-b6c8069047b0", "1585937421612-70a008356fbe", "1604908176997-125f25cc6f3d"],
    "biryani-veg": ["1512058564366-18510be2db19", "1546069901-ba9599a7e63c", "1512621776951-a57141f2eefd"],
    "chicken-65": ["1604908176997-125f25cc6f3d", "1562967916-eb82221dfb92", "1626645738196-c2a7c87a8f58"],
    "chilli-chicken": ["1562967916-eb82221dfb92", "1626645738196-c2a7c87a8f58", "1544025162-d76694265947"],
    "paneer": ["1631452180519-c014fe946bc7", "1567188040759-fb8a883dc6ff", "1512621776951-a57141f2eefd"],
    "gobi": ["1563245372-f21724e3856d", "1525755662778-989d0524087e", "1546069901-ba9599a7e63c"],
    "lollipop": ["1544025162-d76694265947", "1555939594-58d7cb561ad1", "1562967916-eb82221dfb92"],
    "tandoori": ["1555939594-58d7cb561ad1", "1599487488170-d11ec9c172f0", "1544025162-d76694265947"],
    "tikka": ["1599487488170-d11ec9c172f0", "1555939594-58d7cb561ad1", "1603894584373-5ac82b2ae398"],
    "soup": ["1547592166-23ac45744acd", "1470337458703-46ad1756a187", "1546069901-ba9599a7e63c"],
    "curry": ["1585937421612-70a008356fbe", "1633945274405-b6c8069047b0", "1563379926898-05f4575a45d8"],
    "curry-chicken": ["1604908176997-125f25cc6f3d", "1626203038584-2a6c01318b6b", "1544025162-d76694265947"],
    "mutton": ["1626203038584-2a6c01318b6b", "1544025162-d76694265947", "1555939594-58d7cb561ad1"],
    "fish": ["1559742811-822873691df8", "1519708227418-c8fd9a32b7a2", "1504674900247-0877df9cc836"],
    "prawns": ["1519708227418-c8fd9a32b7a2", "1559742811-822873691df8", "1546069901-ba9599a7e63c"],
    "fried-rice": ["1512058564366-18510be2db19", "1563379926898-05f4575a45d8", "1546069901-ba9599a7e63c"],
    "noodles": ["1585032226651-759b368d7246", "1525755662778-989d0524087e", "1563245372-f21724e3856d"],
    "chinese": ["1525755662778-989d0524087e", "1563245372-f21724e3856d", "1585032226651-759b368d7246"],
    "naan": ["1601050690597-df0568f70950", "1563379926898-05f4575a45d8", "1631452180519-c014fe946bc7"],
    "thali": ["1604908176997-125f25cc6f3d", "1633945274405-b6c8069047b0", "1504674900247-0877df9cc836"],
    "veg-curry": ["1567188040759-fb8a883dc6ff", "1512621776951-a57141f2eefd", "1546069901-ba9599a7e63c"],
    "salad": ["1512621776951-a57141f2eefd", "1546069901-ba9599a7e63c", "1510494150914-15e9f36f3bb0"],
    "dessert": ["1551024506-0bccd828d307", "1563805042-7684c019e1cb", "1565958011703-44f9829ba187"],
    "gulab-jamun": ["1563805042-7684c019e1cb", "1551024506-0bccd828d307", "1565958011703-44f9829ba187"],
    "icecream": ["1563805042-7684c019e1cb", "1551024506-0bccd828d307", "1497034825429-c343d7c6a68f"],
    "coffee": ["1495474472287-4d71bcdd2085", "1437418747212-8d9709afab22", "1509042239860-f550ce710b93"],
    "lassi": ["1541572279333-bf4d5e93658b", "1544145945-f90425340c7e", "1551024709-8f23befc6f87"],
    "drinks": ["1544145945-f90425340c7e", "1551024709-8f23befc6f87", "1560008581-09826d1de69e"],
    "juice": ["1560008581-09826d1de69e", "1544145945-f90425340c7e", "1551024709-8f23befc6f87"],
    "breakfast": ["1533089860892-a7c6f0a88666", "1493770348161-369560ae357d", "1504754524776-8f4f37790ca0"],
    # offers / banners
    "offer-biryani": ["1585937421612-70a008356fbe", "1563379926898-05f4575a45d8", "1512058564366-18510be2db19"],
    "offer-family": ["1504674900247-0877df9cc836", "1512621776951-a57141f2eefd", "1546069901-ba9599a7e63c"],
    "offer-student": ["1512058564366-18510be2db19", "1546069901-ba9599a7e63c", "1493770348161-369560ae357d"],
    "offer-party": ["1519225421980-715cb0215aed", "1519671482749-fd09be7ccebf", "1530103862676-de8c9debad1d"],
    "offer-newyear": ["1519671482749-fd09be7ccebf", "1504674900247-0877df9cc836", "1467003909585-2f8a72700288"],
    "offer-membership": ["1552566626-52f8b828add9", "1529042410759-befb1204b468", "1414235077428-338989a2e8c0"],
    # posts
    "post-biryani": ["1585937421612-70a008356fbe", "1563379926898-05f4575a45d8"],
    "post-music": ["1514525253161-7a46d19cd819", "1470229722913-7c0e2dbbafd3", "1493225457124-a3eb161ffa5f"],
    "post-birthday": ["1464366400600-7168b8af9bc3", "1519671482749-fd09be7ccebf", "1530103862676-de8c9debad1d"],
    "post-sankranti": ["1512621776951-a57141f2eefd", "1504674900247-0877df9cc836", "1546069901-ba9599a7e63c"],
    "post-tandoori": ["1555939594-58d7cb561ad1", "1599487488170-d11ec9c172f0"],
    "post-party": ["1519225421980-715cb0215aed", "1519671482749-fd09be7ccebf"],
    "post-kitchen": ["1556910103-1c02745aae4d", "1556911220-bff31c812dba", "1559339352-11d035aa65de"],
    # gallery
    "gal-interior1": ["1517248135467-4c7edcad34c4", "1559339352-11d035aa65de", "1515003197210-e0cd71810b5f"],
    "gal-interior2": ["1559339352-11d035aa65de", "1466978913421-dad2ebd01d17", "1517248135467-4c7edcad34c4"],
    "gal-interior3": ["1515003197210-e0cd71810b5f", "1466978913421-dad2ebd01d17", "1559339352-11d035aa65de"],
    "gal-exterior": ["1552566626-52f8b828add9", "1514933651103-005eec06c04b", "1529042410759-befb1204b468"],
    "gal-food1": ["1504674900247-0877df9cc836", "1476224203421-9ac39bcb3327", "1414235077428-338989a2e8c0"],
    "gal-food2": ["1476224203421-9ac39bcb3327", "1414235077428-338989a2e8c0", "1482049016688-2d3e1b311543"],
    "gal-food3": ["1414235077428-338989a2e8c0", "1504674900247-0877df9cc836", "1498837167922-ddd27525d352"],
    "gal-food4": ["1498837167922-ddd27525d352", "1546069901-ba9599a7e63c", "1504674900247-0877df9cc836"],
    "gal-event1": ["1519671482749-fd09be7ccebf", "1530103862676-de8c9debad1d", "1519225421980-715cb0215aed"],
    "gal-event2": ["1530103862676-de8c9debad1d", "1519671482749-fd09be7ccebf", "1464366400600-7168b8af9bc3"],
    "gal-celebration": ["1464366400600-7168b8af9bc3", "1519225421980-715cb0215aed", "1519671482749-fd09be7ccebf"],
    # restaurant branding
    "hero": ["1504674900247-0877df9cc836", "1414235077428-338989a2e8c0", "1517248135467-4c7edcad34c4"],
}

def download(url, dest):
    r = subprocess.run(["curl", "-s", "-L", "--max-time", "25", "-o", dest, url],
                       capture_output=True)
    if r.returncode != 0:
        return False
    try:
        out = subprocess.run(["file", dest], capture_output=True, text=True).stdout
        if "image" not in out:
            return False
        size = os.path.getsize(dest)
        return size > 8000
    except Exception:
        return False

ok, fail = [], []
for slot, ids in SLOTS.items():
    dest = os.path.join(OUT, f"{slot}.jpg")
    done = False
    for pid in ids:
        url = f"https://images.unsplash.com/photo-{pid}?w=1200&q=78&fm=jpg&fit=crop"
        if download(url, dest):
            ok.append(slot)
            done = True
            print(f"OK   {slot}  <-  {pid}")
            break
    if not done:
        fail.append(slot)
        print(f"FAIL {slot}")

print(f"\n{len(ok)} ok, {len(fail)} failed: {fail}")
