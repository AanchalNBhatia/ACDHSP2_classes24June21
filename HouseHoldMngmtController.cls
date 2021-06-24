public with sharing class HouseHoldMngmtController {
    @AuraEnabled
    public static RelationRuleWrapper getRelRuleWrapper(){
        List<Relation_Rule_Engine__mdt> relEngine = [SELECT Id, DeveloperName, Label, Possible_Values__c FROM Relation_Rule_Engine__mdt];
        Set<String> genderSet = new Set<String>();
        Set<String> categorySet = new Set<String>();
        Map<String, String> genCatToValuesMap = new Map<String, String>();

        for(Relation_Rule_Engine__mdt relItr : relEngine){
            String[] labelString= relItr.Label.split('_');
            genderSet.add(labelString[0]);
            categorySet.add(labelString[1]);
            if(!genCatToValuesMap.containsKey(relItr.Label)){
                genCatToValuesMap.put(relItr.Label, relItr.Possible_Values__c);
            }
        }

        RelationRuleWrapper wrapObj = new RelationRuleWrapper();
        wrapObj.uniqueGenders = genderSet;
        System.debug('wrapObj.uniqueGenders....'+wrapObj.uniqueGenders);
        wrapObj.uniqueCategories = categorySet;
        System.debug('wrapObj.uniqueCategories....'+wrapObj.uniqueCategories);
        wrapObj.genCatToTypeValues = genCatToValuesMap;
        System.debug('wrapObj.genCatToTypeValues....'+wrapObj.genCatToTypeValues);
        System.debug('wrapObj....'+wrapObj);
        return wrapObj;
    }
    @AuraEnabled(cacheable=true)
    public static List<HouseholdDataWrapper> getExistingHouseholds(String clientId, string accId){
        List<HouseholdDataWrapper> wrapListToRet = new List<HouseholdDataWrapper>();
        Set<Id> memIdSet = new Set<Id>();
        List<Relationship__c> allHHRelations = [SELECT Id, Secondary_Member__c,Primary_Member__c, Primary_Member__r.First_Name__c, Primary_Member__r.Last_Name__c, toLabel(Primary_Member__r.Legal_Sex__c), Relation__c, Type__c FROM Relationship__c WHERE Secondary_Member__c=: clientId];
        if(allHHRelations != null && allHHRelations.size()>0){
            for(Relationship__c relItr : allHHRelations){
                memIdSet.add(relItr.Primary_Member__c);
            }
        }
        System.debug('memIdSet....'+memIdSet);
        List<Account_Client__c> accClientList = new List<Account_Client__c>();
        if(memIdSet!= null && memIdSet.size()>0 && accId != ''){
            accClientList = [SELECT Id, Client__c, Account__c, Primary__c FROM Account_Client__c WHERE Client__c IN:memIdSet AND Account__c =:accId];
        }
        System.debug('accClientList....'+accClientList);
        Map<Id, Boolean> clientToPrimaryMap = new Map<Id, Boolean>();
        if(accClientList != null && accClientList.size()>0){
            for(Account_Client__c accClientItr : accClientList){
                if(!clientToPrimaryMap.containsKey(accClientItr.Client__c)){
                    clientToPrimaryMap.put(accClientItr.Client__c, accClientItr.Primary__c);
                }
            }
        }
        System.debug('clientToPrimaryMap....'+clientToPrimaryMap);
        if(allHHRelations != null && allHHRelations.size()>0){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName'+profileName);
            for(Relationship__c relItr : allHHRelations){
                HouseholdDataWrapper wrapObj = new HouseholdDataWrapper();
                if(profileName == 'System Administrator' || profileName == 'Internal Super User'){
                    wrapObj.url ='/' + relItr.Primary_Member__c;
                }
                else{
                    wrapObj.url = System.Label.Portal_URL+'/client/' + relItr.Primary_Member__c;
                } 
                // wrapObj.url = System.Label.Portal_URL+'/client/' + relItr.Primary_Member__c;
                wrapObj.name = relItr.Primary_Member__r.First_Name__c + ' '+ relItr.Primary_Member__r.Last_Name__c;
                wrapObj.relation = relItr.Relation__c;
                wrapObj.category = relItr.Type__c;
                wrapObj.gender = relItr.Primary_Member__r.Legal_Sex__c;
                wrapObj.priConId = relItr.Primary_Member__c;
                wrapObj.secConId = relItr.Secondary_Member__c;
                wrapObj.relId = relItr.Id;
                wrapObj.isSaved = true;
                if(clientToPrimaryMap != null && clientToPrimaryMap.containsKey(relItr.Primary_Member__c)){
                    wrapObj.isDirect = clientToPrimaryMap.get(relItr.Primary_Member__c);
                }
                else{
                    wrapObj.isDirect = false;
                }
                System.debug('wrapObj....'+wrapObj);
                wrapListToRet.add(wrapObj);
            }
        }
        return wrapListToRet;
    }
    @AuraEnabled
    public static HouseHoldAccountWrapper getHHAcc(String clientId, Boolean isDepMember){
        String hhrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account_Client__c> accClientList = [SELECT Id, Client__c,Account__c, Account__r.Name FROM Account_Client__c WHERE Client__c =: clientId AND Primary__c= true AND Account__r.RecordTypeId =:hhrecordTypeId LIMIT 1];
        HouseHoldAccountWrapper hhaccwrapObj = new HouseHoldAccountWrapper();
        if(accClientList != null && accClientList.size()>0 && accClientList[0] != null){
            hhaccwrapObj.accountId = accClientList[0].Account__c;
            hhaccwrapObj.accountName= accClientList[0].Account__r.Name;
        }
        else{
            //create HH account & client account junction
            Client__c clientRecord = [SELECT Id, Last_Name__c FROM Client__c WHERE Id =: clientId LIMIT 1];
            if(!isDepMember && clientRecord != null && clientRecord.Last_Name__c != ''){
                Account hhAccount = new Account();
                hhAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
                hhAccount.Name = clientRecord.Last_Name__c + ' Household';
                insert hhAccount;

                Account_Client__c accClientJunc = new Account_Client__c();
                accClientJunc.client__c = clientId;
                accClientJunc.Account__c = hhAccount.Id;
                accClientJunc.Primary__c= true;
                insert accClientJunc;

                hhaccwrapObj.accountId = hhAccount.Id;
                hhaccwrapObj.accountName= clientRecord.Last_Name__c;
            }
        }
        System.debug('hhaccwrapObj....'+hhaccwrapObj);
        return hhaccwrapObj;
    }
    
    
    public class RelationRuleWrapper{
        @AuraEnabled
        public Set<String> uniqueGenders{get;set;}
        @AuraEnabled
        public Set<String> uniqueCategories{get;set;}
        @AuraEnabled
        public Map<String, String> genCatToTypeValues{get;set;}
    } 
    public class HouseholdDataWrapper{
        @AuraEnabled
        public String url {get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String relation{get;set;}
        @AuraEnabled
        public String gender{get;set;}
        @AuraEnabled
        public String priConId{get;set;}
        @AuraEnabled
        public String secConId{get;set;}
        @AuraEnabled
        public String relId{get;set;}
        @AuraEnabled
        public String category{get;set;}
        @AuraEnabled
        public Boolean isSaved{get;set;}
        @AuraEnabled
        public Boolean isDirect{get;set;}
    }
    public class HouseHoldAccountWrapper{
        @AuraEnabled
        public String accountName{get;set;}
        @AuraEnabled
        public String accountId{get;set;}
    }
}