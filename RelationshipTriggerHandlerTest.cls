@isTest
public class RelationshipTriggerHandlerTest {
    @testSetup static void setupMaster(){
        //creating a non portal system administrator
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('testsetup', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        
        system.runAs(u)
        {
            Client__c PriMember1 = testFactory.createClient ('Relative1', null, true);
            Client__c SecMember1 = testFactory.createClient ('Relative2', null, true);
            Client__c PriMember2 = testFactory.createClient ('Relative1', null, true);
            Client__c SecMember2 = testFactory.createClient ('Relative2', null, true);
            Client__c member1 = testFactory.createClient ('member1', null, true);
            Account hhAcc = testFactory.createAccount('household', 'Household', true);
            Account_Client__c accCli1 = testFactory.createAccountClient(PriMember1.Id,hhAcc.Id,true,null,true);
            Account_Client__c accCli2 = testFactory.createAccountClient(SecMember1.Id,hhAcc.Id,true,null,true);
            Relationship__c rel1 = testFactory.createRelationship(PriMember1.Id, SecMember1.Id, 'Non-Biological', 'Father', null, true);
            Relationship__c rel2 = testFactory.createRelationship(PriMember2.Id, SecMember2.Id, 'Non-Biological', 'Father', null, true);
        }
    }
    static testMethod void testInsert(){
        //creating a non portal system administrator
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('testinsert', null, 'Admin', 'System Administrator', false);
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
    static testMethod void testUpdate(){
        //creating a non portal system administrator
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('testupdate', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u; 
        
        //creating a portal User
        system.runAs(u)
        {
            List<Relationship__c> relUpdateList = new List<Relationship__c>();
            for(Relationship__c relItr : [SELECT Id, Original_Relation__c,relation__c FROM Relationship__c]){
                if(relItr.Original_Relation__c ==null){
                    relItr.relation__c = 'Brother';
                    relUpdateList.add(relItr);
                }
            }
            if(relUpdateList != null && relUpdateList.size()>0){
                update relUpdateList;
            }
        }
    }
}