## Table of Contents

- [What is the Delinea Connector](#what-is-the-delinea-connector)
- [Installing the Delinea Connector from the Command Line](#installing-the-delinea-connector-from-the-command-line)
- [Registering the Delinea Connector from the Command Line](#registering-the-delinea-connector-from-the-command-line)
- [Automating Install and Registration of the Delinea Connector](#automating-install-and-registration-of-the-delinea-connector)

## What is the Delinea Connector

The Delinea Connector enables secure communication between the Delinea Platform
and AD directories.

For additional information about the Connector and instructions on how to
download it, please refer to the [available resources](https://docs.delinea.com/dp/current/connector).

> **_NOTE:_**  For the required permissions to install and register the Delinea Connector, you must be a local administrator on the machine where you are installing Delinea Connector, so that you can copy files to Program Files, set up Windows service, and write settings to the registry.


## Installing the Delinea Connector from the Command Line

You can install a connector from a Windows PowerShell command line with the
following command:

```powershell
.\delinea-connector-installer.exe /quiet
```

## Registering the Delinea Connector from the Command Line

After you have installed the connector, you can configure the connector from the
command line, if desired.


> **_NOTE:_**  [Learn more](https://docs.delinea.com/dp/current/connector#to_create_a_new_registration_code) on how to create registration codes on Delinea Platform


1.  Make sure that the connector is installed.

2.  Navigate to “C:\\Program Files\\Delinea\\Delinea Connector”

3.  Run the following command to register the Delinea Connector with the
    Platform

```powershell
.\DelineaRegisterProxy.exe url=URL regcode=REGCODE
```

 Where:

 - URL is your tenant URL. For example, https://example.delinea.app
 - REGCODE is a valid connector registration code.

4.  Restart the Connector  

    ```powershell
    Restart-Service -Name delineaproxy
    ```

## Automating Install and Registration of the Delinea Connector

The [example PowerShell script](https://github.com/DelineaXPM/delinea-platform/blob/ef04082750b21abf84edfaf6d25cae9d5396e42b/DelineaConnector/delinea-connector-install.ps1) is provided as-is without any warranties.

Save the script as .ps1 file and then run it using PowerShell. The Connector
will be installed silently and will register with the Delinea Platform.

Ensure to replace any variables within the script to suit your environment.


