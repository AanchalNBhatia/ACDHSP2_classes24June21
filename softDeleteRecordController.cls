public with sharing class softDeleteRecordController {
    
    //Method update the Inactive and Owner Id field for Referral Record.
    public static List<Referral__c> deleteReferrals (Set<ID> refIdList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Referral__c> listToReturn = new List<Referral__c>();
        List <Referral__c> refDataList = new List<Referral__c>();
        if (refIdList != Null && refIdList.size()>0)
        {
            refDataList=[select Id, InActive__c, OwnerId from Referral__c where id in:refIdList];
        }
        
        if(refDataList != null && refDataList.size() > 0)
        {
            system.debug('@List '+refDataList);
            for (Referral__c ref : refDataList)
            {
                if(ref.InActive__c == false)
                {
                    ref.InActive__c = true;
                    ref.OwnerId = ownId;
                    listToReturn.add(ref);
                }
            }
        }
        return listToReturn;
    }

    //Method update the Inactive and Owner Id field for Interaction Record.
    public static List<Encounter__c> deleteInteraction (List<ID> intIdList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Encounter__c> listToReturn = new List<Encounter__c>();
        List <Encounter__c> intDataList = new List<Encounter__c>();
        if (intIdList != Null && intIdList.size()>0)
        {
            intDataList=[select Id, InActive__c, OwnerId from Encounter__c where id in:intIdList];
        }
        
        if(intDataList != null && intDataList.size() > 0)
        {
            for (Encounter__c interaction : intDataList)
            {
                if(interaction.InActive__c == false)
                {
                    interaction.InActive__c = true;
                    interaction.OwnerId = ownId;
                    listToReturn.add(interaction);
                }
            }
        }
        return listToReturn;
    }

    //Method update the Inactive and Owner Id field for Client Referral Record.
    public static List <Client_Referral__c> deleteClientReferral (List <ID> cliRefIdList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Client_Referral__c> listToReturn = new List<Client_Referral__c>();
        List <Client_Referral__c> clirefDataList= new List<Client_Referral__c>();
        if (cliRefIdList != Null && cliRefIdList.size()>0)
        {
            clirefDataList=[select Id, InActive__c, OwnerId from Client_Referral__c where Id IN: cliRefIdList];
        }
        
        
        if(clirefDataList != null && clirefDataList.size() > 0)
            {
                for (Client_Referral__c cliref : clirefDataList)
                {
                    if(cliref.InActive__c == false)
                    {
                        cliref.InActive__c = true;
                        cliref.OwnerId = ownId;
                        listToReturn.add(cliref);
                    }
                }
            }
            return listToReturn;
    }

    //Method update the Inactive and Owner Id field for Relationship Record.
    public static List<Relationship__c> deleteRelationship (List<ID> relIDList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Relationship__c> listToReturn = new List<Relationship__c>();
        List <Relationship__c> relDataList=new List<Relationship__c>();
        if (relIDList != null && relIDList.size()>0)
        {
            relDataList=[select ID, InActive__c, OwnerId from Relationship__c where ID in: relIDList];
        }
        
        if(relDataList != null && relDataList.size() > 0)
            {
                for (Relationship__c rel : relDataList)
                {
                    if(rel.InActive__c == false)
                    {
                        rel.InActive__c = true;
                        rel.OwnerId = ownId;
                        listToReturn.add(rel);
                    }
                }
            }
            return listToReturn;
    }

    //Method update the Inactive and Owner Id field for Account Client Record.
    public static List<Account_Client__c> deleteAccCli (List<ID> accCliIDList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Account_Client__c> listToReturn = new List<Account_Client__c>();
        List <Account_Client__c> accClientDataList= new List <Account_Client__c>();
        if (accCliIDList != null && accCliIDList.size()>0)
        {
            accClientDataList=[select Id, InActive__c, OwnerId from  Account_Client__c where id in: accCliIDList];
        }
        if(accClientDataList != null && accClientDataList.size() > 0)
        {
            for (Account_Client__c cliacc : accClientDataList)
            {
                if(cliacc.InActive__c == false)
                {
                    cliacc.InActive__c = true;
                    cliacc.OwnerId = ownId;
                    listToReturn.add(cliacc);
                }
            }
        }
        return listToReturn;
    }
    //Method update the Inactive and Owner Id field for Client Record.
    public static List <Client__c> deleteClient (List <ID> cliIdList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Client__c> listToReturn = new List<Client__c>();
        List <Client__c> clientList=new List<Client__c>();
        if (cliIdList != null && cliIdList.size()>0)
        {
            clientList=[select Id, InActive__c, OwnerId from  Client__c where id in: cliIdList];
        }
        if(clientList != null && clientList.size() > 0)
        {
            for (Client__c cli : clientList)
            {
                if(cli.InActive__c == false)
                {
                    cli.InActive__c = true;
                    cli.OwnerId = ownId;
                    listToReturn.add(cli);
                }
            }
        }
        return listToReturn;

    }

    //Method update the Inactive and Owner Id field for Account Record.
    public static List <Account> deleteAccount (List <ID> accIdList)
    {
        string ownId=label.Delete_Record_Owner;
        List<Account> listToReturn = new List<Account>();
        List <Account> accList=new List<Account>();
        if (accIdList != null && accIdList.size()>0)
        {
            accList=[select Id, InActive__c, OwnerId from  Account where id in: accIdList];
        }
        if(accList != null && accList.size() > 0)
        {
            for (Account acc : accList)
            {
                if(acc.InActive__c == false)
                {
                    acc.InActive__c = true;
                    acc.OwnerId = ownId;
                    listToReturn.add(acc);
                }
            }
        }
        return listToReturn;

    }
    //Method is used for cascading updation of child records of Account record.
    @AuraEnabled
    public static void deleteAccountRecords(List<ID> accID)
    {
        List<sObject> masterList = new List<sObject>();
        List<Account> accountToBeDeleted= new List<Account>();
        List<ID> cliIdList= new List<ID>();
        List <Account_Client__c> accClilist= new List <Account_Client__c>([select Id, Client__c from Account_Client__c where Account__c in: accID]);
        if(accClilist != null && accClilist.size() > 0)
        {
            for (Account_Client__c accCli: accClilist)
            {
                cliIdList.add(accCli.Client__c);
            }
        }
        List<ID> accIdList=new List<ID>(new Map<Id, Account>([select Id from Account where ID IN:accID]).keyset());
        if (accIdList != null && accIdList.size()>0)
            accountToBeDeleted = deleteAccount(accIdList);
        
        if(accountToBeDeleted != null && accountToBeDeleted.size()>0){
            masterList.addAll(accountToBeDeleted);
        }
        
        if(masterList != null && masterList.size() > 0)
        {
            update masterList;
        }
        system.debug('@Account -Client List '+cliIdList);
        deleteClientRecords(cliIdList);
    }

    //Method is used for cascading updation of child records of Client record.
    @AuraEnabled
    public static void deleteClientRecords(List<ID> clientId)
    {
        
        List<sObject> masterList = new List<sObject>();
        List<Client_Referral__c> cliRefToBeDeleted= new List<Client_Referral__c>();
        List<Relationship__c> relationshipToBeDeleted= new List<Relationship__c>();
        List<Account_Client__c> acccliToBeDeleted= new List<Account_Client__c>();
        List<Client__c> clientToBeDeleted= new List<Client__c>();
        
        //Getting referral IDs to delete
        List<ID> refIdList= new List<ID>();
        List <Client_Referral__c> clreflist= new List <Client_Referral__c>([select Id, Referral__c from Client_Referral__c where Client__c in: clientId]);
        if(clreflist != null && clreflist.size() > 0)
        {
            for (Client_Referral__c clref: clreflist)
            {
                refIdList.add(clref.Referral__c);
            }
        }

        //getting Client Referral ID
        List<ID> clirefIDList=new List<ID>(new Map<Id, Client_Referral__c>([select Id from Client_Referral__c where Client__c =:clientId]).keyset());
        if (clirefIDList != null && clirefIDList.size()>0)
            cliRefToBeDeleted = deleteClientReferral(clirefIDList);

        //getting relationship IDs to delete
        List<ID> relIdList=new List<ID>(new Map<Id, Relationship__c>([select Id from Relationship__c where Primary_Member__c =:clientId]).keyset());
        if (relIdList != null && relIdList.size()>0)
            relationshipToBeDeleted = deleteRelationship(relIdList);

        //getting account client IDs
        List<ID> accCLIIDList=new List<ID>(new Map<Id, Account_Client__c>([select Id from Account_Client__c where Client__c =:clientId]).keyset());
        if (accCLIIDList != null && accCLIIDList.size()>0)
            acccliToBeDeleted = deleteAccCli(accCLIIDList);

        //getting Clinet IDs
        List<ID> cliIdList=new List<ID>(new Map<Id, Client__c>([select Id from Client__c where Id =:clientId]).keyset());
        if (cliIdList != null && cliIdList.size()>0)
            clientToBeDeleted = deleteClient(cliIdList);

        if(cliRefToBeDeleted != null && cliRefToBeDeleted.size()>0){
            masterList.addAll(cliRefToBeDeleted);
        }
 
        if(relationshipToBeDeleted != null && relationshipToBeDeleted.size()>0){
            masterList.addAll(relationshipToBeDeleted);
        }
        if(acccliToBeDeleted != null && acccliToBeDeleted.size()>0){
            masterList.addAll(acccliToBeDeleted);
        }
        if(clientToBeDeleted != null && clientToBeDeleted.size()>0){
            masterList.addAll(clientToBeDeleted);
        }
        
        system.debug('@CLient masterList '+masterList);
        if(masterList != null && masterList.size() > 0)
        {
            update masterList;
        } 
        system.debug('@Client-RefList '+refIdList);
        
        deleteReferralRecords(refIdList);
    }

    //Method is used for cascading updation of child records of Referral record.
    @AuraEnabled
    public static void deleteReferralRecords(List<ID> refId)
    {
        
        List<sObject> masterList = new List<sObject>();
        List<Referral__c> referralToBeDeleted= new List<Referral__c>();
        List<Referral__c> dupReferralToBeDeleted= new List<Referral__c>();
        List<Client_Referral__c> cliRefToBeDeleted= new List<Client_Referral__c>();
        List<Encounter__c> interactionsToBeDeleted= new List<Encounter__c>();
        List<Referral__Share> listRefShare = new list<Referral__Share>();
        Set<ID> refIdSet= new Set<ID>();

        /*List<ID> refIdList=new List<ID>(new Map<Id, Referral__c>([select Id from Referral__c where Id=:refId]).keyset());
        for( ID itr: refIdList)
        {
            refIdList.add(itr);
        }*/

        for(Referral__c refItr : [SELECT Id from Referral__c where Id=:refId OR Original_Referral__c =:refId]){
            refIdSet.add(refItr.id);
        }
        if (refIdSet != null && refIdSet.size()>0)
            referralToBeDeleted = deleteReferrals(refIdSet);

        List <ID> clirefIdList=new List<ID> (new Map<Id, Client_Referral__c>([select Id from Client_Referral__c where Referral__c=:refId]).keyset());
        if (clirefIdList != null && clirefIdList.size()>0)
            cliRefToBeDeleted = deleteClientReferral(clirefIdList);

        //List<ID> duprefIdList=new List<ID>(new Map<Id, Referral__c>([select Id from Referral__c where Original_Referral__c =:refId]).keyset());
        /*Set<Id> dupRefSet =new Set<Id>();
        for(Referral__c ref : [select Id from Referral__c where Original_Referral__c =:refId]){
            dupRefSet.add(ref.Id);
        }*/
        /*if (dupRefSet != null && dupRefSet.size()>0)
            dupReferralToBeDeleted = deleteReferrals(dupRefSet);*/

        List<ID> intIdList=new List<ID>(new Map<Id, Encounter__c>([select Id from Encounter__c where Referral__c=:refId]).keyset());
        

        //getting all in master List
        if(referralToBeDeleted != null && referralToBeDeleted.size()>0){
            masterList.addAll(referralToBeDeleted);
        }
        if(cliRefToBeDeleted != null && cliRefToBeDeleted.size()>0){
            masterList.addAll(cliRefToBeDeleted);
        }
        /*if(dupReferralToBeDeleted != null && dupReferralToBeDeleted.size()>0){
            masterList.addAll(dupReferralToBeDeleted);
        }*/
        system.debug('@Referral masterList '+masterList);
        if(masterList != null && masterList.size() > 0)
        {
            update masterList;
        }
        deleteInteractionRecords(intIdList);

        listRefShare = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Referral__Share where ParentId = :refId AND RowCause = 'Manual'];
        if (listRefShare != null && listRefShare.size() > 0)
            delete listRefShare;
        
    }

    //Method is used for cascading updation of child records of Interaction record.
    @AuraEnabled
    public static void deleteInteractionRecords(List<Id> intIDList)
    {
        List<sObject> masterList = new List<sObject>();
        List<Encounter__c> interactionsToBeDeleted= new List<Encounter__c>();

        List<ID> interactionIdList=new List<ID>(new Map<Id, Encounter__c>([select Id from Encounter__c where id IN:intIDList]).keyset());
        if (interactionIdList != null && interactionIdList.size()>0)
            interactionsToBeDeleted = deleteInteraction(interactionIdList);

        if(interactionsToBeDeleted != null && interactionsToBeDeleted.size()>0)
                masterList.addAll(interactionsToBeDeleted);

        if(masterList != null && masterList.size() > 0)
        {
            update masterList;
        }
    }
}