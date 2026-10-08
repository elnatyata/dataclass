# Session 02 · Follow-Along Guide: The GitHub Pull-Request Workflow

**Course:** Python Environments & Engineering Workflows (MSA-DATI07-01) · MSc 1 · 2h

## What we build today

We keep the `greetings` repository from Session 1 (the `Student` class that welcomes, registers and
enrolls a new student) and move it off your laptop. It goes on GitHub, then you and
a classmate improve it through pull requests (PRs). No new Python concept today. The code changes are
tiny, because the workflow around them is what we are here for.

- Roles. In each pair, one person is the owner (their `greetings` repo is the shared one),
  the other is the partner (added as collaborator). Halfway through, you swap.
- **Rule from now on:** nobody commits directly on `main`. Every change goes
  branch, commit, push, PR, review, merge.

Every step has the same four parts as in Session 1:

- **Predict**: say out loud what you expect before pressing Enter.
- **Run**: the command(s).
- **You should see**: the output of the command. Hashes (`63bf464`...) and paths will differ.
- **Why**: what just happened, in one or two sentences.

> Real GitHub adds a few `remote:` lines when you push.

**End of session deliverable:** the URL of your repo, with `main` protected, three merged PRs (one
merge commit with a review round, one squash, one rebase) and one PR whose conflict you resolved.
`git log --oneline --graph --all` shows all of it.

| Part | Topic | Mode |
|---|---|---|
| 0 | Before we start: account, SSH, pairs | all together |
| 1 | Publish `greetings` | all together |
| 2 | Add your partner, clone, `fetch` vs `pull` | pairs |
| 3 | PR #1: the full loop, with a review round | pairs |
| 4 | Protect `main` | pairs |
| | Break (15 min) | |
| 5 | PR #2: squash a messy branch | pairs, swapped |
| 6 | PR #3: rebase and merge | pairs |
| 7 | PR #4: a conflict on GitHub | pairs |
| 8 | Forks (demo) and wrap-up | all together |

On macOS, type `python3` wherever this guide says `python`. On Windows, use **Git Bash**.

---

## Part 0 · Before we start

### 0.1 SSH key and GitHub

GitHub does not accept your password for Git any more. We use an SSH key pair: a private half that
stays on your laptop and a public half that you give to GitHub.

**Predict:** which of the two files can you paste on a public website without risk?

```bash
ls ~/.ssh/id_ed25519.pub        # already there? then skip ssh-keygen
ssh-keygen -t ed25519 -C "you@example.org"
cat ~/.ssh/id_ed25519.pub
```

Accept the default path, choose a passphrase. `cat` prints one line starting with `ssh-ed25519`.
Copy it, then on GitHub: **Settings > SSH and GPG keys > New SSH key**, paste, save.

```bash
ssh -T git@github.com
```

**You should see:**

```
Hi <your-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

**Why:** the private key `id_ed25519` proves who you are, the public key `id_ed25519.pub` lets
GitHub check that proof. Never share, commit or paste the private one.

> **If it goes wrong:** `Permission denied (publickey)`: the public key is not on your GitHub
> account, or the agent does not know the key: `ssh-add ~/.ssh/id_ed25519` (macOS:
> `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`).
>
> `Connection timed out` on port 22 (school Wi-Fi): use SSH over HTTPS port. Create `~/.ssh/config`
> containing
> ```
> Host github.com
>   Hostname ssh.github.com
>   Port 443
>   User git
> ```
> and run `ssh -T git@github.com` again.

### 0.2 Form the pairs

Choose who is owner and who is partner for the first half. Write your GitHub usernames in the
chat or on the board. You will need your partner's username in Part 2.

> **On the board:** two laptops, one cloud in the middle called GitHub. Each laptop has its own full
> copy of the commit graph. The arrows `push` / `fetch` are the only way commits travel.

---

## Part 1 · Publish `greetings`

Everyone, owner and partner: you each publish your own Session 1 repo. Only the owner's will be
used first, but a second copy costs nothing and the partner needs it after the swap.

### 1.1 Create an empty repository on GitHub

On github.com: **New repository**, name `greetings`, **Public**, and leave everything unticked
(no README, no .gitignore, no licence).

**Why:** your local repo already has history. A repo created with a README has a commit yours knows
nothing about, and your first push is rejected.

### 1.2 Connect and push

In your Session 1 repo (`cd greetings`):

**Predict:** `git remote -v` prints nothing today. What will it print after `remote add`?

```bash
git remote add origin git@github.com:<your-username>/greetings.git
git remote -v
git push -u origin main
git status -sb
```

**You should see:**

```
origin	git@github.com:<your-username>/greetings.git (fetch)
origin	git@github.com:<your-username>/greetings.git (push)
```

```
To git@github.com:<your-username>/greetings.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

