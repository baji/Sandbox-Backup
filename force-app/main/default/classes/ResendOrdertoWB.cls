global class ResendOrdertoWB {
    
    webservice static void resendOrdertoWB(String orderId){
        
        List<OrderItem> stockOLIs = [SELECT Id, Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name FROM OrderItem WHERE (Line_Type__c like 'S - Stock%' or Line_Type__c like 'T - Text Line%' or Line_Type__c like 'F - Freight') and OrderId =: orderId];  
        Order someOrder = [SELECT Id, Shipping_Street__c,Billing_Address__r.First_Name__c,Billing_Address__r.Last_Name__c,Billing_Address__r.Country__c,Billing_Phone__c,Shipping_City__c,PriceBookName__c,OrderNumber,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,Non_inventory_Items__c,Billing_Address__r.State__c,Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Inventory_Items__c,TotalAmount,Billing_Address__r.City__c,BillToContact.FirstName,BillToContact.LastName,BillingAddress,Account.Name,Billing_Address__r.Zip_Code__c,Billing_Address__r.Address_Line_1__c,Billing_Address__r.Address_Line_2__c,Account.Mailing_Address_Book__c,Account.Phone,Account.Fax,Error_Log__c,Shipping_Country_Code__c,Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Shipment_Cost__c,Company__c,Payment_Terms__c,Status,NG_Shipment_ID__c,Shipping_Address__r.Address_Line_1__c,Shipping_Address__r.Address_Line_2__c FROM Order WHERE id =: orderId];
        
        if(stockOLIs.size() > 2 && someOrder.Payment_Terms__c != 'To Be Billed'){
            PostShipmentRequest.sendOrderToWB(someOrder,stockOLIs); 
            update someOrder;
        }                
    }

    webservice static void CancelShipment(String ShipmentId, String WBOrderId){
        
        
        Order someOrder = [SELECT Id, Shipping_Street__c,Billing_Address__r.First_Name__c,Billing_Address__r.Last_Name__c,Billing_Address__r.Country__c,Billing_Phone__c,Shipping_City__c,PriceBookName__c,OrderNumber,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,Non_inventory_Items__c,Billing_Address__r.State__c,Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Inventory_Items__c,TotalAmount,Billing_Address__r.City__c,BillToContact.FirstName,BillToContact.LastName,BillingAddress,Account.Name,Billing_Address__r.Zip_Code__c,Billing_Address__r.Address_Line_1__c,Billing_Address__r.Address_Line_2__c,Account.Mailing_Address_Book__c,Account.Phone,Account.Fax,Error_Log__c,Shipping_Country_Code__c,Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Shipment_Cost__c,Company__c,Payment_Terms__c,Status,NG_Shipment_ID__c,Shipping_Address__r.Address_Line_1__c,Shipping_Address__r.Address_Line_2__c FROM Order WHERE NG_Shipment_ID__c=:WBOrderID];
        String orderId=someOrder.Id;
        List<OrderItem> stockOLIs = [SELECT Id, Quantity_Shipped__c,Promo_Code__c,Description,Estimated_Weight__c,Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name,Order.OrderNumber FROM OrderItem WHERE (Line_Type__c like 'S - Stock%' or Line_Type__c like 'T - Text Line%' or Line_Type__c like 'F - Freight') and OrderId =: orderId];  
        Shipment__c ship = [Select Id, Pick_Ticket__c,NG_Package_ID__c,Voided__c from Shipment__c where id=: ShipmentId];
        Map<String,Pick_Ticket_Line_Item__c> PTpliMap = new Map<String,Pick_Ticket_Line_Item__c>();
        WBShipment obj; 
        List<Pick_Ticket_Line_Item__c> pickTicketItems = new List<Pick_Ticket_Line_Item__c>();

        for(Pick_Ticket_Line_Item__c ptli : [select Product__c,Quantity_Ordered__c,Item_Number__c,Quantity_Given_Away__c,Estimated_Weight__c,Quantity__c,Line_Type__c,Price__c,
                                                        Promo_Code__c,Line_Description__c,PreOrder_Backorder_Handling__c,Pick_Ticket__c from Pick_Ticket_Line_Item__c
                                                        Where Pick_Ticket__c =: ship.Pick_Ticket__c] )                   
                {
                    PTpliMap.put(ptli.Pick_Ticket__c+'-'+ptli.Item_Number__c,ptli);
                }

        system.debug('PTLISize:'+PTpliMap.size());
        
        HttpResponse resp = new HttpResponse();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String apikey = '4fc724a5-7a4c-4796-a6b2-dcac2b62448a';
        String appId = 'awana';
        String XMLString='';
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        String Endpoint = 'https://api.whitebox.co/actions/private/shipment?appId='+appId+'&apiKey='+apikey+'&orderIds='+WBOrderId;
        system.debug(Endpoint);
        req.setEndpoint('https://api.whitebox.co/actions/private/shipment?appId='+appId+'&apiKey='+apikey+'&orderIds='+WBOrderId);
        req.setTimeout(60000);
        try{
            if(!Test.isRunningTest()){
                resp = h.send(req);
                if(resp.getStatusCode() == 200)
                    XMLString = resp.getBody();
            }else{
                Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
                XMLString ='{"shipmentCount":1,"shipments":[{"id":989898,"orderId":3312979,"merchantOrderId":"'+someOrder.OrderNumber+'","status":"SHIPPED","shipDate":"2020-04-24 11:08:49","carrier":"fedex","service":"fedex_international_economy","tracking":"392210113498","totalWeight":"44.31","trackingUrl":"http://www.fedex.com/Tracking?action=track&tracknumbers=392210113498","latestTrackingEvent":{"statusDescription":"Test"},"isVoided":false,"containers":[{"id":490317,"shipmentId":989898,"sscc":null,"weight":"44.31","length":"24.00","height":"17.00","width":"16.00","packageCode":"package","items":[{"id":696975,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269471,"sku":"AWNA-41267-001-MCF","upc":"41267","clientSku":"41267"},{"id":696976,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269053,"sku":"AWNA-15587-001-MCF","upc":"15587","clientSku":"15587"},{"id":696977,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269499,"sku":"AWNA-34265-001-MCF","upc":"34265","clientSku":"34265"},{"id":696978,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269035,"sku":"AWNA-32150-001-MCF","upc":"32150","clientSku":"32150"},{"id":696979,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269218,"sku":"AWNA-16096-001-MCF","upc":"16096","clientSku":"16096"},{"id":696980,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269105,"sku":"AWNA-21143-001-MCF","upc":"21143","clientSku":"21143"},{"id":696981,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268925,"sku":"AWNA-14537-001-MCF","upc":"14537","clientSku":"14537"},{"id":696982,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269109,"sku":"AWNA-36982-001-MCF","upc":"36982","clientSku":"36982"},{"id":696983,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268928,"sku":"AWNA-14561-001-MCF","upc":"14561","clientSku":"14561"},{"id":696984,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269502,"sku":"AWNA-41814-001-MCF","upc":"41814","clientSku":"41814"},{"id":696985,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269158,"sku":"AWNA-34522-001-MCF","upc":"34522","clientSku":"34522"},{"id":696986,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269103,"sku":"AWNA-20423-001-MCF","upc":"20423","clientSku":"20423"},{"id":696987,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269603,"sku":"AWNA-16053-001-MCF","upc":"16053","clientSku":"16053"}]}]}]}';
            }
            obj = WBShipment.parse(XMLString);
            
            for(WBShipment.Shipments aShipmentResponse : obj.shipments){
                system.debug(ShipmentId+'-'+aShipmentResponse.id);
                if(ship.NG_Package_ID__c==aShipmentResponse.id && !ship.Voided__c){

                    for(WBShipment.items anItem : aShipmentResponse.Containers[0].items){
                            for(OrderItem someOLI : stockOLIs){
                                if(anItem.upc == someOLI.Product2.ProductCode && someOLI.Order.OrderNumber == someOrder.OrderNumber){
                                    system.debug('In Here:');
                                    if(PTpliMap.get(ship.Pick_Ticket__c+'-'+someOLI.Product2.ProductCode)!=null){
                                        system.debug('In here2:');
                                        pickTicketItems.add(new Pick_Ticket_Line_Item__c(Id=PTpliMap.get(ship.Pick_Ticket__c+'-'+someOLI.Product2.ProductCode).Id,Quantity__c=PTpliMap.get(ship.Pick_Ticket__c+'-'+someOLI.Product2.ProductCode).Quantity__c-anItem.shipQty));
                                        someOLI.Quantity_Shipped__c -= anItem.shipQty; 
                                    }
                                }
                            }// Loop - OLIs
                    }//Loop - NG Global Items per order
                    ship.Voided__c=true;
                    update ship;
                    update pickTicketItems;
                    update stockOLIs;
                }
            }
            
            
            
        }
        catch(Exception Ex){
            system.debug(Ex);
        }

    }
}