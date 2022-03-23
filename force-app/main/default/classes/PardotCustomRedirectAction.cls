public with sharing class PardotCustomRedirectAction {
    public static final String NAMED_CREDENTIAL = 'APEX_Pardot_Credential';

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
        @InvocableVariable(label = 'GA Campaign Source')
        public String gaSource;
        @InvocableVariable(label = 'GA Campaign Medium')
        public String gaMedium;
        @InvocableVariable(label = 'GA Campaign Keyword')
        public String gaTerm;
        @InvocableVariable(label = 'GA Campaign Content')
        public String gaContent;
        @InvocableVariable(label = 'GA Campaign Id')
        public String gaCampaign;

        public String trackedUrl;
    }

    @InvocableMethod(label='Pardot - Create Custom Redirect')
    public static void createCustomRedirect(List<CustomRedirectDto> customRedirects) {
        Http http = new Http();
        for(CustomRedirectDto customRedirect : customRedirects) {
            HttpRequest req = new HttpRequest();
            //first set the request headers. Important to note that the NamedCredential is taking care of the Authorization header automatically
            req.setHeader('Content-Type','application/json');
            req.setHeader('Pardot-Business-Unit-Id', customRedirect.businessUnitId);
            req.setEndpoint('callout:'+NAMED_CREDENTIAL + '/v5/objects/custom-redirects?fields=id,trackedUrl');
            req.setMethod('POST');

            String body = JSON.serialize(customRedirect, true);
            System.debug('Submitting JSON payload: ' + body);
            try {
                HttpResponse response = http.send(req);
                String responsePayload = response.getBody();
                CustomRedirectDto newCustomRedirect = (CustomRedirectDto) JSON.deserialize(responsePayload, CustomRedirectDto.class);
                System.debug('New Custom Redirect has been created, Pardots Tracked URL is: ' + newCustomRedirect.trackedUrl);
            }
            catch(Exception e) {
                System.debug('There was an error submitting the Custom Redirect to Pardot');
                System.debug('Message: ' + e.getMessage() + '\n' +
                                'Cause: ' + e.getCause() + '\n' +
                                'Stack trace: ' + e.getStackTraceString());
            }
        }
    }
}
