# Sean's Doom Emacs Config

Personal Doom Emacs configuration for a Windows-first workflow centered on
Org mode, note taking, reading, feed consumption, and bilingual input.

## Highlights

- `modus-operandi` theme with Maple Mono and CJK-friendly fallback fonts
- Org workflow for inbox, projects, areas, calendar, roam, and journal
- Google Calendar sync through `org-gcal`
- Reading setup for PDF, EPUB (`nov`), and `org-noter`
- Feed reading with `elfeed` and `elfeed-org`
- Windows-specific tuning for process encoding, file I/O, and IME behavior
- Smart input source switching with `sis` and Rime / Weasel

## Included modules

`init.el` enables these Doom modules:

- Input: `chinese`
- Completion: `company`, `vertico`
- UI: dashboard, modeline, treemacs, vc-gutter, workspaces
- Editor: evil, snippets, folds, file templates
- Tools: eval overlay, lookup, magit, pdf
- OS: `windows`
- Languages: emacs-lisp, javascript, org, python, sh, web, yaml, cc

## Extra packages

`packages.el` adds:

- `org-gcal`
- `org-download`
- `elfeed`
- `elfeed-org`
- `cal-china-x`
- `nov`
- `org-noter`
- `powershell`
- `sis`

## Directory assumptions

This setup assumes the following local structure:

- Org root: `~/org`
- Agenda sources under `~/org/inbox.org`, `~/org/projects/`, `~/org/areas/`,
  and `~/org/.calendar`
- Roam notes under `~/org/roam`
- Journal entries under `~/org/journal`
- Reference notes under `~/org/references`

If your layout differs, update the paths in `config.el`.

## Local private configuration

This repo intentionally does **not** track `secrets.el`.

Create `secrets.el` locally for machine-specific secrets such as
`org-gcal-client-id`, `org-gcal-client-secret`, and your
`org-gcal-fetch-file-alist`. The main config loads that file only when it
exists, so the repo stays safe to publish.

## Fonts and external tools

Recommended local dependencies on Windows:

- `Maple Mono NF CN`
- `LXGW WenKai Screen`
- Rime / Weasel for Chinese input
- `ripgrep`, `fd`, `git`
- `mpv` for opening media from Elfeed
- `epdfinfo.exe` from MSYS2 for `pdf-tools`
- `unzip.exe` from Git for `nov.el`

## Setup

1. Install Doom Emacs and clone this directory into `~/.doom.d`.
2. Create a local `secrets.el` file if you use Google Calendar sync.
3. Install the fonts and Windows dependencies listed above.
4. Run `doom sync`.
5. Restart Emacs.

## Repository notes

- `scripts/register-org-protocol.ps1` is included for Windows org-protocol
  registration.
- `snippets/` contains custom yasnippet content.
- `secrets.el` is ignored on purpose and should remain local-only.
