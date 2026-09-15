# mhkr

Source for my personal website, <https://mhkr.xyz>.

## The whole model, in one paragraph

The site is a [Hugo](https://gohugo.io/) build whose **output is committed to
this repository** as `public/`. The server builds nothing and nothing is
uploaded to it: it clones this repo from GitHub and copies `public/` into its
web root. So the rule is *whatever is on `origin/master` is what goes live*.
Everything below follows from that.

There are no secrets. The server's address is public DNS, this repo is public,
and deployment authenticates with your ordinary ssh key. There is no vault, no
ansible, and nothing to install beyond hugo and ssh.

## Update the site

```bash
# edit content/, layouts/, or static/
./bin/deploy
```

`bin/deploy` does the whole thing: builds with hugo, commits `public/` if the
build changed it, pushes master, tells the server to pull, and then fetches
<https://mhkr.xyz/> and checks it matches what you just built. If it prints
"Deployed", the site really is updated — it verified rather than assumed.

To build without deploying, run `./bin/build`.

## Rebuild the server from scratch

```bash
./bin/provision   # once, on a new or rebuilt box
./bin/deploy      # then publish
```

`bin/provision` installs nginx, certbot, ufw, rsync and git over ssh, opens
80 and 443, writes a minimal pre-TLS virtual host, and obtains the TLS
certificate. It is safe to re-run: the certificate step is skipped if one
already exists (Let's Encrypt rate-limits issuance), and the vhost step
refuses to overwrite a certbot-managed config unless you pass `--force`.

DNS must already point at the server before the certificate step can succeed.

## Requirements

- **hugo** — pinned in `mise.toml`. Run `mise install` here to get the right
  version. A different version will produce a large `public/` diff.
- **ssh access to `root@mhkr.xyz`** — a YubiKey-backed key is what I use, but
  any authorized key works.
- **git push access** to `github.com/HoffsMH/mhkr`.

That is the complete list. If a future you is holding only this repository and
an ssh key, that is enough.

## Server facts

| | |
|---|---|
| Hostname | `mhkr.xyz` (DNS is the source of truth for the address) |
| Provider | Vultr, Dallas |
| OS at setup | Debian 11 x64 |
| SSH user | `root` |
| Web root | `/var/www/html` |
| nginx vhost | `/etc/nginx/sites-enabled/default` — **the server's copy is the source of truth** |
| Certificate | `/etc/letsencrypt/live/mhkr.xyz/`, auto-renewed by certbot |

There is deliberately **no nginx config checked into this repo.** certbot
rewrites the vhost in place on the server when it issues the certificate —
adding the `listen 443` block, the `ssl_certificate` lines, and a second
server block redirecting http to https — so any copy kept here would drift
from what is running while looking authoritative. `bin/provision` writes a
minimal pre-TLS seed inline and lets certbot take it from there. To see what
is actually running:

```bash
ssh root@mhkr.xyz cat /etc/nginx/sites-enabled/default
```

One detail in that config is load-bearing: `default_type text/plain` in the
`location /` block is what makes `https://mhkr.xyz/omarchy.sh` render in a
browser instead of downloading, so it can be read before it is run.

## Notable paths

- `content/`, `layouts/`, `static/`, `config.yml` — Hugo source
- `public/` — **generated, but committed.** This is what gets served.
- `static/omarchy.sh` — the machine bootstrap script, served at
  <https://mhkr.xyz/omarchy.sh>. It clones `HoffsMH/infra` and runs
  `bootstrap-omarchy.sh`. Hugo copies `static/` into `public/`, so editing it
  and running `./bin/deploy` publishes it.
- `static/key.pub` — my OpenPGP public key, fingerprint
  `980D93A97C98DA434A1647CA4C58ED089E77CBDC`, served at
  <https://mhkr.xyz/key.pub>. New machines import it during bootstrap, so
  this file is load-bearing even though the site never links to it.
- `static/resume/resume.html` — served at <https://mhkr.xyz/resume/>.

## If something is wrong

```bash
ssh root@mhkr.xyz
systemctl status nginx
nginx -t
journalctl -u nginx -n 100 --no-pager
ls -la /var/www/html
```

`bin/deploy` fails loudly if the live site doesn't match your build, so a
green run means the content is actually there.

To roll back, check out the commit you want, run `./bin/build` to regenerate
`public/` from that source, commit, and deploy. To return to current, go back
to `master` and deploy again.

## History

Deployment used to run through Ansible from the `infra` repository, then
through a self-contained Ansible tree here with host facts in a YubiKey-backed
Ansible Vault. That was removed on 2026-09-15: the vault protected exactly two
values, one of which was the public DNS record for `mhkr.xyz` and the other an
email address. The machinery cost more than it protected, and it put a gpg
session-management problem between me and a static site.
