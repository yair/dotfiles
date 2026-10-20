# Changing the dotfiles (for agents)

This is the chezmoi source for Yair's homes on every host. Several admin
agents change it, and the engine doesn't enrol it yet, so every change
follows the procedure below, whoever makes it and wherever.

## Why `main` is special

Every home runs `chezmoi-autoupdate` from a systemd timer every 30 minutes.
It fast-forwards the home's checkout of this repository (normally
`~/.local/share/chezmoi`) from `origin/main` and applies what changed. It
applies local `main` as it stands, pushed or not:

- **A commit on local `main`** goes live on that home within 30 minutes,
  before anyone has reviewed it.
- **Uncommitted changes** in that checkout stop the home's pulls, and the
  updater pages about them once a day until someone moves them.

So the checkout stays on `main`, clean and level with `origin/main`. Work
happens on branches, in separate worktrees.

## The procedure

1. **Cut a branch in a worktree** from `origin/main`:

       git -C ~/.local/share/chezmoi fetch origin
       git -C ~/.local/share/chezmoi worktree add -b <branch> ~/w/.worktrees/dotfiles-<slug> origin/main

2. **Edit the source files there.** Use the names chezmoi uses: `dot_`,
   `private_`, `executable_`, `modify_`, `.tmpl`. Check the result without
   applying it:

       chezmoi -S ~/w/.worktrees/dotfiles-<slug> diff
       chezmoi -S ~/w/.worktrees/dotfiles-<slug> cat ~/<target>

   Don't run `chezmoi apply`; the updater applies the change after the push.
3. **Commit on the branch.** Never on `main`. Never rewrite what is already on
   `origin`.
4. **Get it reviewed through the engine.** Freeze the branch as a review
   dossier in your own genius's repository, under
   `docs/reviews/<slug>-<task id, 8 chars>/`, and submit the task as usual. A
   dossier holds:
   - `README.md`: the sources (branch, commits, parent), what changed and why,
     how to run the checks, and what wasn't tested;
   - `manifest.json`: full SHAs, and sha256 digests of the snapshot files;
   - `dotfiles.patch`: `git format-patch --stdout origin/main..<branch>`;
   - `snapshot/`: the resulting files, so the reviewer can read and run them;
   - `verify.py`: hermetic checks, with a temporary `HOME`, no network and no
     live services.

   `docs/reviews/` in `yair/zhizi` has worked examples. If the engine's
   whitespace check trips on patch context, add `*.patch -whitespace` to
   `docs/reviews/.gitattributes`.
5. **After it lands, hand it to Yair** with the branch name and these
   commands:

       git -C ~/.local/share/chezmoi merge --ff-only <branch>
       git -C ~/.local/share/chezmoi push origin main

   Every home pulls and applies it within 30 minutes. Then remove your
   worktree and branch.

**Never push,** by any route: git, `gh`, the GitHub API or HTTPS. Only Yair
pushes.

## If you edited a file under `~`

When an agent edits a managed file in the home, the post-edit hooks
(`chezmoi-postedit-hook` for Claude, `codex-chezmoi-postedit-hook` for Codex)
copy the edit back into the checkout's source. That leaves an uncommitted
change on `main`. Move it to your branch straight away:

    git -C ~/.local/share/chezmoi stash push -m <slug> -- <source paths>
    git -C ~/w/.worktrees/dotfiles-<slug> stash pop

Your home keeps the edit, so until the push the updater reports the file as
edited locally and leaves it alone.

The hooks don't copy back templates, `modify_` scripts or encrypted files. For
those, make the same change in the source on your branch.

## Speed bumps

`.githooks/` refuses commits on `main` and all pushes from Claude and Codex
sessions. `chezmoi-autoupdate` points `core.hooksPath` at it. It's a
reminder, not security: `--no-verify` gets past it, and you must not use it
here.

## Notes

- Secrets never go in this repository in plain text.
- `AGENTS.md` and `.githooks/` aren't deployed to `~`. `.chezmoiignore` keeps
  out `AGENTS.md`, and chezmoi skips source entries whose names begin with a
  dot.
