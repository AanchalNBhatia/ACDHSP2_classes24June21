@isTest
public with sharing class ReferralTriggerHandlerTest {
    @testSetup static void setupMaster(){
        //creating a non portal system administrator
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('Test', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        //create a groups- NCJW and ACDHS
        List<Group> groupList = new List<Group>();
        Group NCJWgroup = new Group();
        NCJWgroup.name = 'NCJW Waitlist';
        NCJWgroup.type = 'Queue';
        groupList.add(NCJWgroup);
        Group ACHDSgroup = new Group();
        ACHDSgroup.name = 'ACDHS Waitlist';
        ACHDSgroup.type = 'Queue';
        groupList.add(ACHDSgroup);
        
        insert groupList;

        Group publicGrp = new Group();
		publicGrp.name = 'Test Group1';
		publicGrp.Type = 'Regular'; 
		insert publicGrp;

        Group qGrp=[select Id, Name from Group where type=:'Queue' and name =:'NCJW Waitlist'];
        GroupMember grpMem1 = new GroupMember();
		grpMem1.UserOrGroupId = publicGrp.Id;
		grpMem1.GroupId = qGrp.Id;
		insert grpMem1;
        
        //creating a portal User
        system.runAs(u)
        {
            Account acc = testFactory.createAccount('ACDHS', 'Service Provider', false);
            acc.Id= Label.ACDHS;
            acc.OwnerId = u.Id;
            acc.Waiting_Q_ID__c = [SELECT Id FROM Group WHERE name = 'ACDHS Waitlist' LIMIT 1].Id;
            upsert acc;
            Account acc1 = testFactory.createAccount('NCJW', 'Service Provider', false);
            acc1.OwnerId = u.Id;
            acc1.Waiting_Q_ID__c =  [SELECT Id FROM Group WHERE name = 'NCJW Waitlist' LIMIT 1].Id;
            insert acc1;
            
            Contact con = testFactory.createContact('test Con', 'Super User', null, acc1.Id, true);
            Contact conAdmin = testFactory.createContact('ABD Admin', 'Admin', null, acc.Id, true);
            
            Profile portalProfile = [SELECT Id FROM Profile where Name = 'Provider Users'];
            User user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = con.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            insert user1;
            GroupMember grpMem = new GroupMember();
		    grpMem.UserOrGroupId = user1.Id;
		    grpMem.GroupId =publicGrp.Id;
		    insert grpMem;
        }
    }
  
    Static testmethod void testchangeOwnerOnWailist()
    {
        User userPortal = [SELECT Id, Name FROM User WHERE LastName = 'McTesty' LIMIT 1];
        System.runAs(userPortal){
        	Referral__c refTest=testFactory.createReferral('New','Normal Referral',true);
            refTest.Referral_Status__c = 'Waitlist';
            update refTest;
        } 
    }
    Static testmethod void testWaitListNotAccepted()
    {
        User userPortal = [SELECT Id, Name FROM User WHERE LastName = 'McTesty' LIMIT 1];
        User testUser=[select Id,Name from User where Id in (select UserOrGroupId from GroupMember where Group.Name='Test Group1')];
        system.debug('@User Name '+testUser.Name);
        System.runAs(userPortal){
        	Referral__c refTest=testFactory.createReferral('New',null,true);
            refTest.Referral_Status__c = 'Waitlist';
            update refTest;
            //Referral__c getRefData=[select Id, Referral_Status__c, Not_Accepted_Reason__c from Referral__c limit 1];
            //Referral__c insertRef=new Referral__c();
            //insertRef.Id=refTest.Id;
            //insertRef.Referral_Status__c='Not Accepted';
            //insertRef.Not_Accepted_Reason__c='Duplicate Referral';

            refTest.Referral_Status__c='Not Accepted';
            refTest.Not_Accepted_Reason__c='Duplicate Referral';
            update refTest;
        } 
    }
    Static testmethod void testConfigRefShare()
    {
        User userPortal = [SELECT Id, Name FROM User WHERE LastName = 'McTesty' LIMIT 1];
        System.runAs(userPortal){
        	Referral__c refTest=testFactory.createReferral('New',null,true);
            refTest.Confidential__c=true;
            update refTest;
        } 
    }
    Static testmethod void testCheckOriginalReferral()
    {
        User userPortal = [SELECT Id, Name FROM User WHERE LastName = 'McTesty' LIMIT 1];
        System.runAs(userPortal){
        	Referral__c refTestOrig=testFactory.createReferral('New',null,true);
            Referral__c refTestDup=testFactory.createReferral('New',null,true);
            refTestDup.Referral_Status__c='Not Accepted';
            refTestDup.Not_Accepted_Reason__c='Duplicate Referral';
            refTestDup.Original_Referral__c=refTestOrig.Id;
            update refTestDup;
        } 
    }
    
    static testMethod void testDelete()
    {
        Referral__c refTest=testFactory.createReferral('New','Normal Referral',true);
        Referral__c ref=[select id, name from Referral__c LIMIT 1];
        delete ref;
        undelete ref;
    } 
        
}