#!/usr/bin/env bash
set -ev

TOOLCHAIN=~/Library/Developer/Toolchains/swift-wasm-DEVELOPMENT-SNAPSHOT-2024-10-27-a.xctoolchain
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
cp .build/wasm32-unknown-wasi/debug/Strings.wasm ../Web/dist

cd ../Web
if [ ! -d "node_modules" ]; then
  npm install
fi
npm run build
npm run start
