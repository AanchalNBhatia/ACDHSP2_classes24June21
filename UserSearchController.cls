public with sharing class UserSearchController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchUsersACDHSUsers(String searchTerm, List<String> selectedIds) {
        
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, Name WHERE ContactId = '' AND IsActive=true AND id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];
        //ContactId = '' AND 
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User user : users) {
            results.add(new LookupSearchResult(user.Id, 'User', userIcon, user.Name, ''));
        }

        return results;
    }
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchUsersPortalUsers(String searchTerm, List<String> selectedIds, String accId) {
        System.debug('searchTerm....'+ searchTerm);
        System.debug('selectedIds....'+ selectedIds);
        System.debug('accId....'+ accId);
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, Name WHERE id NOT IN :selectedIds AND IsActive=true AND Contact.AccountId = :accId )
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User user : users) {
            results.add(new LookupSearchResult(user.Id, 'User', userIcon, user.Name, ''));
        }

        // Optionnaly sort all results on title
        //results.sort();

        return results;
    }
    /*
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchAllActiveUsers(String searchTerm, List<String> selectedIds) {
        
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, Name WHERE IsActive=true AND id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];
        //ContactId = '' AND 
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User user : users) {
            results.add(new LookupSearchResult(user.Id, 'User', userIcon, user.Name, ''));
        }

        return results;
    }*/
}