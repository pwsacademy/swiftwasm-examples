#!/usr/bin/env bash
set -ev

# Compile front-end WebAssembly module
cd Front-end
rm -rf Bundle
swift run carton bundle --custom-index-page Sources/play.html 

# Copy compiled front-end to back-end
cd ../Back-end
rm -rf Public
mkdir Public
cp -R ../Front-end/Bundle/* Public
# Carton insists on renaming its HTML file to index.html, so rename it back
mv Public/index.html Public/play.html
# Copy the remaining static files
cp ../Front-end/Public/* Public

# Run
swift run ConnectFourServer serve --bind 127.0.0.1:9090
