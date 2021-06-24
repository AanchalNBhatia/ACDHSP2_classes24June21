@isTest
public with sharing class ContactTriggerHandlerTest {
    public ContactTriggerHandlerTest() {

    }
    @testSetup static void setupMaster(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('Staff1', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        System.runAs(u){
            Account acc= testFactory.createAccount('ACDHS','Household', true);
        	Contact con=testFactory.createContact('Staff1','Supervisor',Null,acc.id,true);
        }
        
    }
    static testMethod void testCreateClient()
    {
        Contact conTest=[select id from contact];
        delete conTest;
        undelete conTest;
    }
    static testMethod void testUpdate(){
        Contact conTest=[select id,Name,Gender__c from contact LIMIT 1];
		conTest.Gender__c = '1';
        update conTest;
    }
}