# git-hooks

## Background

Git hooks resides in every git repository inside `.git/hooks` folder.
Scripts located there cannot be simply shared across all developers involved.

The goal of this project are:
- collecting hooks' implementations.
- sharing hooks
- installing hooks with individual preferences

## How to install?

This project is designed to include it as submodule to your git repository. 
So all you have to do is:

```shell
git submodule add https://github.com/a4099181/git-hooks.git <local-path>
```

## Requirements

- git
- GNU make
- your own git repository

## How the project is organized?

- _Makefile_ - gateway to all possible operations

  - *configure*       - interactive setup
  - *install*         - installs configured hooks
  - *uninstall*       - removes installed hooks
  - *clean*           - cleans workspace (folder `build~`)
  - *reinstall*

- _configure.bash_    - setup script
- build~/_hooks.bash_ - single file as functions' container. 
  This is where all hook implementations are stored.

## How to use it from scratch

- create git repository

  ```shell
  ~ $ git init githooks-show
  Initialized empty Git repository in ~/githooks.show/.git/
  ~ $ cd githooks-show
  ```

- add git-hooks as submodule

  ```shell 
  (master) ~/githooks-show $ git submodule add https://github.com/a4099181/git-hooks.git .githooks
  Cloning into '~/githooks.show/.githooks'...
  ```

- now you can configure hooks to install

  ```shell
  (master) ~/githooks-show $ cd .githooks
  (master) ~/githooks-show/.githooks $ make configure
  bash configure.bash
  0)...................Quit  1)............Choose hook  2)........Choose function  3)................Preview

  Your choice:
  ```

- type `1` to choose a hook you want to configure or 
  type `2` to choose a function to assign to hook you will choose then.

  Let's choose a hook, so `1` is typed to console:

  ```shell
  Your choice: 1
  Choose hook, please
  0).........applypatch-msg  1).............commit-msg  2)............post-update  3).........pre-applypatch
  4).............pre-commit  5)...............pre-push  6).............pre-rebase  7).....prepare-commit-msg
  8).................update

  Your choice:
  ```

  The list of hooks is based on default content of the `.git/hooks` folder.
  Shortly, this is a list of sample hooks in your git repository.

  Let's choose a pre-commit hook, so `4` is typed to console:

  ```shell
  Your choice: 4
  Choose function, please
  0)..assert-utf-8-encoding  1)....assert-handel-tests  2)....comment-with-branch

  Your choice:
  ```

  The list of functions is based on the contect of the `build~/hooks.bash` file. 
  Shortly, this is a list of functions in that file.

  Let's choose a assert-utf8-encoding function, so `0` is typed to console:
  
  ```shell
  Your choice: 0
  0)...................Quit  1)............Choose hook  2)........Choose function  3)................Preview

  Your choice:
  ```

  That's the moment when first hook is configured. All above configures envoding validation on commit. 
  The only one permitted encoding is UTF-8.

  Setup is now in the entry point. You can repeat operation to setup another hook and function.

  When the job is done you have to save your work. Type `3` to preview what have you done:

  ```shell
  Your choice: 3
  Current selection

  pre-commit...............assert-utf-8-encoding
  0)...................Back  1)...................Save
  
  Your choice:
  ``` 

  The list confirms the changes have been made. Let's save it, so `1` is typed to console:

  ```shell
  Your choice: 1
  Saving hook files
    pre-commit
  (master) ~/githooks-show/.githooks $ 
  ```

- The work done is saved, setup quits. Let's check the workspace:

  ```shell
  (master) ~/githooks-show/.githooks $ tree
  .
  ├── build~
  │   ├── hooks.bash
  │   └── pre-commit
  ├── configure.bash
  ├── LICENSE
  ├── Makefile
  └── README.md
  ```

  Folder `build~` is the workspace. Saved setup makes git hook files (`pre-commit`).
  These files are ready, but not yet installed. Let's install them:

  ```shell
  (master) ~/githooks-show/.githooks $ make install
  test -d build\~ && \
    cp build\~/* ../.git/hooks/ && \
    find ../.git/hooks -not -name '*.sample' -type f -exec chmod u+x '{}' \; \
    || exit 0
  ```

  That's all. Now you can enjoy hooks in your main repository.

- Last check

  ```shell
  (master) ~/githooks-show/.githooks $ cd ..
  (master) ~/githooks-show $ touch file
  (master) ~/githooks-show $ git add file
  (master) ~/githooks-show $ git commit -m "New file"
  Invalid encoding detected.
  file: binary
  (master) ~/githooks-show $ 
  ```

## How it works?

  Setup tool generates git hook files. Each file is simple script. 
  It includes all the code within `hooks.bash` and simply invokes selected function.

  Example:

  ```bash
  #!/bin/bash
  source .git/hooks/hooks.bash
  assert-utf-8-encoding $1
  ```

  Note, that `hooks.bash` is copied to `.git/hooks`. 
  It provides that hooks will work also when your code is far behind the moment 
  when git-hooks was introduced to your repository.

  It also may be a disadvantage.
  When update is available you have to `make install` to copy new `hooks.bash`.

## TODO

- Split _hooks.bash_ into separate file for each single function
- Don't copy `hooks.bash` to `.git/hooks` folder. 
- Initialize setup with currently installed hooks. 

  Currently every setup session needs complete configuration because it starts empty.




