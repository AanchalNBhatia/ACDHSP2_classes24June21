public with sharing class AccountTriggerHandler implements ITriggerHandler {
    public AccountTriggerHandler() 
    {

    }
    public static Map<String, String> queuePGMap = new Map<String, String>();
    public static Map<String, Group> accPGMap = new Map<String, Group>();
    public static Map<String, Group> accQMap = new Map<String, Group>();
    
    public void BeforeInsert(List<SObject> newItems) {}

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        newPublicQueueGroup((List<Account>)((Map<Id, Account>)newItems).values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    //UST 584: Method to create Wiatlist queue & Public group for the New Account.
    public static void newPublicQueueGroup(List <Account> acclist)
    {
        List<Group> queueList = new List<Group>();
        List<Group> publicGroupList = new List<Group>();
        List<Account> accListToBeUpdated = new List<Account>();
        String accountName;
        String accRtName;
        Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name FROM RecordType]);
        Map <String, String> qpGroupId = new Map<String, String>();
        for (Account acc: acclist)
        {
            if(mapRecordType.containsKey(acc.recordTypeId))
                 accRtName = mapRecordType.get(acc.recordTypeId).Name;

            if (accRtName=='Service Provider')
            {
                accountName=acc.Name;
                Group queue = new Group();
                Group createPublicGroup = new Group();
                if (acc.Name.length() > 31)
                {
                    accountName=acc.Name.substring(0,31);
                }
                String queueName = accountName+' Waitlist';
                string publicgroupName=accountName+' Group';
                queue = new Group(Name=queueName, Type='Queue',DoesSendEmailToMembers=false);
                queueList.add(queue);
                createPublicGroup= new Group(Name=publicgroupName, Type='Regular');
                publicGroupList.add(createPublicGroup);
                if(!accPGMap.containsKey(acc.Id)){
                    accPGMap.put(acc.Id, createPublicGroup);
                    accQMap.put(acc.Id, queue);
                }
            }
        }
        if(queueList!=null && queueList.size() > 0){
            insert queueList;
        }
        
        if(publicGroupList!=null && publicGroupList.size() > 0){
            insert publicGroupList;
        }

        if(!accPGMap.isEmpty()){
            accListToBeUpdated = [select Id, Public_Group_ID__c, Waiting_Q_ID__c from Account where Id in :accPGMap.keySet()];
            if(accListToBeUpdated!=null && accListToBeUpdated.size() > 0){
                for(Account acc : accListToBeUpdated){
                    Group pgID=accPGMap.get(acc.Id);
                    Group qID=accqMap.get(acc.Id);
                    acc.Public_Group_ID__c = pgID.Id;
                    acc.Waiting_Q_ID__c = qID.id ;  
                    
                }
                update accListToBeUpdated;
            }
            
            
        }
        
      
        
        if(queueList != null && publicGroupList !=null){
            for(Group queue:queueList){
                for(Group pg:publicGroupList){
                    if(!queuePGMap.containsKey(queue.Id)){
                            queuePGMap.put(queue.Id, pg.Id);
                    }
                }    
            }
        }
     
        if (!queuePGMap.isEmpty())
        {
            assignObject(queuePGMap); 
        }
    }
    @future
    Public static Void assignObject(map<string, string> qpgIdMap)
    {
        List<QueuesObject> qsoList = new List<QueuesObject>();
        List<GroupMember> gmList = new List<GroupMember>();
        for (String qid: qpgIdMap.keySet())
        {
            QueuesObject qso = new QueueSObject(QueueID = qid, SobjectType = 'Referral__c');
            qsoList.add(qso);
            GroupMember gm = new GroupMember(GroupID=qid, UserOrGroupId=qpgIdMap.get(qid));
            gmList.add(gm);
        }
        
        if(qsoList!=null && qsoList.size() > 0){
            insert qsoList;
        }
        
        if(gmList!=null && gmList.size() > 0){
            insert gmList;
        }
    }
    

}