```
## main...origin/main
```

(A push also prints `Enumerating objects`, `Writing objects`, and a few `remote:` lines.)

**Why:** `origin` is just a nickname for a URL. `-u` records that your local `main` follows
`origin/main`, so from now on a bare `git push` / `git pull` know where to go. In `status -sb`,
`main...origin/main` with nothing after it means "same commit on both sides".

> **On the board:** draw the graph twice (laptop, GitHub), a label `origin/main` next to the laptop's
> graph. `origin/main` is your laptop's memory of where `main` was on GitHub the last time you
> talked to it. It is not live.

> **If it goes wrong:**
> - `rejected ... fetch first`: the repo was created with a README. Easiest fix: delete the GitHub
>   repo and recreate it empty.
> - `Permission denied (publickey)`: go back to 0.1.
> - `remote origin already exists`: you ran `remote add` twice. `git remote -v` to check the URL,
>   `git remote set-url origin <right url>` to fix it.

Open your repository page in the browser: your commits, `greetings.py` and `.gitignore` are there.
Click **commits** and compare with `git log --oneline`: same messages, same hashes.

---

## Part 2 · Add your partner, clone, `fetch` vs `pull`

### 2.1 Owner: add the partner as collaborator

On the owner's repo: **Settings > Collaborators > Add people**, enter the partner's username. The
partner accepts the invitation (email or the link on GitHub).

**Why:** a required review (Part 4) must come from a second human, and only a collaborator can push
branches to someone else's repo.

### 2.2 Partner: clone the owner's repo

Go outside your own `greetings` folder first (`cd ..`), then:

```bash
git clone git@github.com:<owner-username>/greetings.git greetings-owner
cd greetings-owner
git log --oneline -3
git branch -a
```

**You should see:**

```
Cloning into 'greetings-owner'...
done.
```

```
4929f3c Revert "feat: shout the welcome message"
bc387d9 feat: shout the welcome message
7dc41aa Merge feat/email (PR #2)
```

```
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

**Why:** `clone` is "download the whole graph, add a remote called `origin`, check out `main`". The
`remotes/origin/...` entries are your local memory of the remote branches.

### 2.3 `fetch` vs `pull`

**Owner:** add a README, commit and push, on `main` (the last time we do that, Part 4 forbids it).

```bash
cat > README.md <<'EOF'
# greetings

Welcome desk of Albert School: welcome, register and enroll new students.

Run it: `python greetings.py`
EOF
git add README.md
git commit -m "docs: add README"
git push
```

**Partner:** predict what `git status -sb` says right now, before and after `git fetch`.

```bash
git status -sb
git fetch
git status -sb
git log --oneline --graph --all -4
```

**You should see:**

```
## main...origin/main
```

```
From github.com:<owner-username>/greetings
   4929f3c..63bf464  main       -> origin/main
