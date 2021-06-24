public with sharing class SPServiceTriggerHelper implements ITriggerHandler
{
    public void BeforeInsert(List<SObject> newItems)
    {
        handleConcerns((List<SP_Service__c>)newItems);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        handleConcerns((List<SP_Service__c>)((Map<Id, SP_Service__c>)newItems).values());
    }

    public void BeforeDelete(Map<Id, SObject> oldItems)
    {}

    public void AfterInsert(Map<Id, SObject> newItems)
    {}

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {}

    public void AfterDelete(Map<Id, SObject> oldItems)
    {}

    public void AfterUndelete(Map<Id, SObject> oldItems)
    {}

    public static void handleConcerns(List<SP_Service__c> newItems)
    {
        Set<String> serviceIds = new Set<String>();
        Map<String, Service__c> serviceMap;
        List<String> missingVals = new List<String>();

        for(SP_Service__c spRec : newItems){
            serviceIds.add(spRec.Service__c);
        }

        if(serviceIds != null & serviceIds.size() > 0){
            serviceMap = new Map<String, Service__c>([Select Id, Contracted_Service__c, Concerns__c from Service__c where Id in :serviceIds]);
        }

        for(SP_Service__c spRec : newItems){
            if (serviceMap.get(spRec.Service__c).Concerns__c != null)
            {
                List<String> servicePicklistValues = serviceMap.get(spRec.Service__c).Concerns__c.split(';');
                if(serviceMap.get(spRec.Service__c).Contracted_Service__c == true){
                    Boolean isExistingValMissing = false;
                    if(spRec.Concerns__c != null){
                        List<String> SPServicePicklistValues = spRec.Concerns__c.split(';');
                        for(String val : servicePicklistValues){
                            if(!SPServicePicklistValues.contains(val)){
                                isExistingValMissing = true;
                                missingVals.add(val);
                            }
                        }
                        if(isExistingValMissing == true){
                            spRec.addError('This is Contracted Service, please select missing concerns from Service record. Missng Values: '+missingVals);
                        }
                    }else{
                        spRec.addError('This is Contracted Service, please select missing concerns from Service record. Missng Values: '+servicePicklistValues);
                    }
                }else{
                    spRec.Concerns__c = serviceMap.get(spRec.Service__c).Concerns__c;
                }
            }
        }
    }
}