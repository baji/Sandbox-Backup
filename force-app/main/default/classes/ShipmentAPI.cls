public class ShipmentAPI {
    public List<ShipList> ShipmentList { get; set; }
    public WBShipment obj {get; set;}
    public List<ProductListWrapper> ProdList {get; set;}
    public List<OrderItem> stockOLIs {get; set;}
    public List<String> TotalShip {get;set;}
    public map<string,Integer> pmap {get;set;}
    public String WBOrderID='';
    public Order Ord{get;set;}
    public String Teststring;
    
    public ShipmentAPI() {
        
        WBOrderID=ApexPages.currentPage().getParameters().get('WbOrder');
        Ord=[Select id,OrderNumber,NG_Shipment_Id__c,TotalOrderQuantity__c,Total_Pick_Quantity_Ordered__c,Total_Pick_Quantity__c,Inventory_Items__c,Total_Pick_Tickets__c from Order where NG_Shipment_ID__c=:WBOrderID LIMIT 1];
        ShipmentList = new List<ShipList>();
        ProdList = new List<ProductListWrapper>();
        TotalShip = new List<String>();
        pmap = new map<string,integer>();
        //String WBOrderID = '3312979';
        system.debug(WBOrderID);
        

        HttpResponse resp = new HttpResponse();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String apikey = '4fc724a5-7a4c-4796-a6b2-dcac2b62448a';
        String appId = 'awana';
        String XMLString='';
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        String Endpoint = 'https://api.whitebox.co/actions/private/shipment?appId='+appId+'&apiKey='+apikey+'&orderIds='+WBOrderID;
        system.debug(Endpoint);
        req.setEndpoint('https://api.whitebox.co/actions/private/shipment?appId='+appId+'&apiKey='+apikey+'&orderIds='+WBOrderID);
        req.setTimeout(60000);
        try{
            if(!Test.isRunningTest()){
                resp = h.send(req);
                if(resp.getStatusCode() == 200)
                    XMLString = resp.getBody();
            }else{
                Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
                XMLString ='{"shipmentCount":1,"shipments":[{"id":989898,"orderId":3312979,"merchantOrderId":"'+Ord.OrderNumber+'","status":"SHIPPED","shipDate":"2020-04-24 11:08:49","carrier":"fedex","service":"fedex_international_economy","tracking":"392210113498","totalWeight":"44.31","trackingUrl":"http://www.fedex.com/Tracking?action=track&tracknumbers=392210113498","latestTrackingEvent":{"statusDescription":"Test"},"isVoided":false,"containers":[{"id":490317,"shipmentId":989898,"sscc":null,"weight":"44.31","length":"24.00","height":"17.00","width":"16.00","packageCode":"package","items":[{"id":696975,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269471,"sku":"AWNA-41267-001-MCF","upc":"41267","clientSku":"41267"},{"id":696976,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269053,"sku":"AWNA-15587-001-MCF","upc":"15587","clientSku":"15587"},{"id":696977,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269499,"sku":"AWNA-34265-001-MCF","upc":"34265","clientSku":"34265"},{"id":696978,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269035,"sku":"AWNA-32150-001-MCF","upc":"32150","clientSku":"32150"},{"id":696979,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269218,"sku":"AWNA-16096-001-MCF","upc":"16096","clientSku":"16096"},{"id":696980,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269105,"sku":"AWNA-21143-001-MCF","upc":"21143","clientSku":"21143"},{"id":696981,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268925,"sku":"AWNA-14537-001-MCF","upc":"14537","clientSku":"14537"},{"id":696982,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269109,"sku":"AWNA-36982-001-MCF","upc":"36982","clientSku":"36982"},{"id":696983,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268928,"sku":"AWNA-14561-001-MCF","upc":"14561","clientSku":"14561"},{"id":696984,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269502,"sku":"AWNA-41814-001-MCF","upc":"41814","clientSku":"41814"},{"id":696985,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269158,"sku":"AWNA-34522-001-MCF","upc":"34522","clientSku":"34522"},{"id":696986,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269103,"sku":"AWNA-20423-001-MCF","upc":"20423","clientSku":"20423"},{"id":696987,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269603,"sku":"AWNA-16053-001-MCF","upc":"16053","clientSku":"16053"}]}]}]}';
            }
            obj = WBShipment.parse(XMLString);
            
            for(WBShipment.Shipments aShipmentResponse : obj.shipments){
                TotalShip.add(aShipmentResponse.id);
                ShipmentList.add(new ShipList(aShipmentResponse));
                for(WBShipment.items anItem : aShipmentResponse.Containers[0].items){
                    pmap.put(anItem.upc+'-'+aShipmentResponse.id,anItem.shipQty);
                }
            }
            ShipmentList.sort();
            stockOLIs =[Select Id, Quantity, Order.OrderNumber,ListPrice, UnitPrice, TotalPrice, OrderId, Order.Total_Pick_Tickets__c, Product2Id, Line_Type__c, Product2.Name, Product2.ProductCode, Product2.Quantity__c, Product2.Quantity_on_Pick__c, Product2.Quantity_in_Pick_Bin__c, Quantity_Shipped__c, Product2.Quantity_Available__c, Quantity_Fillable__c, Quantity_Given_Away__c, Quantity_Backordered__c, Promo_Code__c, Description,PreOrder_Backorder_Handling__c,Estimated_Weight__c  FROM OrderItem WHERE (Line_Type__c like 'S - Stock%')  and Order.NG_Shipment_ID__c=:WBOrderID];     
            for(OrderItem OLI:stockOLIs){
                ProdList.add(new ProductListWrapper(OLI));
                for(String ship:TotalShip)
                    if(pmap.get(OLI.Product2.ProductCode+'-'+ship)==null)
                        pmap.put(OLI.Product2.ProductCode+'-'+ship,0);
            }
            ProdList.sort();
        }
        catch(Exception Ex){
            system.debug(Ex);
        }
}

    public class ShipList implements Comparable{
        public String AwanaOrder {get; set;}
        public String WBOrderID {get; set;}
        public String WBShipmentID{ get; set;}
        public String shipDate {get; set;}
        public Boolean isVoided {get; set;}
        public String latestTrackingEvent {get; set;}
        public String trackingURL {get; set;}
        public String tracking {get; set;}
        public String ModifiedOn {get; set;}

        public ShipList(WBShipment.Shipments aShipmentResponse){
            AwanaOrder=aShipmentResponse.merchantOrderId;
            WBOrderID=aShipmentResponse.orderId;
            WBShipmentID=aShipmentResponse.id;
            shipDate=aShipmentResponse.shipDate;
            isVoided=aShipmentResponse.isVoided;
            latestTrackingEvent=aShipmentResponse.latestTrackingEvent!=null?aShipmentResponse.latestTrackingEvent.statusDescription:'';
            trackingURL=aShipmentResponse.trackingUrl;
            tracking=aShipmentResponse.tracking;
            ModifiedOn=aShipmentResponse.modifiedOn;
        }
        
        public Integer compareTo(Object compareTo) {
            ShipList compareToRec = (ShipList)compareTo;
            return WBShipmentID > compareToRec.WBShipmentID?1:WBShipmentID < compareToRec.WBShipmentID?-1:0;
        }
        
    }

    public class ProductListWrapper implements Comparable{
        public String PName {get;set;}
        public String Pcode {get;set;}
        public Decimal Qty{get;set;}
        public Decimal QtyShipped{get;set;}
        public ProductListWrapper(OrderItem OLI){
            PName=OLI.Product2.Name;
            Pcode=OLI.Product2.ProductCode;
            Qty=OLI.Quantity;
            QtyShipped=OLI.Quantity_Shipped__c;
        }
        public Integer compareTo(Object compareTo) {
            ProductListWrapper compareToRec = (ProductListWrapper)compareTo;
            return Pcode > compareToRec.Pcode?1:Pcode < compareToRec.Pcode?-1:0;
        }

    }

    public pageReference export()
    {
        PageReference pageRef = new PageReference('/apex/ExportShipments?WbOrder?='+WBOrderID);
		return pageRef;
    }

}