```

```
## main...origin/main [behind 1]
```

```
* 63bf464 docs: add README
* 4929f3c Revert "feat: shout the welcome message"
* bc387d9 feat: shout the welcome message
*   7dc41aa Merge feat/email (PR #2)
|\
```

Look at your folder: no `README.md` yet. `fetch` only moved `origin/main`. Now:

```bash
git pull
git log --oneline -2
```

```
Updating 4929f3c..63bf464
Fast-forward
 README.md | 5 +++++
 1 file changed, 5 insertions(+)
 create mode 100644 README.md
```

```
63bf464 docs: add README
4929f3c Revert "feat: shout the welcome message"
```

**Why:**

| Command | What it does | Touches your files? |
|---|---|---|
| `git fetch` | downloads new commits, moves `origin/main` | no |
| `git pull` | `fetch` then merges `origin/main` into your current branch | yes |

The first `git status -sb` said "same as origin/main" because Git compares with its last known
`origin/main`. Only `fetch` updates that knowledge. Habit: `fetch`, look at the graph, then decide.

> **If it goes wrong:** `git pull` prints `fatal: Need to specify how to reconcile divergent
> branches`. We set `pull.rebase false` in Session 1; if it is missing:
> `git config --global pull.rebase false`.

---

## Part 3 · PR #1: the full loop, with a review round

Roles: the partner writes the code, the owner reviews. We add a `farewell` method, the mirror
of `welcome`.

### 3.1 Partner: always branch from an up-to-date `main`

```bash
git switch main
git pull
git switch -c feat/farewell
```

Add the method to the class, right after `enroll`:

```python
    def farewell(self):
        return f"See you soon, {self.first_name}!"
```

Run it (it prints nothing new, we have not called it yet, but it must not crash), then commit and
publish the branch:

```bash
python greetings.py
git commit -am "feat: add a farewell message"
git push -u origin feat/farewell
```

**You should see:**

```
[feat/farewell c9f1af0] feat: add a farewell message
 1 file changed, 3 insertions(+)
```

```
 * [new branch]      feat/farewell -> feat/farewell
branch 'feat/farewell' set up to track 'origin/feat/farewell'.
```

(GitHub also prints a link when you push: `Create a pull request for 'feat/farewell' on GitHub by
visiting: ...`.)

### 3.2 Partner: open the pull request

Click the yellow banner **Compare & pull request** on the repo page (or run
`gh pr create --fill`). Fill in:

- **Title**, written as a Conventional Commit: `feat: add a farewell message`.
- **Description**: what, why, how to check (`python greetings.py`).
- **Reviewers**: the owner.

**Why:** a PR is not a Git object. It is GitHub's page that says "please merge branch X into Y",
with a discussion attached. The branch is a normal Git branch.

### 3.3 Owner: review

Open the PR, tab **Files changed**. Read the diff with the Session 1 checklist:

- Does it do what the title says? Is the commit type right?
- Does the script still run? (Optional: `git fetch, `git switch feat/farewell`,
  `python greetings.py`.)
- Is anything missing?

The method exists but nothing calls it. Click the `+` next to a line, write a comment, then
**Review changes > Request changes**:

> Nobody calls `farewell()`. Print it at the end of the demo.

### 3.4 Partner: answer the review on the same branch

**Predict:** do you open a new PR?

No. Add a second commit on the same branch and push:

```bash
echo '    print(student.farewell())' >> greetings.py
python greetings.py
git commit -am "feat: say goodbye at the end of the demo"
git push
```

```
Welcome to Albert School, Tuka!
Registered as student #1
Confirmation sent to tuka@albertschool.com
Tuka Bade joins MSc 1 Data.
See you soon, Tuka!
```

```
   c9f1af0..efe6b97  feat/farewell -> feat/farewell
```

The PR page updates by itself and now shows two commits. The owner re-reads the new commit and clicks
**Review changes > Approve**.

### 3.5 Merge with **Create a merge commit**

On the PR page, the merge button has three modes. For this PR (two meaningful commits, a review
round we want to keep) choose **Create a merge commit**, confirm, then **Delete branch**.

### 3.6 Both: clean up locally

```bash
git switch main
git pull
git fetch --prune
git branch -d feat/farewell
git log --oneline --graph -5
```

**You should see:**

```
From github.com:<owner-username>/greetings
 - [deleted]         (none)     -> origin/feat/farewell
```

```
Deleted branch feat/farewell (was efe6b97).
```

```
*   10c61a8 Merge pull request #3 from partner/feat/farewell
|\
| * efe6b97 feat: say goodbye at the end of the demo
| * c9f1af0 feat: add a farewell message
|/
* cd3145e docs: add README
* 4929f3c Revert "feat: shout the welcome message"
```

**Why:** the PR number (`#3` here, yours will be `#1`) is in the merge commit message. The review
round is visible in the graph: two commits on the side, one merge commit. `fetch --prune` forgets
remote branches deleted on GitHub; `branch -d` refuses to delete a branch whose work is not in
`main`, so it protects you from losing work.

