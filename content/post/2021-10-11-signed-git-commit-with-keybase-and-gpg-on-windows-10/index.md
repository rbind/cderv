---
title: Signed git commit with Keybase and Gpg on Windows 10
author: christophe dervieux
date: '2021-10-11'
slug: signed-git-commit-with-keybase-and-gpg-on-windows-10
categories:
  - windows
tags:
  - windows
  - security
description: 'About setting up GPG key to sign Git Commit on Windows 10'
---

Signing git commit is something that I have already done in the past following Github Documentation. However, last week I stumble upon Garrick's post "[Signed and verified: signed git commits with Keybase and RStudio](https://www.garrickadenbuie.com/blog/signed-verified-git-commits-keybase-rstudio/)" which explains how to use Keybase for signing commit for Mac OS. As often, following a tutorial for Windows user is not as easy. This post is about the step I used to make it happen on Windows 10.

## About the tooling

I am working on Windows 10 and using Powershell 7 in Windows Terminal for most of my CLI task.

If you are trying to setup all this in WSL, following Garrick's post should work fine as it is linux based.

### Gpg on a Windows 10 computer

After several tries, I think the best working tool is *Gpg4Win* . As I used *winget* (and *scoop*) as package manager, I installed it using

``` powershell
winget install gpg4win -i
```

I used `-i` flag for triggering interactive installation to unselect installation of Outlook and IE pluggins which I don't use. Aim is to only install Gpg and Kleopatra (GUI on Windows for GPG).

If you don't use a package manager, you can also download directly from <https://www.gpg4win.org/>

### Keybase for managing identities

Keybase (<https://keybase.io/>) is a "a [key directory](https://en.wikipedia.org/wiki/Key_server_(cryptographic) "Key server (cryptographic)") that maps [social media](https://en.wikipedia.org/wiki/Social_media "Social media") identities to encryption keys (including, but not limited to [PGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy "Pretty Good Privacy") keys) in a publicly auditable manner."[^1]

[^1]: <https://en.wikipedia.org/wiki/Keybase>

``` powershell
winget install keybase
```

After that you can follow Garrick's blog post

#### Creating GPG / PGP key

``` powershell
keybase pgp gen --multi
```

This will run gpg for you to store the private key. Enter a passphrase.

If you open *kleopatra* GUI, you'll see the new created GPG key in your keychain.  
If you open *keybase* GUI, you'll see the registered PGP key in your identities.

### Setting up in Git

Follow [A guide to securing git commits from tricking you on Windows](https://www.ankursheel.com/blog/securing-git-commits-windows)

``` powershell
# Tell Git to use the key
git config --global user.signingkey <keyid>
# Tell Git to sign commit by default
git config --global commit.gpgsign true
# Tell Git to sign tags by default
git config --global tag.gpgsign true
# Tell Git to use the gpg program from gpg4win
git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
```

### **Add your key to GitHub**

``` powershell
keybase pgp export -q <keyid> | Set-Clipboard
```

And paste it in [github.com/settings/keys](https://github.com/settings/keys) when creating a New GPG key.

### Start GPG agent on Windows startup

`gpg-agent` will be used by Git to sign the commit by opening a window to enter your passphrase. I am not sure why this process does not start on windows startup unfortunately. You'll need to manually add it to startup program. 

Following this resource is easy enough [GPG on Windows - Start the agent on startup](https://gist.github.com/matusnovak/302c7b003043849337f94518a71df777#start-the-agent-on-startup)

### Resources 

-   [https://www.garrickadenbuie.com/blog/signed-verified-git-commits-keybase-rstudio/](https://www.garrickadenbuie.com/blog/signed-verified-git-commits-keybase-rstudio/#fn3)

-   <https://www.gpg4win.org/about.html>

-   <https://www.ankursheel.com/blog/securing-git-commits-windows>

-   [https://medium.com/\@roneythomas/keybase-io-gpg-git-signing-on-windows-456cddde4a48](https://medium.com/@roneythomas/keybase-io-gpg-git-signing-on-windows-456cddde4a48)

-   <https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account>
