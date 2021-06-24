public with sharing class SPPortalContainerCntrl
{
    @AuraEnabled(cacheable=true)
    public static sObject getUserDetails (Id userId)
    {
        User loggedUser = [select Id, FirstName, LastName, Name, CompanyName, Contact_Id__c, ContactId, Contact.AccountId, Contact.Account.Name, Contact.Title, IsPortalEnabled, Profile.Name, Profile.UserType, Profile.UserLicense.Name from User where Id = :userId];
        
        /* if ((loggedUser.Profile.Name.contains('Internal') || loggedUser.Profile.Name.contains('System Administrator')) && loggedUser.Contact_Id__c != null && loggedUser.Contact_Id__c != '')//ACDHS Users
        {
            Contact con = [select Id, Name, AccountId, Account.Name, Title from Contact where Id = :loggedUser.Contact_Id__c];
            return con;
        }
        else
        {
            return loggedUser;
        } */

        return loggedUser;
    }
}