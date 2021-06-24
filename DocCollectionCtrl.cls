public class DocCollectionCtrl 
{
    @AuraEnabled
    public static string getSite(){
        return Site.getSiteType();
    }
    
    @AuraEnabled
    public static String updateDocName (String docId, String docName, String notes)
    {
        ContentDocument cd = [select Id, Title, FileExtension, Description, LatestPublishedVersionId from ContentDocument where Id = :docId];
        ContentVersion cv = [select Id, Title, Document_Category__c from ContentVersion where Id = :cd.LatestPublishedVersionId];
        cv.Title = docName + ' - ' + cv.Title;
        cv.Document_Category__c = docName;
        cv.Upload_Date__c = System.today();
        cv.Notes__c = notes;
        try {
            update cv;
            return 'SUCCESS';
        } catch (Exception ex)
        {
            return 'ERROR: ' + ex.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DocWrapper> getAllDocs (String recId)
    {
        List<ContentDocumentLink> listCDL = [select Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Document_Category__c, ContentDocument.LatestPublishedVersion.Upload_Date__c, ContentDocument.LatestPublishedVersion.Notes__c, ContentDocument.LatestPublishedVersion.Owner.Name, ContentDocument.LatestPublishedVersion.createdBy.Name FROM ContentDocumentLink WHERE LinkedEntityId = :recId];
        List<DocWrapper> listDocWrp = new List<DocWrapper>();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        if (listCDL != null && listCDL.size() > 0)
        {
            for (ContentDocumentLink cdl : listCDL)
            {
                DocWrapper dw = new DocWrapper();
                dw.Id = cdl.ContentDocument.LatestPublishedVersionId;
                dw.contentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
                if (profileName == 'System Administrator' || profileName == 'Internal Super User') {
                    dw.urlId ='/' + cdl.ContentDocumentId;
                }
                else{
                    dw.urlId = System.Label.Portal_URL+'/contentdocument/' + cdl.ContentDocumentId;
                }   
                dw.docTitle = cdl.ContentDocument.Title;
                dw.docDesc = cdl.ContentDocument.LatestPublishedVersion.Notes__c;
                dw.docExt = cdl.ContentDocument.FileExtension;
                dw.uploadDate = cdl.ContentDocument.LatestPublishedVersion.Upload_Date__c;
                dw.docType = cdl.ContentDocument.LatestPublishedVersion.Document_Category__c;
                dw.createdBy = cdl.ContentDocument.LatestPublishedVersion.createdBy.Name;
                listDocWrp.add(dw);
            }
            return listDocWrp;
        }
        return null;
    }
    
    @AuraEnabled
    public static String updateCDL (List<Object> listCDL, String recId, String str)
    {
        system.debug('#### str: ' + str);
        List<Object> listStr = (List<Object>)JSON.deserializeUntyped(str);
        List<ContentVersion> listCV = new List<ContentVersion>();
        for (Object o : listStr)
        {
            ContentVersion cv = new ContentVersion();
            Map<String, Object> itemAttributes = (Map<String, Object>)o;
            system.debug('#### itemAttributes: ' + itemAttributes);
            cv.Id = (String)itemAttributes.get('Id');
            if ((String)itemAttributes.get('docTitle') != null && (String)itemAttributes.get('docTitle') != '')
            {
                cv.Title = (String)itemAttributes.get('docTitle');
            }
            if ((String)itemAttributes.get('docDesc') != null && (String)itemAttributes.get('docDesc') != '')
            {
                cv.Notes__c = (String)itemAttributes.get('docDesc');
            }
            if (itemAttributes.get('uploadDate') != null)
            {
                String uploadDate = (String)itemAttributes.get('uploadDate');
                cv.Upload_Date__c = Date.valueOf(uploadDate.substringBefore('T'));
            }
            listCV.add(cv);
        }
        system.debug('#### cvlist: ' + listCV);
        try {
            update listCV;
            return 'SUCCESS';
        } catch (Exception ex)
        {
            return 'Error: ' + ex.getMessage();
        }
    }
    @AuraEnabled
    public static void uploadToConAcc(String DocId, List<String> ContactIds, List<String> AccountIds, Boolean isContactUpload, Boolean isAccountUpload){
        List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();
        Set<String> ContactIdsSet = new Set<String>();
        Set<String> AccountIdsSet = new Set<String>();
        ContactIdsSet.addAll(ContactIds);
        AccountIdsSet.addAll(AccountIds);
        System.debug('ContactIds....'+ContactIds);
        System.debug('AccountIds....'+AccountIds);
        if(isContactUpload && DocId != null && ContactIds != null && ContactIds.size()>0){
            for(String conId : ContactIdsSet){
                ContentDocumentLink cdlNew = new ContentDocumentLink();
                cdlNew.ContentDocumentId = DocId;
                cdlNew.LinkedEntityId = conId;
                cdlNew.ShareType = 'I';
                cdlNew.Visibility = 'AllUsers';
                listCDL.add(cdlNew);
            }
        }

        if(isAccountUpload && DocId != null && AccountIds != null && AccountIds.size()>0){
            for(String accId : AccountIdsSet){
                ContentDocumentLink cdlNew = new ContentDocumentLink();
                cdlNew.ContentDocumentId = DocId;
                cdlNew.LinkedEntityId = accId;
                cdlNew.ShareType = 'I';
                cdlNew.Visibility = 'AllUsers';
                listCDL.add(cdlNew);
            }
        }

        if(listCDL != null && listCDL.size()>0){
            insert listCDL;
        }
    }
    @AuraEnabled(cacheable=true)
    public static String getAccIdForUser(String userId){
        System.debug('userId....'+userId);
        if(userId != ''){
            List<User> user = [SELECT Id, ContactId, Contact.AccountId from User WHERE Id = :userId LIMIT 1];
            if(user[0].ContactId != null){
                return user[0].Contact.AccountId;
            }
            else{
                return '';
            }
        }
        else {
            return '';
        }
    }
    @AuraEnabled(cacheable=true)
    public static String getAccIdforRefOwner(String referralId){
        System.debug('referralId....'+referralId);
        List<Referral__c> ref = [SELECT Id, OwnerId, Referral_Status__c from Referral__c WHERE Id = :referralId LIMIT 1];
        String userId='';
        if(ref != null && ref.size()>0){
            if(ref[0].Referral_Status__c == 'Waitlist'){
                userId = ref[0].OwnerId;
            }
            else{
                System.debug('ref[0].OwnerId....'+ref[0].OwnerId);
                userId = getAccIdForUser(ref[0].OwnerId);
            }
        }
        return userId;
    }
    @AuraEnabled(cacheable=true)
    public static RefDetailsWrapper getRefDetails(String referralId){
        List<Client_Referral__c> ref = [SELECT Id, Client__c, Referral__c, Referral__r.Confidential__c FROM Client_Referral__c WHERE Referral__c = :referralId];
        RefDetailsWrapper refWrapObj = new RefDetailsWrapper();
        List<String> contactIdsList = new List<String>();
        List<String> priAccIdsList = new List<String>();
        if(ref != null && ref.size()>0){
            for(Client_Referral__c cliRefItr : ref){
                contactIdsList.add(cliRefItr.Client__c);
                HouseHoldAccountWrapper hhwrapObj = new HouseHoldAccountWrapper();
                hhwrapObj = getHHAcc(cliRefItr.Client__c);
                if(hhwrapObj != null && hhwrapObj.accountId != null){
                    priAccIdsList.add(hhwrapObj.accountId);
                }
                refWrapObj.isConfidential = cliRefItr.Referral__r.Confidential__c;
            }
            refWrapObj.ClientIds = contactIdsList;
            refWrapObj.HouseholdIds = priAccIdsList;
        }
        
        return refWrapObj;
    }
    @AuraEnabled(cacheable=true)
    public static String getAccIdFromWaitQId(String queId){
        List<Account> acc = [SELECT Id, Name, Waiting_Q_Id__c FROM Account WHERE Waiting_Q_Id__c = :queId LIMIT 1];
        if(acc != null && acc.size()>0){
            return acc[0].Id;
        }
        else{
            return '';
        }
    }
    @AuraEnabled(cacheable=true)
    public static String getAccNameFromAccId(String accId){
        Account accObj = [SELECT Id, Name FROM Account WHERE Id = :accId];
        if(accObj != null){
            return accObj.Name;
        }
        else{
            return '';
        }
    }
    @AuraEnabled(cacheable=true)
    public static HouseHoldAccountWrapper getHHAcc(String clientId){
        List<Account_Client__c> accClientList = [SELECT Id, Client__c, Account__c, Account__r.Name FROM Account_Client__c WHERE Client__c =: clientId AND Primary__c= true LIMIT 1];
        HouseHoldAccountWrapper hhaccwrapObj = new HouseHoldAccountWrapper();
        if(accClientList != null && accClientList.size()>0 && accClientList[0] != null){
            hhaccwrapObj.accountId = accClientList[0].Account__c;
            hhaccwrapObj.accountName= accClientList[0].Account__r.Name;
        }
        return hhaccwrapObj;
    }
    @AuraEnabled(cacheable=true)
    public static String getRole(String userId){
        User loggedInUser = [SELECT Id, UserRole.Name FROM User WHERE Id =: userId LIMIT 1];
        String role = '';
        if(loggedInUser != null){
            role = loggedInUser.UserRole.Name;
        }
        return role;
    }
    @AuraEnabled(cacheable=true)
    public static AccessPermissionsWrapper checkUserAccessOnReferral(String UserId, String ReferralId){
        System.debug('UserId....'+UserId);
        System.debug('ReferralId....'+ReferralId);
        String loggedInUserAccId = getAccIdForUser(UserId);
        String refOwnerAccId = '';
        String accNameForWaitQ = '';
        Boolean isAccess = false;
        Boolean isAdminAccess = false;
        String AccountId = '';
        Referral__c refObj = [SELECT Id, OwnerId, Referral_Status__c FROM Referral__c WHERE Id = :ReferralId];
        
        if(loggedInUserAccId == ''){
            System.debug('....Logged in User is ACDHS USER');
            //check the role, if Admin or Super User, they have access
            String role = getRole(UserId);
            if(refObj != null){
                if(role == 'Admin' || role== 'Super User'){
                    isAccess = true;
                    isAdminAccess = true;
                    if(refObj.Referral_Status__c == 'Waitlist'){
                        System.debug('Referral Status is Waitlist that means owner will be a group');
                        refOwnerAccId = getAccIdFromWaitQId(refObj.OwnerId);
                        if(refOwnerAccId != ''){
                            accNameForWaitQ = getAccNameFromAccId(refOwnerAccId);
                            if(accNameForWaitQ == 'ACDHS'){
                                System.debug('....Waitlist is also for ACDHS Hence access is there');
                                AccountId='';
                            }
                            else{
                                System.debug('....Waitlist is not ACDHS Hence account Id is needed');
                                AccountId = refOwnerAccId;
                            }
                        }
                    }
                    else{
                        System.debug('....Referral is not waitisted');
                        refOwnerAccId = getAccIdforRefOwner(refObj.Id);
                        if(refOwnerAccId == ''){
                            System.debug('....Referrals Owner is also ACDHS, hence access is there');
                            AccountId = '';
                        }
                        else{
                            System.debug('....Referrals Owner is Service Provider, hence no access');
                            AccountId = refOwnerAccId;
                        }
                    }
                }
                else if(refObj.Referral_Status__c == 'Waitlist'){
                    System.debug('Referral Status is Waitlist that means owner will be a group');
                    refOwnerAccId = getAccIdFromWaitQId(refObj.OwnerId);
                    if(refOwnerAccId != ''){
                        accNameForWaitQ = getAccNameFromAccId(refOwnerAccId);
                        if(accNameForWaitQ == 'ACDHS'){
                            System.debug('....Waitlist is also for ACDHS Hence access is there');
                            isAccess = true;
                        }
                        else{
                            System.debug('....Waitlist is not ACDHS Hence access is not there');
                            isAccess = false;
                        }
                    }
                }
                else{
                    System.debug('....Referral is not waitisted');
                    refOwnerAccId = getAccIdforRefOwner(refObj.Id);
                    if(refOwnerAccId == ''){
                        System.debug('....Referrals Owner is also ACDHS, hence access is there');
                        isAccess = true;
                    }
                    else{
                        System.debug('....Referrals Owner is Service Provider, hence no access');
                        isAccess = false;
                    }
                }
            }                
        }
        else{
            System.debug('....Logged in user is service provider USER');
            if(refObj != null){
                if(refObj.Referral_Status__c == 'Waitlist'){
                    refOwnerAccId = getAccIdFromWaitQId(refObj.OwnerId);
                }
                else{
                    refOwnerAccId = getAccIdforRefOwner(refObj.Id);
                }
                if(refOwnerAccId != loggedInUserAccId){
                    System.debug('....Referral Owner is either different Service Provider or ACDHS hence no access');
                    isAccess = false;
                }
                else if(refOwnerAccId == loggedInUserAccId){
                    System.debug('....Referral Owner acc id is same as logged in users account Id hence access');
                    isAccess = true;
                    AccountId = loggedInUserAccId;
                }
            }
        }

        AccessPermissionsWrapper returnWrap = new AccessPermissionsWrapper();
        returnWrap.isAccess = isAccess;
        returnWrap.isAdminAccess = isAdminAccess;
        returnWrap.AccountId = AccountId;
        System.debug('returnWrap # '+ returnWrap);
        return returnWrap;
    }
    @AuraEnabled(cacheable=true)
    public static AccessPermissionsWrapper checkUserAccessOnClientService(String userId, String csId){
        System.debug('UserId....'+userId);
        System.debug('ClientServiceId....'+csId);
        Boolean isAcdhs=false;
        Boolean isPortal = false;
        String contactId = '';
        Boolean isAccess = false;
        Boolean isAdminAccess = false;
        List<User> usrList = [SELECT Id, ContactId, Contact_Id__c,UserRoleId, UserRole.Name FROM User WHERE Id =: userId];
        if(usrList != null && usrList.size()>0){
            if(usrList[0].ContactId != null){
                isPortal = true;
                contactId = usrList[0].ContactId;
            }
            else if(usrList[0].Contact_Id__c != null){
                isAcdhs = true;
                contactId = usrList[0].Contact_Id__c;
                if(usrList[0].UserRoleId!= null){
                    if(usrList[0].UserRole.Name == 'Admin' || usrList[0].UserRole.Name== 'Super User'){
                        isAdminAccess = true;
                    }
                }
            }
        }
        Set<String> accIdsSet = getAccIdsFromACR(contactId);
        String SPServAccId = getAccIdFromCS(csId);

        if(accIdsSet !=null && accIdsSet.size()>0){
            if(accIdsSet.contains(SPServAccId)){
                isAccess = true;
            }
            else{
                isAccess = false;
            }
        }
        AccessPermissionsWrapper returnWrap = new AccessPermissionsWrapper();
        returnWrap.isAccess = isAccess;
        returnWrap.isAdminAccess = isAdminAccess;
        returnWrap.AccountId = SPServAccId;
        return returnWrap;
    }
    public static Set<String> getAccIdsFromACR(String contactId){
        Set<String> accIdSet = new Set<String>();
        
        for(AccountContactRelation acrItr : [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE ContactId =: contactId]){
            accIdSet.add(acrItr.AccountId);
        }
        return accIdSet;
    }
    public static String getAccIdFromCS(String csId){
        String providerId = '';
        List<Client_Service__c> csList = [SELECT Id, SP_Service__c, SP_Service__r.Service_Provider__c FROM Client_Service__c WHERE Id=:csId];
        if(csList != null && csList.size()>0){
            if(csList[0].SP_Service__c != null){
                providerId = csList[0].SP_Service__r.Service_Provider__c;
            }
        }
        return providerId;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getHelpText(){
        List<Doc_Category_Help_Text__mdt> docMetaData = [SELECT Label, Help_Text_Value__c FROM Doc_Category_Help_Text__mdt];
        Map<String, String> helpTextMap = new Map<String, String>();
        for(Doc_Category_Help_Text__mdt itr: docMetaData){
            if(!helpTextMap.containsKey(itr.label)){
                helpTextMap.put(itr.label, itr.Help_Text_Value__c);
            }
        }
        return helpTextMap;
    }
    public class AccessPermissionsWrapper{
        @AuraEnabled public Boolean isAccess;
        @AuraEnabled public Boolean isAdminAccess;
        @AuraEnabled public String AccountId;
    }
    public class RefDetailsWrapper{
        @AuraEnabled public List<String> ClientIds;
        @AuraEnabled public List<String> HouseholdIds;
        @AuraEnabled public Boolean isConfidential;
    }
    public class DocWrapper
    {
        @AuraEnabled public String Id;
        @AuraEnabled public String contentVersionId;
        @AuraEnabled public String urlId;
        @AuraEnabled public String docTitle;
        @AuraEnabled public String docDesc;
        @AuraEnabled public String docExt;
        @AuraEnabled public Date uploadDate;
        @AuraEnabled public String notes;
        @AuraEnabled public String docType;
        @AuraEnabled public String createdBy;
    }
    public class HouseHoldAccountWrapper{
        @AuraEnabled
        public String accountName{get;set;}
        @AuraEnabled
        public String accountId{get;set;}
    }
}