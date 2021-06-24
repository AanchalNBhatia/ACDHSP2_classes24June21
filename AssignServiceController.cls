/**
 * Description - This class is controller class for Service Assignment Quick Action component (ServiceSelectedContainerAura) on Referral Level.
 * Developer Name - Ankit Chowhan
 * Created Date - 06/03/2021
 * Last Modified Date - 06/22/2021
 */
public with sharing class AssignServiceController {

    /**
     * Description - This method pulls all the related members and their relation in context to current Referral
     */
    @AuraEnabled(cacheable=true)
    public static List<ClientReferralWrapper> getMembers(String referralId){
        List<String> primaryContactList = new List<String>();
        Map<String, String> clientRelationMap = new Map<String, String>();
        List<ClientReferralWrapper> responseList = new List<ClientReferralWrapper>();

        String clientId = [Select Id, Primary_Client_Id__c from Referral__c where Id =: referralId].Primary_Client_Id__c;

        System.debug('Client ID # '+clientId);

        List<Client_Referral__c> crList = [select Id, Client__c, Client_Name__c, Client__r.Date_of_Birth__c, Client__r.MCI_ID__c from Client_Referral__c where Referral__c =: referralId order by Client_Name__c];

        if(crList != null && crList.size() > 0){
            for(Client_Referral__c cr: crList){
                primaryContactList.add(cr.Client__c);
            }
        }

        List<Relationship__c> relationList = [select Id, Type__c, Relation__c, Primary_Member__c, Secondary_Member__c from Relationship__c where Secondary_Member__c =: clientId];

        if(relationList !=null && relationList.size() > 0){
            for(Relationship__c relation: relationList){
                if(!clientRelationMap.containsKey(relation.Primary_Member__c)){
                    clientRelationMap.put(relation.Primary_Member__c, relation.Relation__c);
                }
            }
        }

        System.debug('clientRelationMap # '+clientRelationMap);

        for(Client_Referral__c cr: crList){
            if(cr.Client__r.MCI_ID__c != null){
                responseList.add(new ClientReferralWrapper((String)cr.Id, (String)cr.Client__c, cr.Client_Name__c, '/'+cr.Client__c, cr.Client__r.Date_of_Birth__c, cr.Client__r.MCI_ID__c, String.isNotBlank(clientRelationMap.get(cr.Client__c))?clientRelationMap.get(cr.Client__c):'Self', 'Select', 'neutral', false, true));
            }else{
                responseList.add(new ClientReferralWrapper((String)cr.Id, (String)cr.Client__c, cr.Client_Name__c, '/'+cr.Client__c, cr.Client__r.Date_of_Birth__c, cr.Client__r.MCI_ID__c, String.isNotBlank(clientRelationMap.get(cr.Client__c))?clientRelationMap.get(cr.Client__c):'Self', 'Select', 'neutral', true, false));
            }
        }

        System.debug('Resp List # '+responseList);

        return responseList;
    }

    /**
     * Description - This method sends the current status of the Refferral.
     */
    @AuraEnabled
    public static string getReferralStatus(String referralId){
        return [select Id, Referral_Status__c from Referral__c where Id =: referralId].Referral_Status__c;
    }

    /**
     * Description - This method saves the Client Service record.
     */
    @AuraEnabled
    public static String saveCSRecord(String referralId, Client_Service__c csRecord){
        System.debug('csRecord # '+csRecord);
        insert csRecord;
        System.debug('cs.Id '+(String)csRecord.Id);
        return (String)csRecord.Id;
    }

    /**
     * Description - This method saves the Junction Service child records for the selected clients.
     */
    @AuraEnabled
    public static void saveJunctionServiceRecords(String referralId, List<Junction_Service__c> jsList){
        if(jsList!=null && jsList.size()>0){
            insert jsList;
            update new Referral__c(Id = referralId, Referral_Status__c='Services Assigned', Bypass_Validation__c = true);
        }
    }

    /**
     * Description - This method pulls all the services that can be provided by the Staff. For System Admin and Super User it pulls all the services related to ACDHS or Provided accordingly.
     */
    @AuraEnabled(cacheable=true)
    public static List<ServiceWrapper> getAvailableServices(String referralId){
        List<ServiceWrapper> respList = new List<ServiceWrapper>();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        System.debug('Profile Name # '+profileName);
        String referralOwner = [select Id, OwnerId from Referral__c where Id =: referralId limit 1].OwnerId;
        String referralProvider = [select Id, Contact.AccountId from User where Id =: referralOwner limit 1].Contact.AccountId;

        if(profileName == 'System Administrator' || profileName == 'Internal Super User'){
            if(String.isBlank(referralProvider)){
                referralProvider = System.label.ACDHS;
            }
            System.debug('referralProvider # '+referralProvider);
            List<SP_Service__c> spList = [select Id, Service__r.Name, Service_Provider__r.Type, Service_Provider__r.Name from SP_Service__c where Service_Provider__c =: referralProvider];
            
            System.debug('spList # '+spList);
            
            if(spList!=null && spList.size()>0){
                for(SP_Service__c spRec: spList){
                    respList.add(new ServiceWrapper(spRec.Id, spRec.Service__r.Name, spRec.Service_Provider__r.Name, spRec.Service_Provider__r.Type));
                }
            }
        }else{
            String contactId;
            String uId = userinfo.getUserId();
            if(profileName == 'Internal Portal Users'){
                contactId = [select Id, Contact_Id__c from User where id =:uId  limit 1].Contact_Id__c;
            }else if(profileName == 'Provider Users'){
                contactId = [select Id, ContactId from User where id =: uId limit 1].ContactId;
            }
            System.debug('contactId # '+contactId);
            if(String.isNotBlank(contactId)){
                List<Service_Contact__c> scList = [select Id, SP_Service__c, Service__c, SP_Service__r.Service__r.Name, SP_Service__r.Service_Provider__r.Type, SP_Service__r.Service_Provider__r.Name from Service_Contact__c where SP_Staff__c = :contactId];

                for(Service_Contact__c scRec: scList){
                    respList.add(new ServiceWrapper(scRec.SP_Service__c, scRec.SP_Service__r.Service__r.Name, scRec.SP_Service__r.Service_Provider__r.Name, scRec.SP_Service__r.Service_Provider__r.Type));
                }
            }
        }
        System.debug('respList # '+respList);
        return respList;
    }

    class ClientReferralWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String clientId;
        @AuraEnabled public String clientName;
        @AuraEnabled public String clientURL;
        @AuraEnabled public Date clientDOB;
        @AuraEnabled public String clientMCIId;
        @AuraEnabled public String relationship;
        @AuraEnabled public String selectToggle;
        @AuraEnabled public String selectButtonVariant;
        @AuraEnabled public Boolean isSelectDisabled;
        @AuraEnabled public Boolean isGetMCIDisabled;

        ClientReferralWrapper(String Id, String clientId, String clientName, String clientURL, Date clientDOB, String clientMCIId, String relationship, String selectToggle, String selectButtonVariant, Boolean isSelectDisabled, Boolean isGetMCIDisabled){
            this.Id = Id;
            this.clientId = clientId;
            this.clientName = clientName;
            this.clientURL = clientURL;
            this.clientDOB = clientDOB;
            this.clientMCIId = clientMCIId;
            this.relationship = relationship;
            this.selectToggle = selectToggle;
            this.selectButtonVariant = selectButtonVariant;
            this.isSelectDisabled = isSelectDisabled;
            this.isGetMCIDisabled = isGetMCIDisabled;
        }
    }

    class ServiceWrapper{
        @AuraEnabled public String SPServiceId;
        @AuraEnabled public String serviceName;
        @AuraEnabled public String providerName;
        @AuraEnabled public String providerType;

        ServiceWrapper(String SPServiceId, String serviceName, String providerName, String providerType){
            this.SPServiceId = SPServiceId;
            this.serviceName = serviceName;
            this.providerName = providerName;
            this.providerType = providerType;
        }
    }
}