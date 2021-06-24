@isTest
public with sharing class SPServiceTriggerHelperTest {
    public SPServiceTriggerHelperTest() {

    }
    @testSetup static void setupMaster(){

        Account acc=testFactory.createAccount('TestAccount', 'Service Provider', true);
        Program__c pro=testFactory.createProgram('TestProgram',Null,true);
        Service__c ser=testFactory.createService('TestService', pro.Id, Null, false);
        ser.Concerns__c='Child Care';
        ser.Contracted_Service__c=true;
        insert ser;
        SP_Service__c spSer=testFactory.createSPService(acc.id,ser.Id, Null, false);
        spSer.Concerns__c='Child Care';
        insert spSer;
        
    }

    static testMethod void testhandleConcerns()
    {
        List <string> spConcern=new List<String>();
        SP_Service__c spser=[select Id, name,Concerns__c  from SP_Service__c];
        spConcern=spser.Concerns__c.split(';');
        String missingVal;
        Boolean isExisting=false;
        update spser;
        delete spser;
        undelete spser;
    }
}