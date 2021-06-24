@isTest
public class DocCollectionCtrlTest{
    @testSetup static void setupMaster(){
        //creating a non portal system administrator
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u = TestFactory.createUser('Test', null, 'Admin', 'System Administrator', false);
        u.UserRoleId = portalRole.Id;
        insert u;
        //create a groups- NCJW and ACDHS
        List<Group> groupList = new List<Group>();
        Group NCJWgroup = new Group();
        NCJWgroup.name = 'NCJW Waitlist';
        NCJWgroup.type = 'Queue';
        groupList.add(NCJWgroup);
        Group ACHDSgroup = new Group();
        ACHDSgroup.name = 'ACDHS Waitlist';
        ACHDSgroup.type = 'Queue';
        groupList.add(ACHDSgroup);
        
        insert groupList;
        system.runAs(u)
        {
            Account accACDHS = testFactory.createAccount('ACDHS', 'Service Provider', false);
            accACDHS.Id= Label.ACDHS;
            accACDHS.OwnerId = u.Id;
            accACDHS.Waiting_Q_ID__c = [SELECT Id FROM Group WHERE name = 'ACDHS Waitlist' LIMIT 1].Id;
            upsert accACDHS;
            Contact conAdmin = testFactory.createContact('ABD Admin', 'Admin', null, accACDHS.Id, true);
            
            Account accSP=testFactory.createAccount('DocAcc',null, true);
            Contact con=testFactory.createContact('contacttestings', 'Household',Null, accSP.id,true);
            
            Referral__c ref=testFactory.createReferral('New', Null, true);
            Client__c cli=testFactory.createClient('TestClient', Null, true);
            Client_Referral__c cliRef=testFactory.createClientReferral(cli.Id,ref.Id, Null, true);
            Account_Client__c acccli=testFactory.createAccountClient(cli.Id, accSP.id,false,null,true);
           
    
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document'; 
            cv.PathOnClient = 'TestDocument.pdf';    
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;           
            cv.Notes__c = 'test Notes';
            cv.Upload_Date__c = system.today();
            insert cv; 
    
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=accSP.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: cv.Id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
           
            insert contentlink;  
            
            Account acc1 = testFactory.createAccount('NCJW', 'Service Provider', false);
            acc1.Waiting_Q_ID__c =  [SELECT Id FROM Group WHERE name = 'NCJW Waitlist' LIMIT 1].Id;
            acc1.OwnerId = u.Id;
            insert acc1;
            
            Contact conPortal = testFactory.createContact('test Con', 'Super User', null, acc1.Id, true);
            
            Profile portalProfile = [SELECT Id FROM Profile where Name = 'Provider Users'];
            User user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = conPortal.Id,
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
            PermissionSet pd = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Provider_Worker'];
            insert new PermissionSetAssignment(AssigneeId= user1.Id, PermissionSetId=pd.Id);
        }
    } 
    static testMethod void testgetSite(){
        DocCollectionCtrl.getSite();
        DocCollectionCtrl.getHelpText();
    }
   
    static testMethod void testUpdateDocName(){
         User usrAdmin = [SELECT Id FROM USER WHERE Name = 'Test' LIMIT 1];
         System.runAs(usrAdmin){
            ContentDocument cd = [select Id from ContentDocument];
            ContentVersion cv = [select Id from ContentVersion];
            String Status='';

            status=DocCollectionCtrl.updateDocName(cd.id, 'Consent', 'testnotes');
            status=DocCollectionCtrl.updateDocName(cd.id, 'test', 'testnotes');
         }
     }
    
    static testMethod void testGetAllDocs()
    {
        Account testacc=[select Id from Account LIMIT 1];
        User usrAdmin = [SELECT Id FROM USER WHERE Name = 'Test' LIMIT 1];
        System.runAs(usrAdmin){
            DocCollectionCtrl.getAllDocs(testacc.id);
            DocCollectionCtrl.getAllDocs('');
            DocCollectionCtrl.getAccNameFromAccId(testacc.id);
        }
    }
    static testMethod void testupdateCDL()
        {
            account testacc=[select Id from Account WHERE Name = 'DocAcc' LIMIT 1];
            List<Object> listCDLTest= new List<Object>{'test','testing12'};
            
            List<DocCollectionCtrl.DocWrapper> wrapList = DocCollectionCtrl.getAllDocs(testacc.id);
            String str=  JSON.serialize(wrapList);
            
            DocCollectionCtrl.updateCDL(listCDLTest,testacc.id,str);
        }

