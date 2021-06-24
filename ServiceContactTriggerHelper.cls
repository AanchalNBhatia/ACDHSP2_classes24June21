public with sharing class ServiceContactTriggerHelper implements ITriggerHandler
{
    public void BeforeInsert(List<SObject> newItems)
    {
        checkSP((List<Service_Contact__c>)newItems);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        checkSP((List<Service_Contact__c>)((Map<Id, Service_Contact__c>)newItems).values());
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

    //Checks if Selected SP Service and Staff records are from same Service Provider or not
    public static void checkSP (List<Service_Contact__c> listSC)
    {
        User u = [select Id, Name, ContactId from User where Id = :UserInfo.getUserId()];
        Set<Id> setSPId = new Set<Id>();
        Set<Id> setStaffId = new Set<Id>();
        Set<Id> setSPSId = new Set<Id>();
        Map<Id, List<AccountContactRelation>> mapStaffIdListSP = new Map<Id, List<AccountContactRelation>>();
        Map<Id, Id> mapSPSIdSPId = new Map<Id, Id>();

        if (u.ContactId != null)
        {
            for (AccountContactRelation acr : [select Id, AccountId, ContactId from AccountContactRelation where ContactId = :u.ContactId])
            {
                setSPId.add(acr.AccountId);
            }
        }

        for (Service_Contact__c sc : listSC)
        {
            setStaffId.add(sc.SP_Staff__c);
            setSPSId.add(sc.SP_Service__c);
        }
        for (Contact con : [Select Id, (Select Id, AccountId from AccountContactRelations) from Contact where Id IN :setStaffId])
        {
            mapStaffIdListSP.put(con.Id, con.AccountContactRelations);
        }
        for (SP_Service__c sps : [select Id, Service_Provider__c from SP_Service__c where Id IN :setSPSId])
        {
            mapSPSIdSPId.put(sps.Id, sps.Service_Provider__c);
        }

        for (Service_Contact__c sc : listSC)
        {
            if (sc.SP_Service__c != null)
            {
                if (!setSPId.contains(mapSPSIdSPId.get(sc.SP_Service__c)) && u.ContactId != null)
                {
                    sc.addError('Service Provider of selected SP Service and Logged In User is not same.');
                }
                else
                {
                    Boolean matchFound = false;
                    for (AccountContactRelation acr : mapStaffIdListSP.get(sc.SP_Staff__c))
                    {
                        if (mapSPSIdSPId.get(sc.SP_Service__c) == acr.AccountId)
                        {
                            matchFound = true;
                        }
                    }
                    if (!matchFound)
                    {
                        sc.addError('Service Provider is not same for the selected Staff and SP Service record.');
                    }
                }
            }
        }
    }
}