> **On the board:** the loop.
> ```
> switch -c -> commit(s) -> push -> open PR -> review -> (request changes -> commit again)
>      ^                                                          |
>      +---- pull main <- delete branch <- merge <- approve <-----+
> ```

> **If it goes wrong:**
> - `git push` says `The current branch feat/farewell has no upstream branch`: you forgot `-u` the
>   first time. Run the command Git prints, then continue normally.
> - You committed on `main` by mistake (before the ruleset exists): `git switch -c feat/x` keeps the
>   commit on the new branch, then `git switch main && git reset --hard origin/main`.

---

## Part 4 · Protect `main`

Until now the rule "nobody pushes on `main`" was only a promise. Make GitHub enforce it.

### 4.1 Owner: create the ruleset

**Settings > Rules > Rulesets > New ruleset > New branch ruleset.**

- Name: `protect main`. **Enforcement status: Active.**
- **Target branches:** Add target > Include default branch.
- Tick: **Restrict deletions**, **Block force pushes**, **Require a pull request before merging**
  with **Required approvals: 1** and **Dismiss stale pull request approvals when new commits are
  pushed**.
- Leave **Bypass list empty**.
- Save.

**Why each rule exists:**

| Rule | What it prevents |
|---|---|
| Require a pull request | `git push origin main` from anyone |
| 1 approval | merging your own unreviewed code |
| Dismiss stale approvals | approval of v1 silently covering v2 |
| Block force pushes | rewriting shared history |
| Restrict deletions | deleting `main` |

> **If it goes wrong:** ruleset page says "not available" on a private repo with a free plan. Rulesets
> are enforced on public repos on every plan; make the repo public (there is nothing secret in it,
> `.env` is ignored) or use the GitHub Student Developer Pack.

### 4.2 Everyone: try to break it

Owner and partner, on `main`:

```bash
git switch main
echo "# test" >> README.md
git commit -am "docs: try to push on main"
git push
```

**You should see:**

```
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote: - Changes must be made through a pull request.
 ! [remote rejected] main -> main (push declined due to repository rule violations)
error: failed to push some refs to 'github.com:<owner-username>/greetings.git'
```

Undo your local commit (it was never shared, so rewriting is fine):

```bash
git reset --hard origin/main
```

**Why:** it works even for the owner, because the bypass list is empty. If you leave yourself in the
bypass list, the rule looks fine in settings and does nothing for you.

---

## Break (15 min)

---

## Part 5 · PR #2: squash a messy branch

**Swap roles.** The owner is now the author, the partner reviews. The repo is still the owner's, and
its `main` is protected, so everything goes through a PR. Real branches are messy, so this is the normal case.

**Author:** a `full_name` helper. Commit the way you normally would, mistakes included.

```bash
git switch main
git pull
git switch -c feat/full-name
```

Add before `welcome`:

```python
    def full_name(self):
        return f"{self.first_name} {self.lastname}"
```

(`lastname` is a typo, it should be `last_name`. Leave it.)

```bash
git commit -am "wip"
```

Use it in `enroll`: replace `{self.first_name} {self.last_name}` by `{self.full_name()}`.

```bash
python greetings.py
```

```
AttributeError: 'Student' object has no attribute 'lastname'. Did you mean: 'last_name'?
```

```bash
git commit -am "use it"
```

Fix the typo, run again (it works), commit `oops typo`, then publish and look at what the reviewer
will see:

```bash
git commit -am "oops typo"
git log --oneline main..feat/full-name
git push -u origin feat/full-name
```

```
90be626 oops typo
fcc4db7 use it
b4f9760 wip
```

Open the PR with the title `refactor: add a full_name helper`. The reviewer approves it.

On the merge button choose **Squash and merge**. GitHub proposes the title and the three commit
messages as the body: keep the title, delete the body noise, confirm, delete the branch. Then both:

```bash
git switch main
git pull
git branch -D feat/full-name
git log --oneline --graph -4
```

**You should see:**

```
* 6450b68 refactor: add a full_name helper (#4)
*   10c61a8 Merge pull request #3 from partner/feat/farewell
|\
| * efe6b97 feat: say goodbye at the end of the demo
| * c9f1af0 feat: add a farewell message
|/
```

