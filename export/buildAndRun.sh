#!/usr/bin/env bash
set -ev

TOOLCHAIN=~/Library/Developer/Toolchains/swift-wasm-6.0-SNAPSHOT-2024-04-19-a.xctoolchain
SWIFT=$TOOLCHAIN/usr/bin/swift

cd Swift
$SWIFT build \
  --triple wasm32-unknown-wasi \
  -Xswiftc -static-stdlib \
  -Xswiftc -Xclang-linker \
  -Xswiftc -mexec-model=reactor
if [ ! -d "../Web/dist" ]; then
  mkdir ../Web/dist
fi
cp .build/wasm32-unknown-wasi/debug/Export.wasm ../Web/dist

cd ../Web
if [ ! -d "node_modules" ]; then
  npm install
fi
npm run build
npm run start
