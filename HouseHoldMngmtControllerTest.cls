@isTest
public class HouseHoldMngmtControllerTest {
    static testMethod void getRelRuleWrapperTest(){
        HouseHoldMngmtController.getRelRuleWrapper();
    }
    static testMethod void getExistingHouseholdsTest(){
        //creating a non portal system administrator
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('test', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u; 
        
        //creating a portal User
        system.runAs(u)
        {
            Client__c PriMember = testFactory.createClient ('Relative1', null, true);
            Client__c SecMember = testFactory.createClient ('Relative2', null, true);
            Client__c member1 = testFactory.createClient ('member1', null, true);
            Account hhAcc = testFactory.createAccount('household', 'Household', true);
            Account_Client__c accCli1 = testFactory.createAccountClient(PriMember.Id,hhAcc.Id,true,null,true);
            Account_Client__c accCli2 = testFactory.createAccountClient(SecMember.Id,hhAcc.Id,true,null,true);
            Relationship__c rel = testFactory.createRelationship(PriMember.Id, SecMember.Id, 'Non-Biological', 'Father', null, true);
            HouseHoldMngmtController.getExistingHouseholds(SecMember.Id,hhAcc.id);
            HouseHoldMngmtController.getHHAcc(SecMember.Id,true);
            HouseHoldMngmtController.getHHAcc(member1.Id,false);            
        }
    }
}