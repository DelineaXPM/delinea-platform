# Secret Server Linked Secrets

To create a link between 2 secrets so that when 1 secret changes its password, the others also change to match there is a (process documented in the official documentation)[https://docs.delinea.com/secrets/current/remote-password-changing/sync-passwords-during-rpc/index.md].  This document implements the process using the soap API. Many organizations prefer REST APIs for a variety of reasons so this is a REST based replacement. 

# Implementation 

Follow the steps outlined in the official document, but use (LinkedPassword_Change.ps1) instead of the script provided. All functionality is identical to the soap script as documented.

