public with sharing class ShipmentTest {

    private ApexPages.StandardController standardController;

    public ShipmentTest(ApexPages.StandardController standardController) {
        this.standardController = standardController;
    }

    public PageReference createShipment()
    {
        Id OrdId = standardController.getId();
        Order Ord = (Order) standardController.getRecord(); 
        List<OrderItem> stockOLIs = [SELECT Id, Order.OrderNumber, Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name,Quantity_Fillable__c FROM OrderItem WHERE (Line_Type__c like 'S - Stock%') and OrderId =: OrdId];  
                                string json = '{"shipmentCount":1,"shipments":[{"id":989898,"orderId":'+Integer.valueOf(stockOLIs[0].Order.OrderNumber)+',"merchantOrderId":"'+stockOLIs[0].Order.OrderNumber+'","status":"SHIPPED","shipDate":"2020-04-24 11:08:49","carrier":"fedex","service":"fedex_international_economy","tracking":"392210113498","totalWeight":"44.31","trackingUrl":"http://www.fedex.com/Tracking?action=track&tracknumbers=392210113498","latestTrackingEvent":{"statusDescription":"Test"},"isVoided": false,"containers":[{"id":490317,"shipmentId":989898,"sscc":null,"weight":"44.31","length":"24.00","height":"17.00","width":"16.00","packageCode":"package","items":[';
        Decimal qfillable = 0;
        for(Integer i=0;i<stockOLIs.size();i++){
            qfillable+=stockOLIs[i].Quantity_Fillable__c;
            string upc =  String.valueOf(stockOLIs[i].PricebookEntry.Product2.ProductCode);
            string json2='';
            if(i>0)
                json+=',{';
            else    
                json+='{';
            
            json2+='"id":'+ String.valueOf(696975+i);
            json2+=',"shipmentId":989898';
            json2+=',"shipmentContainerId":490317';
            json2+=',"shipQty":'+Integer.valueOf(stockOLIs[i].Quantity);
            json2+=',"skuId":4269471';
            json2+=',"sku":"AWNA-'+upc+'-001-MCF"';
            json2+=',"upc":"'+upc+'"';
            json2+=',"clientSku":"'+upc+'"}';
            json+=json2;
        }
        json+=']}]}]}';
        if(qfillable>0){
            BatchSearchWBShipments batchObjBSNS = new BatchSearchWBShipments();
            batchObjBSNS.Teststring=json;
            Database.executeBatch(batchObjBSNS);
        }
        PageReference OrdPage = new PageReference('/' + OrdId);
        OrdPage.setRedirect(true);
        return OrdPage;
    } 

}