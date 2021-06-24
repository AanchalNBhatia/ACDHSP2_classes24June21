@isTest
public with sharing class softDeleteRecordControllerTest {
    

    @testSetup static void setupMaster(){
        Group waitQ=new Group(name='Waitlist');
        Account acchh=testFactory.createAccount('Testhh','Household', true);
        //Contact conTest=testFactory.createContact('TestContact','Supervisor',Null, acchh.id, true);
        Referral__c ref=testFactory.createReferral('New', 'Normal Referral',true);
        Client__c cli=testFactory.createClient('Test Client1',Null, true);
        Client__c cli1=testFactory.createClient('Test Client2',Null, true);
        Account_Client__c acccli=testFactory.createAccountClient(cli.Id, acchh.Id, false,null, true);
        Client_Referral__c cliRef=testFactory.createClientReferral(cli.Id, ref.Id, null, true);
        Relationship__c rel=testFactory.createRelationship(cli.Id,cli1.Id, 'Family/Biological','Brother', null, true);
        Encounter__c enco=testFactory.createInteraction('Test Interaction',ref.Id, Null, true);

    }

    static testMethod void testSoftDelete()
    {

        List<ID> intIDList= new List<ID>();
        For(Encounter__c encData:[select id from Encounter__c])
        {
            intIDList.add(encData.id);
        }
        softDeleteRecordController.deleteInteractionRecords(intIDList);

        List <ID> intrefList= new List<ID>();
        for(Referral__c ref: [select id from Referral__c])
        {
            intrefList.add(ref.Id);
        }
        softDeleteRecordController.deleteReferralRecords(intrefList);

        List<ID> cliList= new List<ID>();
        for(Client__c cli: [select id from Client__c])
        {
            cliList.add(cli.Id);
        }
        softDeleteRecordController.deleteClientRecords(cliList);

        List<ID> accList= new List<ID>();
        for(Account acc: [select id from Account])
        {
            accList.add(acc.Id);
        }
        softDeleteRecordController.deleteAccountRecords(accList);
    }
    
}