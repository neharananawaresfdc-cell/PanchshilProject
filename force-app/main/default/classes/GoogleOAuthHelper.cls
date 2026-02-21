public class GoogleOAuthHelper {
    private static final String GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token';
    private static final String SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

    public static String getAccessToken() {
        // Step 1: Load and parse the JSON file from the static resource 
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'GoogleServiceAccountKey' LIMIT 1];
        String jsonBody = sr.Body.toString();

        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

        String clientEmail = (String) jsonData.get('client_email');
        String privateKeyRaw = (String) jsonData.get('private_key');
		System.debug('clientEmail : '+clientEmail);
        System.debug('privateKeyRaw : '+privateKeyRaw);
        // Important: Ensure proper formatting of the private key
        String privateKey = privateKeyRaw.replace('\\n', '\n');
		System.debug('privateKey : '+privateKey);
        // Step 2: Create JWT
        Long now = DateTime.now().getTime() / 1000;
        Long exp = now + 3600;

        Map<String, Object> header = new Map<String, Object>{
            'alg' => 'RS256',
            'typ' => 'JWT'
        };

        Map<String, Object> claim = new Map<String, Object>{
            'iss' => clientEmail,
            'scope' => SCOPE,
            'aud' => GOOGLE_TOKEN_URL,
            'iat' => now,
            'exp' => exp
        };

        String jwtHeader = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(header))).replace('=', '');
        String jwtClaim = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(claim))).replace('=', '');
        String signatureBase = jwtHeader + '.' + jwtClaim;

        // Step 3: Sign JWT using the private key
        // Convert the PEM private key to binary
       /* Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey.replace('-----BEGIN PRIVATE KEY-----\n', '')
                                                                   .replace('-----END PRIVATE KEY-----', '')
                                                                   .replace('\n', ''));*/
        String cleanedKey = privateKey.replace('-----BEGIN PRIVATE KEY-----', '')
                              .replace('-----END PRIVATE KEY-----', '')
                              .replaceAll('\\s', ''); // removes all whitespace including \n
        System.debug('cleanedKey : '+cleanedKey);
		Blob privateKeyBlob = EncodingUtil.base64Decode(cleanedKey);
        System.debug('privateKeyBlob : '+privateKeyBlob);
        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(signatureBase), privateKeyBlob);
        String jwtSignature = EncodingUtil.base64Encode(signature).replace('=', '').replace('/', '_').replace('+', '-');
        System.debug('jwtSignature : '+jwtSignature);

        String jwt = signatureBase + '.' + jwtSignature;

		System.debug('jwt : '+jwt);
        // Step 4: Exchange JWT for Access Token
        HttpRequest req = new HttpRequest();
        req.setEndpoint(GOOGLE_TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('response : '+response);
            System.debug('response : '+response.get('access_token'));
            return (String) response.get('access_token');
        } else {
            System.debug('Error getting token: ' + res.getBody());
            return null;
        }
    }
}