@isTest
public class LookupSearchResultTest {
    public LookupSearchResultTest(){
        
    }
     @testSetup static void setupMaster(){
        Account a=testFactory.createAccount('TestAccount', 'Service Provider', true);
    }
      public static  testMethod void testCallClass(){
		
        Test.startTest();
        Account acc =[Select Id From Account LIMIT 1];
        List<LookupSearchResult> lcrList = new List<LookupSearchResult>();
        LookupSearchResult lcr = new LookupSearchResult(acc.id,'Account','Test Icon','Test Title','Test Sub-Title');
        LookupSearchResult lcr2 = new LookupSearchResult(acc.id,'Account','Test Icon','Test Title','Test Sub-Title');
        lcrList.add(lcr);
        lcrList.add(lcr2);
        system.assert(lcr.getId() == acc.id);
        system.assert(lcr.getSObjectType() == 'Account');
        system.assert(lcr.getIcon() == 'Test Icon');
        system.assert(lcr.getTitle() == 'Test Title'); 
        system.assert(lcr.getSubtitle() == 'Test Sub-Title'); 
        lcrList.sort();
        Test.stopTest();
    }
}