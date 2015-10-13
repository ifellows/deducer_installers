javaFile <- Sys.getenv("JAVA_FILE")
if(is.null(javaFile) || javaFile=="") javaFile <- "jre-8u5-windows-i586.exe"

rname <- Sys.getenv("RNAME")
if(is.null(rname) || rname=="") rname <- "R-3.1.1"


#############################
##  Patches R.iss to include custom installation items
#############################
riss <- readLines("R.iss")

setup <- paste0("OutputBaseFilename=RdsAnalystSetup.0.43
AppName=RDS Analyst
AppVerName=RDS Analyst version 0.43
AppVersion=0.42
AppID=RDS Analyst
VersionInfoVersion=3.1.0
DefaultDirName={code:UserPF}\\RDS Analyst
InfoBeforeFile=",rname,"\\COPYING
AppPublisher=HPMRG
PrivilegesRequired=none
MinVersion=0,5.0
DefaultGroupName=RDS Analyst
AllowNoIcons=yes
DisableReadyPage=yes
DisableStartupPrompt=yes
OutputDir=.
WizardSmallImageFile=R.bmp
UsePreviousAppDir=no
ChangesAssociations=yes
Compression=lzma/ultra
SolidCompression=yes
AppPublisherURL=http://wiki.stat.ucla.edu/hpmrg/index.php/RDS_Analyst_Manual
AppSupportURL=http://wiki.stat.ucla.edu/hpmrg/index.php/RDS_Analyst_Manual
AppUpdatesURL=http://wiki.stat.ucla.edu/hpmrg/index.php/RDS_Analyst_Manual")

startsWith <- function(a,b) substring(a,1,nchar(b))==b

setLine <- which(startsWith(riss,"[Setup]"))
langLine <- which(startsWith(riss,"[Languages]"))
insert <- function(txt,i=NULL,j=NULL){
		if(is.null(i))
			i<-j-1
		if(is.null(j))
			j<-i+1
		riss <<- c(riss[1:i],strsplit(txt,"\n")[[1]],riss[j:length(riss)])
}
insert(setup,setLine,langLine)

icLine <- which(startsWith(riss,"[Icons]"))
regLine <- which(startsWith(riss,"[Registry]"))
txt <- 'Name: "{group}\\RDS Analyst"; Filename: "{app}\\bin\\RDSAnalyst.exe"; WorkingDir: "{userdocs}"; Parameters: {code:CmdParms}
Name: "{commondesktop}\\RDS Analyst"; Filename: "{app}\\bin\\RDSAnalyst.exe"; MinVersion: 0,5.0; Tasks: desktopicon; WorkingDir: "{userdocs}"; Parameters: {code:CmdParms}
Name: "{app}\\RDS Analyst"; Filename: "{app}\\bin\\RDSAnalyst.exe"; MinVersion: 0,5.0; Tasks: desktopicon; WorkingDir: "{userdocs}"; Parameters: {code:CmdParms}
Name: "{userappdata}\\Microsoft\\Internet Explorer\\Quick Launch\\RDS Analyst"; Filename: "{app}\\bin\\RDSAnalyst.exe"; Tasks: quicklaunchicon; WorkingDir: "{userdocs}"; Parameters: {code:CmdParms}
'
insert(txt,icLine+1,regLine)

txt <- paste0('Name: Java; Description: Java (required if not already installed); Types: user custom

[Run]
Filename: "{tmp}\\',javaFile,'"; Parameters: ""; Components: Java; StatusMsg: "Installing Java runtime environment (needed for RDS Analyst GUI)..."; Check:JREVerifyInstall

[InstallDelete]
Type: filesandordirs; Name: "{userdocs}\\RDSAnalyst\\win-library"

')

codeLine <- which(startsWith(riss,"[Code]"))
insert(txt,,codeLine)

txt <- "
Function JREVerifyInstall:Boolean;
begin
 if (RegValueExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\\JavaSoft\\Java Runtime Environment','CurrentVersion'))  then 
 begin
  if ((msgBox ('A Java Runtime has been found. Do you want to install another one anyway?',mbinformation,mb_YesNo)=idYes)) then
  begin
     Result:=True;
  end
  else
      Result:=False;
    end
  else Result:=True;
end;

"
fileLine <- which(startsWith(riss,"[Files]"))
insert(txt,,fileLine)

txt <- paste0('Source: ".JGRprefsrc"; DestDir: "{userdesktop}\\.."; Components: main
Source: ',javaFile,'; DestDir: "{tmp}"; Components: Java; Flags: onlyifdoesntexist
Source: "',rname,'\\bin\\RDSAnalyst.exe"; DestDir: "{app}\\bin"; Flags: ignoreversion; Components: main
Source: "',rname,'\\bin\\jgrParams.txt"; DestDir: "{app}\\bin"; Flags: ignoreversion; Components: main
')
riss <- c(riss,txt)

riss <- gsub("R-core","RDSAnalyst",riss)

#########################
## Write out new script
#########################
cat(paste(riss,collapse="\n"),file="RDSAnalyst.iss")


#########################
## some edits to RProfile to seperate user library from ours
#########################
prof <- readLines(paste0(rname,"/library/base/R/Rprofile"))
prof <- gsub("               file.path(Sys.getenv(\"R_USER\"), \"R\",",
	"               file.path(Sys.getenv(\"R_USER\"), \"RDSAnalyst\",",
	prof,fixed=TRUE)
cat(paste(prof,collapse="\n"),file=paste0(rname,"/library/base/R/Rprofile"))







