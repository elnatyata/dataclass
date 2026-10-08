#!/usr/bin/env bash
# Session 01 companion: rebuilds, step by step, the commit graph drawn on the board.
#
#   bash session_01_build_demo_history.sh [target_dir]
#
# Creates a throwaway repo (default: ./s01-demo) around the starter script, with
# six atomic Conventional Commits, one branch, one resolved merge conflict, one revert,
# plus restore / reset demos. Every step prints what it is about to do: pause the
# script mentally there and ask the room to predict the graph BEFORE reading the output.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
starter="$here/../../starter"
target="${1:-./s01-demo}"

step() { printf '\n\033[1m### %s\033[0m\n' "$*"; }
edit() { python3 - "$@"; }   # portable in-place edits (sed -i differs on macOS/Linux)

rm -rf "$target"
mkdir -p "$target"
cd "$target"
git init -q -b main
git config user.name "Demo Student"
git config user.email "student@example.org"
git config commit.gpgsign false

step "c1 chore: .gitignore first (.env is ALWAYS ignored)"
cat > .gitignore <<'GI'
.env
.venv/
__pycache__/
.DS_Store
GI
git add .gitignore
git commit -q -m "chore: add .gitignore"

step "c2 feat: the 50-line script and its sample data"
cp "$starter/audience_report.py" .
mkdir -p data && cp "$starter/data/audience_sample.csv" data/
git add audience_report.py data/audience_sample.csv
git commit -q -m "feat: add daily audience report script"

step "c3 docs: README"
printf '# audience report\n\n    python audience_report.py data/audience_sample.csv\n' > README.md
git add README.md
git commit -q -m "docs: add README with usage"

step "three areas: an unstaged edit, then git restore throws it away"
echo "# scratch idea" >> audience_report.py
git status --short                     # ' M' = modified in working dir, not staged
git restore audience_report.py
git status --short                     # clean again

step "a secret almost committed: .env is ignored, git add does nothing"
echo "AUDIENCE_API_TOKEN=s3cr3t" > .env
git add -A
git status --short                     # .env does not appear
rm .env

step "branch feat/minutes: c4 shows read time in minutes"
git switch -q -c feat/minutes
edit <<'PY'
p = "audience_report.py"
s = open(p).read()
s = s.replace("'avg read (s)':>13", "'avg read (min)':>15")
s = s.replace('f"{avg:.1f}"', 'f"{avg / 60:.1f}"')
s = s.replace("{avg_txt:>13}", "{avg_txt:>15}")
open(p, "w").write(s)
PY
git commit -q -am "feat: show average read time in minutes"

step "back on main: c5 renames the views header (same line as c4: conflict ahead)"
git switch -q main
edit <<'PY'
p = "audience_report.py"
s = open(p).read()
s = s.replace("{'views':>8}", "{'total views':>12}")
s = s.replace("{total:>8}", "{total:>12}")
open(p, "w").write(s)
PY
git commit -q -am "style: rename views column to total views"

git log --oneline --graph --all

step "merge feat/minutes into main: expect CONFLICT on the header line"
if git merge feat/minutes -m "merge: feat/minutes" >/dev/null 2>&1; then
    echo "unexpected: no conflict" && exit 1
fi
git status --short                     # UU = both modified, unresolved
sed -n '/<<<<<<</,/>>>>>>>/p' audience_report.py

step "resolve: keep BOTH intentions (total views + minutes), then add + commit"
edit <<'PY'
import re
p = "audience_report.py"
s = open(p).read()
s = re.sub(
    r"<<<<<<< HEAD\n.*?\n=======\n.*?\n>>>>>>> feat/minutes\n",
    "    print(f\"{'section':<10} {'total views':>12} {'avg read (min)':>15}\")\n"
    "    for section, (total, avg) in sorted(report.items(), key=lambda kv: -kv[1][0]):\n"
    "        avg_txt = f\"{avg / 60:.1f}\" if avg is not None else \"n/a\"\n"
    "        print(f\"{section:<10} {total:>12} {avg_txt:>15}\")\n",
    s,
    flags=re.S,
)
open(p, "w").write(s)
PY
! grep -q '<<<<<<<' audience_report.py   # no marker left behind
python3 audience_report.py data/audience_sample.csv
git add audience_report.py
git commit -q --no-edit

step "c6 feat: a grand-total line"
edit <<'PY'
p = "audience_report.py"
s = open(p).read()
s = s.replace(
    "        print(f\"{section:<10} {total:>12} {avg_txt:>15}\")\n",
    "        print(f\"{section:<10} {total:>12} {avg_txt:>15}\")\n"
    "    print(f\"{'ALL':<10} {sum(t for t, _ in report.values()):>12}\")\n",
)
open(p, "w").write(s)
PY
git commit -q -am "feat: add grand total line"

step "the newsroom says the total line confuses readers: revert (history kept)"
git revert --no-edit HEAD >/dev/null
git log --oneline -3

step "reset --soft: undo the LAST LOCAL commit but keep its changes staged"
echo "Run it with uv later." >> README.md
git commit -q -am "docs: wip"
git reset --soft HEAD~1
git status --short                     # 'M ' = staged, ready to recommit properly
git commit -q -m "docs: mention uv in README"

step "final graph"
git log --oneline --graph --all
echo
echo "commits on main: $(git rev-list --count main)"
