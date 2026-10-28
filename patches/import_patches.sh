#!/bin/bash
# Import local patches into the source tree.
#
# Lives in peridot_manifest/patches/, run it from the ROOT of the Android tree:
#   bash ../peridot_manifest/patches/import_patches.sh
#
# For every patch: creates/checkouts branch "24" in the target repo, then
#   git am -3 --ignore-whitespace <patch>   (preferred, keeps authorship)
#   fallback: git apply -C1 --index <patch> + commit with authorship from the patch
# Skips a patch whose changes are already on the branch (reverse-check).

set -u

cd "$(dirname "$0")" || exit 1
PATCH_DIR="$(pwd)"
cd - >/dev/null || exit 1

: "${BRANCH:=24}"

patches=(
    "vendor/xiaomi/peridot:0000-voltage-lineage.patch"
    "frameworks/base:0001-SystemUI-Update-buildNumber-flow-to-return-null.patch"
    "frameworks/base:0002-SystemUI-Add-roaming-indicator-to-statusbar-tuner.patch"
    "frameworks/base:0003-SystemUI-Forward-port-HD-wifi-calling-statusbar-icon.patch"
    "packages/apps/Launcher3:0004-Launcher3-Show-clear-all-button-in-recents-overview.patch"
    "packages/apps/Settings:0005-Settings-Expose-radio-info-4636.patch"
)

fuzzy_apply_commit() {
    # $1 = patch file; working dir = target repo. Applies with reduced context
    # and commits preserving the patch's author and message.
    local patch="$1" tmp
    tmp="$(mktemp -d)"
    if ! git apply -C1 --ignore-whitespace --index "$patch" >/dev/null 2>&1; then
        rm -rf "$tmp"
        return 1
    fi
    git mailinfo "$tmp/msg" "$tmp/info" < "$patch" >/dev/null
    local name email author
    name="$(sed -n 's/^Author: //p' "$tmp/info" | head -1)"
    email="$(sed -n 's/^Email: //p' "$tmp/info" | head -1)"
    author="${name:+${name} <${email}>}"
    if [ -n "$author" ]; then
        git commit -q -F "$tmp/msg" --author="$author"
    else
        git commit -q -F "$tmp/msg"
    fi
    rm -rf "$tmp"
}

ensure_branch() {
    # $1 = branch name. Checked-out branch is left as is when already $1.
    # The branch does not track upstream, so `repo sync` detaches HEAD at the
    # new upstream and leaves the branch on the old base: rebase it onto HEAD.
    if [ "$(git rev-parse --abbrev-ref HEAD)" = "$1" ]; then
        return 0
    fi
    if git show-ref --verify --quiet "refs/heads/$1"; then
        local base
        base="$(git rev-parse HEAD)"
        git checkout -q "$1" || return 1
        git rebase -q "$base" || { git rebase --abort; return 1; }
    else
        git checkout -q -b "$1" || return 1
    fi
}

echo "Importing patches from $PATCH_DIR (branch \"$BRANCH\")..."
echo "----------------------------------------"

fail=0
for entry in "${patches[@]}"; do
    IFS=: read -r directory patchfile <<< "$entry"
    patch="$PATCH_DIR/$patchfile"

    if [ ! -d "$directory/.git" ]; then
        echo "✗ $directory: no git repo here, skipping"
        fail=1
        continue
    fi
    cd "$directory" || { echo "✗ can't enter $directory"; fail=1; cd - >/dev/null || true; continue; }

    if [ ! -f "$patch" ]; then
        echo "✗ $patchfile: file not found in $PATCH_DIR"
        fail=1
        cd - >/dev/null || true
        continue
    fi

    if [ -n "$(git status --porcelain)" ]; then
        echo "✗ $directory: dirty working tree, refusing to patch (commit or clean it first)"
        fail=1
        cd - >/dev/null || true
        continue
    fi

    if ! ensure_branch "$BRANCH"; then
        echo "✗ $directory: failed to switch to branch $BRANCH"
        fail=1
        cd - >/dev/null || true
        continue
    fi

    subject="$(grep -m1 '^Subject: ' "$patch" | sed 's/^Subject: \(\[PATCH[^]]*\]\)\?\s*//')"
    if git log --grep="$subject" -F --oneline -1 >/dev/null 2>&1 && \
       [ -n "$(git log --grep="$subject" -F --format=%H -1)" ]; then
        echo "✓ $patchfile in $directory already committed, skipping"
        cd - >/dev/null || true
        continue
    fi

    if git apply --reverse --check "$patch" >/dev/null 2>&1; then
        echo "✓ $patchfile in $directory already applied, skipping"
        cd - >/dev/null || true
        continue
    fi

    if git am -3 --ignore-whitespace "$patch" >/dev/null 2>&1; then
        echo "✓ Patch OK in $directory ($patchfile, committed)"
    elif fuzzy_apply_commit "$patch"; then
        echo "✓ Patch OK in $directory ($patchfile, committed via apply -C1)"
    else
        git am --abort >/dev/null 2>&1
        git reset -q >/dev/null 2>&1
        echo "✗ Patch NOK in $directory ($patchfile)"
        fail=1
    fi

    cd - >/dev/null || true
done

echo "----------------------------------------"
[ "$fail" -eq 0 ] && echo "Patches imported OK!" || { echo "Some patches failed, see above."; exit 1; }
