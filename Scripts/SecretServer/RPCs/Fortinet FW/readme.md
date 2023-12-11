# Introduction

This document provides the details for having Secret Server manage Fortinet firewall accounts 

# Permissions

no specific permissions needed

# Setup

## Create Password Changer

1. Navigate to **Admin | Remote Password Changing**
2. Click **Configure Password Changers**
3. Click **New**

### Create New Password Changer

1. Provide following details:

    | Field                 | Value                     |
    | --------------------- | ------------------------- |
    | Base Password Changer | Unix Account Custom (SSH) |
    | Name                  | Fortinet Firewall (SSH)   |

2. Click **Save**

### Enter Commands

1. Under _Verify Password Changed Commands_
2. Under _Authenticate As_
    |Item    | Value       |
    |--------|-------------|
    |Username|$USERNAME|
    |Password|$CURRENTPASSWORD|
 
3. Under _Password Changed Commands_
2. Under _Authenticate As_
    |Item    | Value       |
    |--------|-------------|
    |Username|$USERNAME|
    |Password|$CURRENTPASSWORD|
    
4. Enter Commands

    | Order | Field                                   | Comment                   | Pause (ms) |
    | ----- | --------------------------------------- | ------------------------- | ---------- |
    | 1     | config global                           | config global             | 2000       |
    | 2     | config system admin                     | config system admin       | 2000       |
    | 3     | edit $USERNAME                          | edit $USERNAME            | 2000       |
    | 4     | set password $NEWPASSWORD               | set password              | 2000       |
    | 5     | end                                     | end                       | 2000       |

![Screenshot of configured commands](Fortinet%20FW/Fortinet_RPC.png)

