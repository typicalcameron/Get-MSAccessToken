# Get-MSAccessToken
## Description:
* This function is designed to retrieve an access token from Azure, using a computer certificate for authentication. It can be used in automation or scripting scenarios without the use of entering client credentials.

## Pre-Reqs:
### Create Azure application:
1. Navigate to the **Microsoft Entra admin center**.
2. Expand the **Identity** menu > Exapand **Applications** > Select **App Registrations** > Select **New registration**.
3. Enter the name for your application; for example `My MS Graph App`.
4. For the type of supported account types, select **Accounts in any organizational directory (Any Microsoft Entra ID tenant - Multitenant)**.
5. Confirm changes by selecting the **Register** button.
6. Note the **application (client) ID**.

### Azure application permissions:
1. Within your registered application, navigate to the **API permissions** tab.
2. Click on **Add a permission** > Select **Microsoft Graph (or another app of your choosing)**.
3. Choose the appropriate permissions your application needs to access Microsoft Graph; such as `User.Read` or `Mail.Read`.
4. Click on **Grant admin consent for [your tenant]** if you have the necessary permissions.

### Create user/computer certificate:
#### Just to note, these are steps for requesting a certificate through your CA server.
1. In the **MMC console** > **File** > **Add/Remove Snap-in**.
2. Select **Certificates** from the list of available snap-ins > Click **Add**.
3. Choose **Computer Account (or "My User Account")** > Click **Next**.
4. If **Computer Account**, Select **Local Computer** > Click **Finish**.
5. Click **OK** to add the snap-in.
6. Under **Personal > Certificates**, right-click **All Tasks** > Select **Request New Certificate...**
7. Certificate Properties Requirements:
   * a. Alternative name > DNS = `[your tenant name]`
   * b. Extended Key usage (application policies): `Server Authentication`, `Client Authentication`
   * c. Key Options/algorithem: `2048` or `sha256RSA`
   * d. Key Type: `Signature`
8. Once the certificate is created, export it as **Base-64 encoded X.509 (.CER)**.

### Upload certificate to Azure Application:
1. Within your registered application, navigate to **Certificates & Secrets** tab.
2. Under the** Certificates** tab > Click **Upload Certificate**.
3. Select the exported certificate from your local machine.
4. Give a **description** if needed.
5. Click **Add**.

## Parameters:
* `$ApplicationID`:
    * Description: The Application (Client) ID of the Azure application requesting the token.
    * Mandatory Paramater: `$true`
* `$Scope`:
    * Description: The scope of the access token. Based upon the permissions of the Azure application, you would choose between the specified values. **Additional Scopes can be added.**
    * Mandatory Paramater: `$true` 
    * ValidateSet: `https://vault.azure.net/.default`, `https://graph.microsoft.com/.default`. `https://api.securitycenter.microsoft.com/.default`
* `$Location`:
    * Description: The location of the certificate used for signing the JWT. If you're using the certificate stored in the **LocalMachine** path, it's important to run the script with administrator rights. If you don't, the script won't be able to read the certificate.
    * Mandatory Paramater: `$true`
* `$TenantName`:
    * Description: The name of the Azure tenant. Example: `contoso.onmicrosoft.com`
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

## Example(s):
### Code:
```powershell
Get-MSAccessToken -ApplicationID "XXXXXXXXXXXXXXXXX" -Scope "https://api.securitycenter.microsoft.com/.default" -Location "Cert:\LocalMachine\My" -Thumbprint "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -TenantName "contoso.onmicrosoft.com"
```
### Output:
`qharerkhvjzkmcbytbmgbldppobigtvmhfsbgorurklkmxzumigltjtebzweoofmzkfdcntrmkpperzggcphrxghtojovsxxyveqwztbhldnkoqgavjhyotozqgdvtygiplzsptdecpuynsuljmktyjhvailizdfgbeurcqgvmqffuhuyecadilcwkjvpbpfebvpvfovhqfpsyeyhsgwiwubksjloktgcegikplxzxedeuqupiedtnixvtlgggpccxaeuntsfscljwppduhvlkvhmxvscblrosujqdhrsowvlzhskrkoipmyadpaxlmmhsdzajlhjjjanqitimshbbylgadimhtbsxzjsszmtidkptcxvxfwknjrykfexhwgudsprliesfpjbhpucdjvpdwqoboexjteyynpfjfytlxndvrtjqsktysureuaghayohwzfkdqxvfwjvbwrhsbasjhjuohovmrsqehjzyklcgqipqgmmrerixcatjtlfmzehnimumkgbjkzufffsomyhvxalbbelubumeypbphtrxrpdcndcusuxxkii`

### Code:
```powershell
$AT = Get-MSAccessToken -ApplicationID "XXXXXXXXXXXXXXXXX" -Scope https://api.securitycenter.microsoft.com/.default -Location Cert:\CurrentUser\My -Thumbprint XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -TenantName "contoso.onmicrosoft.com"
Connect-MgGraph -AccessToken $AT
```
