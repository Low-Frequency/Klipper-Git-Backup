# Installing `git` from source

If `apt` doesn't let you update `git` to version 2.28 or newer, you have to install a newer version from the source. To do that you first have to uninstall `git`:
```bash
sudo apt remove git
```

After that you'll have to install some dependencies to build `git`:
```bash
sudo apt update
sudo apt install make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext
```

Once the installation is complete, visit the `git` [releases](https://github.com/git/git/tags) and copy the latest download URL that ends in `.tar.gz`, for example: https://github.com/git/git/archive/refs/tags/v2.39.0.tar.gz

Navigate to `/usr/src/` and download the file with `wget`:
```bash
cd /usr/src/
sudo wget -O git.tar.gz <insert download URL here>
```

Next extract the tarball and change to the `git` source directory:
```bash
sudo tar -xf git.tar
cd git-*
```

To compile and install `git` run the following two commands:
```bash
sudo make prefix=/usr/local all
sudo make prefix=/usr/local install
```

To verify the installation execute `git --version`. If the installation was successful, you should see an output like this:
```bash
git version 2.39.0
```
