@isTest
public with sharing class CheckInteractionAccessTest {
    public CheckInteractionAccessTest() {

    }

    @testSetup static void setupMaster(){
        Referral__c ref= testFactory.createReferral('New', null, true);
    }

    static testmethod void testCheckAccess()
    {
        Referral__c testRef=[select id from Referral__c limit 1];
        CheckInteractionAccess.checkAccess(testRef.id);
    }
}