@isTest
public class UserSearchControllerTest {
    public UserSearchControllerTest(){
        
    }/*
    static testMethod void setupMaster(){
            
        User usr = testFactory.createUser('user test',null, null, 'standerd user', true); 
        insert usr;
        system.runAs(usr){
            Account a= testFactory.createAccount('test user', 'Normal', true); 
             List<String> ids = new  List<String>{'Test','Test1','Portal user'};          
        Test.startTest();
         UserSearchController.searchUsersACDHSUsers('Test',ids);  
         UserSearchController.searchUsersPortalUsers('portal', ids, a.Id);
        Test.stopTest();            
            
        }*/
            
            
    @isTest static void testsearchUsersACDHSUsers(){    
        Account acc = new Account();
        acc.Name ='Test Acc 121212';
        insert acc; 	            
         List<String> ids = new  List<String>{'Test','Test1','portal user'};   
        Test.startTest();
        UserSearchController.searchUsersACDHSUsers('Test',ids);
        UserSearchController.searchUsersPortalUsers('Test1', ids, acc.Id);
        Test.stopTest();       
    }
    
  }