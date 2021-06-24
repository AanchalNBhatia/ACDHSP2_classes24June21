@isTest public class SPPortalContainerCntrlTest
{
    @testSetup static void setupData ()
    {
        User u = TestFactory.createUser('test', null, null, 'System Administrator', true); 
    }
    
    @isTest static void getUserDetailsTest ()
    {
        User u = [select Id from User LIMIT 1];
        Test.startTest();
        SPPortalContainerCntrl.getUserDetails(u.Id);
        Test.stopTest();
    }
}