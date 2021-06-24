@isTest
public class ConfigClientShareBatchTest
{
    @testSetup static void setupMaster ()
    {   
        User u = TestFactory.createUser('test', null, null, 'System Administrator', true);
        system.runAs(u)
        {
            Referral__c ref = testFactory.createReferral('New', null, true);
            Client__c client = testFactory.createClient('TestClient', null, true);
            Client_Referral__c cRef = testFactory.createClientReferral(client.id, ref.id, null, true);
        }
    }

    @isTest static void testConfigClientShareBatch ()
    {
        Test.startTest();
        
        ConfigClientShareBatch confclient = new ConfigClientShareBatch();
        Database.executeBatch(confclient);
		confclient.execute(null);
        
        Test.stopTest();
    }
}