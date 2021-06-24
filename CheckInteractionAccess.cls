public with sharing class CheckInteractionAccess
{
    @AuraEnabled(cacheable=true)
    public static UserRecordAccess checkAccess (Id refId)
    {
        Id userId = UserInfo.getUserId();
        //Referral__c ref = [select Id, UserRecordAccess.MaxAccessLevel, UserRecordAccess.HasEditAccess from Referral__c where Id = :refId];
        UserRecordAccess ura = [select RecordId, HasEditAccess, MaxAccessLevel from UserRecordAccess where UserId = :userId AND RecordId = :refId];
        system.debug('#### ura: ' + ura);
        //return ura.HasEditAccess;
        //return ref;
        return ura;
    }    
}