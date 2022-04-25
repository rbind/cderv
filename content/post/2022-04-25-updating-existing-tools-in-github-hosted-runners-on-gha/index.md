---
title: Updating existing tools in Github-hosted runners on GHA
author: Christophe Dervieux
date: '2022-04-25'
slug: updating-gha-tools
categories:
  - tips
tags:
  - gha
description: 'How to use a new version before it gets updated on GHA ?'
---

# Some context about the problem

Recently, I have been working on migrating our workflows for TinyTeX bundles released on [`tinytex-release`](https://github.com/yihui/tinytex-releases) from Appveyor to Github Action[^1].

[^1]: And more exactly these PR [yihui/tinytex#362](https://github.com/yihui/tinytex/pull/362), [yihui/tinytex#369](https://github.com/yihui/tinytex/pull/369) and [yihui/tinytex-releases#22](https://github.com/yihui/tinytex-releases/pull/22).

For adapting the workflow, I needed to work with easily create and update release from the workflow itself. Github CLI tool (<https://cli.github.com/>) comes in handy for such tasks, like managing Github Releases using `gh release` or making request with Github API using `gh api` . Github CLI is part of the pre-installed tools one can found in github-hosted runners.[^2]

[^2]: You can find about supported sofware in github-hosted runners in the doc for each OS at <https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-software>

While I was in the process of updating the workflows, it happens that a new release of the CLI went out and I was really waiting for it: `gh` version 2.8 adds a new `gh release edit` command that, among other things, allows to undraft an existing draft. That was the missing piece I needed to avoid some weird API call as workaround.

However, I found out that github-hosted runners does not get updated right away with latest version- `gh`version 2.7 was still the one available by default.

That's too bad - I really want to use the last version and don't want to wait!

# Updating a pre-installed software

So in order to use the last new release, I needed to find a way to update the existing one. Here are two solutions with example for `unbuntu-latest` runners

## Install a newer version using `brew`

It happens that `brew` package manager has been updated so `brew install gh` could be used. The important pieces are:

-   Default `gh` is not install with `brew` so `brew update gh` won't work
-   `brew update` needs to be run for the runner to have the info about the new version
-   Specific `brew` binary `gh` needs to be used, located in `$(brew --prefix gh)/bin/gh`

Example in workflow file

``` yaml
    steps:      
      # this uses version 2.7
      - run: gh --version
        
      # installing new version 2.8
      - name: update
        run: |
          brew update
          brew install gh
        
      # still point to version 2.7
      - run: which gh
      
      # this using version 2.8
      - run: $(brew --prefix gh)/bin/gh --version
```

## Updating the included version using a `.deb` file

Github CLI is released on <https://github.com/cli/cli> as a Github release. This means it is really easy to download a release bundle:

-   Using available `gh` CLI directly

-   Specifying `-R` option to target CLI repo

-   Specificying `--pattern` to target which release asset to download. Example for `ubuntu-latest`

    ``` bash
    gh release download -R cli/cli --pattern '*linux_amd64.deb'
    ```

    The `pattern` needs to be adjusted according to the OS.

Then it can be installed on the system, which will replace the pre-installed version

``` bash
sudo dpkg -i 'gh_2.8.0_linux_amd64.deb'
```

Here is a complete example in a workflow file

``` yaml
    steps:
      # this is 2.7 version
      - run: gh --version
      
      # Updating and downloading the release
      - name: update
        env:
          # Needed for gh CLI to work
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release download -R cli/cli --pattern '*linux_amd64.deb'
          sudo dpkg -i $(ls *.deb)
      
      # same binary as 2.7
      - run: which gh
      
      # now updated to 2.8
      - run: gh --version
```

# Conclusion

I ended using the second solution adding the update step in my workflow. Obviously, this can be removed when `gh` 2.8 will be available on the runners.

This post will be useful for future me maybe so that I don't search again for this. But maybe it can be useful to someone else... that is why it is best to go public with notes, right ?
