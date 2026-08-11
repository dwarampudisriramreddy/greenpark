#!/usr/bin/env python3
"""Upload generated seed images to Supabase Storage buckets."""
import os
import json
import urllib.request

REF = "tygwlqvtxhepngwnnpqu"
SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Z3dscXZ0eGhlcG5nd25ucHF1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjQyMDk5MywiZXhwIjoyMTAxOTk2OTkzfQ.iM--NeF22ZGY40Vzqp-sSig_T3-68RzcofWG7uVsqDc"
BASE = f"https://{REF}.supabase.co/storage/v1/object"

MENU = ["biryani","biryani-mutton","biryani-veg","chicken-65","chilli-chicken","paneer","gobi","lollipop",
        "tandoori","tikka","soup","curry","curry-chicken","mutton","fish","prawns","fried-rice","noodles",
        "chinese","naan","thali","veg-curry","salad","dessert","gulab-jamun","icecream","coffee","lassi",
        "drinks","juice","breakfast"]
OFFERS = ["offer-biryani","offer-family","offer-student","offer-party","offer-newyear","offer-membership"]
POSTS = ["post-biryani","post-music","post-birthday","post-sankranti","post-tandoori","post-party","post-kitchen"]
GALLERY = ["gal-interior1","gal-interior2","gal-interior3","gal-exterior","gal-food1","gal-food2","gal-food3",
           "gal-food4","gal-event1","gal-event2","gal-celebration"]

SRC = "/tmp/greenpark-imgs"

def upload(bucket, path, filepath, mime="image/jpeg"):
    with open(filepath, "rb") as f:
        data = f.read()
    url = f"{BASE}/{bucket}/{path}"
    req = urllib.request.Request(url, data=data, method="PUT")
    req.add_header("Authorization", f"Bearer {SERVICE_KEY}")
    req.add_header("Content-Type", mime)
    req.add_header("x-upsert", "true")
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.status == 200
    except Exception as e:
        print("  ERR", path, e)
        return False

jobs = [(f, "menu-images", f"{f}.jpg", os.path.join(SRC, f"{f}.jpg")) for f in MENU]
jobs += [(f, "offer-banners", f"{f}.jpg", os.path.join(SRC, f"{f}.jpg")) for f in OFFERS]
jobs += [(f, "post-images", f"{f}.jpg", os.path.join(SRC, f"{f}.jpg")) for f in POSTS]
jobs += [(f, "gallery-images", f"{f}.jpg", os.path.join(SRC, f"{f}.jpg")) for f in GALLERY]
jobs += [("logo", "restaurant-images", "logo.png", os.path.join(SRC, "logo.png"), "image/png")]
jobs += [("hero", "restaurant-images", "hero.jpg", os.path.join(SRC, "hero.jpg"))]

ok = fail = 0
for job in jobs:
    mime = "image/png" if len(job) == 5 else "image/jpeg"
    bucket, path = job[1], job[2]
    src_path = job[3]
    if upload(bucket, path, src_path, mime):
        ok += 1
        print(f"OK  {bucket}/{path}")
    else:
        fail += 1
        print(f"FAIL {bucket}/{path}")

print(f"\n{ok} uploaded, {fail} failed")
