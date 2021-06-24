@isTest
public class ConfigInteractionShareBatchTest
{
    @testSetup static void setupData ()
    {
        User u = TestFactory.createUser('test', null, null, 'System Administrator', true);
        system.runAs(u)
        {
            Referral__c ref = testFactory.createReferral('New', null, true);
            Encounter__c enc = testFactory.createInteraction('test', ref.Id, null, true);
        }
    }
    
    @isTest static void testConfigInteractionShareBatch ()
    {
        Test.startTest();
        
        ConfigInteractionShareBatch confInt = new ConfigInteractionShareBatch();
        Database.executeBatch(confInt);
		confInt.execute(null);
        
        Test.stopTest();
    }
}