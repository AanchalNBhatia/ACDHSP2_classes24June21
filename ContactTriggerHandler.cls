public with sharing class ContactTriggerHandler implements ITriggerHandler
{
    public void BeforeInsert(List<SObject> newItems)
    {
        createClient((List<Contact>)newItems);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {}

    public void BeforeDelete(Map<Id, SObject> oldItems)
    {}

    public void AfterInsert(Map<Id, SObject> newItems)
    {
        updateConId((Map<Id, Contact>) newItems);
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {}

    public void AfterDelete(Map<Id, SObject> oldItems)
    {}

    public void AfterUndelete(Map<Id, SObject> oldItems)
    {}

    //Client Record will be created for every Staff and will be linked back to the Staff record.
    public static void createClient (List<Contact> listCon)
    {
        Map<Contact, Client__c> mapConClient = new Map<Contact, Client__c>();

        for (Contact con: listCon)
        {
            Client__c cl = new Client__c();
            cl.First_Name__c = con.FirstName;
            cl.Last_Name__c = con.LastName;
            cl.Client_Create_MCI__c = true;

            mapConClient.put(con, cl);
        }
        insert mapConClient.values();

        for (Contact con : listCon)
        {
            con.Client_Record__c = mapConClient.get(con).Id;
        }
    }

    //update Contact_Id in User from ACDHS Staff
    public static void updateConId (Map<Id, Contact> mapIdCon)
    {
        Set<Id> setConId = new Set<Id>();
        Map<String, Id> mapStaffNameId = new Map<String, Id>();

        for (Contact c : mapIdCon.values())
        {
            if (c.AccountId != null)
            {
                setConId.add(c.Id);
            }
        }

        List<Contact> listCon = [select Id, Name, AccountId, Account.Name from Contact where Id IN :setConId];
        for (Contact c : listCon)
        {
            if (c.Account.Name.contains('ACDHS'))
            {
                mapStaffNameId.put(c.Name, c.Id);
            }
        }

        List<User> listUser = [select Id, Name, Contact_Id__c from User where Name IN :mapStaffNameId.keySet() AND (Profile.Name = 'System Administrator' OR Profile.Name = 'Internal Portal Users')];
        for (User u : listUser)
        {
            u.Contact_Id__c = mapStaffNameId.get(u.Name);
        }
        update listUser;
    }
}