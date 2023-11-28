> Instructions copied from the following article:  
> [The Best Way to Store Your Dotfiles a Bare Git Repository Explained](https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/)  
> Which is based on this article:  
> [Dotfiles: Best Way to Store in a Bare Git Repository](https://www.atlassian.com/git/tutorials/dotfiles)

# Overview of Storing Dotfiles in a Git Repository

* Set a Git repository’s work tree to `$HOME`
* `git add` and `commit` your dotfiles to the Git repository. The dotfiles remain at their original paths.
* Push your Git repository to a remote server such as GitHub. Now your dotfiles are backed up, and can be replicated.

Replicate your dotfiles by cloning down the repo, configuring it, and checking out the files. The files are checked out at their original paths relative to `$HOME`.

## Creating local repo:
1. `git init --bare $HOME/.cfg`
2. `alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`
3. `echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bash_aliases`
4. `config config --local status.showUntrackedFiles no`
5. `config add <files>` + `config commit -m "add things"`

## Getting existing repo:
1. `echo ".cfg" >> .gitignore`
2. `git clone --bare <remote-git-repo-url> $HOME/.cfg`
3. `alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`
4. `config config --local status.showUntrackedFiles no`
5. `config checkout`


# Line by line breakdown

## Creating Local Repo

1. `git init --bare $HOME/.cfg`  
    Create the folder `.cfg`, a bare Git repository which will be used to track our dotfiles.

2. `alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`  
    Create an alias named `config` which allows you to send Git commands to the `.cfg` repository from any location, even outside of the repository.
    It also configures the initially bare `.cfg` repository to set `$HOME` as the work tree, and store the Git state at `.cfg`.

3. `echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bash_aliases`  
    Make the `config` alias permanently available.

4. `config config --local status.showUntrackedFiles no`  
    Only show config files manually added, not every file under `$HOME`.

5. `add`, `commit` and `push` to the remote  
    Use the `config` alias to `add` and `commit` files from any directory.  
    `config remote add origin <remote-url>`  
    `config push -u origin master`


## Install Your Dotfiles on a New System

1. `echo ".cfg" >> .gitignore`  
    There could be weird behaviour if `.cfg` tries to track itself. Avoid recursive issues by adding `.cfg` to your global Git ignore.
 
2. `git clone --bare <remote-git-repo-url> $HOME/.cfg`  
    Clone the dotfile repo to your `.cfg` directory.
 
3. `alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'`  
    Set up an alias to send Git commands to `.cfg`, and also set `$HOME` as the work tree, while storing the Git state at `.cfg`

4. `config config --local status.showUntrackedFiles no`  
    Set a local configuration in `.cfg` to ignore untracked files.
 
5. `config checkout`  
    Checkout the actual content from your dotfile repository to `$HOME`.  
    `config checkout` might fail with a message like:
    ```bash
    error: The following untracked working tree files would be overritten by checkout:  
        .bashrc  
        .gitignore  
    Please move or remove them before you can switch branches.  
    Aborting  
    ```

    Git doesn’t want to overwrite your local files. Back up the files if they’re useful, delete them if they aren’t.


# Programs used

In no particular order:
* alacritty
* i3
* i3status
* nvim
* picom
* feh

