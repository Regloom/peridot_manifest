# Local Manifests

This repository contains local manifest overrides for the Android source tree, used by the Neon-Duchamp project. These manifests are cloned into .repo/local_manifests to extend or modify the default source manifest.

## 📦 What This Is

Instead of modifying the main manifest directly, we place additional project entries here. This allows us to:

- Add extra repositories to sync
- Replace existing upstream repos with forks
- Customize the build without touching the upstream manifest

## 📁 Usage

### Normal 

```bash
# git clone https://github.com/Regloom/peridot_manifest.git -b hals .repo/local_manifests
curl -L --create-dirs https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/local_manifest.xml -o .repo/local_manifests/local_manifest.xml

repo sync -j$(nproc --all)
```

### Crave.io

```bash
crave run --clean --no-patch -- "curl https://gist.githubusercontent.com/Regloom/dc650e6f9ba6a035b994f9bb714206b6/raw/crave.sh | bash"
```
