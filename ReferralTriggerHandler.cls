public with sharing class ReferralTriggerHandler implements ITriggerHandler
{   
    public void BeforeInsert(List<SObject> newItems)
    {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        checkOriginalReferral((List<Referral__c>)((Map<Id, Referral__c>)newItems).values());
        checkPrimaryReasonChange((Map<Id, Referral__c>)oldItems, (Map<Id, Referral__c>)newItems);
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems)
    {}
    
    public void AfterInsert(Map<Id, SObject> newItems)
    {
        configRefShare((List<Referral__c>)((Map<Id, Referral__c>)newItems).values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        changeOwnerOnWailist((List<Referral__c>)((Map<Id, Referral__c>)newItems).values(), (Map<Id, Referral__c>) oldItems );
        waitListNotAccepted((List<Referral__c>)((Map<Id, Referral__c>)newItems).values(), (Map<Id, Referral__c>) oldItems );
        configRefShare((List<Referral__c>)((Map<Id, Referral__c>)newItems).values());
        configCROwner((Map<Id, Referral__c>)oldItems, (Map<Id, Referral__c>)newItems);
    }

    public void AfterDelete(Map<Id, SObject> oldItems)
    {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems)
    {}
    
    //Method will move the Referral to Waitlist que if status is updated to Waitlist
    public static void changeOwnerOnWailist(List <Referral__c> refList, Map <Id, Referral__c> oldmap)
    {
        Set <ID> refIdSet= new set<ID>();
        String accId;
        String accRTID;
        Account ac= new Account();
        list <Referral__c> dataRefList= new List <Referral__c>();
        List <Referral__c> newRefList= new List <Referral__c>();
        For (Referral__c ref: refList)
        {
            if ((ref.Referral_Status__c != oldmap.get(ref.id).Referral_Status__c) && ref.Referral_Status__c == 'Waitlist')
            {
                refIdSet.add(ref.id);
            }           

        }
        if (refIdSet != null && refIdSet.size() > 0)
        {
           dataRefList= [select Id, Referral_Status__c,Queue_Start_Date__c, OwnerId from Referral__c where id in: refIdSet];
           user u=[select id, ContactId from user where id=: UserInfo.getUserId()];
            System.debug('User####'+ u);
            if (u.ContactId != null)
            {
                System.debug('Users contact is not null####');
                Contact con= [select Id, AccountId from contact where id =:u.ContactId];
                accId=con.AccountId;
            }
            else
            {
                accId=Label.ACDHS;
            }
            if (accId != null && accId != '')
            {
                ac= [select Id, Waiting_Q_ID__c from Account where id =: accId];   
            }
            if(dataRefList != null && dataRefList.size() >0)
            {
                for (Referral__c rf: dataRefList)
                {
                    if (ac != null)
                    {
                        rf.OwnerId=(ID)ac.Waiting_Q_ID__c;
                        rf.Queue_Start_Date__c=date.today();
                        newRefList.add(rf);
                    }
                }
            }
            if ((!newRefList.isEmpty()) && (newRefList.size()>0))
            {
                update newRefList; 
            }
        }
    }
    //Method will assign Referral to current user if status is updated from Waitlist to Not accepted.
    public static void waitListNotAccepted (List <Referral__c> refList, Map <Id, Referral__c> oldmap)
    {
        List <Referral__c> newRefList= new List <Referral__c>();
        Set <ID> refIdSet= new set<ID>();
        list <Referral__c> dataRefList= new List <Referral__c>();

        for (Referral__c ref: refList)
        {
            String staffID=(string)(ref.OwnerId);
            
            if ((oldmap.get(ref.id).Referral_Status__c=='WaitList') && (ref.Referral_Status__c == 'Not Accepted'))
            {
                refIdSet.add(ref.id);
            }
        }      
        if (refIdSet != null && refIdSet.size() > 0)
        {
            dataRefList= [select Id, OwnerId from Referral__c where id in: refIdSet];
        }
        user u=[select id, ContactId from user where id=: UserInfo.getUserId()];
        system.debug('@uid '+u.id);
        if (dataRefList != null && dataRefList.size() >0)
        {
            for (Referral__c rf: dataRefList)
            {
                Referral__c newRef= new Referral__c(
                    id=rf.Id,
                    OwnerId=u.id
                );
                newRefList.add(newRef);
            }
        }
        if ((!newRefList.isEmpty()) && (newRefList.size()>0))
        {
            update newRefList; 
        }
    }

    //Configuring Referral Share Object
    public static void configRefShare (List<Referral__c> listRef)
    {
        List<Referral__Share> listRefShare = new List<Referral__Share>();
        Set<Id> setUserId = new Set<Id>();
        Map<Id, Id> mapRefIdGrpId = new Map<Id, Id>();
        Map<Id, Id> mapUserIdAccId = new Map<Id, Id>();
        Set<Id> setConfRefId = new Set<Id>();
        
        
        for (Referral__c ref : listRef)
        {
            if (ref.Confidential__c == false && ref.InActive__c == false)
            {
                if (String.valueOf(ref.OwnerId).startsWithIgnoreCase('00G'))
                {
                    system.debug('#### Owner is Queue');
                    GroupMember gm = [Select UserOrGroupId From GroupMember where GroupId = :ref.OwnerId LIMIT 1];
                    mapRefIdGrpId.put(ref.Id, gm.UserOrGroupId);
                }
                else
                {
                    setUserId.add(ref.OwnerId);
                }
            }

            if (ref.Confidential__c) setConfRefId.add(ref.Id);
        }
        system.debug('#### setUserId: ' + setUserId);
        system.debug('#### mapRefIdGrpId: ' + mapRefIdGrpId);

        for (User u : [select Id, Name, ContactId, IsActive from User where Id IN :setUserId AND ContactId = null AND IsActive = true])
        {
            mapUserIdAccId.put(u.Id, Label.ACDHS);
        }
        for (User u : [select Id, Name, ContactId, Contact.AccountId from User where Id IN :setUserId AND ContactId != null AND IsActive = true])
        {
            mapUserIdAccId.put(u.Id, u.Contact.AccountId);
        }
        system.debug('#### mapUserIdAccId: ' + mapUserIdAccId);

        Map<Id, Id> mapAccIdGrpId = new Map<Id, Id>();

        for (Account acc : [select Id, Public_Group_ID__c from Account where Id IN :mapUserIdAccId.values()])
        {
            mapAccIdGrpId.put(acc.Id, acc.Public_Group_ID__c);
        }
        system.debug('#### mapAccIdGrpId: ' + mapAccIdGrpId);

        for (Referral__c ref : listRef)
        {
            if (ref.Confidential__c == false && ref.InActive__c == false)
            {
                Referral__Share refShare = new Referral__Share();
                refShare.ParentId = ref.Id;
                refShare.UserOrGroupId = (String.valueOf(ref.OwnerId).startsWithIgnoreCase('00G')) ? (mapRefIdGrpId.get(ref.Id)) : (mapAccIdGrpId.get(mapUserIdAccId.get(ref.OwnerId)));
                refShare.AccessLevel = 'edit';
                refShare.RowCause = Schema.Referral__Share.RowCause.Manual;
                listRefShare.add(refShare);
            }
        }

        if (listRefShare != null && listRefShare.size() > 0)
        {
            Database.SaveResult[] refShareInsertResult = Database.insert(listRefShare, false);
        }

        if (setConfRefId != null && setConfRefId.size() > 0)
        {
            List<Referral__Share> listConfRefShare = [select Id, ParentId, RowCause from Referral__Share where ParentId IN :setConfRefId AND RowCause = 'Manual'];
            if (listConfRefShare != null && listConfRefShare.size() > 0) delete listConfRefShare;
        }
    }

    //User should not be able to attach Referral of any other Provider in Original Referral Field
    public static void checkOriginalReferral (List<Referral__c> listRef)
    {
        Boolean providerUser = true;
        Set<Id> setSPId = new Set<Id>(); //Set of Provider Ids of which logged in User is a member
        Map<Id, Id> mapRefIdOrgRefId = new Map<Id, Id>();
        Map<Id, Boolean> mapRefIdAccess = new Map<Id, Boolean>(); 
        
        User u = [select Id, Name, ContactId from User where Id = :UserInfo.getUserId()];
        if (u.ContactId == null) //ACDHS User
        {
            providerUser = false;
            //u = [select Id, Name, Contact_Id__c from User where Id = :UserInfo.getUserId()];
        }

        if (providerUser) //Provider User
        {
            for (AccountContactRelation acr : [select Id, AccountId, ContactId from AccountContactRelation where ContactId = :u.ContactId])
            {
                setSPId.add(acr.AccountId);
            }

            for (Referral__c ref : listRef)
            {
                if (ref.Original_Referral__c != null) mapRefIdOrgRefId.put(ref.Id, ref.Original_Referral__c);
            }

            if (mapRefIdOrgRefId.values() != null && mapRefIdOrgRefId.values().size() > 0) //Original Ref is not null
            {
                for (UserRecordAccess ura : [Select RecordId, HasEditAccess, MaxAccessLevel from UserRecordAccess where UserId = :userInfo.getUserId() AND RecordId = :mapRefIdOrgRefId.values()])
                {
                    mapRefIdAccess.put(ura.RecordId, ura.HasEditAccess);
                }

                for (Referral__c ref : listRef)
                {
                    if (ref.Original_Referral__c != null)
                    {
                        Boolean hasAccess = mapRefIdAccess.get(ref.Original_Referral__c);
                        if (hasAccess == false) ref.addError('Selected Original Referral is not from your Provider. Please select a different Referral record.');
                    }
                }
            }
        }
        /* else //ACDHS User
        {
            if (u.Contact_Id__c != null)
            {
                for (AccountContactRelation acr : [select Id, AccountId, ContactId from AccountContactRelation where ContactId = :u.Contact_Id__c])
                {
                    setSPId.add(acr.AccountId);
                }
            }
            else
            {
                for (Referral__c ref : listRef)
                {
                    if (ref.Original_Referral__c != null) ref.addError('Logged In User\'s record is not setup correctly. Please contact your System Admin.');
                }
            }
        } */
    }

    //User should not be able to select a Primary Reason which does not align with User's Provider's SP Services
    public static void checkPrimaryReasonChange (Map<Id, Referral__c> mapOldRef, Map<Id, Referral__c> mapNewRef)
    {
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        List<Referral__c> listRef = new List<Referral__c>();
        Set<Id> setAccId = new Set<Id>();
        Set<Id> setServId = new Set<Id>();

        User u = [select Id, Name, Contact_Id__c, ContactId from User where Id = :UserInfo.getUserId()];
        if (u.Contact_Id__c != null) //ACDHS User
        {
            listACR = [select Id, ContactId, AccountId from AccountContactRelation where ContactId = :u.Contact_Id__c];
        }
        else //Provider User
        {
            //u = [select Id, Name, ContactId from User];
            listACR = [select Id, ContactId, AccountId from AccountContactRelation where ContactId = :u.ContactId];
        }

        for (Referral__c ref : mapNewRef.values())
        {
            if (mapOldref.get(ref.Id).Primary_Reason1__c != mapNewRef.get(ref.Id).Primary_Reason1__c && mapNewRef.get(ref.Id).Primary_Reason1__c != null)
            {
                listRef.add(ref);
            }
        }

        if (listACR != null && listACR.size() > 0)
        {
            for (AccountContactRelation acr : listACR)
            {
                setAccId.add(acr.AccountId);
            }

            for (SP_Service__c sps : [select Id, Service_Provider__c, Service__c from SP_Service__c where Service_Provider__c IN :setAccId])
            {
                setServId.add(sps.Id);
            }
        }

        for (Referral__c ref : listRef)
        {
            if (!setServId.contains(ref.Primary_Reason1__c))
            {
                ref.addError('This Service is not provided by your Provider. Please select any other Service in Primary Reason.');
            }
        }
    }

    //Owner of Client Referral should also change with Owner change in Referral
    public static void configCROwner (Map<Id, Referral__c> mapOldRef, Map<Id, Referral__c> mapNewRef)
    {
        Map<Id, Id> mapRefIdOwnerId = new Map<Id, Id>();

        for (Referral__c ref : mapNewRef.values())
        {
            if (mapOldRef.get(ref.Id).OwnerId != mapNewRef.get(ref.Id).OwnerId && !String.valueOf(mapNewRef.get(ref.Id).OwnerId).startsWithIgnoreCase('00G'))
            {
                mapRefIdOwnerId.put(ref.Id, ref.OwnerId);
            }
        }

        if (mapRefIdOwnerId.values() != null && mapRefIdOwnerId.values().size() > 0)
        {
            List<Client_Referral__c> listCR = [select Id, Referral__c, OwnerId from Client_Referral__c where Referral__c IN :mapRefIdOwnerId.keySet()];
            for (Client_Referral__c cr : listCR)
            {
                cr.OwnerId = mapRefIdOwnerId.get(cr.Referral__c);
            }
            update listCR;
        }
    }
}