@isTest
public with sharing class UserDetailsTest {
  
    @testSetup static void setupMaster(){

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('test', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        Boolean uFlag;
        system.runAs(u)
        {
            Account accProvider = testFactory.createAccount('NCJW', 'Service Provider', false);
            accProvider.OwnerId = u.Id;
            insert accProvider;
            Account accACDHS = testFactory.createAccount('ACDHS', 'Service Provider', false);
            //accACDHS.Id= Label.ACDHS;
            accACDHS.OwnerId = u.Id;
            insert accACDHS;
            Contact conProvider = testFactory.createContact('Provider Contact', 'Super User', null, accProvider.Id, true);
            Contact conACDHS = testFactory.createContact('ACDHS Contact', 'Super User', null, accACDHS.Id, true);
            User portalUser = TestFactory.createUser('Portal User', conProvider.ID, Null, 'Provider Users', true);
            User acdhsUser = TestFactory.createUser('ACDHSUser', null, 'Super User', 'Internal Super User', false);
            acdhsUser.Contact_Id__c=conACDHS.Id;
            insert acdhsUser; 
            
        }  
             
    }
    
    static testMethod void testCheckAccess()
    {
        //Contact conTest=[select id, title, name from Contact];
        
        User userPortal = [SELECT Id, Name, Contact_Id__c, ContactId FROM User WHERE LastName = 'Portal User' LIMIT 1];
        User userACDHS = [SELECT Id, Name, Contact_Id__c, ContactId FROM User WHERE LastName = 'ACDHSUser' LIMIT 1];
        //User us=[select id, name, ContactId, Contact_Id__c, ProfileId from User limit 1];
        //Referral__c ref= new Referral__c();
        system.debug('@us conid '+userPortal.ContactId);
        system.debug('@us con_id '+userACDHS.Contact_Id__c);
        System.runAs(userPortal)
        {
            Referral__c ref=testFactory.createReferral('New',null, false);
            ref.OwnerId=userPortal.Id;
            insert ref;
            User getUser=[select id, Name from User where id =:ref.OwnerId];
            UserRecordAccess ura = [select RecordId, HasEditAccess, MaxAccessLevel from UserRecordAccess where UserId = :userPortal.Id AND RecordId = :ref.Id];
            system.debug('@access '+ura.HasEditAccess+getUser.Name);
            userDetails.checkAccess(ref.Id);
            userDetails.getUserInfo(userPortal.Id);
        }
        System.runAs(userACDHS)
        {
            userDetails.getUserInfo(userACDHS.Id);
        }
        
        userDetails.validUser();
        
    }
}