        static testMethod void testUploadToConAcc()
        { 
            User usr = [SELECT Id FROM USER WHERE Email = 'test12345@test.com' LIMIT 1];
            System.runAs(usr){
                String DocId = [SELECT ContentDocumentId FROM ContentVersion].ContentDocumentId;
                
                List<String> accList=new List<String>();
                List<String> conList=new List<String>();
                Account accSP=testFactory.createAccount('account testing',null, true);
                Contact con=testFactory.createContact('contacttestings', 'Household',Null, accSP.id,true);
                accList.add(accSP.Id);
                conList.add(con.Id);
                DocCollectionCtrl.uploadToConAcc(DocId, conList, accList, true, true);
            }
        }
    static testMethod void testGetAccIdForUser()
        {
            User us=[Select id from user WHERE LastName = 'McTesty' limit 1];
            DocCollectionCtrl.getAccIdForUser(us.id);
            DocCollectionCtrl.getRole(us.id);
            DocCollectionCtrl.getAccIdForUser('');
        }
        Static testmethod void testGetAccIdforRefOwner()
        {
            User us=[Select id from user WHERE LastName = 'McTesty' limit 1];
            //Account accSP=testFactory.createAccount('account testing',null, true);
            System.runAs(us){
                //Contact con=testFactory.createContact('contacttestings', 'Household',Null, accSP.id,true);
                Referral__c testRef=testFactory.createReferral('Waitlist', Null, true);
                DocCollectionCtrl.getAccIdforRefOwner(testRef.Id);
                /*testRef.Referral_Status__c = 'Waitlist';
                update testRef;
                
                Referral__c refObj = [SELECT Id, Referral_Status__c FROM Referral__c WHERE Referral_status__c = 'Waitlist' LIMIT 1];
                DocCollectionCtrl.getAccIdforRefOwner(refObj.Id);*/
            }
            
               
        }
    static testmethod void testGetRefDetails()
        {
            Client_Referral__c cliref=[select Id from Client_Referral__c];
            Referral__c testRef=[select id from Referral__c];
            DocCollectionCtrl.getRefDetails(testRef.Id);
        }
        static testmethod void checkAccessUserAcdhsAdminRefNew()
        {
            User usrAdmin = [SELECT Id FROM USER WHERE Name = 'Test' LIMIT 1];
            Referral__c testRef=[select id from Referral__c LIMIT 1];
            DocCollectionCtrl.checkUserAccessOnReferral(usrAdmin.id, testRef.Id);    
        }
     	static testmethod void checkAccessUserAcdhsAdminRefWait()
        {
            User usrAdmin = [SELECT Id FROM USER WHERE Name = 'Test' LIMIT 1];
            System.runAs(usrAdmin){
                Referral__c testRef=testFactory.createReferral('New', Null, true);
                System.debug('status ####'+testRef.Referral_Status__c);
                testRef.Referral_Status__c = 'Waitlist';
                //update testRef;
            	//DocCollectionCtrl.checkUserAccessOnReferral(usrAdmin.id, testRef.Id);
            }    
        }
    	static testmethod void checkAccessUserPortalRefNew()
        {
            User userPortal = [SELECT Id FROM USER WHERE Name = 'McTesty' LIMIT 1];
            System.runAs(userPortal){
                Referral__c testRef=testFactory.createReferral('New', Null, false);
                testRef.OwnerId = userPortal.Id;
                insert testRef;
                DocCollectionCtrl.checkUserAccessOnReferral(userPortal.Id, testRef.Id);
            }    
        }
    	static testmethod void checkAccessUserPortalCS()
        {
            User userPortal = [SELECT Id FROM USER WHERE Name = 'McTesty' LIMIT 1];
            Program__c progObj = testFactory.createProgram('Area Agency on Aging (AAA)', null, true);
            Service__c serviceObj = testFactory.createService('Back to School Store', progObj.Id, null, true);
            Account servProvAcc = testFactory.createAccount('Holy Family', 'Service Provider', true);
            SP_Service__c spServ = testFactory.createSPService(servProvAcc.Id, serviceObj.Id, null, true);
            System.runAs(userPortal){
                Referral__c testRef=testFactory.createReferral('New', Null, false);
                testRef.OwnerId = userPortal.Id;
                insert testRef;
                Client__c cli=testFactory.createClient('TestClient', Null, true);  
                Client_Service__c csObj = testFactory.createClientService(spServ.Id, testRef.Id, null, true);
                DocCollectionCtrl.checkUserAccessOnClientService(userPortal.Id, csObj.Id);
            }    
        }
}