**Why:** the three commits `wip`, `use it`, `oops typo` collapsed into one commit on `main`, and
the PR title became its message. Since the squash commit is a new commit with the same *content*,
Git does not recognise `feat/full-name` as merged: that is why we use `-D` here, after checking on
GitHub that the PR is merged.

> **Rule.** With squash, the PR title is what lands in history. Write it as a Conventional Commit.

---

## Part 6 · PR #3: rebase and merge

Same author. Something small, and meanwhile the other person (the reviewer) merges a different change
on `main`, so the branch is behind when it is time to merge.

**Author:**

```bash
git switch -c feat/is-enrolled
```

Add before `enroll`:

```python
    def is_enrolled(self):
        return self.classroom is not None
```

```bash
git commit -am "feat: add is_enrolled"
git push -u origin feat/is-enrolled
```

**Reviewer, at the same time:** open your own tiny PR (`feat/registry-size`) that changes the line
`print(f"Registered as student #{student.student_id}")` to
`print(f"Registered as student #{student.student_id} of {len(registry)}")`, and merge it (get it
approved by your partner, then **Squash and merge**).

**Author:** open the PR for `feat/is-enrolled`, reviewer approves, choose **Rebase and merge**.
Everyone:

```bash
git switch main
git pull
git log --oneline --graph -4
```

**You should see:**

```
* a624933 feat: add is_enrolled
* 60979ed feat: show the registry size on registration
* 6450b68 refactor: add a full_name helper (#4)
*   10c61a8 Merge pull request #3 from partner/feat/farewell
```

**Why:** the graph is a straight line, with no merge commit. GitHub replayed `feat: add is_enrolled`
on top of the newest `main`. Look at the hash: `a624933` is not the hash you pushed on the branch,
because replaying creates a new commit.

> **On the board:** the three merge buttons, three drawings of the same two branches.
>
> | Button | `main` afterwards | Use when |
> |---|---|---|
> | Create a merge commit | all commits + one merge commit | the history of the branch is meaningful |
> | Squash and merge | one new commit | the branch has `wip` / `oops` commits |
> | Rebase and merge | commits replayed, linear | commits are already clean and atomic |

---

## Part 7 · PR #4: a conflict on GitHub

Two PRs touch the same line. Same story as Session 1, except GitHub is the one that finds the
conflict.

**Author A:** from `main`, a branch `feat/title`: change the `welcome` return to
`f"Welcome to Albert School, {self.first_name}! Your desk is ready."`, commit
`feat: say the desk is ready`, push, open the PR (do **not** merge yet).

