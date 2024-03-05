function Get-MSAccessToken
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$ApplicationID,
        	[Parameter(Mandatory = $true)]
		[validateset("https://vault.azure.net/.default","https://graph.microsoft.com/.default","https://api.securitycenter.microsoft.com/.default")]
        	[string]$Scope,
        	[Parameter(Mandatory = $true)]
		[validateset("Cert:\LocalMachine\My","Cert:\CurrentUser\My")]
		[string]$Location,
		[Parameter(Mandatory = $true)]
		[string]$TenantName
        
	)

    DynamicParam {
        if ($Location)
        {
            $parameterName = 'Thumbprint'
            $runtimeParameterDictionary = New-Object "System.Management.Automation.RuntimeDefinedParameterDictionary"
            
            $attributes = New-Object "System.Management.Automation.ParameterAttribute"
            $attributes.ParameterSetName = "__AllParameterSets"
            $attributes.Mandatory = $true
            $attributes.Position = 1
            
            $validator = New-Object "System.Management.Automation.ValidateSetAttribute"((Get-ChildItem -Path $Location | Select-Object -ExpandProperty Thumbprint))
        
            $dynamicParam = New-Object "System.Management.Automation.RuntimeDefinedParameter"($parameterName, [string], $attributes)
            $dynamicParam.Attributes.Add($validator)
        
            $runtimeParameterDictionary.Add($parameterName, $dynamicParam)
        
            return $runtimeParameterDictionary
        }
    }

    process
    {
        $thumbprint = $PSBoundParameters['Thumbprint']
        $selectedThumbprint = $thumbprint

        $CertPath = Get-Item -Path "$($Location)\$($ThumbPrint)"
    
	    $CertificateBase64Hash = [System.Convert]::ToBase64String($CertPath.GetCertHash())
	    
	    $StartDate = (Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()
	    $JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
	    $JWTExpiration = [math]::Round($JWTExpirationTimeSpan, 0)
	    
	    $NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
	    $NotBefore = [math]::Round($NotBeforeExpirationTimeSpan, 0)

	    $JWTHeader = @{
	    	alg = "RS256"
	    	typ = "JWT"
	    	x5t = $CertificateBase64Hash -replace '\+', '-' -replace '/', '_' -replace '='
	    }
	    
	    $JWTPayLoad = @{
	    	aud = "https://login.microsoftonline.com/$TenantName/oauth2/token"
	     	exp = $JWTExpiration
	      	iss = $ApplicationID	
	      	jti = [guid]::NewGuid()
	    	nbf = $NotBefore
	    	sub = $ApplicationID
	    }

	    $JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
	    $EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)
	    
	    $JWTPayLoadToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
	    $EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)
	    
	    $JWT = $EncodedHeader + "." + $EncodedPayload	    
	    $PrivateKey = $CertPath.PrivateKey

	    $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
	    $HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256

	    $Signature = [Convert]::ToBase64String(
	    	$PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT), $HashAlgorithm, $RSAPadding)
	    ) -replace '\+', '-' -replace '/', '_' -replace '='
	    
	    $JWT = $JWT + "." + $Signature
	    
	    $Body = @{
	    	client_id	      = $ApplicationID
	    	client_assertion      = $JWT
	    	client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
	    	scope   	      = $Scope
	    	grant_type	      = "client_credentials"
	    	
	    }

	    $Uri = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"
	    
	    $Header = @{
	    	Authorization = "Bearer $JWT"
	    }
	    
	    $PostSplat = @{
	    	ContentType = 'application/x-www-form-urlencoded'
	    	Method	    = 'POST'
	    	Body	    = $Body
	    	Uri 	    = $Uri
	    	Headers	    = $Header
	    }
	    
	    $Request = Invoke-RestMethod @PostSplat
	    $Request.Access_Token
    }
}
