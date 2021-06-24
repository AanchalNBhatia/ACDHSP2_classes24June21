public with sharing class userDetails {
    //This class is used in Soft Delete LWC component

    //Method is used to chack the record access of user.
    @AuraEnabled(cacheable=true)
    public static boolean checkAccess(string recId)
    {
        boolean accessFlag=false;
        Id userId = UserInfo.getUserId();
        UserRecordAccess ura = [select RecordId, HasEditAccess, MaxAccessLevel from UserRecordAccess where UserId = :userId AND RecordId = :recId];
        if (ura.RecordId != null && ura.HasEditAccess==true)
            {
                accessFlag=true;
            }
        //system.debug('@rec '+recid);
        //system.debug('@objname '+objAPIName);
        
        return accessFlag;
    }
   /* @AuraEnabled(cacheable=true)
    public static String getUserTitle(String cUId) {
        String userTitle;
        User currentUser=[Select Id, ContactId from User where Id =:cUId limit 1];
        //system.debug('@uid '+currentUser.Id);
        Contact con=[select id, Title from Contact where id =: currentUser.ContactId limit 1];
        //system.debug('@contitle '+con.Title);
        if (con.Title != Null && con.Title != '')
        {
            userTitle=con.Title;
        }
        else{
            userTitle='No Access';
        }
        return userTitle;
    }*/
    //Method is used to check the validity of Deleted record user.
    @AuraEnabled(cacheable=true)
    public static Boolean validUser() {
        String uId = Label.Delete_Record_Owner;
        System.debug('uId....'+uId);
        //if uId not blank
        Boolean userFlag=false;
        List <User> userList= new List<User>();
        if(uId != null && uId != ''){
            userList = [Select Id , Name, IsActive from User where Id =:uId limit 1];
        }
        //system.debug('@ulist '+userlist.isEmpty());
        if((userList != null) && (userList.size() > 0)){
            if (userlist[0].IsActive)
            {
                userFlag=true;
            }
        }     
        //system.debug('@flag '+userFlag1); 
        return userFlag;      
    }
    //Method is used to provide current user Profile & Title.
    @AuraEnabled(cacheable=true)
    public static userWrapper getUserInfo(string uId)
    {
        uId = userInfo.getUserId();
        userWrapper uWrapper=new userWrapper();
        String uTitle;
        string uProfile;
        User currentUser=[Select Id, ContactId, Contact_Id__c, ProfileId from User where Id =:uId];
        uProfile=[select name from profile where id =:currentUser.ProfileId].name;
        system.debug('conid '+currentUser.ContactId);
        if(currentUser.ContactId != null)
        {
            Contact con=[select id, Title from Contact where id =: currentUser.ContactId];
            uTitle=con.Title;
        }
        else if (currentUser.Contact_Id__c != null)
        {
            Contact con=[select id, Title from Contact where id =: currentUser.Contact_Id__c limit 1];
            uTitle=con.Title;
        }
        else
        {
            system.debug('User is not setup properly');
        }
        
        uWrapper.userTitle=uTitle;
        uWrapper.userProfile=uProfile;

        return uWrapper;
    }
    
    public class userWrapper{
        @AuraEnabled public String userTitle;
        @AuraEnabled public String userProfile;
    }
   
}