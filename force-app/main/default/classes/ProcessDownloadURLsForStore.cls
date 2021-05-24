/*
Purpose - CLass ProcessDownloadURLsForStore  - ASP-1177
Description - Coe will handle updating of Downloadable WOO (Awana Store) order Items. 
Author - Tony Wiliams.
Called By : ProcessOrder.Trigger
Test Class: ProcessDownloadURLsForStore_Test
*/
public class ProcessDownloadURLsForStore {
	public static void updateOrderItems(List<ID> AwanaStoreOrderIds){
        List<String> productCodes = new List<String>();
        List<OrderItem> subsetOrderItem = new List<OrderItem>();
        List<OrderItem> ois = [SELECT Id,Downloadable_Product_URL__c,Product2.Line_Type__c,Product2.ProductCode,Product2.Downloadable_Product_URL__c FROM OrderItem WHERE Order.Id =: AwanaStoreOrderIds];
       
		//Now go through all active products per each order item and  match the product code for this item and copy over the DOwnloadableURLS
        
        for(OrderItem anOrderItem : ois){
            system.debug('<<O ITEM LINE TYPE >> '+anOrderItem.Product2.Line_Type__c);
        	system.debug('<<PROD2 DOWNLOADABLE URL >> '+anOrderItem.Product2.Downloadable_Product_URL__c);
            system.debug('<<O ITEM DOWNLOADABLE URL >> '+anOrderItem.Downloadable_Product_URL__c);
            if(anOrderItem.Product2.Downloadable_Product_URL__c !='' && (anOrderItem.Product2.Line_Type__c.contains('ND -') || anOrderItem.Product2.Line_Type__c.contains('N -'))){
                anOrderItem.Downloadable_Product_URL__c = anOrderItem.Product2.Downloadable_Product_URL__c;
                subsetOrderItem.add(anOrderItem);
            }
		}
        if(subsetOrderItem.size() > 0){
            update subsetOrderItem;
        }
        
	}
}