global class BatchSearchWBShipmentsCatchup implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    global String query; 
    global String startShippedTimestamp;
    global String endShippedTimestamp;
    List<Pick_Ticket__c> ptickets = new List<Pick_Ticket__c>();
    global Newgistics_Settings__c custSettings = Newgistics_Settings__c.getValues('NewgsticsAPIFields'); //CC - later
    global set<string> ShipmentIDs = new set<string>();
    global set<string> OrderNos = new set<string>();
    global WBShipment obj; 
    global integer packages = 0;
    global String EmailMessage = '',ErrorLog='';
    global String Teststring;
    global String API='';
    
    //Constructor
    global BatchSearchWBShipmentsCatchup(){      
        custSettings = [SELECT id,End_Shipped_Time__c,Start_Shipped_Time__c,Added_Hours__c,NG_API_Key__c,NG_Endpoint__c,FRT_Code__c,TAX_Code__c from  Newgistics_Settings__c];
        checkRecursive.setBatchStatus('NGSearch'); //Used to prevent execution of triggers
        Awana_Settings__c custSetting =  Awana_Settings__c.getValues('WBShipmentAPI');
        API=custSetting.value__c;
        
        if(custSettings.End_Shipped_Time__c != null){
            system.debug('Start Time before +:'+custSettings.Start_Shipped_Time__c);
            system.debug('End Time before +:'+custSettings.end_Shipped_Time__c);            
            endShippedTimestamp=custSettings.End_Shipped_Time__c;
            startShippedTimestamp =custSettings.Start_Shipped_Time__c;
        }
    }
 
    //Start - BEGIN
    global database.querylocator start(Database.BatchableContext BC){
        String endpoint;
        String status = 'SHIPPED';
        checkRecursive.setBatchStatus('NGSearch'); //Used to prevent execution of triggers
        if(API=='On'){
            try{
                List<Order> Ords = new List<Order>();
                set<String> Ornos = new set<string>();
                set<String> WBOrnos = new set<string>();
                String WBOrderId='';
                Ords = [Select id,OrderNumber,Status,CreatedDate,NG_Shipment_ID__c from Order where CreatedDate > 2020-04-29T00:00:00Z AND(Status='Order Being Fulfilled' OR Status='Order Partially Invoiced') and NG_Shipment_ID__c!=null ORDER BY CreatedDate];
                for(Order O : Ords){
                    Ornos.add(O.OrderNumber);
                    WBOrnos.add(O.NG_Shipment_ID__c);
                    WBOrderID = WBOrderID==''? O.NG_Shipment_ID__c : WBOrderID+','+O.NG_Shipment_ID__c;
                }
                HttpResponse resp = new HttpResponse();
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String apikey = '4fc724a5-7a4c-4796-a6b2-dcac2b62448a';
                String appId = 'awana';
                String XMLString='';
                req.setMethod('GET');
                req.setHeader('Content-Type','application/json');
                Endpoint = 'https://api.whitebox.co/actions/private/shipment?appId='+appId+'&apiKey='+apikey+'&shipDateEnd='+endShippedTimestamp+'&orderIds='+WBOrderID;
                system.debug(Endpoint);
                req.setEndpoint('https://api.whitebox.co/actions/private/shipment?appId='+appId+'&apiKey='+apikey+'&shipDateEnd='+endShippedTimestamp+'&orderIds='+WBOrderID);
                req.setTimeout(90000);
                if(!Test.isRunningTest()){
                    resp = h.send(req);
                    if(resp.getStatusCode() == 200)
                        XMLString = resp.getBody();
                    else 
                        EmailMessage = resp.getStatusCode()==204?'No Shipments found between '+startShippedTimestamp+' and '+endShippedTimestamp:resp.getStatus();
                }else{
                    Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
                    XMLString = Teststring!=null?Teststring:BatchSearchWBShipmentsTest.CreateShipments_TestMethod();
                }

                WBShipment obj = WBShipment.parse(XMLString);
                List<Shipment__c> sfShipments = [Select NG_Shipment_ID__c, Id,NG_Package_ID__c from Shipment__c where NG_Shipment_ID__c in:  WBOrnos];
                Map<String,Shipment__c> shipmap =  new map<String,Shipment__c>();
                List<String> missship = new List<String>();
                for(Shipment__c s : sfShipments)
                    shipmap.put(s.NG_Shipment_ID__c+'-'+s.NG_Package_ID__c,s);    
                
                for(WBShipment.shipments aShipmentResponse : obj.shipments)
                    if(shipmap.get(aShipmentResponse.OrderId+'-'+aShipmentResponse.Id)==null){
                        missship.add(aShipmentResponse.merchantOrderId+'*'+aShipmentResponse.OrderId+'*'+aShipmentResponse.Id+'*'+aShipmentResponse.shipDate);
                        OrderNos.add(aShipmentResponse.merchantOrderId);
                        packages +=1;
                        shipmentIDs.add(aShipmentResponse.OrderId);
                    }
            }
            /*try {                  
                // Unit Testing - BEGIN
                    //StaticResource sres = [Select Body From StaticResource Where Name = 'XMLData' LIMIT 1 ];
                    //XMLString = (sres.Body.toString());
                // Unit Testing - End
            }*/
            Catch(Exception e){
                system.debug(e);
                ErrorLog+='<< Stack Trace >> '+e.getStackTraceString()+' << Line Number >> '+e.getLineNumber()+'---'+e.getMessage()+'; ';
            }
        } 
        if(query == null){
            query  = 'SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,'
                +'Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c,Estimated_Weight__c,' 
                +'Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Tax__c,Shipment_Cost__c,Payment_Terms__c,'
                +'AccountId, Account.Name, OrderNumber, Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name,'
                +'HasOrderLineItem__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c,'
                +'Total_Pick_Quantity__c, Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,'
                +'Order.NG_Shipment_ID__c, (Select Id,NG_Package_ID__c,NG_Shipment_ID__c,Order__c From Pick_Tickets__r where Status__c=\'Open\') '
                +'FROM Order '
                +'where (Status = \'Order Being Fulfilled\' or Status like \'%Partially%\')'
                +' And (NOT Status like \'%Cancelled%\')'
                +' And OrderNumber IN: OrderNos';
        }
        return Database.getQueryLocator(query);
    }
    //Start - END
    
    //Execute - BEGIN
    global void execute(Database.BatchableContext BC, List<Order> orders) { 
        checkRecursive.setBatchStatus('NGSearch'); //Used to prevent execution of triggers
        system.debug('Order Size: '+orders.size());
        
        List<String> ngShipmentIDs = new List<String>();
        Map<String,String> NGShipIDToNgOrderIDs = new Map<String,String>();
        Map<String,String> NgOrderIDsToNGShipID = new Map<String,String>();
	    Map<String,String> NGShipIDToSFShipID = new Map<String,String>();
	    Map<Id,String> OrderIDToOrderNumber = new Map<Id,String>();
        Map<String,Order> OrderNumberToOrder = new Map<String,Order>();
	    Set<OrderItem> OLIs = new Set<OrderItem>();
        Map<String,Double> OrderNumberToFillable = new Map<String,Double>();
        Map<String,Double> OrderNumberToFilled = new Map<String,Double>();
        Map<String,Double> OrderNumberToShipped = new Map<String,Double>();
        Map<String,Double> OrderNumberToOrdered = new Map<String,Double>();
        Map<String, Set<OrderItem>> OrderNumberToOLIs = new Map<String, Set<OrderItem>>();
        List<OrderItem> stockOLIs = new List<OrderItem>();
        map<id,List<Pick_Ticket__c>> OrderPTMap = new map<id,List<Pick_Ticket__c>>();
        Map<id,List<Pick_Ticket_Line_Item__c>> pickTicketVsLineItemMap = new Map<id,List<Pick_Ticket_Line_Item__c>>();
        Map<String,Pick_Ticket_Line_Item__c> PTpliMap = new Map<String,Pick_Ticket_Line_Item__c>();
        ptickets = new list<Pick_Ticket__c>();
        Map<String,Id> OrderNumberToPTicketID = new Map<String,Id>();
        Map<String,Order> srShipmentIDToOrderMap = new Map<String,Order>();
        List<Shipment__c> shipmentsTobeCreated = new List<Shipment__c>();
        List<Shipment__c> shipmentsTobeInserted = new List<Shipment__c>();
        List<Pick_Ticket__c> pts,OpenPts = new List<Pick_Ticket__c>();
        List<Pick_Ticket_Line_Item__c> ptls = new List<Pick_Ticket_Line_Item__c>();
        List<Pick_Ticket_Line_Item__c> ptlsNonStock = new List<Pick_Ticket_Line_Item__c>();
        Map<String,Pick_Ticket_Line_Item__c> pickTicketItems = new Map<String,Pick_Ticket_Line_Item__c>();
        map<String,String> OpenPTpackagesmap = new map<String,String>();
        map<string,Pick_Ticket__c> OrderTonewPT = new map<string,Pick_Ticket__c>();
        map<string,boolean> voidedshiporders = new map<string,boolean>();
        
        if(obj.shipments.size() > 0){
	        for(WBShipment.shipments aShipmentResponse : obj.shipments){
		        ngShipmentIDs.add(aShipmentResponse.OrderId); 
		        NGShipIDToNgOrderIDs.put(aShipmentResponse.OrderId,aShipmentResponse.merchantOrderId);
                NgOrderIDsToNGShipID.put(aShipmentResponse.merchantOrderId,aShipmentResponse.OrderId);
                if(aShipmentResponse.isVoided)
                    voidedshiporders.put(aShipmentResponse.merchantOrderId,aShipmentResponse.isVoided);
            }   
            List<Shipment__c> sfShipments = [Select NG_Shipment_ID__c, Id,NG_Package_ID__c from Shipment__c where NG_Shipment_ID__c in:  shipmentIDs];
	        for(Shipment__c someShipment : sfShipments){
		        NGShipIDToSFShipID.put(someShipment.NG_Package_ID__c,someShipment.NG_Shipment_ID__c);
		        OpenPTpackagesmap.put(someShipment.NG_Package_ID__c,someShipment.NG_Shipment_ID__c);
	        }
        }
        for(Order someOrder : orders){
        	OrderNumberToOrder.put(someOrder.OrderNumber,someOrder);
        	OrderIDToOrderNumber.put(someOrder.Id,someOrder.OrderNumber);
        }
        
        if(OrderIDToOrderNumber.size()>0)
            stockOLIs =[Select Id, Quantity, Order.OrderNumber,ListPrice, UnitPrice, TotalPrice, OrderId, Order.Total_Pick_Tickets__c, Product2Id, Line_Type__c, Product2.ProductCode, Product2.Quantity__c, Product2.Quantity_on_Pick__c, Product2.Quantity_in_Pick_Bin__c, Quantity_Shipped__c, Product2.Quantity_Available__c, Quantity_Fillable__c, Quantity_Given_Away__c, Quantity_Backordered__c, Promo_Code__c, Description,PreOrder_Backorder_Handling__c,Estimated_Weight__c  FROM OrderItem WHERE (Line_Type__c like 'S - Stock%'  OR Line_Type__c like '% - Freight%' or Line_Type__c like '% - Text Line%')  and Order.OrderNumber in: OrderIDToOrderNumber.values()];     
        try{
            for(Order someOrder : orders){
            	OLIs = new Set<OrderItem>();
            	if(stockOLIs.size() > 0){
            		Double TotalFillableItems = 0;
            		Double TotalOrderedItems = 0;
            		Double TotalShippedItems = 0;
            		OrderNumberToOrder.put(someOrder.OrderNumber,someOrder);
            		OrderIDToOrderNumber.put(someOrder.Id,someOrder.OrderNumber);
            		for(OrderItem someOLI : stockOLIs){
            			if(someOrder.OrderNumber == someOLI.Order.OrderNumber){  
            			    if(someOLI.Line_Type__c=='S - Stock Inventory Item'){
            			        TotalOrderedItems +=someOLI.Quantity;
            			    }
            			        
            				TotalFillableItems += someOLI.Quantity_Fillable__c+someOLI.Quantity_Backordered__c;
            				TotalShippedItems +=someOLI.Quantity_Shipped__c;
            				OLIs.add(someOLI);
                         }
                    }
            		OrderNumberToFillable.put(someOrder.OrderNumber,TotalFillableItems);
            		OrderNumberToFilled.put(someOrder.OrderNumber,0);
            		OrderNumberToShipped.put(someOrder.OrderNumber,TotalShippedItems);
            		OrderNumberToOrdered.put(someOrder.OrderNumber,TotalOrderedItems);
                    OrderNumberToOLIs.put(someOrder.OrderNumber,OLIs);
                    }
            }
            
            system.debug('ANVFillable:'+OrderNumberToFillable);
            system.debug('ANVFilled:'+OrderNumberToFilled);
            system.debug('ANVTotal:'+OrderNumberToOrdered);
            system.debug('ANVShipped:'+OrderNumberToShipped);
            
            for(WBShipment.shipments aShipmentResponse : obj.shipments){
            	String orderNumber = NGShipIDToNgOrderIDs.get(aShipmentResponse.OrderId);  
            	if(OrderNumberToOrder.get(orderNumber) != null){
            		Order someOrder = OrderNumberToOrder.get(orderNumber);
            		OpenPts = someOrder.Pick_Tickets__r;
            		system.debug('A:'+OpenPTpackagesmap);
            	    if(OpenPTpackagesmap.get(aShipmentResponse.Id)==null || OpenPTpackagesmap.get(aShipmentResponse.Id)==''){  
            			OLIs = OrderNumberToOLIs.get(orderNumber);
            			Double totalFillableItems = OrderNumberToFillable.get(orderNumber);
            			system.debug(someOrder.orderNumber+'-'+someOrder.Inventory_Items__c);
            			if(someOrder.Inventory_Items__c > 0){
            			    Pick_Ticket__c nonNullPT = GeneratePickTickets(someOrder,OLIs,totalFillableItems,aShipmentResponse.OrderId,aShipmentResponse.Id,OrderTonewPT); 
            			    system.debug(nonNullPT);
            				if(nonNullPT != null){
            				    system.debug(nonNullPT);
            					ptickets.add(nonNullPT); 
            					OrderTonewPT.put(someOrder.orderNumber,nonNullPT);
            				}
            			}	
            			srShipmentIDToOrderMap.put(aShipmentResponse.OrderId,someOrder);// CHange to Order NUmber
            			someOrder.NG_Shipment_ID__c = aShipmentResponse.OrderId; 
            		}     
            	}
            }
        }
        catch(SObjectException ex){
            system.debug('There was an exception that occurred while processing Order Numbers. Check the SOQL statements or Http response. '+ex.getMessage());
            system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            ErrorLog+='<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber()+'---'+ex.getMessage()+'; ';
        }
        if(OrderTonewPT.values().size() > 0)
            ptickets = OrderTonewPT.values();
        system.debug(ptickets.size());

        try{
            if(ptickets.size() > 0){
                upsert ptickets; 
            }
            List<Pick_Ticket__c> pnumberIncs = new List<Pick_Ticket__c>(); 
            List<Pick_Ticket__c> pnumberIncsUpdate = new List<Pick_Ticket__c>();
            pnumberIncs = [select Id,Pick_Number_Increment__c,Order__c,NG_Shipment_ID__c,NG_Package_ID__c from Pick_Ticket__c where Order__c IN :orders];
            OrderPTMap = new map<id,List<Pick_Ticket__c>>();
            Set<id> pickTicketIds = new Set<id>();
            for(Pick_Ticket__c Pt:pnumberIncs){
                pickTicketIds.add(pt.id);
                if(OrderPTMap.get(Pt.Order__c)!=null)
                    OrderPTMap.get(Pt.Order__c).add(Pt);
                else
                    OrderPTMap.put(Pt.Order__c,new List<Pick_Ticket__c>{Pt});
            }
        
            if(!pickTicketIds.isEmpty()){
                for(Pick_Ticket_Line_Item__c ptli : [select Product__c,Quantity_Ordered__c,Item_Number__c,Quantity_Given_Away__c,Estimated_Weight__c,Quantity__c,Line_Type__c,Price__c,
                                                        Promo_Code__c,Line_Description__c,PreOrder_Backorder_Handling__c,Pick_Ticket__c from Pick_Ticket_Line_Item__c
                                                        Where Pick_Ticket__c IN: pickTicketIds] )                   
                {
                    PTpliMap.put(ptli.Pick_Ticket__c+'-'+ptli.Item_Number__c,ptli);
                    if(pickTicketVsLineItemMap.get(ptli.Pick_Ticket__c)!= null)
                        pickTicketVsLineItemMap.get(ptli.Pick_Ticket__c).add(ptli);
                    else
                        pickTicketVsLineItemMap.put(ptli.Pick_Ticket__c,new List<Pick_Ticket_Line_Item__c>{ptli});
                }
            }
                
            if(ptickets.size () > 0){
                for(Order o: orders){
                    pnumberIncs=OrderPTMap.get(o.Id);
                    Integer i = 0;
                    for(Pick_Ticket__c pt: pnumberIncs){
                        pt.Pick_Number_Increment__c = pt.Pick_Number_Increment__c + i;
                        i++;
                        pnumberIncsUpdate.add(pt);   
                    }
                }
            }
            update pnumberIncsUpdate;
        }
        catch(DMLException ex){
            system.debug('There was a DML exception that occurred while processing Pick Tickets. Check the GeneratePickTickets method. '+ex.getMessage());
            system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            ErrorLog+='<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber()+'---'+ex.getMessage()+'; ';
        }
        
        for(Pick_Ticket__c aPT : ptickets){
            String orderNumber = OrderIDToOrderNumber.get(aPT.Order__c);
            OrderNumberToPTicketID.put(orderNumber,aPT.Id);
        }
        
        system.debug('<<SHIPMENT RESPONSE TOTAL  >> '+ obj.shipments.size());
        WBShipment.Shipments nextShipmentResponse;
        WBShipment.Shipments previousShipmentResponse;
        for(WBShipment.Shipments aShipmentResponse : obj.shipments){
            Order someOrder = srShipmentIDToOrderMap.get(aShipmentResponse.OrderID);
            if(someOrder != null &&  aShipmentResponse.merchantOrderId == someOrder.OrderNumber && (OpenPTpackagesmap.get(aShipmentResponse.Id)==null || OpenPTpackagesmap.get(aShipmentResponse.Id)=='')){
                for(Pick_Ticket__c p:ptickets){
                    if(p.NG_Shipment_ID__c == aShipmentResponse.OrderID && p.NG_Package_ID__c!=null && p.NG_Package_ID__c.contains('P-'+aShipmentResponse.Id)){
                        system.debug('Shipment matches');
                        shipmentsTobeCreated.clear();
                        shipmentsTobeCreated = GenerateSFShipments(p.Id,someOrder,aShipmentResponse); 
                    }
                }
                shipmentsTobeInserted.addAll(shipmentsTobeCreated);
                if(OrderNumberToPTicketID.get(someOrder.OrderNumber)!= null){
                    OLIs = OrderNumberToOLIs.get(someOrder.OrderNumber);
                    system.debug('<< OrderNumber >> '+someOrder.OrderNumber+' << OLIS >> '+OLIs);
                    system.debug('<< aShipmentResponse.items >> '+aShipmentResponse.Containers[0].items);
                    if(aShipmentResponse.Containers[0].items != null){
                        String frtCode = custSettings.FRT_Code__c;
                        String taxCode = custSettings.TAX_Code__c;
                        OrderItem saveFRT = new OrderItem();
                        OrderItem saveTAX = new OrderItem();
                        Boolean gotItems = false;
                        Decimal backOrderQuantity = 0.0;
                        Integer backOrderSize = 0;
                        List<Pick_Ticket__c> orderPts = new List<Pick_Ticket__c>();
                        orderPts = OrderPTMap.get(someOrder.Id);
                        pts=OrderPTMap.get(someOrder.Id);
                        system.debug('No. Of PTs for Current Order: '+pts.size());
                                
                        //Refresh line items lists for each order.
                        ptls = new List<Pick_Ticket_Line_Item__c>();
                        ptlsNonStock = new List<Pick_Ticket_Line_Item__c>();
                        
                        for(Pick_Ticket__c pt :pts){
                            if(pickTicketVsLineItemMap.containsKey(pt.id)){                                 
                                ptls.addAll(pickTicketVsLineItemMap.get(pt.id));
                                for(Pick_Ticket_Line_Item__c ptli : pickTicketVsLineItemMap.get(pt.id)){
                                    if(ptli.Line_Type__c!=null && (ptli.Line_Type__c.contains('- Non-Stock') || ptli.Line_Type__c.contains('P - Donation') || ptli.Line_Type__c.contains('- Direct Ship') ))
                                        ptlsNonStock.add(ptli);
                                }
                            }                               
                        }
                        
                        for(WBShipment.items anItem : aShipmentResponse.Containers[0].items){
                            for(Pick_Ticket__c p: orderPts){
                                for(OrderItem someOLI : OLIs){
                                    system.debug('<< COMPARE OLI PCODE>> '+someOLI.Product2.ProductCode+' << SKU >> '+anItem.upc );
                                    if(anItem.upc == someOLI.Product2.ProductCode && someOLI.Order.OrderNumber == someOrder.OrderNumber && p.NG_Shipment_ID__c == aShipmentResponse.OrderId && p.NG_Package_ID__c!=null && p.NG_Package_ID__c.contains('P-'+aShipmentResponse.Id)){
                                        system.debug('ANVPTMap'+p.Id+'-'+someOLI.Product2.ProductCode+'---'+PTpliMap.get(p.Id+'-'+someOLI.Product2.ProductCode)+'---'+pickTicketItems.get(p.Id+'-'+someOLI.Product2.ProductCode));
                                        Pick_Ticket_Line_Item__c newPTli = new Pick_Ticket_Line_Item__c(Pick_Ticket__c=p.Id,Product__c=someOLI.Product2Id, Quantity_Ordered__c=someOLI.Quantity, Item_Number__c=someOLI.Product2.ProductCode, Quantity_Given_Away__c=someOLI.Quantity_Given_Away__c,Estimated_Weight__c =  someOLI.Estimated_Weight__c,Quantity__c=anItem.shipQty,Line_Type__c=someOLI.Line_Type__c, Price__c=someOLI.UnitPrice, Promo_Code__c = someOLI.Promo_Code__c, Line_Description__c = someOLI.Description, PreOrder_Backorder_Handling__c = someOLI.PreOrder_Backorder_Handling__c);
                                        //IF ptli exists in SF and also exists in current batch
                                        if(PTpliMap.get(p.Id+'-'+someOLI.Product2.ProductCode)!=null && pickTicketItems.get(p.Id+'-'+someOLI.Product2.ProductCode)!=null){
                                            system.debug('PTLI Case 1');
                                            newPTli.id=PTpliMap.get(p.Id+'-'+someOLI.Product2.ProductCode).Id;
                                            newPTli.Quantity__c+=pickTicketItems.get(p.Id+'-'+someOLI.Product2.ProductCode).Quantity__c;
                                        }
                                        //IF ptli exists in SF
                                        else if(PTpliMap.get(p.Id+'-'+someOLI.Product2.ProductCode)!=null){
                                            system.debug('PTLI Case 2');
                                            newPTli.id=PTpliMap.get(p.Id+'-'+someOLI.Product2.ProductCode).Id;
                                            newPTli.Quantity__c+=PTpliMap.get(p.Id+'-'+someOLI.Product2.ProductCode).Quantity__c;
                                        }
                                        //IF ptli exists in another shipment in current batch
                                        else if(pickTicketItems.get(p.Id+'-'+someOLI.Product2.ProductCode)!=null){
                                            system.debug('PTLI Case 3');
                                            newPTli.Quantity__c+=pickTicketItems.get(p.Id+'-'+someOLI.Product2.ProductCode).Quantity__c;
                                        }
                                        
                                        
                                        pickTicketItems.put(p.Id+'-'+someOLI.Product2.ProductCode,newPTli);
                                        someOLI.Quantity_Shipped__c += anItem.shipQty;    // anItem.qty represents Total Qty Fillable.
                                        system.debug('<< PTLIS SO FAR >> '+pickTicketItems.values()+'<<  PER ORDER ID>> '+someOrder.OrderNumber);
                                        gotItems = true;
                                        OrderNumberToFilled.put(someOrder.OrderNumber,OrderNumberToFilled.get(someOrder.OrderNumber)+anItem.shipQty);
                                    }
                                    else{
                                        system.debug('Inside Freight and Tax');
                                        if(someOLI.Product2.ProductCode == frtCode){
                                            saveFRT = someOLI;
                                        }
                                        if(someOLI.Product2.ProductCode == taxCode){
                                            saveTAX = someOLI;
                                        }
                                    }
                                }// Loop - OLIs
                            }//PickTickets for Order
                        }//Loop - NG Global Items per order
                        if(gotItems == true){              
                            /*
                            TAX is being calculated in INTACTT
                            system.debug('<< ADD TAX >>');
                          	pickTicketItems.add(new Pick_Ticket_Line_Item__c(Pick_Ticket__c =PTicketID, Item_Number__c=taxCode,Product__c=saveTAX.Product2Id, Quantity_Ordered__c=1,Quantity__c=1,Line_Description__c = 'Sales Tax', Line_Type__c ='T - TextLine' ,Price__c=saveTAX.UnitPrice));            
                        	*/
                            Boolean freightExist = false;
                            if(pts.size() > 0){
                            system.debug('PTs exist, So Check whether Freight exist or not');
                            for(Pick_Ticket_Line_Item__c ptli: ptls){         
                                if(ptli.Item_Number__c == '43490')
                                {
                                    freightExist = true;
                                    break;
                                }
                            }      
                            if(!freightExist){
                                system.debug('Since Freight Not-Exist on the PTLIs, create Freight PTLI');
                                system.debug('<< ADD FRT >>');
                                if(ptlsNonStock.size() > 0){
                                    pickTicketItems.put(pts[1].Id+'-'+frtCode,(new Pick_Ticket_Line_Item__c(Pick_Ticket__c =pts[1].Id, Item_Number__c=frtCode,Product__c=saveFRT.Product2Id, Quantity_Ordered__c=1,Quantity__c=1,Line_Description__c = 'Freight Charge', Line_Type__c ='F - Freight' ,Price__c=saveFRT.UnitPrice))); 
                                }
                                else{
                                    pickTicketItems.put(pts[0].Id+'-'+frtCode,(new Pick_Ticket_Line_Item__c(Pick_Ticket__c =pts[0].Id, Item_Number__c=frtCode,Product__c=saveFRT.Product2Id, Quantity_Ordered__c=1,Quantity__c=1,Line_Description__c = 'Freight Charge', Line_Type__c ='F - Freight' ,Price__c=saveFRT.UnitPrice))); 
                                }
                            }
                            else{
                                system.debug('Since Freight Exist on the PTLIs, donot Create another Freight');
                            }
                        }
                    }
                        
                    }//IF - Items
                }//IF - Order has PT
                upsert someOrder;
            }//IF - Each Shipment Order
        } //FOR - Shipment Master
        
        try{
            Set<Pick_Ticket_Line_Item__c> ptis = new Set<Pick_Ticket_Line_Item__c>();
            List<Pick_Ticket_Line_Item__c> plsList = new List<Pick_Ticket_Line_Item__c>();
            if(pickTicketItems.size() > 0){
                ptis.addAll(pickTicketItems.values());
                plsList.addAll(ptis);
                upsert plsList;
            }
            //Insert all the shipments
            if(shipmentsTobeInserted.size() > 0){
                system.debug('ANVsh2:'+shipmentsTobeInserted.size()+'-'+shipmentsTobeInserted);
                Set<Shipment__c> ShipmentsSet = new Set<Shipment__c>();
	            ShipmentsSet.addAll(shipmentsTobeInserted);
                shipmentsTobeInserted=new List<Shipment__c>();
                shipmentsTobeInserted.addall(ShipmentsSet);
                system.debug('ANVsh3:'+shipmentsTobeInserted.size()+'-'+shipmentsTobeInserted);
                upsert shipmentsTobeInserted;
            }
            
            List<Pick_Ticket_Line_Item__c> pitls = new List<Pick_Ticket_Line_Item__c>();
            List<Pick_Ticket__c> ptDelete = new List<Pick_Ticket__c>();
            List<Pick_Ticket__c> ptToBeClosed = new List<Pick_Ticket__c>();
            List<Pick_Ticket__c> ptickets2 = [Select id,Name, Has_Voided_Shipment__c,Total_Pick_Ticket_Line_Items__c,Order__c,Status__c, (select Product__c,Quantity_Ordered__c,Item_Number__c,Quantity_Given_Away__c,Estimated_Weight__c,Quantity__c,Line_Type__c,Price__c,Promo_Code__c,Line_Description__c,PreOrder_Backorder_Handling__c from Pick_Ticket_Line_Items__r) from Pick_Ticket__c where Id IN:ptickets];
            system.debug('No. Of PTs for Current Order: '+ptickets.size()+'-'+ptickets2.size());
        
            for(Pick_Ticket__c pit: ptickets2){
                pitls = pit.Pick_Ticket_Line_Items__r;
                system.debug('No. Of PTLIs for all for PT: '+pitls.size());
                if(pitls.size() == 0){
                    system.debug('Empty Pick Ticket: '+ pit.Id);
                    ptDelete.add(pit);
                }
                else{
                    ptToBeClosed.add(pit);
                }
            }
            
            List<Pick_Ticket__c> delete0PTs = new List<Pick_Ticket__c>();
            if(ptToBeClosed.size() > 0){
                for(Pick_Ticket__c aPT : ptToBeClosed){
                    string OrderNum = OrderIDToOrderNumber.get(aPT.Order__c);
                    apt.Has_Voided_Shipment__c=voidedshiporders.get(OrderNum)!=null?true:false;
                    system.debug('ANVFILLable:'+OrderNumberToFillable.get(OrderNum)+'- ANVFILLed:'+OrderNumberToFilled.get(OrderNum));
                    system.debug('ANVordered:'+OrderNumberToOrdered.get(OrderNum)+'- ANVShipped:'+OrderNumberToShipped.get(OrderNum));
                    if(!apt.Has_Voided_Shipment__c && aPT.Total_Pick_Ticket_Line_Items__c != 0 && OrderNumberToFillable.get(OrderNum)-OrderNumberToFilled.get(OrderNum)==0 && OrderNumberToOrdered.get(OrderNum) - (OrderNumberToShipped.get(OrderNum) +OrderNumberToFilled.get(OrderNum))==0){
                        aPT.Status__c = 'Closed';
                        system.debug('In Here ');
                    }else if(aPT.Total_Pick_Ticket_Line_Items__c==0){
                        delete0PTs.add(aPT);
                    }  
                }
                if(delete0PTs.size() > 0){
                    delete delete0PTs;
                }
                if(ptickets.size() > 0){
                    upsert ptToBeClosed; 
                } 
            }
            
            if(stockOLIs.size() > 0){
                upsert stockOLIs;
            }
        }
        catch(CalloutException ex){
            system.debug('There was an exception that occurred while updating order objects and their child obejcts '+ex.getMessage());
            system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            ErrorLog+='<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber()+'---'+ex.getMessage()+'; ';
        }
    }
    //Execute - END
    
    //GeneratePickTickets() - Taken from the Original GeneratePickTicket in OrderEntryStatus
    private Pick_Ticket__c GeneratePickTickets(Order someOrder,Set<OrderItem> stockOLIs, Double TotalFillableItems,String ngShipmentID,String PackageId, map<string,Pick_Ticket__c> OrderTonewPT){
        // See OrderEntrystatus and copy that inito here.
        system.debug(' INSIDE GEN PTS: <<ORDER>> '+someOrder);
        system.debug(' INSIDE GEN PTS: <<stockOLIs>> '+stockOLIs);
        system.debug(' INSIDE GEN PTS: <<TotalFillableItems>> '+TotalFillableItems);
        Pick_Ticket__c pticket = new  Pick_Ticket__c();
         // !!! generate pick tickets (See Apex Code OrderEntryStatus)
       // system.debug('Inventory Items: '+someOrder.Inventory_Items__c+'; '+'Non-Inventory: '+someOrder.Non_inventory_Items__c+'; '+'Total Fillable: '+TotalFillableItems);
        if(someOrder.Inventory_Items__c > 0 && TotalFillableItems >= 1 && someOrder.Pick_Tickets__r!=null && someOrder.Pick_Tickets__r.size()>0){
            system.debug('case 1 : I>0  TF>0 OpenPT already Exists');
            pticket=someOrder.Pick_Tickets__r[0];
            if(pticket.NG_Package_ID__c!=null && !pticket.NG_Package_ID__c.contains('P-'+PackageId))
                pticket.NG_Package_ID__c+= ';P-'+PackageId;
        }
        else if(someOrder.Inventory_Items__c > 0 && TotalFillableItems >= 1 && OrderTonewPT.get(someOrder.orderNumber)!=null){
            system.debug('case 2 : I>0  TF>0 OpenPT already created this shipment');
            pticket=OrderTonewPT.get(someOrder.orderNumber);
            if(pticket.NG_Package_ID__c!=null && !pticket.NG_Package_ID__c.contains('P-'+PackageId))
                pticket.NG_Package_ID__c+= ';P-'+PackageId;
        }
        else if(someOrder.Inventory_Items__c > 0 && TotalFillableItems >= 1){
            system.debug('case 3 : I>0  TF>0 OpenPT Create');
                 pticket =new Pick_Ticket__c(Order__c=someOrder.Id,Status__c='Open',NG_Shipment_ID__c=ngShipmentID,NG_Package_ID__c='P-'+PackageId,Company__c=someOrder.Company__c,Package_Shipped__c = true,Shipment_Created__c = true );
        }
        else if(someOrder.Inventory_Items__c > 0  && TotalFillableItems <= 0){
            system.debug('case 4 : I>0 TF=0');
            // do not generate a pick ticket
            someOrder.Pick_Ticket_Not_Fulfillable__c = true;
        }//TW: 2-28-13 If an odr is of Payment Status "To Be Billed" then that is similar to a Back order and the ticket shouldbe closed.
        else if(someOrder.Inventory_Items__c > 0  && TotalFillableItems <= 0){
            system.debug('case 5 : I>0  TF=0');   
            if(stockOLIs.size() > 0){
                if(someOrder.Inventory_Items__c > 0 && TotalFillableItems <= 0){
                    someOrder.Pick_Ticket_Not_Fulfillable__c = true;
                }
            }//END TW 4-3-2012
            else{
                someOrder.Pick_Ticket_Not_Fulfillable__c = true;
            }
        }
        else {
            system.debug('case 6 else');
            String OrderError = someOrder.Error_Log__c;
            if(OrderError != null) { OrderError += '\n'; } else { OrderError = ''; }
                someOrder.Error_Log__c = OrderError + String.valueOf(DateTime.Now())+': Attempted to generate Pick Ticket, but did not match any case. I='+
                someOrder.Inventory_Items__c+' N='+someOrder.Non_inventory_Items__c+' TF='+TotalFillableItems;
        }                   
        system.debug(pticket);
        system.debug('<<  GENERATE PTS - LAST INSIDE PTICKETS >> '+ptickets);
        return pticket;
    }
    
    //GenerateSFShipments() - Taken from the Original GeneratePickTicket in OrderEntryStatus
    private List<Shipment__c> GenerateSFShipments(ID PTicketID, Order someOrder,WBShipment.Shipments aShipmentResponse){
        List<Shipment__c> pkgShipments = new List<Shipment__c>();
        Integer pos = 0;
        Shipment__c someShipment = new Shipment__c(Order__c=someOrder.Id, Pick_Ticket__c = PTicketID,Carrier__c=aShipmentResponse.carrier,Tracking_Number__c=aShipmentResponse.tracking,ShipmentCreated__c=true, NG_Shipment_ID__c=aShipmentResponse.orderId,NG_Package_ID__c=String.valueOf(aShipmentResponse.Id),Shipping_Weight__c=Decimal.valueOf(aShipmentResponse.totalWeight),Tracking_URL_WB__c=aShipmentResponse.trackingUrl);
        if(aShipmentResponse.shipDate != '' &&  aShipmentResponse.shipDate != null){
            pos = aShipmentResponse.shipDate.indexOf(' ');
            if(pos >0){
                system.debug('<<aShipmentResponse.shipDate >> '+aShipmentResponse.shipDate+' with Position of: '+pos+'<< Results of Date: '+aShipmentResponse.shipDate.substring(0,pos));
                aShipmentResponse.shipDate = aShipmentResponse.shipDate.substring(0,pos);
                someShipment.Ship_Date__c =  Date.valueOf(aShipmentResponse.shipDate);
                }
        }
        system.debug('ANVDupes:'+PTicketID+'-'+someOrder.OrderNumber+'-'+aShipmentResponse.orderId+'-'+aShipmentResponse.Id);
        pkgShipments.add(someShipment);
        // PKG-FOR    
        return  pkgShipments;
    }
    
    //Finish
    global void finish(Database.BatchableContext BC){
        //Swap start and end times
        custSettings.Start_Shipped_Time__c = custSettings.End_Shipped_Time__c;
        //add hour/hours to the end ship time
        custSettings.end_Shipped_Time__c = custSettings.end_Shipped_Time__c.replace('T',' ');
        custSettings.end_Shipped_Time__c = String.valueOf(DateTime.valueOf(custSettings.end_Shipped_Time__c).addHours(Integer.valueOf(custSettings.Added_Hours__c)));
        custSettings.end_Shipped_Time__c = custSettings.end_Shipped_Time__c.replace(' ','T');
        system.debug('Start Time After :'+custSettings.Start_Shipped_Time__c);
        system.debug('End Time After :'+custSettings.end_Shipped_Time__c);
        if(API=='On')
        	update custSettings;
        
        AsyncApexJob apexBatchResult = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        String emailBody = ' Apex Batch Search WhiteBox Shipment objects  processed: '+ apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n';
        emailBody += '<<==== Batch Window ====>:'+startShippedTimestamp+' to '+endShippedTimestamp+'\n';
        emailBody += '<<==== WB Shipment Responses processed ====>>: '+packages+'\n';
        emailBody += '<<==== WB Orders processed ====>>: '+ShipmentIDs.size()+'\n';
        emailBody += EmailMessage!=''?EmailMessage+'\n\n':'';
        emailBody += ErrorLog!='' && EmailMessage==''?'Errors in the batch:====>'+ErrorLog+'\n\n':'';
        Integer eolineCnt = 0;
        if(ShipmentIDs.size()>0)
            for(WBShipment.Shipments aShipmentResponse: obj.shipments){
                if(eolineCnt == 10){emailBody +='\n\n'; eolineCnt = 0;}
                if(eolineCnt < 9)
                    emailBody += aShipmentResponse.OrderId+', ';
                else
                    emailBody += aShipmentResponse.OrderId;
            eolineCnt++;
            }
        //Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'SF Administrator')]);
        List<GroupMember> Sfusers = [select GroupId,UserOrGroupId from GroupMember where Group.Name='WB Batch Notifications'];
        List<String> userEmail = new List<String>();
        if(Test.isRunningTest()){
            User tUser=[Select Email from User where Name Like 'MyAwana%' Limit 1];
            userEmail.add(tUser.Email);
        }else
            userEmail.add('SFApps@awana.org');
        if(ErrorLog!='' && EmailMessage==''){
            for(GroupMember g : Sfusers)
                userEmail.add(g.UserOrGroupId);
        }
        List<String> sendTo = new List<String>();
        sendTo.addAll(userEmail);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('ORG: Processes WhiteBox Shipments');
        mail.setSubject('ORG: Batch to Processes WhiteBox Shipments: ' + apexBatchResult.Status);
        mail.setPlainTextBody('ORG: Batch Process has completed\n\n' + emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}