public with sharing class RelationshipTriggerHandler implements ITriggerHandler {

    public void BeforeInsert(List<SObject> newItems) {}
  
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
  
    public void BeforeDelete(Map<Id, SObject> oldItems) {}

    public void AfterInsert(Map<Id, SObject> newItems) {

        createReciprocal((Map<Id, Relationship__c>)newItems);
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

        updateReciprocal((Map<ID, Relationship__c>) newItems, (Map<Id, Relationship__c>) oldItems);
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    public static void createReciprocal(Map<Id, Relationship__c> relationshipMap){
        String objectName = 'Client__c';
        String fieldName ='Legal_Sex__c';
        Map<String, String> genderAPItoLabelMap = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            if(!genderAPItoLabelMap.containsKey(pickListVal.getValue())){
                genderAPItoLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
            }
        } 

        List<Relationship__c> reciprocalRelationshipList =  new List<Relationship__c>();
        Map<Id, Relationship__c> relationshipDataMap = new Map<Id, Relationship__c>(); 
        List<Relation_Reciprocal_Mapping__mdt> relationMetaData = [SELECT id, Label, DeveloperName, Reciprocal_Female__c, Reciprocal_Male__c, Reciprocal_Neutral__c FROM Relation_Reciprocal_Mapping__mdt];
        if(relationshipMap != null && relationshipMap.size()>0){
            relationshipDataMap = new Map<Id, Relationship__c>([SELECT id, Original_Relation__c, Primary_Member__c,Relation__c,Name,Secondary_Member__c, Summary__c, Type__c, Secondary_Member__r.Date_Of_Birth__c, Primary_Member__r.Date_Of_Birth__c FROM Relationship__c WHERE Id IN: relationshipMap.keySet()]);
        }
        //IsOver__c, Start_Date__c, Expiry_Date__c
        Map<String, Relation_Reciprocal_Mapping__mdt> nameToRelationMDTMap = new Map<String, Relation_Reciprocal_Mapping__mdt>();
        for(Relation_Reciprocal_Mapping__mdt relationMDTitr : relationMetaData){
            if(!nameToRelationMDTMap.containsKey(relationMDTitr.Label)){
                nameToRelationMDTMap.put(relationMDTitr.Label, relationMDTitr);
            }
        }
        System.debug('nameToRelationMDTMap####'+ nameToRelationMDTMap);
        
        List<Id> clientIds = new List<Id>();
        for(Relationship__c rel : relationshipDataMap.values()){
            clientIds.add(rel.Secondary_Member__c);
        }
        Map<Id, Client__c> idToClientMap = new Map<Id, Client__c>([SELECT Id, Legal_Sex__c FROM Client__c  WHERE Id IN:clientIds]);
        
        for(Relationship__c relationItr : relationshipDataMap.values()){
            //Create a new Relationship record
            Relationship__c reciprocalRelationship = new Relationship__c();
            reciprocalRelationship.Type__c =  relationItr.Type__c;
            reciprocalRelationship.Primary_Member__c =  relationItr.Secondary_Member__c;
            reciprocalRelationship.Secondary_Member__c =  relationItr.Primary_Member__c;
            reciprocalRelationship.Original_Relation__c = relationItr.Id;
            if(nameToRelationMDTMap != null && nameToRelationMDTMap.containsKey(relationItr.Relation__c)){
                if(idToClientMap != null && idToClientMap.containsKey(relationItr.Secondary_Member__c)){
                    Client__c con = idToClientMap.get(relationItr.Secondary_Member__c);
                    if(genderAPItoLabelMap != null && genderAPItoLabelMap.containsKey(con.Legal_Sex__c) && genderAPItoLabelMap.get(con.Legal_Sex__c) == 'Male'){
                        reciprocalRelationship.Relation__c = nameToRelationMDTMap.get(relationItr.Relation__c).Reciprocal_Male__c;
                    }
                    else if (genderAPItoLabelMap != null && genderAPItoLabelMap.containsKey(con.Legal_Sex__c) && genderAPItoLabelMap.get(con.Legal_Sex__c) == 'Female'){
                        reciprocalRelationship.Relation__c = nameToRelationMDTMap.get(relationItr.Relation__c).Reciprocal_Female__c;
                    }
                    else{
                        reciprocalRelationship.Relation__c = nameToRelationMDTMap.get(relationItr.Relation__c).Reciprocal_Neutral__c;
                    }
                    /*if(nameToRelationMDTMap.get(relationItr.Relation__c).Time_Period__c == 'Permanent'){
                        if(relationItr.Start_Date__c== null){
                            if(relationItr.Secondary_Member__r.Birthdate > relationItr.Primary_Member__r.Birthdate){
                                relationItr.Start_Date__c= relationItr.Secondary_Member__r.Birthdate;
                                reciprocalRelationship.Start_Date__c= relationItr.Secondary_Member__r.Birthdate;
                            }
                            else if(relationItr.Primary_Member__r.Birthdate > relationItr.Secondary_Member__r.Birthdate){
                                relationItr.Start_Date__c= relationItr.Primary_Member__r.Birthdate;
                                reciprocalRelationship.Start_Date__c= relationItr.Primary_Member__r.Birthdate;
                            }
                        }
                    }*/
                    /*reciprocalRelationship.IsOver__c = relationItr.IsOver__c;
                	reciprocalRelationship.Expiry_Date__c = relationItr.Expiry_Date__c;
                    reciprocalRelationship.Start_Date__c = relationItr.Start_Date__c;*/
                }  
            }
            reciprocalRelationshipList.add(reciprocalRelationship);
            reciprocalRelationshipList.add(relationItr);
            TriggerCount.setRunTimes();
        }
        if(reciprocalRelationshipList != null && reciprocalRelationshipList.size()>0){
            upsert reciprocalRelationshipList;
        }        
    }
    /**
     * @description Is Over & Effective Untill date is populated on reciprocal should also reflect on primary and vise versa
     * @return void
     */
    public static void updateReciprocal(Map<Id, Relationship__c> relationshipNewMap, Map<Id, Relationship__c> relationshipOldMap){
        List<Relationship__c> reciproRelListUpdated = new List<Relationship__c>();
        List<Id> primaryRelIdUpdated = new List<Id>();
        List<Id> primaryRelIds = new List<Id>();
        List<Relationship__c> relationRecsTobeUpdated = new List<Relationship__c>();
       	Map<Id, Relationship__c> priRelIdToPriRecMap = new Map<Id, Relationship__c>();
        List<Relation_Reciprocal_Mapping__mdt> relationMetaData = [SELECT id, Label, DeveloperName, Reciprocal_Female__c, Reciprocal_Male__c, Reciprocal_Neutral__c FROM Relation_Reciprocal_Mapping__mdt];
        Map<String, Relation_Reciprocal_Mapping__mdt> nameToRelationMDTMap = new Map<String, Relation_Reciprocal_Mapping__mdt>();
        for(Relation_Reciprocal_Mapping__mdt relationMDTitr : relationMetaData){
            if(!nameToRelationMDTMap.containsKey(relationMDTitr.Label)){
                nameToRelationMDTMap.put(relationMDTitr.Label, relationMDTitr);
            }
        }
        System.debug('nameToRelationMDTMap####'+ nameToRelationMDTMap);
        if(relationshipNewMap != null && relationshipNewMap.size()>0){
            for(Relationship__c relItr : relationshipNewMap.values()){
                //relItr.IsOver__c != relationshipOldMap.get(relItr.Id).IsOver__c || relItr.Expiry_Date__c != relationshipOldMap.get(relItr.Id).Expiry_Date__c || relItr.Start_Date__c != relationshipOldMap.get(relItr.Id).Start_Date__c || 
                if(relItr.Relation__c != relationshipOldMap.get(relItr.Id).Relation__c){
                    //if records Original_Relation__c is not null, that means it is a reciprocal relation.
                    if(relItr.Original_Relation__c != null){
                        reciproRelListUpdated.add(relItr);
                        primaryRelIds.add(relItr.Original_Relation__c);
                    }
                    //else it is a Primary relation
                    else{
                        primaryRelIdUpdated.add(relItr.Id);
                        if(priRelIdToPriRecMap != null && !priRelIdToPriRecMap.containsKey(relItr.Id)){
                            priRelIdToPriRecMap.put(relItr.Id, relItr);
                        }
                    }
                }
            }
        }
        String objectName = 'Client__c';
        String fieldName ='Legal_Sex__c';
        Map<String, String> genderAPItoLabelMap = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            if(!genderAPItoLabelMap.containsKey(pickListVal.getValue())){
                genderAPItoLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
            }
        } 
        //IsOver__c, Expiry_Date__c,
		Map<Id, Relationship__c> priIdToPriRelRecMap = new Map<Id, Relationship__c>([SELECT Id,  Relation__c,Type__c, Primary_Member__r.Legal_Sex__c FROM Relationship__c WHERE Id IN: primaryRelIds]);
        // case when Reciprocal record is updated -> update the Primary record as well
        if(reciproRelListUpdated != null && reciproRelListUpdated.size()>0){
            for(Relationship__c relItr : reciproRelListUpdated){
                Relationship__c relRecord = priIdToPriRelRecMap.get(relItr.Original_Relation__c);
                System.debug('relRecord....'+relRecord);
                /*relRecord.IsOver__c = relItr.IsOver__c;
                relRecord.Expiry_Date__c = relItr.Expiry_Date__c;
                relRecord.Start_Date__c = relItr.Start_Date__c;*/
                if(genderAPItoLabelMap != null && genderAPItoLabelMap.containsKey(relRecord.Primary_Member__r.Legal_Sex__c) && genderAPItoLabelMap.get(relRecord.Primary_Member__r.Legal_Sex__c) == 'Male'){
                    relRecord.Relation__c = nameToRelationMDTMap.get(relItr.Relation__c).Reciprocal_Male__c;
                }
                else if(genderAPItoLabelMap != null && genderAPItoLabelMap.containsKey(relRecord.Primary_Member__r.Legal_Sex__c) && genderAPItoLabelMap.get(relRecord.Primary_Member__r.Legal_Sex__c) == 'Female'){
                    relRecord.Relation__c = nameToRelationMDTMap.get(relItr.Relation__c).Reciprocal_Female__c;
                }
                else{
                    relRecord.Relation__c = nameToRelationMDTMap.get(relItr.Relation__c).Reciprocal_Neutral__c;
                }
                relRecord.Type__c = relItr.Type__c;
                relationRecsTobeUpdated.add(relRecord);
            }
        }
        //Case when primary Record is updated -> update the reciprocal record as well
        
        if(primaryRelIdUpdated != null && primaryRelIdUpdated.size()>0){
            //IsOver__c, Expiry_Date__c,
			List<Relationship__c> reciprocalRelations = [SELECT Id, Original_Relation__c,  Relation__c, Primary_Member__r.Legal_Sex__c FROM Relationship__c WHERE Original_Relation__c IN: primaryRelIdUpdated];    
            for(Relationship__c reciRelItr : reciprocalRelations){
                if(priRelIdToPriRecMap!= null && priRelIdToPriRecMap.containsKey(reciRelItr.Original_Relation__c)){
                    /*reciRelItr.IsOver__c = priRelIdToPriRecMap.get(reciRelItr.Original_Relation__c).IsOver__c;
                    reciRelItr.Expiry_Date__c = priRelIdToPriRecMap.get(reciRelItr.Original_Relation__c).Expiry_Date__c;
                    reciRelItr.Start_Date__c = priRelIdToPriRecMap.get(reciRelItr.Original_Relation__c).Start_Date__c;*/
                    String relName = priRelIdToPriRecMap.get(reciRelItr.Original_Relation__c).Relation__c;
                    if(genderAPItoLabelMap != null && genderAPItoLabelMap.containsKey(reciRelItr.Primary_Member__r.Legal_Sex__c) && genderAPItoLabelMap.get(reciRelItr.Primary_Member__r.Legal_Sex__c )== 'Male'){
                        reciRelItr.Relation__c = nameToRelationMDTMap.get(relName).Reciprocal_Male__c;
                    }
                    else if(genderAPItoLabelMap != null && genderAPItoLabelMap.containsKey(reciRelItr.Primary_Member__r.Legal_Sex__c) && genderAPItoLabelMap.get(reciRelItr.Primary_Member__r.Legal_Sex__c )== 'Female'){
                        reciRelItr.Relation__c = nameToRelationMDTMap.get(relName).Reciprocal_Female__c;
                    }
                    else{
                        reciRelItr.Relation__c = nameToRelationMDTMap.get(relName).Reciprocal_Neutral__c;
                    }
                    relationRecsTobeUpdated.add(reciRelItr);
                }
        	}
        }
        if(relationRecsTobeUpdated != null && relationRecsTobeUpdated.size() > 0){
            update relationRecsTobeUpdated;
        }
    }
}