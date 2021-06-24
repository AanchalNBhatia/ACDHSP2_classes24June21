@isTest public class IRT_LWC_CntrlTest
{
    @testSetup public static void setupData ()
    {
        Account acc = testFactory.createAccount('test Acc', 'Service Provider', true);
        
        Contact con = testFactory.createContact('test Con', 'Super User', null, acc.Id, true);
        
        Program__c prog = testFactory.createProgram('test Prog', null, false);
        insert prog;
            
        Service__c serv = testFactory.createService('test Serv', prog.Id, null, false);
        serv.Concerns__c = 'Education';
        serv.Referral_Type__c = 'Household';
        insert serv;
            
        SP_Service__c sps = testFactory.createSPService(acc.Id, serv.Id, null, true);
        
        Service_Contact__c sc = testFactory.createServiceContact(con.Id, sps.Id, null, true);
        
        Client__c cl = testFactory.createClient('test', null, true);
    }
    
    @isTest public static void testMethods ()
    {
        Contact con = [select Id from Contact LIMIT 1];
        Referral__c ref = testFactory.createReferral('New', null, false);
        ref.Self_Referral__c = true;
        Client__c cl = [select Id from Client__c LIMIT 1];
        List<String> concerns = new List<String>{'Education'};
		List<String> clients = new List<String>{cl.Id};
        
        test.startTest();
        IRT_LWC_Cntrl.getIRTSettings();
        IRT_LWC_Cntrl.getPrimaryReasons(con.Id, 'Household');
        IRT_LWC_Cntrl.createReferral(ref, 'NoneID', concerns, clients, 'Individual within a Household', cl.Id);
        test.stopTest();
    }
}