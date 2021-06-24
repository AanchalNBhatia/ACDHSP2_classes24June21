public with sharing class ConfigClientShareBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    public Integer recordsProcessed = 0;

    public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator('select Id, Name, Client__c, Referral__c, Referral__r.OwnerId, Referral__r.Referral_Status__c, Referral__r.InActive__c, Referral__r.Confidential__c from Client_Referral__c where Referral__r.Referral_status__c != \'Not Accepted\' AND Referral__r.Referral_status__c != null AND Referral__r.InActive__c = false AND Referral__r.Confidential__c = false LIMIT 50000');
    }

    public void execute (Database.BatchableContext bc, List<Client_Referral__c> scope)
    {
        List<Client__Share> listClientShare = new List<Client__Share>();
        Set<Id> setRefId = new Set<Id>();
        Set<Id> setClientId = new Set<Id>();
        Map<Id, Id> mapRefIdGrpId = new Map<Id, Id>();
        Set<Id> setUserId = new Set<Id>();
        Map<Id, Id> mapUserIdAccId = new Map<Id, Id>();

        for (Client_Referral__c cr : scope)
        {
            if (!cr.Referral__r.Confidential__c) //Not Confidential
            {
                if (String.valueOf(cr.Referral__r.OwnerId).startsWithIgnoreCase('00G'))
                {
                    system.debug('#### Owner is Queue');
                    GroupMember gm = [Select UserOrGroupId From GroupMember where GroupId = :cr.Referral__r.OwnerId LIMIT 1]; mapRefIdGrpId.put(cr.Referral__c, gm.UserOrGroupId);
                }
                else
                {
                    setUserId.add(cr.Referral__r.OwnerId);
                }
            }
        }
        system.debug('#### setUserId: ' + setUserId);
        system.debug('#### mapRefIdGrpId: ' + mapRefIdGrpId);

        for (User u : [select Id, Name, ContactId, IsActive from User where Id IN :setUserId AND ContactId = null AND IsActive = true])
        {
            mapUserIdAccId.put(u.Id, Label.ACDHS);
        }
        for (User u : [select Id, Name, ContactId, Contact.AccountId from User where Id IN :setUserId AND ContactId != null AND IsActive = true]) { mapUserIdAccId.put(u.Id, u.Contact.AccountId); }
        system.debug('#### mapUserIdAccId: ' + mapUserIdAccId);

        Map<Id, Id> mapAccIdGrpId = new Map<Id, Id>();

        for (Account acc : [select Id, Public_Group_ID__c from Account where Id IN :mapUserIdAccId.values()]) { mapAccIdGrpId.put(acc.Id, acc.Public_Group_ID__c); }
        system.debug('#### mapAccIdGrpId: ' + mapAccIdGrpId);

        for (Client_Referral__c cr : scope)
        {
            if (!cr.Referral__r.Confidential__c)
            {
                Client__Share clientShare = new Client__Share();
                clientShare.ParentId = cr.Client__c;
                clientShare.UserOrGroupId = (String.valueOf(cr.Referral__r.OwnerId).startsWithIgnoreCase('00G')) ? (mapRefIdGrpId.get(cr.Referral__c)) : (mapAccIdGrpId.get(mapUserIdAccId.get(cr.Referral__r.OwnerId)));
                clientShare.AccessLevel = 'edit';
                clientShare.RowCause = Schema.Client__Share.RowCause.Manual;
                if (clientShare.UserOrGroupId == null) system.debug('#### client:Share: ' + clientShare);
                listClientShare.add(clientShare);
            }
        }

        if (listClientShare != null && listClientShare.size() > 0)
        {
            Set<Client__Share> setClientShare = new Set<Client__Share>(listClientShare);
            List<Client__Share> listNewClientShare = new List<Client__Share>(setClientShare);
            recordsProcessed = listNewClientShare.size();
            Database.SaveResult[] clientShareInsertResult = Database.insert(listNewClientShare, false);
            //insert listNewClientShare;
        }
    }

    public void finish (Database.BatchableContext bc)
    {
        system.debug('#### records processed in ConfigClientShareBatch: ' + recordsProcessed);
        if (!Test.isRunningTest()) { ConfigClientShareBatch m = new ConfigClientShareBatch(); System.scheduleBatch(m ,'Client Share Job', 5, 200); }

        /* To Run=>
        ConfigClientShareBatch m = new ConfigClientShareBatch();
        System.scheduleBatch(m ,'Client Share Job', 5, 200); */
    }

    public void execute (SchedulableContext SC)
    {
        ConfigClientShareBatch batchable = new ConfigClientShareBatch();
        Database.executeBatch(batchable);
    }
}