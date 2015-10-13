# deducer_installers
Code for creating all-in-one windows installers for Deducer/RDSAnalyst


# How-to
How to build the RDS Analyst installer.

## Preliminaries:
1. Install Rtools into the default location
2. Install MikTex
3. Install Inno Installer into C:\packages\Inno
4. Make sure the JGR source is in files:
cd files
svn co svn://svn.rforge.net/JGR/trunk JGR
Ian has a modified version of this.
5. mkdir tmp

## Build:
As an administrator, run:
makeRDS.bat > makeRDS.log

## Notes:
- To upgrade R remove R-3.1.0.tar.gz and the R-3.1.0 folder. 
Then download the new R (e.g., R-3.1.1.tar.gz), but do not untar it.
Then edit the RNAME and RHOME variables in makeRDS.bat to 
their appropriate values. 
- To upgrade packages, put them in the packages folder, removing the old versions.
- To add new packages, put them in the packages folder and edit the install.packages line
of makeRDS.bat to include any dependencies.
- I have added a patched "CustomMsg.iss" for R 3.1.0 at the top level. This is needed as the vanilla R-3.1.0 has a odd character in it that leads to a failed compile. It needs to go in R-3.1.0/src/gnuwin32/installer
I added "gawk.exe" to operate on it/
