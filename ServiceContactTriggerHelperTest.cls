@isTest
public with sharing class ServiceContactTriggerHelperTest {

    @testSetup static void setupMaster(){

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('test', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        system.runAs(u)
        {
            Account acc = testFactory.createAccount('NCJW', 'Service Provider', false);
            acc.OwnerId = u.Id;
            insert acc;
            Contact con = testFactory.createContact('test Con', 'Super User', null, acc.Id, true);
            User portalProfile = TestFactory.createUser('McTesty', con.ID, Null, 'Provider Users', true);
            
            }
    }

    static testMethod void testCheckSP()
    {
        Account accData=[select id from account limit 1];
        Contact conData=[select id from Contact limit 1];
        User userPortal = [SELECT Id, Name FROM User WHERE LastName = 'McTesty' LIMIT 1];
        System.runAs(userPortal){
            Program__c prog=testFactory.createProgram('TestProg',Null, true);
            Service__c serv=testFactory.createService('TestService',prog.Id, Null, true);
            SP_Service__c spServ=testFactory.createSPService(accData.Id,serv.Id, Null, true);
            Service_Contact__c servCon=testFactory.createServiceContact(conData.Id,spServ.Id, Null, true);
            List<Service_Contact__c> testSCData=[select id, SP_Staff__c, SP_Service__c from Service_Contact__c limit 1];
            update testSCData;
        }

    }
    static testMethod void otherTest()
    {
        Account accData=[select id from account limit 1];
        Contact conData=[select id from Contact limit 1];
        User userPortal = [SELECT Id, Name FROM User WHERE LastName = 'McTesty' LIMIT 1];
        System.runAs(userPortal){
            Program__c prog=testFactory.createProgram('TestProg',Null, true);
            Service__c serv=testFactory.createService('TestService',prog.Id, Null, true);
            SP_Service__c spServ=testFactory.createSPService(accData.Id,serv.Id, Null, true);
            Service_Contact__c servCon=testFactory.createServiceContact(conData.Id,spServ.Id, Null, true);
            List<Service_Contact__c> testSCData=[select id, SP_Staff__c, SP_Service__c from Service_Contact__c limit 1];
            update testSCData;
            delete testSCData;
            undelete testSCData;
        }
    }
    
}