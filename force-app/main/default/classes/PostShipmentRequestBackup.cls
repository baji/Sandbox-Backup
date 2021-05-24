/*
Name - PostShipmentRequestBackup
Purpose - Backup code taken for PostShipmentRequest class while moving to WhiteBox from Newgistics in TEST sandbox. 

*/
global class PostShipmentRequestBackup{

        @future (callout=true) // future method needed to run callouts from Triggers
      
        global static void postOrders(List<String> orderIds){
        List<Pick_Ticket__c> tickets = new List<Pick_Ticket__c>();
        IDHelper currentID = null;
        List<ID> currentIDs = new List<ID>();
       
       
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
                                Billing_Address__r.Address_Line_2__c,Account.Mailing_Address_Book__c,Account.Phone,Account.Fax,
                                Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Shipment_Cost__c,Company__c,Payment_Terms__c,Status,NG_Shipment_ID__c
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
                if(someOrder.Payment_Terms__c != 'Sales Credit'){
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
                    if(sOLIs.size() > 2 && gotTBB == false){
                        system.debug('<< GET OLIS >> '+sOLIs);
                        sendOrderToNewgistics(someOrder,sOLIs); 
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
            if(Os[0].NG_Shipment_ID__c == ''){
                   List<String> sendTo = new List<String>();
                    sendTo.add('bajibasha.s@accionlabs.com');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(sendTo);
                    //mail.setSenderDisplayName('Shipment Id is null for the order:'+someOrder.OrderNumber);
                    mail.setSubject('Shipment Id is EMpty for Order no:'+Os[0].NG_Shipment_ID__c);
                    mail.setPlainTextBody('NG did not sent Shipment Id in the response');
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
               }
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
      sendOrderToNewgistics: Calls NG Web serice for all Orders with stock items
    *******************************************************************************/
    public static HttpResponse sendOrderToNewgistics(Order someOrder,List<OrderItem> stockOLIs){  
        String builtXMLPostStream = CreateXMLTemplate(someOrder, stockOLIs);
        system.debug('XML POST Request String: '+builtXMLPostStream); //Check for OLIS
        // build callout
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String apikey='4d0512866afd439f966fa089f51155ee';
        req.setMethod('POST');
        req.setHeader('Content-Type','application/xml; charset=UTF-8');
        req.setEndpoint('http://apistaging.newgisticsfulfillment.com/post_shipments.aspx?key='+apikey);
        req.setBody(builtXMLPostStream);
        system.debug('<< XML PAYLOAD SENT >> '+builtXMLPostStream);
        req.setTimeout(20000);
        // Send the POST Shipment Request
        try{
            res = h.send(req);
            // Log the XML content
            system.debug('Did We Get Here? '+res.getBody()); 
            
            // Generate the HTTP response as an XML stream
             String shipmentID = ''; // placeholder for the recursive call stack
            //Retrieve the response info for this document (Shipment Response). Even if status is On Hold we always get the Shipment ID and Order ID back.
            if(res.getStatusCode() == 200) {
                String xml = res.getBody();
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xml);
                system.debug('<< POST XML >> '+xml);
                Dom.XMLNode root =domDoc.getRootElement();
                // Traverse through the child elements to get response info from the returned Post SHipment Response message.
               shipmentID=traverseXML(root,someOrder);
               system.debug('Shipment ID for the Order: '+shipmentID);
            }
            else{
                //Baji: mail code added to see the response body
                List<String> sendTo = new List<String>();
                sendTo.add('SFApps@awana.org');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(sendTo);
                mail.setSenderDisplayName('Send Order to NG with Order Number:'+someOrder.OrderNumber);
                mail.setSubject('Error in sending Order to NG ');
                mail.setPlainTextBody('Not able to send Order to NG please check the response body \n\n' + res.getBody());
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
         
        }catch(Exception ex){
            system.debug('There was an exception that occurred while processing the Shipment Response '+ex.getMessage());
            system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
       }  
       return res;
    }
    /*******************************************************************************
      CreateXMLTemplate:
        1. Sets up the XML payload to deliver to Post orders to Newgistics.
    *******************************************************************************/
    public static String CreateXMLTemplate(Order someOrder, List<OrderItem> ListOLIs){
        // Calculate the Billign info to insert into the XML payload of the custom field element.
     //  List<Address__c> someBillingAddr =  [SELECT Id, Address_Line_1__c, Address_Line_2__c, City__c,Country__c,First_Name__c,Last_Name__c,State__c,Zip_Code__c From Address__c  
       //                               WHERE Account__c =: someOrder.AccountId and Account__r.Mailing_Address_Book__c=: someOrder.Account.Mailing_Address_Book__c  Limit 1];
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
            xmlW.writeStartDocument('utf-8','1.0');
                xmlW.writeStartElement(null,'Orders',null);
                    xmlW.writeAttribute(null, null,'apiKey','4d0512866afd439f966fa089f51155ee');
                    xmlW.writeStartElement(null,'Order',null);
                        if(someOrder.OrderNumber != Null){
                            xmlW.writeAttribute(null, null,'orderID',someOrder.OrderNumber);    
                        }
                        //system.debug('<< XML STRING: >>'+xmlW.getxmlString());
                        xmlW.writeStartElement(null,'Warehouse',null);
                            xmlW.writeAttribute(null, null,'id','160'); 
                        xmlW.writeEndElement();
                            xmlW.writeStartElement(null,'CustomerInfo',null);
                                xmlW.writeStartElement(null,'Company',null);
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'FirstName',null);
                                    if(someOrder.Ship_to_First_Name__c != Null){
                                        xmlW.writeCharacters(someOrder.Ship_to_First_Name__c);
                                    }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'LastName',null);
                                    if(someOrder.Ship_to_Last_Name__c != Null){
                                        xmlW.writeCharacters(someOrder.Ship_to_Last_Name__c);
                                    }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Address1',null);
                                    xmlW.writeCharacters(someOrder.Shipping_Street__c);
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Address2',null);
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'City',null);
                                    if(someOrder.Shipping_City__c != Null){
                                        xmlW.writeCharacters(someOrder.Shipping_City__c);
                                    }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'State',null);
                                     if(someOrder.Shipping_State__c != Null){
                                        xmlW.writeCharacters(someOrder.Shipping_State__c);
                                    }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Zip',null);
                                     if(someOrder.Shipping_State__c != Null){
                                        xmlW.writeCharacters(someOrder.Shipping_Zip_Code__c);
                                     }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Country',null);
                                    xmlW.writeCharacters(someOrder.Shipping_Country__c);
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Email',null);
                                    if(someOrder.Billing_Email__c != null){
                                        xmlW.writeCharacters(someOrder.Billing_Email__c);
                                    }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Phone',null);
                                if(someOrder.Billing_Phone__c != null){
                                    xmlW.writeCharacters(someOrder.Billing_Phone__c);
                                }
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'Fax',null);
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'IsResidential',null);
                                    xmlW.writeCharacters('true'); // <--- Verify this with someone
                                xmlW.writeEndElement();
                    xmlW.writeEndElement();// <--- End Customer Info
                    
                    xmlW.writeStartElement(null,'DropShipInfo',null);
                        xmlW.writeStartElement(null,'CompanyName',null);
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'Address',null);        
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'City',null);       
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'State',null);      
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'Zip',null);
                        xmlW.writeEndElement();
                    xmlW.writeEndElement();// <-- End Drop Ship INfo
       
      
                    xmlW.writeStartElement(null,'AllowDuplicate',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'OrderDate',null);
                        if(someOrder.EffectiveDate != null){
                            xmlW.writeCharacters(String.valueOf(someOrder.EffectiveDate));
                        }
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'ShipMethod',null);
                        xmlW.writeCharacters(someOrder.Shipping_Type__c);// Was shipping carrier.
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'InfoLine',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'Reference1',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'Reference2',null);
                    xmlW.writeEndElement();
       system.debug('<< SHIPPING TYPE >> '+someOrder.Shipping_Type__c);
                    /*xmlW.writeStartElement(null,'RequiresSignature',null);
                    if(someOrder.Shipping_Type__c != Null ){
                        if(someOrder.Shipping_Type__c.contains('UPS') || someOrder.Shipping_Type__c.contains('Priority')){
                            xmlW.writeCharacters('YES');
                        }else{
                            xmlW.writeCharacters('NO');
                        }
                    }
                    xmlW.writeEndElement();*/
                    xmlW.writeStartElement(null,'IsInsured',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'InsuredValue',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'InsuredValue',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'Customs_ShipmentContents',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'Customs_DeclaredValue',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'Customs_CountryOfOrigin',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'AddGiftWrap',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'GiftMessage',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'ISCOD',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'CODAmount',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'CODChashiersOnly',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'CODAddShipping',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'IsBill3rdParty',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'Bill3rdPartyAccountNum',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'HoldForAllInventory',null);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'CustomFields',null);
                        xmlW.writeStartElement(null,'BillingCompany',null);
                            if(someOrder.Account.Name!=null ) { 
                                xmlW.writeCharacters(String.valueOf(someOrder.Account.Name));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingFirstName',null);
                            if(someOrder.Billing_Address__r.First_Name__c!=null ) {                                                                                                                                                                                                                                                         
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.First_Name__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingLastName',null);
                            if( someOrder.Billing_Address__r.Last_Name__c != null){                                                                                                                                                                                                                                                         
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.Last_Name__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingAddress1',null);
                            if(someOrder.Billing_Address__r.Address_Line_1__c != null){                                                                                                                                                                                                                                                         
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.Address_Line_1__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingAddress2',null);
                            if(someOrder.Billing_Address__r.Address_Line_2__c != null){                                                                                                                                                                                                                                                         
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.Address_Line_2__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingCity',null);
                            if(someOrder.Billing_Address__r.City__c != null){                                                                                                                                                                                                                                                           
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.City__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingState',null);
                            if(someOrder.Billing_Address__r.State__c != null){                                                                                                                                                                                                                                                          
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.State__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingZip',null);
                            if(someOrder.Billing_Address__r.Zip_Code__c != null){                                                                                                                                                                                                                                                           
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.Zip_Code__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingCountry',null);
                            if(someOrder.Billing_Address__r.Country__c != null){                                                                                                                                                                                                                                                            
                                xmlW.writeCharacters(String.valueOf(someOrder.Billing_Address__r.Country__c));
                            }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingEmail',null);
                            if(someOrder.Billing_Email__c != null)
                            xmlW.writeCharacters(String.valueOf(someOrder.Billing_Email__c));
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingPhone',null);
                        if(String.valueOf(someOrder.Billing_Phone__c) != null){
                            xmlW.writeCharacters(String.valueOf(someOrder.Billing_Phone__c));
                        }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'BillingFax',null);
                        if(String.valueOf(someOrder.Account.Fax) != null){
                            xmlW.writeCharacters(String.valueOf(someOrder.Account.Fax));
                        }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'SalesTax',null);
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'Tax',null);
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'Shipping',null);
                            for( OrderItem someItem : ListOLIs ){
                                if(someItem.Line_Type__c == 'F - Freight'){
                                    xmlW.writeCharacters(String.valueOf(someItem.UnitPrice));
                            }
                        }
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'Subtotal',null);
                        xmlW.writeEndElement();
                        xmlW.writeStartElement(null,'Total',null);
                            if(String.valueOf(someOrder.TotalAmount) != null){
                                xmlW.writeCharacters(String.valueOf(someOrder.TotalAmount));
                                system.debug('<<  TOTAL AMOUNT >> '+someOrder.TotalAmount);
                            }
                        xmlW.writeEndElement();
                    xmlW.writeEndElement();//<-- Custom Fields
        
                    xmlW.writeStartElement(null,'Items',null);
                    //--- Start your OLI loop here to add Dynamic items.
                    //system.debug('<< ORDER ITEMS >> '+ListOLIs);
                    for( OrderItem someItem : ListOLIs ){
                        if(someItem.Line_Type__c != 'F - Freight'  && someItem.Line_Type__c != 'T - Text Line'){
                            xmlW.writeStartElement(null,'Item',null);
                                xmlW.writeStartElement(null,'SKU',null);
                                    xmlW.writeCharacters(String.valueOf(someItem.PricebookEntry.Product2.ProductCode)); 
                                xmlW.writeEndElement(); 
                                xmlW.writeStartElement(null,'Qty',null);
                                    xmlW.writeCharacters(String.valueOf(someItem.Quantity.intValue())); 
                                xmlW.writeEndElement();
                                xmlW.writeStartElement(null,'IsGiftWrapped',null);
                                    xmlW.writeCharacters('false');
                                xmlW.writeEndElement(); 
                                xmlW.writeStartElement(null,'CustomFields',null);   
                                xmlW.writeEndElement(); 
                            xmlW.writeEndElement(); // <-- Item
                        }
                    }// FOR LOOP
                       
             xmlW.writeEndElement();// <-- Items
        // -- END OF OLI LOOP
                    xmlW.writeStartElement(null,'PdfInserts',null);
                        xmlW.writeStartElement(null,'PdfInsert',null);
                        xmlW.writeEndElement();
                    xmlW.writeEndElement();
                xmlW.writeEndElement();// <-- Order
        xmlW.writeEndElement(); // <--  Orders
        xmlW.writeEndDocument(); //Close XML document
        // Run the order Items list in a loop  and include the xmlW info in a loop 
        String xmlStringxmlResult = xmlW.getXmlString(); 
        system.debug('THE XML:'+xmlStringxmlResult);
        xmlW.close();
        return xmlStringxmlResult;
    }// Method CreateXMLTemplate
     
    /**************************************************************************************************
      traverseXML:Parses the Post Shipment Response message for Shipment ID and Order ID (Order Number)
    ***************************************************************************************************/    
    private static String traverseXML(DOM.XmlNode node,Order someOrder ){
        String result = '';
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug('<< SHIPMENT >> '+node.getName());
            if (node.getName().trim() == 'shipment') {
                system.debug('<< SHIPMENT ID >>'+node.getAttributeValue('id', ''));
                someOrder.NG_Shipment_ID__c = node.getAttributeValue('id', '');
                result  = node.getAttributeValue('id', '');
                return result;
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            result = traverseXML(child,someOrder);
        }
        return '';  //should never reach here   

    }//Method traverseXML
}//Class