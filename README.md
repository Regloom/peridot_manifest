# sm8635-dev Local Manifests

This repository contains local manifest overrides for the Android source tree, used by the Neon-Duchamp project. These manifests are cloned into .repo/local_manifests to extend or modify the default source manifest.

## 📦 What This Is

Instead of modifying the main manifest directly, we place additional project entries here. This allows us to:

- Add extra repositories to sync
- Replace existing upstream repos with forks
- Customize the build without touching the upstream manifest

## 📁 Usage

Clone this repository into your local manifest directory:

```bash
git clone https://github.com/sm8635-dev/manifest.git -b hals .repo/local_manifests

repo sync -j$(nproc --all)
