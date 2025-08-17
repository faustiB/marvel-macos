# marvel-macos

## Local setup: Marvel API keys

The app requires Marvel API credentials to build and run locally.

1) Get keys
- Create an account at `https://developer.marvel.com` and generate a Public and Private key.

2) Create `keys.xcconfig` at the repo root (same folder as this README)
```ini
MARVEL_PUBLIC_KEY = your_public_key_here
MARVEL_PRIVATE_KEY = your_private_key_here
```

3) Build
- The Xcode project is already configured to read these values and inject them into `Info.plist` as `MARVEL_PUBLIC_KEY` and `MARVEL_PRIVATE_KEY`. Open the project in Xcode and build/run.

Notes
- Do not commit secrets. Add this to your gitignore if needed:
```gitignore
keys.xcconfig
```
