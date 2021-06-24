public with sharing class ExternalReferralController {
    //this class is used in External Referral and Concrete Goods components
    //UST 585,586,621,622: Method to get Client List for External Refeeral & Concrete Goods.
    @AuraEnabled(cacheable=true)
    public static List<ClientListWrapper> getClient(string intId, String rtName)
    {
        system.debug('@rtname '+rtname);
        List<Client__c> getClientList= new List<Client__c>();
        list<ClientListWrapper> clientWrapperList= new List<ClientListWrapper>();
        encounter__c intData=[select Id, Referral__c,Client_Service__c from encounter__c where id =:intId];
        
        If (rtName=='Referral')
        {
            List<Client_Referral__c> cliRefList=new List<Client_Referral__c>([select Id, Client__c from Client_Referral__c where Referral__c =:intData.Referral__c]);
            List<Id> cliList=new List<Id>();
            Referral__c ref=[select id, Referral_Status__c from Referral__c where id =:intData.Referral__c];

            if (cliRefList != null && cliRefList.size() > 0)
            {
                for (Client_Referral__c cliRef: cliRefList)
                {
                    cliList.add(cliRef.Client__c);
                }
                getClientList=[SELECT Id, Name, Full_Name__c,Date_of_Birth__c FROM Client__c WHERE Id IN:cliList ];
                if(getClientList!=null && getClientList.size()>0){
                    for(Client__c cli: getClientList){
                        clientWrapperList.add(new ClientListWrapper(cli.Id, cli.Name, cli.Full_Name__c, cli.Date_of_Birth__c,intData.Referral__c,'Referral',ref.Referral_Status__c));
                    }
                }
            }
        }else {
            List<Junction_Service__c> jServList =new List<Junction_Service__c>([select id, Client__c from Junction_Service__c where Client_Service__c =:intData.Client_Service__c]);
            List<Id> cliList= new List<Id>();
            system.debug('@jservlist '+jServList);
            if (jServList != null && jServList.size() > 0)
            {
                for (Junction_Service__c jServ: jServList)
                {
                    cliList.add(jServ.Client__c);
                }
                getClientList=[SELECT Id, Name, Full_Name__c,Date_of_Birth__c FROM Client__c WHERE Id IN:cliList ];
                if(getClientList!=null && getClientList.size()>0){
                    for(Client__c cli: getClientList){
                        clientWrapperList.add(new ClientListWrapper(cli.Id, cli.Name, cli.Full_Name__c, cli.Date_of_Birth__c,intData.Client_Service__c,'ClientService',''));
                    }
                }
            }
        }
        //system.debug('@Clientdata '+getClientList);
        return clientWrapperList;
    }
    //UST 585,586,621,622: Method gets ExternalReferral List for given Interaction ID
    @AuraEnabled(cacheable=true)
    public static List<External_Referral__c> getExRef(string intId)
    {
        List<External_Referral__c> getExRefList=[select Id, Name, Client__c, Client_Name__c,Referral_Category__c, Referred_To__c from External_Referral__c where Interaction__c =:intId];
        return getExRefList;
    }
    //UST 585,586,621,622: Method gets Concrete Goods List for given Interaction ID
    @AuraEnabled(cacheable=true)
    public static List<Concrete_Goods__c> getConGoods(string intId)
    {
        List<Concrete_Goods__c> getConGoodsList=[select Id, Name, Client__c, Client_Name__c,Category__c,Number_of_Item_Provided__c,Description_of_Items_Provided__c from Concrete_Goods__c where Interaction__c =:intId];
        return getConGoodsList;
    }


    class ClientListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String clientName;
        @AuraEnabled public String clientFullName;
        @AuraEnabled public Date clientDOB;
        @AuraEnabled public String objId;
        @AuraEnabled public String objName;
        @AuraEnabled public String refStatus;

        ClientListWrapper(string Id, string clientName, string clientFullName, Date clientDOB, string objId, String objName, String refStatus)
        {
            this.Id = Id;
            this.clientName = clientName;
            this.clientFullName = clientFullName;
            this.clientDOB = clientDOB;
            this.objId = objId;
            this.objName = objName;
            this.refStatus=refStatus;
        }

    }
}