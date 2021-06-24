@isTest
public with Sharing class AccountTriggerHandlerTest {
    
    @testSetup static void setupMaster(){
        Account acc=testFactory.createAccount('TestAccount', 'Service Provider', true);
    }
	static testMethod void testNewPublicQueueGroup()
    {
        Account accTest=[select id, name from Account];
        
        Delete accTest;
        UnDelete accTest;
    }
}