# Get-MSAccessToken
## Description:
* This function is designed to retrieve an access token from Azure, using a computer certificate for authentication. It can be used in automation or scripting scenarios without the use of entering client credentials.

## Pre-Reqs:
### Create Azure application:
1. Navigate to the **Microsoft Entra admin center**.
2. Expand the **Identity** menu > Exapand **Applications** > select **App Registrations** > select the **New registration** button.
3. Enter the name for your application; for example ```My MS Graph App```.
4. For the type of supported account types, select **Accounts in any organizational directory (Any Microsoft Entra ID tenant - Multitenant)**.
5. Confirm changes by selecting the **Register** button.

### Create computer certificate and upload to Azure application:
