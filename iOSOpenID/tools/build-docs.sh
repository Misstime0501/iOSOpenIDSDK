# !/bin/sh
rm -rf doc
appledoc \
    --no-create-docset \
    --project-name iOSOpenID \
    --project-company "huaruiwangyan" \
    --company-id com.huaruiwangyan.iOSOpenID  \
    --output doc ./iOSOpenID
