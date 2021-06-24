public with sharing class IRT_LWC_Cntrl
{
    @AuraEnabled(cacheable=true)
    public static Boolean getIRTSettings ()
    {
        IRT_Settings__c irts = IRT_Settings__c.getInstance();
        Boolean eq = irts.Enable_IRT_Questionnaire__c;
        system.debug('#### eq: ' + eq);
        return eq;
    }

    @AuraEnabled(cacheable=true)
    public static List<PrimReasonWrapper> getPrimaryReasons (Id conId, String refType)
    {
        system.debug('#### conId: ' + conId);
        system.debug('#### refType: ' + refType);
        List<PrimReasonWrapper> listPRW = new List<PrimReasonWrapper>();
        List<PrimReasonWrapper> listPRWUnique = new List<PrimReasonWrapper>();
        List<SP_Service__c> listSPServ = new List<SP_Service__c>();
        Set<Id> setSPServId = new Set<Id>();

        List<String> allowedRefType = new List<String>{'Both'};
        if (refType.contains('Individual')) allowedRefType.add('Individual');
        else if (refType.contains('Household')) allowedRefType.add('Household');

        for (Service_Contact__c sc : [select Id, Name, SP_Service__c, SP_Staff__c from Service_Contact__c where SP_Staff__c = :conId])
        {
            setSPServId.add(sc.SP_Service__c);
        }
        system.debug('#### setSPServId: ' + setSPServId);
        if (setSPServId != null && setSPServId.size() > 0)
        {
            listSPServ = [select Id, Name, Service_Provider__c, Service__c, Service__r.Name, Service__r.Description__c, Type__c, Extension_Date__c, Extension_Type__c, End_Date__c from SP_Service__c where Id IN :setSPServId AND Type__c IN :allowedRefType];
        }
        system.debug('#### listSPServ: ' + listSPServ);

        if (listSPServ != null && listSPServ.size() > 0)
        {
            for (SP_Service__c sps : listSPServ)
            {
                //UST 1053
                if (    (sps.End_Date__c == null || sps.End_Date__c >= Date.today()) || 
                        (sps.Extension_Date__c != null && sps.Extension_Type__c != null && sps.Extension_Date__c >= Date.today() && sps.Extension_Type__c == 'Documentation and Referral/Cases')
                   )
                {
                    PrimReasonWrapper prw = new PrimReasonWrapper();
                    //prw.ServiceId = sps.Service__c;
                    prw.ServiceId = sps.Id; //UST 1053
                    prw.Name = sps.Service__r.Name;
                    prw.Description = sps.Service__r.Description__c;
                    listPRW.add(prw);
                }
            }

            Set<Id> setServId = new Set<Id>();
            for (PrimReasonWrapper prw : listPRW)
            {
                if (!setServId.contains(prw.ServiceId))
                {
                    setServId.add(prw.ServiceId);
                    listPRWUnique.add(prw);
                }
            }
        }
        
        return listPRWUnique;
    }

    @AuraEnabled
    public static ReferralSubmitWrapper createReferral (Referral__c referral, String primReasonId, List<String> concerns, List<String> listClients, String refType, String selectedClientId)
    {
        ReferralSubmitWrapper rsw = new ReferralSubmitWrapper();
        Set<String> setClientIds = new Set<String>(listClients);

        system.debug('#### referral: ' + referral);
        system.debug('#### primReasonId: ' + primReasonId);
        system.debug('#### concerns: ' + concerns);
        system.debug('#### setClientIds: ' + setClientIds);

        String selectedConcerns = '';
        for (String con : concerns)
        {
            selectedConcerns = selectedConcerns + con + ';';
        }

        List<Account_Client__c> aClient = [select Id, Name, Client__c, Account__c, Primary__c from Account_Client__c where Client__c = :selectedClientId AND Primary__c = true];

        Referral__c ref = referral;
        //ref.RecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Normal_Referral').getRecordTypeId();
        ref.From_IRT__c = true;
        ref.Client__c = null;
        ref.Primary_Client_ID__c = selectedClientId;
        if (primReasonId != 'NoneID') ref.Primary_Reason1__c = primReasonId; //ref.Primary_Reason__c = primReasonId;
        ref.Referral_Status__c = 'New';
        ref.Concerns__c = selectedConcerns;
        ref.Referral_Type__c = refType;
        if (refType == 'Household') ref.Household__c = (aClient.size() > 0) ? (aClient[0].Account__c) : null;
        if (ref.Self_Referral__c)
        {
            ref.RB_First_Name__c = ref.First_Name__c;
            ref.RB_Last_Name__c = ref.Last_Name__c;
        }

        try {
            insert ref;
            Referral__c newRef = [select Id, Name, Confidential__c from Referral__c where Id = :ref.Id];
            rsw.status = 'Success';
            rsw.ref = newRef;
            
            List<Client_Referral__c> listCR = new List<Client_Referral__c>();
            for (String s : setClientIds)
            {
                Client_Referral__c cr = new Client_Referral__c();
                cr.Client__c = s;
                cr.Referral__c = ref.Id;
                cr.Confidential__c = ref.Confidential__c;
                listCR.add(cr);
            }
            insert listCR;

            if (refType == 'Individual within a Household')
            {
                //List<Account_Client__c> aClient = [select Id, Name, Client__c, Primary__c from Account_Client__c where Client__c = :selectedClientId AND Primary__c = true];
                if (aClient == null || aClient.size() == 0)
                {
                    Client__c cl = [select Id, Last_Name__c from Client__c where Id = :selectedClientId];
                    Account acc = new Account();
                    acc.Name = cl.Last_Name__c + ' Household';
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
                    insert acc;

                    Account_Client__c ac = new Account_Client__c();
                    ac.Account__c = acc.Id;
                    ac.Client__c = selectedClientId;
                    ac.Primary__c = true;
                    insert ac;
                }
            }

            return rsw;
        } catch (exception ex) { rsw.ref = null; rsw.status = 'Error while Inserting Referral: ' + ex.getMessage(); return rsw; }
    }

    public class ReferralSubmitWrapper
    {
        @AuraEnabled public Referral__c ref;
        @AuraEnabled public String status;
    }

    public class PrimReasonWrapper
    {
        @AuraEnabled public Id ServiceId;
        @AuraEnabled public String Name;
        @AuraEnabled public String Description;
    }
}