/*
@Company:Infoglen
@Author:Imran
@Creation date:27/11/2017
Reference:
*/
/**
 * Class S2SPartnerNetworkRecordUtility
 *
 * This class is used to return new and old record id's of all objects
 */
public class S2SPartnerNetworkRecordUtility{
    
    public static Map<Id,Id> getData(List<String> listOldId){   
        //Map of old and new record id's
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        
        //Passing old id's to query to get new record id's
        for(PartnerNetworkRecordConnection obj : [select Id, ConnectionId, PartnerRecordId, LocalRecordId from PartnerNetworkRecordConnection where PartnerRecordId in :listOldId AND (Status ='Sent' OR Status = 'Received')]){
            oldNewIdMap.put(obj.PartnerRecordId,obj.LocalRecordId);
        }
        return oldNewIdMap;
    }

    public static Map<String,Id> getUsers(List<String> listEmailId){
        Map<String,Id> mapUsersWithNewId = new Map<String,Id>();
        for(User obj : [SELECT Id,Source_User_Rec_Id_c__c FROM User WHERE Source_User_Rec_Id_c__c IN : listEmailId AND IsActive=true]){
            mapUsersWithNewId.put(obj.Source_User_Rec_Id_c__c,obj.Id);
        }
        return mapUsersWithNewId;
    } 
    
    public static Map<Id,Id> getOrder(List<String> listOppId){
        Map<Id,Id> orderMap = new Map<Id,Id>();
        for(Order obj : [SELECT Id,Source_Opportunity_Id__c FROM Order WHERE Source_Opportunity_Id__c IN : listOppId]){
            orderMap.put(obj.Source_Opportunity_Id__c,obj.Id);
        }
        return orderMap;
    
    } 
    
    public static Map<Id,Id> getCamp(List<String> listCampId){
        Map<Id,Id> campMap = new Map<Id,Id>();
        for(Campaign obj : [SELECT Id,Source_Campaign_Record_Id__c FROM Campaign WHERE Source_Campaign_Record_Id__c IN : listCampId]){
            campMap.put(obj.Source_Campaign_Record_Id__c,obj.Id);
        }
        return campMap;
    } 
    
    public static Map<Id,Id> getPriceBook(List<String> listPriceBookId){
        Map<Id,Id> priceBookMap = new Map<Id,Id>();
        for(PriceBook2 obj : [SELECT Id,Source_Pricebook_Rec_Id__c FROM PriceBook2 WHERE Source_Pricebook_Rec_Id__c IN : listPriceBookId]){
            priceBookMap.put(obj.Source_Pricebook_Rec_Id__c,obj.Id);
        }
        return priceBookMap;
    } 
    
    public static Map<Id,Id> getShipment(List<String> listShipId){
        Map<Id,Id> shipMap = new Map<Id,Id>();
        for(Shipment__c obj : [SELECT Id,Source_Shipment_Rec_Id__c FROM Shipment__c WHERE Source_Shipment_Rec_Id__c IN : listShipId]){
            shipMap.put(obj.Source_Shipment_Rec_Id__c,obj.Id);
        }
        return shipMap;
    }
    
}