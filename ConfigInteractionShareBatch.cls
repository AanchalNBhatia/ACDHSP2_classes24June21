public with sharing class ConfigInteractionShareBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    public Integer recordsProcessed = 0;

    public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator('select Id, Name, OwnerId, Referral__c, Referral__r.InActive__c, Referral__r.Confidential__c, Referral__r.OwnerId, Referral__r.Referral_status__c from Encounter__c where Referral__c != null AND Referral__r.InActive__c = false AND Referral__r.Referral_status__c != \'Not Accepted\' AND Referral__r.Referral_status__c != null LIMIT 50000');
    }

    public void execute (Database.BatchableContext bc, List<Encounter__c> scope)
    {
        List<Encounter__Share> listEncShare = new List<Encounter__Share>();
        Set<Id> setRefId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        Map<Id, Id> mapUserIdAccId = new Map<Id, Id>();
        Map<Id, Id> mapEncIdGrpId = new Map<Id, Id>();

        for (Encounter__c enc : scope)
        {
            if (enc.Referral__c != null) setRefId.add(enc.Referral__c);
            system.debug('#### Confidential__c: ' + enc.Referral__r.Confidential__c);
            if (!enc.Referral__r.Confidential__c) //Not Confidential
            {
                if (String.valueOf(enc.Referral__r.OwnerId).startsWithIgnoreCase('00G'))
                {
                    system.debug('#### Owner is Queue');
                    GroupMember gm = [Select UserOrGroupId From GroupMember where GroupId = :enc.Referral__r.OwnerId LIMIT 1]; mapEncIdGrpId.put(enc.Id, gm.UserOrGroupId);
                }
                else
                {
                    setUserId.add(enc.Referral__r.OwnerId);
                }
            }
        }
        system.debug('#### setUserId: ' + setUserId);
        system.debug('#### mapEncIdGrpId: ' + mapEncIdGrpId);

        for (User u : [select Id, Name, ContactId, IsActive from User where Id IN :setUserId AND ContactId = null AND IsActive = true])
        {
            mapUserIdAccId.put(u.Id, Label.ACDHS);
        }
        for (User u : [select Id, Name, ContactId, Contact.AccountId from User where Id IN :setUserId AND ContactId != null AND IsActive = true]) { mapUserIdAccId.put(u.Id, u.Contact.AccountId); }
        system.debug('#### mapUserIdAccId: ' + mapUserIdAccId);

        Map<Id, Id> mapAccIdGrpId = new Map<Id, Id>();

        for (Account acc : [select Id, Public_Group_ID__c from Account where Id IN :mapUserIdAccId.values()]) { mapAccIdGrpId.put(acc.Id, acc.Public_Group_ID__c); }
        system.debug('#### mapAccIdGrpId: ' + mapAccIdGrpId);

        for (Encounter__c enc : scope)
        {
            if (!enc.Referral__r.Confidential__c)
            {
                Encounter__Share encShare = new Encounter__Share();
                encShare.ParentId = enc.Id;
                encShare.UserOrGroupId = (String.valueOf(enc.Referral__r.OwnerId).startsWithIgnoreCase('00G')) ? (mapEncIdGrpId.get(enc.Id)) : (mapAccIdGrpId.get(mapUserIdAccId.get(enc.Referral__r.OwnerId)));
                encShare.AccessLevel = 'edit';
                encShare.RowCause = Schema.Encounter__Share.RowCause.Manual;
                listEncShare.add(encShare);
            }
        }
        system.debug('#### listEncShare: ' + listEncShare);

        if (listEncShare != null && listEncShare.size() > 0)
        {
            recordsProcessed = listEncShare.size();
            Database.SaveResult[] encShareInsertResult = Database.insert(listEncShare, false);
            //insert listEncShare;
        }
    }

    public void finish (Database.BatchableContext bc)
    {
        system.debug('#### records processed in ConfigInteractionShareBatch: ' + recordsProcessed);
        if (!Test.isRunningTest()) { ConfigInteractionShareBatch m = new ConfigInteractionShareBatch(); System.scheduleBatch(m ,'Interaction Share Job', 5, 200); }        

        /* To Run=>
        ConfigInteractionShareBatch m = new ConfigInteractionShareBatch();
        System.scheduleBatch(m ,'Interaction Share Job', 5, 200); */
    }

    public void execute (SchedulableContext SC)
    {
        ConfigInteractionShareBatch batchable = new ConfigInteractionShareBatch();
        Database.executeBatch(batchable);
    }
}