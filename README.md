# TrailblazerDX 22 - Build Powerful Marketing Integrations

## Description
This code sample was used during a TrailblazerDX 2022 Presentation to demonstrate how the Pardot V5 API can be leveraged from within Salesforce.

## Setting it up
**Requirements**: You will need a Salesforce Org which has Pardot provisioned and set up, including Connected Campaigns.

### [Prepare your Salesforce Environment](https://thespotforpardot.com/2021/02/02/pardot-api-and-getting-ready-with-salesforce-sso-users-part-3a-connecting-to-pardot-api-from-apex/)
1. Create an Integration User (if required)
2. Create Salesforce Self-Signed Certificate
3. Create a Connected App, allowing our User to be pre-authorized
4. Create Named Credential with name `APEX_Pardot_Credential` which connects to your Pardot instance

### Deploy the Project
1. Setup your environment
    - [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)

1. Authorize your Salesforce org and provide it with a nickname (**myorgNickname** in the commands below)
    ```
    # Production: likely the command that will work for you
    sfdx force:auth:web:login -s -a myorgNickname

    # Sandbox: if you are using a sandbox, use this:
    sfdx force:auth:web:login -s -a myorgNickname -r https://test.salesforce.com

    # Custom Login URL: if you want to specify a company specific login URL, use this command
    sfdx force:auth:web:login -s -a myorgNickname -r https://mycompanyloginurl.my.salesforce.com
    ```

1. Run this command in a terminal to deploy the APEX Classes & Flow
    ```
    # Production: Simple Command, hope it works!
    sfdx force:source:deploy --manifest package.xml -u myorgNickname
    ```
    If you have failing APEX tests, OR if you have hundreds of tests, you can limit the scope of the testing to 1 class that passes.
    ```
    # Production: Command above failed due to APEX Tests
    # (replace "NameOfAnyTestThatPassesHere" with name of a passing test class)
    sfdx force:source:deploy --manifest package.xml --testlevel RunSpecifiedTests -r NameOfAnyTestThatPassesHere -u myorgNickname

    # Sandbox: In a sandbox, we don't need tests to deploy
    sfdx force:source:deploy --manifest package.xml -u myorgNickname
    ```


## Project Information

**APEX Classes**
- PardotCampaignAction - Provides Flow Action to retrieve Pardot Campaign information based on Campaign Name
- PardotCustomRedirectAction - Provides Flow Action to create a Pardot Custom Redirect

**Flows**
- Custom Redirect App - Provides an example of how to integrate the 2 Pardot-based actions into a Screen Flow