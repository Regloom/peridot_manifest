# Local Manifests

Local manifest and build scripts for LineageOS 24 on Poco F6 (`peridot`).
`local_manifest.xml` goes to `.repo/local_manifests` and adds or replaces
projects on top of the LineageOS manifest.

## 📁 Contents

| File | Purpose |
|---|---|
| `local_manifest.xml` | Extra and replaced projects (device, vendor, kernel, MIUI camera, apps) |
| `patches/import_patches.sh` | Applies the patches in `patches/` to a synced tree (branch `24` in each project, safe to re-run) |
| `build.sh` | Local build: sync, patches, optional RBE, `m bacon` |
| `rbe.sh` | RBE via BuildBuddy (Siso native REAPI). Put the API key in `BUILDBUDDY_API_KEY`; with the `xxx` placeholder the build runs without RBE |
| `crave.sh` | Build on crave.io |
| `yd-upload.sh` | Upload a build to Yandex Disk |
| `ota/` | OTA metadata |

## 📦 Usage

### Local

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
git clone -b 24 https://github.com/Regloom/peridot_manifest.git ../peridot_manifest
mkdir -p .repo/local_manifests
cp ../peridot_manifest/local_manifest.xml .repo/local_manifests/
cp ../peridot_manifest/build.sh ../peridot_manifest/rbe.sh .
# optional: set BUILDBUDDY_API_KEY in rbe.sh
./build.sh
```

### Crave.io

```bash
crave run --clean --no-patch -- "curl -sL https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/24/crave.sh | bash"
```
