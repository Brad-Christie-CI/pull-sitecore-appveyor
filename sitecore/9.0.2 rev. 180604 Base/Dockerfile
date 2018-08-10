#escape=`
FROM microsoft/windowsservercore
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG INSTALL_TEMP=C:\temp

COPY . ${INSTALL_TEMP}
WORKDIR ${INSTALL_TEMP}

RUN Write-Host "I spy, with my little eye..." ; `
    Get-ChildItem | Select-Object Name ; `
    Write-Host "Speedier build"