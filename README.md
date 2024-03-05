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

## Parameters:
* `$ApplicationID`:
    * Description: The Application (Client) ID of the Azure application requesting the token.
    * Mandatory Paramater: `$true`
* `$Scope`:
    * Description: The scope of the access token. Based upon the permissions of the Azure application, you would choose between the specified values. **Additional Scopes can be added**
    * Mandatory Paramater: `$true` 
    * ValidateSet: `https://vault.azure.net/.default`, `https://graph.microsoft.com/.default`. `https://api.securitycenter.microsoft.com/.default`
* `$Location`:
    * Description: The location of the certificate used for signing the JWT. If you're using the certificate stored in the **LocalMachine** path, it's important to run the script with administrator rights. If you don't, the script won't be able to read the certificate.
    * Mandatory Paramater: `$true`
* `$TenantName`:
    * Description: The name of the Azure tenant. Example: ```contoso.onmicrosoft.com```
    * Mandatory Paramater: `$true`
* `$ThumbPrint`:
    * Description: Inside the **Dynamic Param** block, the code dyanmically generates a parameter named `$Thumbprint`. Based upon the provided certificate location (`$Location`). the parameter allows you to specify the thumbprint of the certificate to use for signing the JWT.
    * Mandatory Parameter: `$true`

### Process block:
* Retrieves the specified certificate based on the provided thumbprint and location.
* Constructs a JWT including the header and payload.
* Signs the JWT using the pkey of the certificate.
* Sends a POST request (`$PostSplat`) to the Azure endpoint to obtain an access token.
* Returns the access token (`$Request.Access_Token`) obtained from the token response.

## Examples:
```
Get-MSAccessToken -ApplicationID "XXXXXXXXXXXXXXXXX" -Scope https://api.securitycenter.microsoft.com/.default -Location Cert:\CurrentUser\My -Thumbprint XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -TenantName "contoso.onmicrosoft.com"
```
