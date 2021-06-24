public with sharing class MciCalloutHelper 
{
    public String accessToken;
    //public String callOut { get; set; }
    //public String sub { get; set; }
    public static String endPoint;
    public static String tokenEndPoint;
    public static String authProvider;
    public static List<String> authList = new List<String>();

    /* Method to get token from MCI Authentication API */
    public static void getDetails (String apiType, String authType)
    {
        String authLabel;
        List<MCI_API__mdt> mciMetadataList = [SELECT Id, Label, Endpoint__c, Auth_Providers__c FROM MCI_API__mdt];
        
        for (MCI_API__mdt mdt : [SELECT Id, Label, Endpoint__c, Auth_Providers__c FROM MCI_API__mdt])
        {
            if (mdt.label == apiType) endPoint = mdt.Endpoint__c;
            
            if (mdt.label == 'token') tokenEndPoint = mdt.Endpoint__c;
            else if (mdt.label == authType) authLabel = mdt.Auth_Providers__c;
        }

        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        authProvider = [select Id, DeveloperName from AuthProvider where DeveloperName = :authLabel limit 1].Id;
    }

    public static String getAccessToken (String authProvider, String tokenURL)
    {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String url = tokenURL;

        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer '+ Auth.AuthToken.getAccessToken(authProvider, 'Open ID Connect'));
        HTTPResponse resp = http.send(req);
        
        return Auth.AuthToken.getAccessToken(authProvider, 'Open ID Connect');
    }

    public static String getAuthType ()
    {
        String authType;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        
        if (profileName == 'System Administrator' || profileName == 'Internal Super User') authType = 'Internal';
        else if (profileName == 'Internal Portal User' || profileName == 'Internal Read Only' || profileName == 'Provider Users' || profileName == 'Provider Read Only') authType = 'External';

        return authType;
    }

    @AuraEnabled
    public static String searchClient (String client) 
    {
        system.debug('#### client: ' + client);
        getDetails('Clearance', getAuthType());

        String token = getAccessToken(authProvider, tokenEndPoint);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        System.debug('Token # '+token);
        req.setHeader('Authorization','Bearer '+ token);
        req.setBody(client);
        
        HttpResponse res = http.send(req);
        system.debug('#### status: ' + res.getStatusCode());
        system.debug('#### resp: ' + res.getBody());

        String resBody = String.valueOf(res.getStatusCode()) + '####' + res.getBody();
        return resBody;
    }

    @AuraEnabled
    public static String insertNewClient (String client)
    {
        system.debug('#### client: ' + client);
        getDetails('NewClient', getAuthType());

        String token = getAccessToken(authProvider, tokenEndPoint);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization','Bearer '+ token);
        req.setBody(client);
        HttpResponse res = http.send(req);
        system.debug('#### status: ' + res.getStatusCode());
        system.debug('#### resp: ' + res.getBody());

        String resBody = String.valueOf(res.getStatusCode()) + '####' + res.getBody();
        return resBody;
    }

    @AuraEnabled
    public static String updateClient (String client)
    {
        String resBody = calloutToUpdateClient(client);
        return resBody;
    }

    @future(callout=true)
    public static void updateClientAuto (String client)
    {
        calloutToUpdateClient(client);
    }

    public static String calloutToUpdateClient (String client)
    {
        system.debug('#### client: ' + client);
        getDetails('UpdateClient', getAuthType());

        String token = getAccessToken(authProvider, tokenEndPoint);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization','Bearer '+ token);
        req.setBody(client);
        HttpResponse res = http.send(req);
        system.debug('#### status: ' + res.getStatusCode());
        system.debug('#### resp: ' + res.getBody());

        String resBody = String.valueOf(res.getStatusCode()) + '####' + res.getBody();
        return resBody;   
    }
}