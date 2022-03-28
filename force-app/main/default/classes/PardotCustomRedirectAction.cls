public with sharing class PardotCustomRedirectAction {
    public static final String NAMED_CREDENTIAL = 'APEX_Pardot_Credential';
    private static final Boolean GA_ANALYTICS_CONNECTOR_ENABLED = false;

    public class CustomRedirectDto {
        @InvocableVariable(label = 'Custom Redirect name' required=true)
        public String name;
        @InvocableVariable(label = 'Target URL' required=true)
        public String destinationUrl;
        @InvocableVariable(label = 'Business Unit Id' required=true)
        public String businessUnitId;
        @InvocableVariable(label = 'Pardot Campaign Id' required=true)
        public Integer campaignId;
        // @InvocableVariable(label = 'Pardot Tracker Domain Id' required=true)
        // public Integer trackerDomainId;
        @InvocableVariable(label = 'Vanity URL Path')
        public String vanityUrlPath;
        @InvocableVariable(label = 'GA Campaign Sources')
        public String gaSource;
        @InvocableVariable(label = 'GA Campaign Medium')
        public String gaMedium;
        @InvocableVariable(label = 'GA Campaign Keyword')
        public String gaTerm;
        @InvocableVariable(label = 'GA Campaign Content')
        public String gaContent;
        @InvocableVariable(label = 'GA Campaign Id')
        public String gaCampaign;
    }

    public class PardotCustomRedirect {
        public String name;
        public String destinationUrl;
        public Integer campaignId;
        // public Integer trackerDomainId;
        public String vanityUrlPath;
        public String gaSource;
        public String gaMedium;
        public String gaTerm;
        public String gaContent;
        public String gaCampaign;

        public String trackedUrl;
    }

    @InvocableMethod(label='Pardot - Create Custom Redirect')
    public static void createCustomRedirect(List<CustomRedirectDto> customRedirects) {
        Http http = new Http();
        for(CustomRedirectDto customRedirect : customRedirects) {
            List<String> utmSources = new List<String>();
            if(customRedirect.gaSource != null)
                utmSources = customRedirect.gaSource.split(',');
            if(utmSources.isEmpty()) utmSources.add('');

            for(String utmSource : utmSources) {
                System.debug('Building URL with utmSource: ' + utmSource);
                PardotCustomRedirect redirectRequest = buildRequest(customRedirect, utmSource);

                HttpRequest req = new HttpRequest();
                //first set the request headers. Important to note that the NamedCredential is taking care of the Authorization header automatically
                req.setHeader('Content-Type','application/json');
                req.setHeader('Pardot-Business-Unit-Id', customRedirect.businessUnitId);
                req.setEndpoint('callout:'+ NAMED_CREDENTIAL + '/v5/objects/custom-redirects?fields=id,trackedUrl');
                req.setMethod('POST');

                //clear it out, as if it is included in the body Pardot will yell at us
                String body = JSON.serialize(redirectRequest, true);
                req.setBody(body);
                System.debug('Submitting JSON payload: ' + body);
                try {
                    HttpResponse response = http.send(req);
                    String responsePayload = response.getBody();
                    PardotCustomRedirect newCustomRedirect = (PardotCustomRedirect) JSON.deserialize(responsePayload, PardotCustomRedirect.class);
                    System.debug('New Custom Redirect has been created, Pardots Tracked URL is: ' + newCustomRedirect.trackedUrl);
                }
                catch(Exception e) {
                    System.debug('There was an error submitting the Custom Redirect to Pardot');
                    System.debug(   'Message: ' + e.getMessage() + '\n' +
                                    'Cause: ' + e.getCause() + '\n' +
                                    'Stack trace: ' + e.getStackTraceString());
                }
            }
        }
    }

    private static PardotCustomRedirect buildRequest(CustomRedirectDto customRedirect, String utmSource) {
        PardotCustomRedirect newRedirect = new PardotCustomRedirect();
        newRedirect.name = customRedirect.name;
        newRedirect.campaignId = customRedirect.campaignId;
        newRedirect.vanityUrlPath = customRedirect.vanityUrlPath;

        if(GA_ANALYTICS_CONNECTOR_ENABLED) {
            //If the connector is enabled, we can pass this straight to the Custom Redirect in Pardot
            newRedirect.gaCampaign = customRedirect.gaCampaign;
            newRedirect.gaContent = customRedirect.gaContent;
            newRedirect.gaMedium = customRedirect.gaMedium;
            newRedirect.gaSource = utmSource;
            newRedirect.gaTerm = customRedirect.gaTerm;
            newRedirect.destinationUrl = customRedirect.destinationUrl;
        }
        else {
            //If the connector is not enabled, we can adjust the destinationURL to include the UTM params
            //For production code, you may want to escape the values in the event Marketing gets too creative
            List<String> utmComponents = new List<String>();
            if(String.isNotEmpty(customRedirect.gaMedium)) utmComponents.add('utm_medium='+ customRedirect.gaMedium);
            if(String.isNotEmpty(customRedirect.gaTerm)) utmComponents.add('utm_term='+ customRedirect.gaTerm);
            if(String.isNotEmpty(customRedirect.gaContent)) utmComponents.add('utm_content='+ customRedirect.gaContent);
            if(String.isNotEmpty(customRedirect.gaCampaign)) utmComponents.add('utm_campaign='+ customRedirect.gaCampaign);
            if(String.isNotEmpty(customRedirect.gaSource)) utmComponents.add('utm_source='+ customRedirect.gaSource);

        
            String fullUrl = customRedirect.destinationUrl;
            if(!utmComponents.isEmpty()) 
                fullUrl = customRedirect.destinationUrl + (customRedirect.destinationUrl.contains('?') ? '&' : '?' ) + String.join(utmComponents,'&');
            
            System.debug('built URL: ' + fullUrl);
            newRedirect.destinationUrl = fullUrl;
        }
        return newRedirect;
    }
}
