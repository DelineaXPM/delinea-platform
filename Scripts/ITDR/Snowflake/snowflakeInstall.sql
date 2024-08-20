USE ROLE ACCOUNTADMIN;

-- Create a user with the least privilege to carry out the tasks
CREATE OR REPLACE ROLE DELINEA_ROLE;

CREATE OR REPLACE USER DELINEA_USER
PASSWORD = '<your_password>';

-- Note the default role will be used during scan
ALTER USER DELINEA_USER SET DEFAULT_ROLE = DELINEA_ROLE;

-- Add user to Delinea role
GRANT ROLE DELINEA_ROLE TO USER DELINEA_USER;

-- Activities are inside views of SNOWFLAKE database
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE DELINEA_ROLE;

-- Database for creation of stored procedure
CREATE OR REPLACE DATABASE DELINEA_DATABASE;

-- Give access to database to ROLE_NAME
GRANT USAGE, MONITOR ON DATABASE DELINEA_DATABASE TO ROLE DELINEA_ROLE;

-- Create warehouse for running the stored procedure
CREATE OR REPLACE WAREHOUSE DELINEA_WAREHOUSE WITH
    WAREHOUSE_SIZE = 'XSMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

-- Create a stored procedure that will grant usage privileges on all databases - Initialize to execute as owner
CREATE OR REPLACE PROCEDURE DELINEA_DATABASE.public.grant_usage_on_all_dbs(role_name STRING)
    returns varchar not null
    language javascript
    execute as owner
    as
    $$
    // Retrieve the role_name parameter passed to the stored procedure
    var roleName = ROLE_NAME;

    // Function to execute a single grant statement
    function execute_Statement(query, dbName, ret) {
        ret += "\n- " + query;

        try {
            snowflake.execute({ sqlText: query });
            ret += "\n\t-SUCCESS-";
        } catch (err) {
            ret += "\n\tQuery Failed for " + dbName;
            ret += "\n\tCode: " + err.code;
            ret += "\n\tState: " + err.state;
            ret += "\n\tMessage: " + err.message;
            ret += "\n\tStack Trace:\n" + err.stackTraceTxt;
        }

        return ret;
    }

    // We build up the return value string
    var ret = "USAGE access granted on: ";

    // Get all databases
    var res = snowflake.execute({ sqlText: "SHOW DATABASES;" });

    // Iterate through each database row
    while (res.next()) {
        // Extract the database name
        var dbName = '"' + res.getColumnValue(2) + '"';

        // Add each DB processed to the return value
        ret += "\n\n\n- " + dbName;

        if (dbName === '"SNOWFLAKE"' || dbName === '"SNOWFLAKE_SAMPLE_DATA"') {
            ret += "\n\t-Imported privileges on snowflake db already added to the role-";
        } else {
            // Create grant usage queries on database and its schemas/tables
            var grantDbQuery = `GRANT USAGE ON DATABASE ${dbName} TO ROLE ${roleName};`;
            var grantSchemaQuery = `GRANT USAGE ON ALL SCHEMAS IN DATABASE ${dbName} TO ROLE ${roleName};`;
            var grantFutureSchemaQuery = `GRANT USAGE ON FUTURE SCHEMAS IN DATABASE ${dbName} TO ROLE ${roleName};`;
            var grantFutureTableQuery = `GRANT USAGE ON FUTURE TABLES IN DATABASE ${dbName} TO ROLE ${roleName};`;

            // Execute each grant query and add it to the return value
            ret = execute_Statement(grantDbQuery, dbName, ret);
            ret = execute_Statement(grantSchemaQuery, dbName, ret);
            ret = execute_Statement(grantFutureSchemaQuery, dbName, ret);
            ret = execute_Statement(grantFutureTableQuery, dbName, ret);
        }
    }
    return ret;
    $$;

-- Grant usage on procedure and and grant usage and operate on warehouse to the role we just created
GRANT USAGE ON PROCEDURE DELINEA_DATABASE.public.grant_usage_on_all_dbs(STRING) TO ROLE DELINEA_ROLE;
GRANT USAGE, OPERATE ON WAREHOUSE DELINEA_WAREHOUSE TO ROLE DELINEA_ROLE;

-- Execute the stored procedure
USE WAREHOUSE DELINEA_WAREHOUSE;
CALL DELINEA_DATABASE.public.grant_usage_on_all_dbs('DELINEA_ROLE');