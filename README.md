# Diffblue Cbmc

## How do I install these formulae?

`brew install diffblue/cbmc/<formula>`

Or `brew tap diffblue/cbmc` and then `brew install <formula>`.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Maintainer Notes

To add a new version to the tap, proceed as follows on a system that has `brew`
set up:
1. Wait until after homebrew has actually picked up the new version of CBMC and
   built/released it. To check if this is completed on homebrew’s CBMC page
   check that the correct version is displayed.
2. Update your local homebrew using `brew upgrade`
3. In the homebrew-cbmc repository (usually in
   `/usr/local/Homebrew/Library/Taps/diffblue/homebrew-cbmc` or similar) run
   `./transform_binary.sh <version>` for the version you wish to do the new tap
   for.
4. Do brew extract `cbmc diffblue/cbmc --version=<version>` for the version
   you're doing the tap for
5. Do `brew edit cbmc@<version>` for the version...
6. Find a previous formula from the repository and copy the bottles section and
   update the hashes from step 2.
7. Add/commit the edited file to the tap (homebrew-cbmc repo)... -- note that the
   file you edit may be in another random place!
8. Add the bottles you downloaded (they are tar.gz files) to here:
   https://github.com/diffblue/homebrew-cbmc/releases/edit/bag-of-goodies and
   "Update release" to commit the upload
9. Verify the upload was successful by doing `brew fetch cbmc@<version>`. The URL
   shown at the second line of the command output (after ==> Downloading) should
   have this form:
   https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies/cbmc%40<version>-<version>.<mactype>.bottle