**Author B:** from `main` (not from A's branch), a branch `feat/campus`: change the same line to
`f"Welcome to Albert School Paris, {self.first_name}!"`, commit
`feat: name the campus in the welcome`, push, open the PR. Approve and **merge B's PR first**
(merge commit).

Now go back to A's PR page: GitHub shows **This branch has conflicts that must be resolved**. The
merge button is disabled.

**Author A, on the laptop:** bring `main` into your branch and resolve there.

```bash
git fetch
git merge origin/main
git diff
```

**You should see:**

```
Auto-merging greetings.py
CONFLICT (content): Merge conflict in greetings.py
Automatic merge failed; fix conflicts and then commit the result.
```

```
@@@ -10,7 -10,7 +10,11 @@@ class Student
      def welcome(self):
++<<<<<<< HEAD
 +        return f"Welcome to Albert School, {self.first_name}! Your desk is ready."
++=======
+         return f"Welcome to Albert School Paris, {self.first_name}!"
++>>>>>>> origin/main
```

`HEAD` is your branch (`feat/title`), `origin/main` is what B just merged. Keep both
changes: Paris and "Your desk is ready." Edit the file by hand so only one line remains:

```python
        return f"Welcome to Albert School Paris, {self.first_name}! Your desk is ready."
```

Check nothing is left, run the code, finish the merge and push:

```bash
grep -n "<<<<<<<\|=======\|>>>>>>>" greetings.py     # prints nothing
python greetings.py
git add greetings.py
git commit --no-edit
git push
git log --oneline --graph -7
```

**You should see:**

```
Welcome to Albert School Paris, Tuka! Your desk is ready.
Registered as student #1 of 1
Confirmation sent to tuka@albertschool.com
Tuka Bade joins MSc 1 Data.
See you soon, Tuka!
```

```
*   84553f9 Merge remote-tracking branch 'origin/main' into feat/title
|\
| *   5af9372 Merge pull request #6 from partner/feat/campus
| |\
| | * 395c17f feat: name the campus in the welcome
| |/
| * a624933 feat: add is_enrolled
* | 3d8e8e7 feat: say the desk is ready
|/
* 60979ed feat: show the registry size on registration
```

The PR page now says the branch can be merged. Dismiss stale approvals is active, so if A's PR
was approved before this push, the approval is gone: the reviewer re-checks the resolution and approves
again. Then **Squash and merge** (or merge commit), delete the branch, and both run
`git switch main && git pull && git fetch --prune`.

**Why:** we do not resolve this one in the browser, because you have to run the
code before saying "resolved". The conflict markers are just text; only Python tells you the merged line
works. The merge goes into your branch, not into `main`, so `main` stays clean until the
PR is merged.

> **If it goes wrong:**
> - You want out: `git merge --abort` brings you back to before the merge.
> - You committed with the markers still in the file: `grep` for them, fix, commit again on the same
>   branch and push; the PR updates.
> - The approved PR cannot be merged any more after the push: that is expected: the ruleset dismissed it.
>   Ask for a new approval.

---

## Part 8 · Forks (demo) and wrap-up

You cannot push branches to a repository you do not own. Forks cover that case: GitHub copies
the repo under your account, you push there and open a PR to the original (called upstream).

I demo it on a public repo (the course repo or any small open-source library):

```bash
gh repo fork <owner>/<repo> --clone
cd <repo>
git remote -v
```

```
origin    git@github.com:<you>/<repo>.git (fetch)
origin    git@github.com:<you>/<repo>.git (push)
upstream  git@github.com:<owner>/<repo>.git (fetch)
upstream  git@github.com:<owner>/<repo>.git (push)
```

Same PR loop, with two remotes. To keep your fork's `main` up to date:

```bash
git fetch upstream
git switch main
git merge --ff-only upstream/main
git push origin main
```

Inside a team repository (your semester project) you use branches in the same repo, as you did
today. No forks there.

### Deliverable

Hand in the URL of your repository and paste in your submission the output of:

```bash
git log --oneline --graph --all
```

It must show: the README commit, the merge commit of `feat/farewell`, the squashed `full_name`
commit, the linear `is_enrolled` commit, and the conflict resolution merge. `main` must be protected.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Permission denied (publickey)` | key not on your GitHub account, or agent empty | Part 0.1, `ssh-add` |
| `rejected ... fetch first` on first push | GitHub repo created with a README | recreate it empty, or `git pull --rebase origin main` once |
| `git push` rejected on `main` | the ruleset works | branch, push, PR |
| Cannot approve my PR | you cannot approve yourself | ask your partner, check they are a collaborator |
| Merge button greyed out | missing approval, or conflict | read the message under the button |
| Approval vanished after a push | "dismiss stale approvals" | ask for a new approval, it is intended |
| `git branch -d` refuses after a squash | squash creates a different commit | check the PR is merged, then `-D` |
| Pushed to the wrong branch | forgot `switch -c` before committing | `git switch -c right-branch`, then `git switch main && git reset --hard origin/main` |

## Glossary

- **remote**: another copy of the repository, reached by a URL. **origin** is its usual nickname.
- **origin/main**: your laptop's last known position of `main` on GitHub. Updated only by `fetch`.
- **upstream** (branch): the remote branch your local branch follows (`push -u`). **upstream**
  (remote): in a fork, the original repository.
- **pull request (PR)**: GitHub's request to merge one branch into another, with review and checks.
- **review**: comments on specific lines, ending in **Comment**, **Approve** or **Request changes**.
- **squash**: merge a whole branch as a single new commit.
- **rebase**: replay commits on top of another base, creating new commits with new hashes.
- **ruleset / branch protection**: server-side rules that refuse a push or a merge.
- **fork**: your own copy of someone else's GitHub repository.
