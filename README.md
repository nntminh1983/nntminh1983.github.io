# Personal website — Minh N. T. Nguyen

A single-page academic portfolio. Static HTML, CSS and JavaScript with no build step
and no dependencies — open `index.html` and it works.

```
index.html     the whole page (content lives here, not in JS)
styles.css     design tokens at the top, then layout and components
script.js      theme toggle, scrollspy, publication search/filter
assets/        your photo and CV go here
```

## Two files to add

| Put here | What it is |
|---|---|
| `assets/photo.jpg` | A square-ish portrait, ~600×700px. Until it exists the page shows an "MN" monogram instead. |
| `assets/CV_Minh_Nguyen_EN.pdf` | Linked from the **Download CV** button in the hero. |

## Running it

**Just to look at it** — double-click `index.html`. No server needed.

**On your network**, so phones and other computers can reach it — double-click
`start-website.bat`. It prints two addresses:

| Address | Who can use it |
|---|---|
| `http://localhost:8000` | This computer only |
| `http://<your-ip>:8000` | Any device on the same Wi-Fi |

The batch file detects your IP automatically, since it changes whenever you join a
different network. Close the window to stop the server.

The equivalent command by hand:

```bash
cd personal-website
python -m http.server 8000 --bind 0.0.0.0
```

`--bind 0.0.0.0` is the part that matters. Without it Python listens only on
`127.0.0.1` and no other device can connect, which looks exactly like a broken site.

### If other devices cannot connect

1. **Same network?** Both devices must be on the same Wi-Fi. A phone on mobile data
   will not reach it.
2. **Firewall.** Windows must allow inbound connections to `python.exe`. To add an
   explicit rule, run PowerShell **as Administrator**:
   ```powershell
   New-NetFirewallRule -DisplayName "Personal website 8000" -Direction Inbound `
     -LocalPort 8000 -Protocol TCP -Action Allow
   ```
3. **Client isolation.** Many university, office, hotel and public Wi-Fi networks block
   devices from talking to each other, whatever your firewall says. Nothing on this
   machine can fix that — use a phone hotspot to test, or deploy publicly instead.

Anyone with the address can view the site while the server runs, so treat it as visible
to everyone on that network.

## Editing

All content is plain HTML in `index.html` — edit the text and it changes on the page.

**Adding a publication.** Copy any `<li class="pub">` block into `#pubList`, keeping the
list in reverse-chronological order. `data-type` must be `journal`, `conference` or
`talk` for the filter chips to catch it. Wrap your own name in `<strong>` so it stands
out. Then update the count in the hero stats (`<dt>Publications</dt>`) — it is written
by hand, not computed.

**Changing the colours.** Every colour is a CSS custom property in the `:root` block at
the top of `styles.css`, with the dark-theme values in `:root[data-theme="dark"]` right
below. Change `--accent` in both and the whole page follows.

## Deploying

The site is three static files, so any host works.

- **GitHub Pages** — push to a repo, then Settings → Pages → deploy from `main` / root.
- **Netlify or Vercel** — drag the folder onto their dashboard.
- **University web space** — upload the folder over SFTP.

## Notes

- Dark mode follows the operating system on first visit; the toggle overrides it and the
  choice is remembered in `localStorage`.
- Publication search and filtering work over the DOM, so the papers are in the HTML
  source and remain visible to search engines and to visitors without JavaScript.
- The page carries a JSON-LD `Person` block for search engines. Update it if your title
  or affiliation changes.
- `Ctrl+P` prints a clean copy — navigation, filters and buttons are hidden.
- The home address and mobile number from the CV were deliberately left off. Add them
  in the Contact section if you want them public.
