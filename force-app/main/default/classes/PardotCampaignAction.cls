public with sharing class PardotCampaignAction {
    public static final String NAMED_CREDENTIAL = 'APEX_Pardot_Credential';

    public class CampaignInputDto {
        @InvocableVariable(label='Campaign Name' required=true)
        public String name;
        @InvocableVariable(label = 'Business Unit Id' required=true)
        public String businessUnitId;

        public Integer id;
    }

    public class CampaignOutputDto {
        @InvocableVariable(label='Campaign Id' required=true)
        public Integer id;
    }

    public class CampaignQueryResult {
        public List<CampaignOutputDto> values;
    }

    @InvocableMethod(label='Pardot - Find Campaign By Name')
    public static List<CampaignOutputDto> findCampaignByName(List<CampaignInputDto> campaigns) {
        List<CampaignOutputDto> results = new List<CampaignOutputDto>();
        Http http = new Http();
        for(CampaignInputDto campaign : campaigns) {
            HttpRequest req = new HttpRequest();
            //first set the request headers. Important to note that the NamedCredential is taking care of the Authorization header automatically
            req.setHeader('Content-Type','application/json');
            req.setHeader('Pardot-Business-Unit-Id', campaign.businessUnitId);
            req.setEndpoint('callout:'+NAMED_CREDENTIAL + '/v5/objects/campaigns?fields=id,name');
            req.setMethod('GET');

            try {
                HttpResponse response = http.send(req);
                String responsePayload = response.getBody();
                CampaignQueryResult searchResult = (CampaignQueryResult) JSON.deserialize(responsePayload, CampaignQueryResult.class);
                if(searchResult.values != null && searchResult.values.size()>0) {
                    System.debug('Found Campaign in Pardot by name');
                    results.add(searchResult.values.get(0));
                }
            }
            catch(Exception e) {
                System.debug('There was an error submitting the Custom Redirect to Pardot');
                System.debug('Message: ' + e.getMessage() + '\n' +
                                'Cause: ' + e.getCause() + '\n' +
                                'Stack trace: ' + e.getStackTraceString());
            }
        }
        return results;
    }
}
