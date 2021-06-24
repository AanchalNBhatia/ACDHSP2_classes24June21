public with sharing class ConfigSPServShareBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    public Integer recordsProcessed = 0;

    public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator('SELECT Id, Name, Service_Provider__c, Service__c, Contracted_Service__c, InActive__c FROM SP_Service__c where InActive__c = false AND Contracted_Service__c = false LIMIT 50000');
    }

    public void execute (Database.BatchableContext bc, List<SP_Service__c> scope)
    {
        List<SP_Service__Share> listSPSShare = new List<SP_Service__Share>();
        Set<Id> setSPId = new Set<Id>(); //Set with Service Provider (Account) IDs
        Map<Id, List<AccountContactRelation>> mapSPIdListStaff = new Map<Id, List<AccountContactRelation>>();
        Set<Id> setStaffId = new Set<Id>();
        Map<Id, Id> mapStaffIdUserId = new Map<Id, Id>();

        for (SP_Service__c sps : scope)
        {
            setSPId.add(sps.Service_Provider__c);
        }
        system.debug('#### setSPId: ' + setSPId);

        if (setSPId != null)
        {
            for (Account sp : [Select Id, Name, (Select Id, ContactId, Contact.Name, Contact.Title from AccountContactRelations where Contact.Title = 'Super User') from Account where Id IN :setSPId])
            {
                if (sp.AccountContactRelations != null && sp.AccountContactRelations.size() > 0)
                {
                    mapSPIdListStaff.put(sp.Id, sp.AccountContactRelations);
                    for (AccountContactRelation acr : sp.AccountContactRelations)
                    {
                        setStaffId.add(acr.ContactId);
                    }
                }
            }
            system.debug('#### setStaffId: ' + setStaffId);
            system.debug('#### mapSPIdListStaff: ' + mapSPIdListStaff);

            for (User u : [Select Id, Name, ContactId from User where IsActive = true AND ContactId IN :setStaffId])
            {
                mapStaffIdUserId.put(u.ContactId, u.Id);
            }
            system.debug('#### mapStaffIdUserId: ' + mapStaffIdUserId);

            for (SP_Service__c sps : scope)
            {
                for (AccountContactRelation acr : mapSPIdListStaff.get(sps.Service_Provider__c))
                {
                    if (mapStaffIdUserId.get(acr.ContactId) != null)
                    {
                        SP_Service__Share spsShare = new SP_Service__Share();
                        spsShare.ParentId = sps.Id;
                        system.debug('#### UserOrGroupId: ' + mapStaffIdUserId.get(acr.ContactId));
                        spsShare.UserOrGroupId = mapStaffIdUserId.get(acr.ContactId);
                        spsShare.AccessLevel = 'edit';
                        spsShare.RowCause = Schema.SP_Service__Share.RowCause.Manual;
                        listSPSShare.add(spsShare);
                    }
                }
            }
            system.debug('#### listSPSShare: ' + listSPSShare);
        }

        if (listSPSShare != null && listSPSShare.size() > 0)
        {
            recordsProcessed = listSPSShare.size();
            insert listSPSShare;
        }
    }

    public void finish (Database.BatchableContext bc)
    {
        system.debug('#### records processed in ConfigSPServShareBatch: ' + recordsProcessed);
        if (!Test.isRunningTest()) { ConfigSPServShareBatch m = new ConfigSPServShareBatch(); System.scheduleBatch(m ,'SPService Share Job', 5, 200); }

        /* To Run=>
        ConfigSPServShareBatch m = new ConfigSPServShareBatch();
        System.scheduleBatch(m ,'SPService Share Job', 5, 200); */
    }

    public void execute (SchedulableContext SC)
    {
        ConfigSPServShareBatch batchable = new ConfigSPServShareBatch();
        Database.executeBatch(batchable);
    }
}