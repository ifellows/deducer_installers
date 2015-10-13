SET RHOME=R-3.1.1
SET RNAME=R-3.1.1
SET TMPDIR=%~dp0\tmp
ECHO %TMPDIR%
REM C:\Users\ianfellows\Documents\tmp
SET JAVA_FILE=jre-8u5-windows-i586.exe


:MakeLauncher

cd files
cp RDSAnalyst.ico JGR\launcher\windows\jgr.ico
cd JGR\launcher\windows
CALL build.bat
cp jgr2.exe ..\..\..\RDSAnalyst.exe
cd ..\..\..\..

:InstallR

IF EXIST "%RHOME%" (
REM cd %RHOME%\src\gnuwin32
) ELSE (
tar --no-same-owner -xf %RHOME%.tar.gz
cp -r libs\libpng-1.6.3 %RHOME%\src\gnuwin32\bitmap\libpng
cp -r libs\jpeg-9 %RHOME%\src\gnuwin32\bitmap\
cp -r libs\tiff-4.0.3\libtiff %RHOME%\src\gnuwin32\bitmap\libtiff
REM cp misc\Rd.sty %RHOME%\share\texmf\tex\latex
cd %RHOME%\src\gnuwin32
REM Odd characters in the header comments
cp installer\CustomMsg.iss installer\CustomMsg2.iss
REM more +2 installer\CustomMsg.iss > installer\CustomMsg.iss
..\..\..\files\gawk.exe "{ if (NR==1) sub(/^\xef\xbb\xbf/,\""\""); print }" installer\CustomMsg2.iss > installer\CustomMsg.iss
cp -r C:/R/Tcl ../..
REM You can comment these next three lines if R has been built already.
make rsync-recommended
make distribution
REM make check-all
cd ../../..
)


:InstallPackages

REM Install Deducer family of packages
%RHOME%\bin\R -e "update.packages(repos='http://cran.stat.ucla.edu',ask=FALSE)"
%RHOME%\bin\R -e "install.packages(c('JGR','JavaGD','png','rJava','iplots','Deducer','DeducerExtras','DeducerPlugInScaling','DeducerSpatial','DeducerText','XLConnect','RDS'),lib=.libPaths()[length(.libPaths())],repos='http://cran.stat.ucla.edu',dependencies=TRUE)"

REM install packages in packages directory + dependencies
REM add extra CRAN packages here
%RHOME%\bin\R -e "install.packages(c('coda','locfit','xtable','gridExtra','igraph','network','testthat','iplots','brew','Rook','XML','rgexf','survey','isotone'),lib=.libPaths()[length(.libPaths())],repos='http://cran.stat.ucla.edu')"
REM install local packages (and updates of CRAN packages) here
cd packages
..\%RHOME%\bin\R -e "install.packages(rev(dir()),lib=.libPaths()[length(.libPaths())],repos=NULL,type='source')"
cd ..

:MakeScript

REM Make Inno installer script
%RHOME%\bin\R -e "exis = function(x, table) match(x, table, nomatch = 0) > 0;pkgs=installed.packages(lib.loc=.libPaths()[length(.libPaths())]);pkgs=pkgs[!exis(pkgs[,'Priority'], c('base','recommended')),1];pkgs=paste(pkgs[!exis(pkgs , c('translations'))],collapse=' ');cat('make R.iss EXTRA_PKGS=\'',pkgs,'\'',file='mktmp.bat',sep='')"
cd %RHOME%\src\gnuwin32\installer
CALL ..\..\..\..\mktmp.bat
..\..\..\bin\R -f ..\..\..\..\patch-iss.R

cp ..\..\..\..\files\JGRprefsrc.txt .JGRprefsrc
cp ..\..\..\..\files\%JAVA_FILE% .
cp ..\..\..\..\files\RDSAnalyst.exe %RNAME%\bin\RDSAnalyst.exe
cp ..\..\..\..\files\jgrParams.txt %RNAME%\bin\jgrParams.txt
"C:\packages\Inno\iscc" RDSAnalyst.iss
mv RdsAnalystSetup.0.43.exe ../../../../RDSAnalystSetup.0.43.exe
cd ../../../..


:End