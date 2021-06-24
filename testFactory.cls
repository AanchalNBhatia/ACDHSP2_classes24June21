/* Test_Factory Class to Insert Records to be used in Test Classes */
@isTest
public with sharing class testFactory
{
    public static Id getDefaultRT (Schema.DescribeSObjectResult dsr)
    {
        Id rtID;
        for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) 
        {
            if (rti.isDefaultRecordTypeMapping()) 
            {
                rtId = rti.getRecordTypeId();
            }
        }
        return rtId;
    }
    
    //Create Account
    public static Account createAccount (String name, String rtName, Boolean create)
    {
        Id accRTId;
        if (rtName != null && rtName != '')
        {
            accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            accRTId = testFactory.getDefaultRT(Account.SObjectType.getDescribe());
        }
        Account acc = new Account();
        acc.Name = name;
        acc.RecordTypeId = accRTId;
        if (create) insert acc;
        return acc;
    }
    
    //Create Contact
    public static Contact createContact (String lastName, string title, String rtName, ID accountId, Boolean create)
    {
        Id conRTId;
        if (rtName != null && rtName != '')
        {
            conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            conRTId = testFactory.getDefaultRT(Contact.SObjectType.getDescribe());
        }
        Contact con = new Contact();
        con.LastName = lastName;
        con.Title=title;
        con.Email='test@test.com';
        con.Phone_Type__c='Cell';
        con.Phone='1234567890';
        con.AccountId = accountId;
        //con.RecordTypeId = conRTId;
        if (create) insert con;
        return con;
    }
    //Create Client
    public static Client__c createClient (String FirstName, String rtName, Boolean create)
    {
        Id cliRTId;
        if (rtName != null && rtName != '')
        {
            cliRTId = Schema.SObjectType.Client__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            cliRTId = testFactory.getDefaultRT(Client__c.SObjectType.getDescribe());
        }
        Client__c cli = new Client__c();
        cli.First_Name__c = FirstName;
        
        if (create) insert cli;
        return cli;
    }
    public static Relationship__c createRelationship (Id primaryCliId, Id secondaryCliId, String category, String relation, String rtName, Boolean create)
    {
        Id relRTId;
        if (rtName != null && rtName != '')
        {
            relRTId = Schema.SObjectType.Relationship__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            relRTId = testFactory.getDefaultRT(Relationship__c.SObjectType.getDescribe());
        }
        Relationship__c relData = new Relationship__c();
        relData.Type__c = category;
        relData.Relation__c = relation;
        relData.Primary_Member__c = primaryCliId;
        relData.Secondary_Member__c = secondaryCliId;
        
        if (create) insert relData;
        return relData;
    }
    //Create Client Referral
    public static Client_Referral__c createClientReferral (Id clientID, ID referralId, String rtName, Boolean create)
    {
        Id cliRefRTId;
        if (rtName != null && rtName != '')
        {
            cliRefRTId = Schema.SObjectType.Client_Referral__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            cliRefRTId = testFactory.getDefaultRT(Client_Referral__c.SObjectType.getDescribe());
        }
        Client_Referral__c cliRef = new Client_Referral__c();
        cliRef.Referral__c = referralId;
        cliRef.Client__c = clientID;
        if (create) insert cliRef;
        return cliRef;
    }
    //Create Account Client
    public static Account_Client__c createAccountClient (Id clientID, ID accountId, Boolean isPrimary, String rtName, Boolean create)
    {
        Id acccliRTId;
        if (rtName != null && rtName != '')
        {
            acccliRTId = Schema.SObjectType.Account_Client__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            acccliRTId = testFactory.getDefaultRT(Account_Client__c.SObjectType.getDescribe());
        }
        Account_Client__c acccli = new Account_Client__c();
        acccli.Client__c = clientID;
        acccli.Account__c = accountId;
        acccli.Primary__c = isPrimary;
        if (create) insert acccli;
        return acccli;
    }
    //Create External Referral
    public static External_Referral__c createExternalReferral (Id clientId, Id interactionId,String rtName, Boolean create)
    {
        Id exrefRTId;
        if (rtName != null && rtName != '')
        {
            exrefRTId = Schema.SObjectType.External_Referral__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            exrefRTId = testFactory.getDefaultRT(External_Referral__c.SObjectType.getDescribe());
        }
        External_Referral__c exref = new External_Referral__c();
        exref.RecordTypeId = exrefRTId;
        exref.Client__c = clientId;
        exref.Interaction__c = interactionId;
        if (create) insert exref;
        return exref;
    }
    //Create Concrete Goods
    public static Concrete_Goods__c createConcreteGoods (Id clientId, Id interactionId,Integer qty, String rtName, Boolean create)
    {
        Id cgRTId;
        if (rtName != null && rtName != '')
        {
            cgRTId = Schema.SObjectType.Concrete_Goods__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            cgRTId = testFactory.getDefaultRT(Concrete_Goods__c.SObjectType.getDescribe());
        }
        Concrete_Goods__c cg = new Concrete_Goods__c();
        cg.RecordTypeId = cgRTId;
        cg.Number_of_Item_Provided__c = qty;
        cg.Client__c = clientId;
        cg.Interaction__c = interactionId;
        if (create) insert cg;
        return cg;
    }
    //Create Program
    public static Program__c createProgram (String name, String rtName, Boolean create)
    {
        Id progRTId;
        if (rtName != null && rtName != '')
        {
            progRTId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            progRTId = testFactory.getDefaultRT(Program__c.SObjectType.getDescribe());
        }
        Program__c prog = new Program__c();
        prog.Name = name;
        if (create) insert prog;
        return prog;
    }
    //Create Service
    public static Service__c createService (String name, ID progId,String rtName, Boolean create)
    {
        Id servRTId;
        if (rtName != null && rtName != '')
        {
            servRTId = Schema.SObjectType.Service__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            servRTId = testFactory.getDefaultRT(Service__c.SObjectType.getDescribe());
        }
        Service__c serv = new Service__c();
        serv.Name = name;
        serv.Program__c = progId;
        if (create) insert serv;
        return serv;
    }
     //Create SP Service
     public static SP_Service__c createSPService (ID accid, ID serviceId, String rtName, Boolean create)
     {
         Id spServRTId;
         if (rtName != null && rtName != '')
         {
             spServRTId = Schema.SObjectType.SP_Service__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
         }
         else
         {
             spServRTId = testFactory.getDefaultRT(SP_Service__c.SObjectType.getDescribe());
         }
         SP_Service__c spServ = new SP_Service__c();
         spServ.Service_Provider__c=accid;
         spServ.Service__c = serviceId;
         if (create) insert spServ;
         return spServ;
     }
    //Create Referral
    public static Referral__c createReferral (String status, String rtName, Boolean create)
    {
        Id refRTId;
        if (rtName != null && rtName != '')
        {
            refRTId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            refRTId = testFactory.getDefaultRT(Referral__c.SObjectType.getDescribe());
        }
        Referral__c refe = new Referral__c();
        refe.Referral_Status__c = status;
        refe.From_IRT__c = true;
        if (create) insert refe;
        return refe;
    }
    
    //Create Interaction
    public static Encounter__c createInteraction (String Subject, String objId, String rtName, Boolean create)
    {
        Id intRTId;
        if (rtName != null && rtName != '')
        {
            intRTId = Schema.SObjectType.Encounter__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            intRTId = testFactory.getDefaultRT(Encounter__c.SObjectType.getDescribe());
        }
        Encounter__c inter = new Encounter__c();
        inter.RecordTypeId=intRTId;
        inter.Start_Time__c = System.Now();
        inter.End_Time__c = System.Now();
        inter.Subject__c = Subject;
        inter.Type__c = 'Phone Call';
        inter.Status__c = 'Attempted';
        inter.Description__c = 'Test';
        if (rtName == 'Referral')
        {
            inter.Referral__c = objId;
        }else {
            inter.Client_Service__c=objId;
        }
        if (create) insert inter;
        return inter;
    }
    //Create Client Service
    public static Client_Service__c createClientService (ID spServiceId, Id ReferralId, String rtName, Boolean create)
    {
        Id clServRTId;
        if (rtName != null && rtName != '')
        {
            clServRTId = Schema.SObjectType.Client_Service__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            clServRTId = testFactory.getDefaultRT(Client_Service__c.SObjectType.getDescribe());
        }
        Client_Service__c clServ = new Client_Service__c();
        //clServ.Client__c = clientId; - removed for Story 1137 as the field has been removed
        clServ.SP_Service__c = spServiceId;
        clServ.Referral__c = ReferralId;
        if (create) insert clServ;
        return clServ;
    }

     //Create Junction Service
     public static Junction_Service__c createJunctionService (ID clientId, ID clientServiceId, String rtName, Boolean create)
     {
         Id juncServRTId;
         if (rtName != null && rtName != '')
         {
            juncServRTId = Schema.SObjectType.Junction_Service__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
         }
         else
         {
            juncServRTId = testFactory.getDefaultRT(Junction_Service__c.SObjectType.getDescribe());
         }
         Junction_Service__c juncServ = new Junction_Service__c();
         //juncServ.RecordTypeId = juncServRTId;
         juncServ.Client__c = clientId;
         juncServ.Client_Service__c = clientServiceId;
         if (create) insert juncServ;
         return juncServ;
     }
    
    //Create Service Contact
    public static Service_Contact__c createServiceContact (ID contactId, ID spServiceId, String rtName, Boolean create)
    {
        Id servConRTId;
        if (rtName != null && rtName != '')
        {
            servConRTId = Schema.SObjectType.Service_Contact__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            servConRTId = testFactory.getDefaultRT(Service_Contact__c.SObjectType.getDescribe());
        }
        Service_Contact__c servCon = new Service_Contact__c();
        servCon.SP_Staff__c = contactId;
        servCon.SP_Service__c = spServiceId;
        if (create) insert servCon;
        return servCon;
    }
    //Create Service Delivery
    /* public static Service_Delivery__c createServiceDelivery (ID clientServiceId, String rtName, Boolean create)
    {
        Id servDelRTId;
        if (rtName != null && rtName != '')
        {
            servDelRTId = Schema.SObjectType.Service_Delivery__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            servDelRTId = testFactory.getDefaultRT(Service_Delivery__c.SObjectType.getDescribe());
        }
        Service_Delivery__c servDel = new Service_Delivery__c();
        servDel.Client_Service__c = clientServiceId;
        if (create) insert servDel;
        return servDel;
    } */
    
    //Create Household Service
    public static Household_Service__c createhhDelivery (ID accountId, ID serviceId, String rtName, Boolean create)
    {
        Id hhDelRTId;
        if (rtName != null && rtName != '')
        {
            hhDelRTId = Schema.SObjectType.Household_Service__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            hhDelRTId = testFactory.getDefaultRT(Household_Service__c.SObjectType.getDescribe());
        }
        Household_Service__c hhDel = new Household_Service__c();
        hhDel.Household__c = accountId;
        hhDel.Service__c = serviceId;
        if (create) insert hhDel;
        return hhDel;
    }
    //Create Question
    /*public static Question__c createQuestion (String queText, String rtName, Boolean create)
    {
        Id queRTId;
        if (rtName != null && rtName != '')
        {
            queRTId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            queRTId = testFactory.getDefaultRT(Question__c.SObjectType.getDescribe());
        }
        Question__c que = new Question__c();
        que.Question_Text__c = queText;
        if (create) insert que;
        return que;
    }
    //Create Answer
    public static Answer__c createAnswer (String ansText, String rtName, Boolean create)
    {
        Id ansRTId;
        if (rtName != null && rtName != '')
        {
            ansRTId = Schema.SObjectType.Answer__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            ansRTId = testFactory.getDefaultRT(Answer__c.SObjectType.getDescribe());
        }
        Answer__c ans = new Answer__c();
        ans.Answer_Text__c = ansText;
        if (create) insert ans;
        return ans;
    }
     //Create Answer Option
    public static Answer_Option__c createAnswerOption (String ansID, String queID, String rtName, Boolean create)
    {
        Id ansOpRTId;
        if (rtName != null && rtName != '')
        {
            ansOpRTId = Schema.SObjectType.Answer_Option__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            ansOpRTId = testFactory.getDefaultRT(Answer_Option__c.SObjectType.getDescribe());
        }
        
        Answer_Option__c ansOp = new Answer_Option__c();
        ansOp.Answer__c = ansID;
        ansOp.Question__c = queID;
        if (create) insert ansOp;
        return ansOp;
    }
    //Create Questionnaire Template
    public static Questionnaire_Template__c createQuestTemp (String name, String templType, String sectionName, String rtName, Boolean create)
    {
        Id QusetTemplateRTId;
        if (rtName != null && rtName != '')
        {
            QusetTemplateRTId = Schema.SObjectType.Questionnaire_Template__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            QusetTemplateRTId = testFactory.getDefaultRT(Questionnaire_Template__c.SObjectType.getDescribe());
        }
        Questionnaire_Template__c QuestTemp = new Questionnaire_Template__c();
        QuestTemp.Name = name;
        QuestTemp.Template_Type__c = templType;
        QuestTemp.Section_Names__c = sectionName;
        if (create) insert QuestTemp;
        return QuestTemp;
    }
    //Create Template Question
    public static Template_Question__c createTempQue (String name, ID questTempl, ID ques, String rtName, Boolean create)
    {
        Id tempQueRTId;
        if (rtName != null && rtName != '')
        {
            tempQueRTId = Schema.SObjectType.Template_Question__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            tempQueRTId = testFactory.getDefaultRT(Template_Question__c.SObjectType.getDescribe());
        }
        Template_Question__c tempQue = new Template_Question__c();
        //tempQue.Name = name;
        tempQue.Questionnaire_Template__c = questTempl;
        tempQue.Question__c = ques;
        if (create) insert tempQue;
        return tempQue;
    }
     //Create Assesment
    public static Assessment__c createAssesment (String name, String rtName, Boolean create)
    {
        Id assRTId;
        if (rtName != null && rtName != '')
        {
            assRTId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            assRTId = testFactory.getDefaultRT(Assessment__c.SObjectType.getDescribe());
        }
        Assessment__c ass = new Assessment__c();
        ass.Name = name;
        if (create) insert ass;
        return ass;
    }
     //Create Assesment Result
    public static Assessment_Result__c createAssResult (String name, ID assID, String rtName, Boolean create)
    {
        Id assResultRTId;
        if (rtName != null && rtName != '')
        {
            assResultRTId = Schema.SObjectType.Assessment_Result__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            assResultRTId = testFactory.getDefaultRT(Assessment_Result__c.SObjectType.getDescribe());
        }
        Assessment_Result__c assResult = new Assessment_Result__c();
        assResult.Name = name;
        assResult.Assessment__c = assID;
        if (create) insert assResult;
        return assResult;
    }
    //Create Response
    public static Response__c createResponse (String name, ID assResult, String rtName, Boolean create)
    {
        Id resRTId;
        if (rtName != null && rtName != '')
        {
            resRTId = Schema.SObjectType.Response__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        }
        else
        {
            resRTId = testFactory.getDefaultRT(Response__c.SObjectType.getDescribe());
        }
        Response__c res = new Response__c();
        res.Name = name;
        res.Assessment_Result__c = assResult;
        if (create) insert res;
        return res;
    }*/
    //Create User
    public static User createUser (String lastName, ID conId, string userRoleName, String profName, Boolean create)
    {
        Profile p = [Select Id from profile where name = : profName limit 1];
        
        System.debug('profile is'+ p.Id);
        User userTest = new User();
        if (p.Id != null && profName == 'Provider Users')
        {
            userTest.Username = System.now().millisecond() + 'test12345@test.com';
            userTest.ContactId = conId;
            userTest.ProfileId = p.Id;
            userTest.Alias = 'test123';
            userTest.Email = 'test12345@test.com';
            userTest.EmailEncodingKey = 'UTF-8';
            userTest.LastName = lastName;
            userTest.CommunityNickname = 'test12345';
            userTest.TimeZoneSidKey = 'America/Los_Angeles';
            userTest.LocaleSidKey = 'en_US';
            userTest.LanguageLocaleKey = 'en_US';
            
        }
        else
        {
            if(userRoleName != null && userRoleName !=''){
                UserRole urole=[select id from UserRole where name =: userRoleName limit 1];
                userTest.UserRoleId = urole.id; 
            }
            
            userTest.Alias = 'test123';
            userTest.LastName = lastName;
            userTest.Email = 'test12345@test.com';
            userTest.ProfileId = p.Id;
            
            userTest.LanguageLocaleKey ='en_US';
            userTest.LocaleSidKey = 'en_US';
            userTest.TimeZoneSidKey='America/Los_Angeles';
            userTest.EmailEncodingKey='UTF-8';
            userTest.Username=lastName+'.'+lastName+'@demo.com';
            userTest.Contact_Id__c=conId;
        }
        if (create) insert userTest;
        System.debug('@usertest'+userTest.Contact_Id__c);
        return userTest;
    }
     
   
}