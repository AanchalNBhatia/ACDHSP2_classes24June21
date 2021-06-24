@isTest
public class ConfigSPServShareBatchTest
{
    @testSetup static void setupData ()
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('test', null, null, 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        system.runAs(u)
        {
            Account acc = testFactory.createAccount('test Acc', 'Service Provider', false);
            acc.OwnerId = u.Id;
            insert acc;
            
            Contact con = testFactory.createContact('test Con', 'Super User', null, acc.Id, true);
            
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
            
            Program__c prog = testFactory.createProgram('test Prog', null, true);
            
            Service__c serv = testFactory.createService('test Serv', prog.Id, null, false);
            serv.Concerns__c = 'Education';
            insert serv;
            
            SP_Service__c sps = testFactory.createSPService(acc.Id, serv.Id, null, true);
        }
    }
    
    @isTest static void testConfigSPServShareBatch ()
    {
        Test.startTest();
        
        ConfigSPServShareBatch confSPS = new ConfigSPServShareBatch();
        Database.executeBatch(confSPS);
		confSPS.execute(null);
        
        Test.stopTest();
    }
}