/*
Purpose - Class PostShipmentRequest 
Description - Code will handle REst API  Http call out to Newgistics Warehouse for new orders   
Author:     Tony Wiliams.
Project:    Newgistics
Created:    12/01/2018 - <NEW 25>  - sending orders to Newgsitics web services from SFDC.Gets shipment ID from the response.
Updated:    01/31/2019 - <NEW-75> - Fixed Duplicate Ptickets from Non-Stock items
Updated Baji: WhiteBox project (converted xml to Json). 
Called By : ProcessOrder.Trigger
Test Class: PostShipmentRequest_Test with Newgistics_Mock and IDHelper
*/
global class PostShipmentRequest{

        @future (callout=true) // future method needed to run callouts from Triggers

      
        global static void postOrders(List<String> orderIds){
        List<Pick_Ticket__c> tickets = new List<Pick_Ticket__c>();
        IDHelper currentID = null;
        List<ID> currentIDs = new List<ID>();
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Awana_Settings__c custSetting =  Awana_Settings__c.getValues('WBOrderAPI');
        String API = '';
        API=custSetting.value__c;
       
            for (String ser : orderIds)
            {   // We need to deserialize these IDs into a list of IDS because SOQL will crash using String representation of IDs in the WHERE clause
                currentID = (IDHelper) JSON.deserialize(ser, IDHelper.class);
                currentIDs.add((ID)currentID.Id);
            }  
            system.debug('<< CURRENT IDs >> '+currentIDs);
            // Get Order Items and place non-stock and stock in 2 different lists:
            List<OrderItem> stockOLIs = [SELECT Id, Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name
                                FROM OrderItem WHERE (Line_Type__c like 'S - Stock%' or Line_Type__c like 'T - Text Line%' or Line_Type__c like 'F - Freight') and OrderId =: currentIDs];  
            system.debug('<< stockOLIs >> '+stockOLIs);
            List<OrderItem> non_stockOLIs = [SELECT Id, Quantity,OrderId,UnitPrice,LineNumber__c,PreOrder_Backorder_Handling__c,Product2Id,Quantity_Shipped__c,Quantity_Given_Away__c,Product2.ProductCode,Line_Type__c,PricebookEntry.Product2.ProductCode,PricebookEntry.Product2.Name
                                FROM OrderItem WHERE (Line_Type__c like '% - Non-Stock%' or Line_Type__c like '%P - Donation%' or Line_Type__c like '% - Direct Ship%')  and OrderId =: currentIDs];  
           
            // Get newly confirmed Orders 
            List<Order> Os = [SELECT Id, Shipping_Street__c,Billing_Address__r.First_Name__c,Billing_Address__r.Last_Name__c,Billing_Address__r.Country__c,Billing_Phone__c,Shipping_City__c,PriceBookName__c,OrderNumber,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,Non_inventory_Items__c,Billing_Address__r.State__c,
                                Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Inventory_Items__c,TotalAmount,Billing_Address__r.City__c,
                                BillToContact.FirstName,BillToContact.LastName,BillingAddress,Account.Name,Billing_Address__r.Zip_Code__c,Billing_Address__r.Address_Line_1__c,
                                Billing_Address__r.Address_Line_2__c,Account.Mailing_Address_Book__c,Account.Phone,Account.Fax,Error_Log__c,Shipping_Country_Code__c,
                                Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Shipment_Cost__c,Company__c,Payment_Terms__c,Status,NG_Shipment_ID__c,
                                Shipping_Address__r.Address_Line_1__c,Shipping_Address__r.Address_Line_2__c
                                FROM Order WHERE id in: currentIDs];
            
            List<OrderItem> sOLIs = new List<OrderItem>();
            List<OrderItem> nsOLIs = new List<OrderItem>();
            List<OrderItem> tbbOLIs = new List<OrderItem>();
            Map<Id,List<OrderItem>> ordersWithNonStockItems = new Map<Id,List<OrderItem>>();
            // Check all Non-Stocks  including (Donation, FRT charge, and Direct/Drop Ship )and then generate the pick ticket and its items
            for(Order someOrder : Os){
                sOLIs.clear();
                nsOLIs.clear(); 
                tbbOLIs.clear();
                if(someOrder.Payment_Terms__c != 'Sales Credit' && someOrder.Payment_Terms__c != 'Sales Credit - Refunded'){
                    Boolean nonStockFound = false;
                    someOrder.status = 'Order Being Fulfilled';
                    Boolean gotTBB = false;
                    if(someOrder.Payment_Terms__c == 'To Be Billed'){
                        if(non_stockOLIs.size() > 0  ){
                            for(OrderItem someOLI : non_stockOLIs){
                                if(someOLI.OrderId == someOrder.Id){
                                    tbbOLIs.add(someOLI);
                                }
                            }
                        system.debug('<< TBB NON_STOCK  >> '+tbbOLIs);// OK
                        }
                        if(stockOLIs.size() > 0 ){
                            for(OrderItem someOLI : stockOLIs){
                                if(someOLI.OrderId == someOrder.Id){
                                    tbbOLIs.add(someOLI);
                                }
                            }
                        system.debug('<< TBB STOCK  >> '+tbbOLIs);// OK
                        }
                        gotTBB = true;
                        nonStockFound = true;
                        if(tbbOLIs.size() > 0){
                            ordersWithNonStockItems.put(someOrder.Id, tbbOLIs);
                            Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=someOrder.Id,Status__c='Closed', Company__c=someOrder.Company__c);
                            tickets.add(pt);
                            system.debug('<< TBB PT CREATE >> '+tbbOLIs);// OK
                        }
                    }//IF TBB
                    else{
                        if(non_stockOLIs.size() > 0){
                            for(OrderItem someOLI : non_stockOLIs){
                                if(someOLI.OrderId == someOrder.Id){
                                    nsOLIs.add(someOLI);
                                }
                            system.debug('<< PLAIN NON-STOCK >> '+tickets);// OK   
                            }
                            nonStockFound = true;
                            if(nsOLIs.size() > 0){
                                ordersWithNonStockItems.put(someOrder.Id, nsOLIs);
                                Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=someOrder.Id,Status__c='Closed', Company__c=someOrder.Company__c);
                                tickets.add(pt);
                                system.debug('<< PLAIN NON_STOCK #2 >> '+tickets);// OK
                            }
                        }
                        if(stockOLIs.size() > 0 ){
                            for(OrderItem someOLI : stockOLIs){
                                if(someOLI.OrderId == someOrder.Id){
                                    sOLIs.add(someOLI);
                                }
                            }                       }
                    }//ELSE
                    //FRT CHARGE
                    if(sOLIs.size() == 2 && gotTBB == false && nonStockFound == false){
                        for(OrderItem frtTax : sOLIs){
                            if(frtTax.Line_Type__c.contains('T - Text Line')){nonStockFound = true;}
                            if(frtTax.Line_Type__c.contains('F - Freight')){nonStockFound = true;}
                        }
                        ordersWithNonStockItems.put(someOrder.Id, sOLIs);
                        Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=someOrder.Id,Status__c='Closed', Company__c=someOrder.Company__c);
                        tickets.add(pt);
                        system.debug('<< OK 1st FRTCHRG PT #3 >> '+tickets);// OK
                    }
                    
                    // For non-TBB and  non-FRT-Charge-Stock items do an Http Callout to NG Web service.
                    system.debug('Stock OLIs size is:'+sOLIs.size());
                    if(sOLIs.size() > 2 && gotTBB == false){
                        system.debug('<< GET OLIS >> '+sOLIs);
                        if(!isSandbox && API=='On')
                            sendOrderToWB(someOrder,sOLIs); 
                    }
                }// IF-Sales Credit
            }// master Order loop
            if(tickets.size() > 0){
                insert tickets;
                createNSPickTicketItems(tickets,ordersWithNonStockItems);
            }
            upsert Os;
            system.debug('<< UPDATED ORDERS >>' + Os);
            system.debug('Order Shipment ID:'+Os[0].NG_Shipment_ID__c);
            
    }//Method 
 
    /*******************************************************************************
      createNSPickTicketItems: Creates pick tickets for Non-Stock Items
    *******************************************************************************/
    public static void createNSPickTicketItems(List<Pick_Ticket__c> tickets,Map<Id,List<OrderItem>> ordersWithNonStockItems ){ 
        system.debug('<< PICK TICKETS >> '+tickets);
        // Create pick ticket line items for the closed and open pick tickets.
        List<Pick_Ticket_Line_Item__c> ptlis = new List<Pick_Ticket_Line_Item__c>();
        for(Pick_Ticket__c pt : tickets){
            List<OrderItem> non_stock_olis =  ordersWithNonStockItems.get(pt.Order__c);
            system.debug('<< LINE ITEMS FOR FRT CHARGE  >> '+non_stock_olis);
            if(pt.Status__c == 'Closed'){ 
                for(OrderItem anOli : non_stock_olis){
                    ptlis.add(new Pick_Ticket_Line_Item__c(Pick_Ticket__c=pt.Id,
                        Line_Type__c=anOli.Line_Type__c,
                        Price__c=anOli.UnitPrice,
                        Quantity_Given_Away__c=anOli.Quantity_Given_Away__c,
                        Product__c=anOli.Product2Id,
                        Item_Number__c = anOli.Product2.ProductCode,
                        PreOrder_Backorder_Handling__c=anOli.PreOrder_Backorder_Handling__c,
                        Quantity__c = anOli.Quantity,                                   
                        Quantity_Ordered__c = anOli.Quantity));    
                    }//for
                }
            }
            if(ptlis.size() > 0){
                insert ptlis; 
            }
        upsert tickets;
        List<Pick_Ticket__c> delete_0_PTLIs = new List<Pick_Ticket__c>();
        for(Pick_Ticket__c pt : tickets){
            system.debug('<< PICK TICKET >>--'+pt.Id+'--<< TOT LINE LINE ITEM COUNT >> '+pt.Total_Freight_Line_Items__c);
            if(pt.Total_Freight_Line_Items__c == 0){
                delete_0_PTLIs.add(pt);
            }
        }
        if(delete_0_PTLIs.size() > 0){
            delete delete_0_PTLIs;
        }
        upsert tickets;
     }
    /*******************************************************************************
      sendOrderToWB: Calls NG Web serice for all Orders with stock items
    *******************************************************************************/
    public static HttpResponse sendOrderToWB(Order someOrder,List<OrderItem> stockOLIs){  
        //String builtXMLPostStream = CreateJSON(someOrder, stockOLIs);
        String builtJSON = CreateJSON(someOrder, stockOLIs);
        //system.debug('JSON POST Request String: '+builtJSON); //Check for OLIS
        // build callout
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String apikey = '4fc724a5-7a4c-4796-a6b2-dcac2b62448a';
        String appId = 'awana';
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        //req.setEndpoint('https://stagingapi.whitebox.co/actions/private/order/create?appId='+appId+'&apiKey='+apikey);
        req.setEndpoint('https://api.whitebox.co/actions/private/order/create?appId='+appId+'&apiKey='+apikey);
        req.setBody(builtJSON);
        system.debug('<< JSON PAYLOAD SENT >> '+builtJSON);
        
        req.setTimeout(120000);
        // Send the POST Shipment Request
        try{
            res = h.send(req);
            // Log the XML content
            system.debug('Did We Get Here? '+res.getBody()); 
            String strJSON = res.getBody();
            // Generate the HTTP response as an XML stream
             String shipmentID = ''; // placeholder for the recursive call stack
            //Retrieve the response info for this document (Shipment Response). Even if status is On Hold we always get the Shipment ID and Order ID back.
            if(res.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(strJSON);
                String fieldName = parser.getText();
                while (parser.nextToken() != null ) {
                    while(parser.getCurrentToken() != JSONToken.START_OBJECT){
                        parser.nextToken();
                    }
                    parser.nextToken();
                    while(parser.getCurrentToken() != JSONToken.END_OBJECT){
                        if(parser.getText() =='orderId'){
                            parser.nextToken();
                            system.debug('<< Order VALUE >> '+parser.getText());
                            someOrder.NG_Shipment_ID__c = parser.getText();
                        }
                        parser.nextToken();
                    }
                    parser.nextToken(); 
                } // WHILE parser.nextToken() != null 
            }
            else if(res.getStatusCode() == 400){
                someOrder.Error_Log__c = someOrder.Error_Log__c==null?res.getBody():someOrder.Error_Log__c +'\n'+res.getBody();
            }
            else{
                //Baji: mail code added to see the response body
                someOrder.Error_Log__c = someOrder.Error_Log__c==null?res.getBody():someOrder.Error_Log__c +'\n'+res.getBody();
                List<String> sendTo = new List<String>();
                sendTo.add('SFApps@awana.org');Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(sendTo);mail.setSenderDisplayName('Send Order to WB with Order Number:'+someOrder.OrderNumber);
                mail.setSubject('Error in sending Order to WhiteBox');mail.setPlainTextBody('Not able to send Order to WhiteBox please check the response body \n\n' + res.getBody());
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
         
        }catch(Exception ex){
            system.debug('There was an exception that occurred while processing the Shipment Response '+ex.getMessage());
            system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            someOrder.Error_Log__c = someOrder.Error_Log__c==null?ex.getMessage():someOrder.Error_Log__c +'\n'+ex.getMessage();
       }  
       return res;
    }
    /*******************************************************************************
      CreateJSON:
        1. Sets up the JSON payload to deliver to Post orders to WhiteBox.
    *******************************************************************************/
    public static String CreateJSON(Order someOrder, List<OrderItem> ListOLIs){
        // Calculate the Billign info to insert into the XML payload of the custom field element.
     //  List<Address__c> someBillingAddr =  [SELECT Id, Address_Line_1__c, Address_Line_2__c, City__c,Country__c,First_Name__c,Last_Name__c,State__c,Zip_Code__c From Address__c  
       //                               WHERE Account__c =: someOrder.AccountId and Account__r.Mailing_Address_Book__c=: someOrder.Account.Mailing_Address_Book__c  Limit 1];
                //Shipping Street Lines - Anvesh
                List<string> StreetLines = someOrder.Shipping_Street__c!=null?someOrder.Shipping_Street__c.split('\r\n'):new List<string>();
                                
                system.debug('ANV:'+StreetLines.size()+'-'+StreetLines);
                //Shipping Street Lines - End
                JSONGenerator builtJSON = JSON.createGenerator(true);
                builtJSON.writeStartObject();
                builtJSON.writeFieldName('order');
                    builtJSON.writeStartObject();
                    builtJSON.writeObjectField('createdDate', someOrder.EffectiveDate);
                    if(someOrder.OrderNumber != Null){
                        builtJSON.writeObjectField('merchantOrderId', someOrder.OrderNumber);
                    }    
                    builtJSON.writeObjectField('currency', 'USD');
                    builtJSON.writeObjectField('requestedShipService', someOrder.Shipping_Type__c);
                    builtJSON.writeObjectField('salesChannel', 'Awana');
                    builtJSON.writeFieldName('addresses');
                    builtJSON.writeStartArray();
                    builtJSON.writeStartObject(); //addresses start
                    builtJSON.writeObjectField('isShipTo', true);
                    builtJSON.writeObjectField('isBillTo', false);
                    builtJSON.writeObjectField('isReturnTo', false);
                    builtJSON.writeObjectField('isShippedFrom', false);
                    builtJSON.writeObjectField('isThirdPartyBilling', false);
                    builtJSON.writeFieldName('address');
                    builtJSON.writeStartObject(); //address start
                    if(someOrder.Ship_to_First_Name__c != Null){
                        builtJSON.writeObjectField('firstName', someOrder.Ship_to_First_Name__c);
                    }
                    if(someOrder.Ship_to_Last_Name__c != Null){
                        builtJSON.writeObjectField('lastName', someOrder.Ship_to_Last_Name__c);
                    }
                    /*if(someOrder.Account.Name != Null){
                        builtJSON.writeObjectField('name', someOrder.Account.Name);
                    }*/
                    if(someOrder.Billing_Phone__c != Null){
                        builtJSON.writeObjectField('phone', someOrder.Billing_Phone__c);
                    }
                    if(someOrder.Billing_Email__c != Null){
                        builtJSON.writeObjectField('email', someOrder.Billing_Email__c);
                    }
                    if(someOrder.Account.Name != Null){
                        builtJSON.writeObjectField('company', someOrder.Account.Name);
                    }
                    if(StreetLines.size()>0)
                        builtJSON.writeObjectField('street', StreetLines[0]);
                    if(StreetLines.size()>1)
                        builtJSON.writeObjectField('street2', StreetLines[1]);
                    if(StreetLines.size()>2)
                        builtJSON.writeObjectField('street3', StreetLines[2]);
                    if(someOrder.Shipping_City__c != Null){
                        builtJSON.writeObjectField('city', someOrder.Shipping_City__c);
                    }
                    if(someOrder.Shipping_State__c != Null){
                        builtJSON.writeObjectField('state', someOrder.Shipping_State__c);
                    }
                    if(someOrder.Shipping_Zip_Code__c != Null){
                        builtJSON.writeObjectField('zip', someOrder.Shipping_Zip_Code__c);
                    }
                    if(someOrder.Shipping_Country_Code__c != Null){
                        builtJSON.writeObjectField('country', someOrder.Shipping_Country_Code__c);
                    }
                    builtJSON.writeEndObject(); //address End
                    builtJSON.writeEndObject(); //addresses End
                    builtJSON.writeEndArray();  //addresses array end
                    builtJSON.writeFieldName('orderItems');
                        builtJSON.writeStartArray();
                        for( OrderItem someItem : ListOLIs ){
                            if(someItem.Line_Type__c != 'F - Freight'  && someItem.Line_Type__c != 'T - Text Line'){
                                builtJSON.writeStartObject(); //orderItems start
                                builtJSON.writeObjectField('merchantItemId', '1');
                                builtJSON.writeObjectField('upc', String.valueOf(someItem.PricebookEntry.Product2.ProductCode));
                                builtJSON.writeObjectField('qty', someItem.Quantity.intValue());
                                builtJSON.writeObjectField('unitPrice', someItem.UnitPrice);
                                builtJSON.writeEndObject(); //orderItems End
                            }
                        }    
                    builtJSON.writeEndArray();  //orderItems array end
                builtJSON.writeEndObject(); //Order End
                builtJSON.writeEndObject(); //End
                String stringJSON = builtJSON.getAsString();
                system.debug('JSON String\n'+stringJSON);
        
            return stringJSON;
            
    }// Method CreateJSON
    
}//Class