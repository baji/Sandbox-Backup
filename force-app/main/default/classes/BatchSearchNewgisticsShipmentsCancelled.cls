/*************************************************************************************************************************************
    Programmer:        Tony Williams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Newgistics
    Created:    12/06/2018 - <NEW 29>  - Retrieveing  Shipments from  Newgsitics web services. , Removed any reference to BO pick tickets and their SF Shipments
                                       - Creating Pick Tickets and HSimpents from Packages to get the ttracking info as well from the packages.
	Updated: 	02/07/2019 - <NEW-79> - Created custom settings varibale to save the start time globally i order to catch all sshipped NG shipments for PT processing.
	Updated:	02/017/2019 - <NEW-97> - Updated to include multiple shipments per Pick Ticket based on multiple NG Package tracking numbers per NG Shipment
------------------------------------------------------------------
Example: How to clean up straggling MFT accounts when their Registration Due Date is up? (This  example runs once per year)
BatchCanceledNewgisticsShipmentsScheduler j = new BatchCanceledNewgisticsShipmentsScheduler();
String sch = '59 59 12 * * ? *';
String jobID = system.schedule('CANCELED NG SHIPMENTS', sch, j);
For recusive help see: https://developer.secure.force.com/cookbook/recipe/parsing-xml-using-the-apex-dom-parser
 ********************************************************************************************************************************/ 
global class BatchSearchNewgisticsShipmentsCancelled implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
global String query;
    global String startCancelTimestamp;
    global String endCancelTimestamp;
    public Integer ordersProcessed = 0;
    // Holds the list of NG Shipped shipments
    List<NGUtilityClasses.Shipment> ShipmentResponses = new List<NGUtilityClasses.Shipment>(); 
  /************************************************************************************
  * start() - Method indirectly calls execute() method using a simple query.
  **************************************************************************************/
    global database.querylocator start(Database.BatchableContext BC){ 
    if(query == null){
            query  = 'SELECT Id FROM Order Limit 1' ;
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    }//mETHOD sTART
  /************************************************************************************
  * execute() - Method creates pick tickets and shipments for each NG Shipment Response
  **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Order> orders) { 
        String endpoint;
           
    	// Processes each individual NG shipment record returned from call out.
    	NGUtilityClasses.Shipment   ShipmentResponse; 
    	//Used in Recursive calls to get access to the Shipment Records
    	SearchShipmentRequestBKUP sr;
    	//Associate PTLIs with Pick Ticket using NG Package Id
    	Map<String,List<Pick_Ticket_Line_Item__c>> ngPackageIdToPTLI = new  Map<String,List<Pick_Ticket_Line_Item__c>>();
   		// Associate SF Shipments with Pick Ticket using NG Package Id
    	Map<String,Shipment__c> ngPackageIdToSFShipment = new  Map<String,Shipment__c>();
    	List<Pick_Ticket__c> ptickets = new List<Pick_Ticket__c>();
    	Newgistics_Settings__c custSettings = Newgistics_Settings__c.getValues('NewgsticsAPIFields');
        //Retrieves a Pick TIcket for a SF SHipment Record ID
        Map<Id,Pick_Ticket__c> SFShipIDToSFPTs = new Map<Id,Pick_Ticket__c>();
        //Retrieves a SF SHipment Record  for each NG Shipment ID
        Map<String,Shipment__c> NGShipIdToSFShipRecord = new Map<String,Shipment__c>();
        // Holds all order items per order.
        List<OrderItem> stockOLIs = new List<OrderItem>();
        // Retrieves a pick ticket for each order's order number.
        Map<String,Pick_Ticket__c> OrderNumToPickT = new Map<String,Pick_Ticket__c>();
        //Retrieves an Order Numbers for each NG Shipment IDs
        Map<String,String> NGShipIDToNgOrderIDs = new Map<String,String>();
        Map<String,String>  NgOrderIDsToNGShipID = new Map<String,String>();
        // Associate Pick Ticket Line Items with Pick Ticket using NG Package Id
        Map<String,List<Pick_Ticket_Line_Item__c>> ngPackageIdToPTLIs = new  Map<String,List<Pick_Ticket_Line_Item__c>>();
       
        // Use these next two maps in tandem to get the totalfillable for a pick ticket and order.
        Map<String,Double> OrderNumberToFillable = new Map<String,Double>();
        Map<String, Set<OrderItem>> OrderNumberToOLIs = new Map<String, Set<OrderItem>>();
        List<Product2> Products = new List<Product2>();
        Map<String,List<Shipment__c>> shipments = new  Map<String,List<Shipment__c>>();
        Set<OrderItem> OLIs = new Set<OrderItem>();
        // New pick ticket line items for new open PT
        List<Pick_Ticket_Line_Item__c> pickTicketItems = new List<Pick_Ticket_Line_Item__c>();
        Map<Id,String> OrderIDToOrderNumber = new Map<Id,String>();
        Map<String,Id> OrderNumberToPTicketID = new Map<String,Id>();
        Map<String,Order> OrderNumberToOrder = new Map<String,Order>();
        Map<String,String> NGShipIDToSFShipID = new Map<String,String>();
        List<NGUtilityClasses.Shipment> cleanNGShipments = new List<NGUtilityClasses.Shipment>();
         List<String> ShipIds = new List<String>();
         //Format Search Dates for the timestamp range and convert those dates to string for the Http search
        Boolean foundMidnight = false;        	
       	Date startDate = Date.today();// We are running this code at 12:59:59 CST so MST needs to be 1 less.
        startDate.addDays(-1);
        custSettings.End_Cancel_Time__c =String.valueOf(startDate)+'T'+'23:59:59';
		custSettings.Start_Cancel_Time__c = String.valueOf(startDate)+'T'+'00:00:00';
        system.debug('<< custSettings.Start_Cancel_Time__c >>'+String.valueOf(custSettings.Start_Cancel_Time__c));
        system.debug('<< custSettings.End_Cancel_Time__c>>'+String.valueOf(custSettings.End_Cancel_Time__c));             
        endCancelTimestamp=custSettings.End_Shipped_Time__c;
        startCancelTimestamp =custSettings.Start_Shipped_Time__c;
        String status = 'CANCELED';
      	system.debug('<< START SHIPPED DATE>> '+startCancelTimestamp+' << END SHIPPED DATE>> '+endCancelTimestamp);
        // Get a map of Map(Order.Id, Order )
        Map<String,Order> srShipmentIDToOrderMap = new Map<String,Order>();
        Set<String> orderNumbers = new Set<String>();
    //0. Process the Shipped Response messages returned from NG
        try {                  
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            // Set values to Params
            String apikey = custSettings.NG_API_Key__c;
            String timeParameters = '&startExceptionTimestamp='+startCancelTimestamp+'&endExceptionTimestamp='+endCancelTimestamp+'&Company=Awana&status='+status;
            endpoint = custSettings.NG_Endpoint__c+custSettings.NG_API_Key__c+timeParameters;
           	system.debug('<< API KEY>> '+custSettings.NG_API_Key__c);
           	system.debug('<< ENDPOINT:  >> '+endpoint);            
            req.setHeader('Content-Type','application/xml; charset=UTF-8');
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(20000);
            HTTPResponse resp; 
            if(!Test.isRunningTest())
            {
                resp = http.send(req);  
            }else{
                    Test.setMock(HttpCalloutMock.class, new Newgistics_SearchMock(true));
            }
            String shipmentID = '';
            // Read through the Search Shipment Resposne XML
    		if(!Test.isRunningTest())
			{
                 String XMLString = resp.getBody();
            	system.debug('<< XML STRING AFTER Call OUT >> '+XMLString);
            	sr  = new SearchShipmentRequestBKUP(XMLString);
    		}else{ // Test the Mock XML string
        		String XMLString = BatchSearchNewgisticsShipmentsTest.CreateShipments_TestMethod();
             	sr  = new SearchShipmentRequestBKUP(XMLString);
    		}
			ShipmentResponses = sr.ShipmentResponses;
            system.debug('<<  SHIP RESPONSES FROM NG >> ' +ShipmentResponses);
 		}catch(CalloutException ex){
        	system.debug('There was an exception that occurred while processing the Shipment Repsonse '+ex.getMessage());
           	system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
        }// Try-Catch
      	// Get the hour for EndSHipped date to see if it is = 23 and if so set it to 00 and go to the next day.
		// Save the current End Shipped Time as the next Start time. Also save a copy of it.
		update custSettings;
    //1. Process all NG SHipments read form the NG Service and load them into Apex Maps and the NGUtilityClass structure
        List<String> ngShipmentIDs = new List<String>();
        if(ShipmentResponses.size() > 0){
            for(NGUtilityClasses.Shipment aShipmentResponse : ShipmentResponses){
                ngShipmentIDs.add(aShipmentResponse.shipmentID); 
                orderNumbers.add(aShipmentResponse.orderID);
                NGShipIDToNgOrderIDs.put(aShipmentResponse.shipmentID,aShipmentResponse.orderID);
               system.debug('<< SHIPID RESPONSED >>'+aShipmentResponse.shipmentID+' <<  ORDER NUMBER>>'+NGShipIDToNgOrderIDs.get(aShipmentResponse.shipmentID));
           }//For      
    //2. Get Orders from the Order ID List created from the corresponding Shipment Response records from NG
            orders = [SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,
                Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c,Estimated_Weight__c, 
                Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Tax__c,Shipment_Cost__c,Payment_Terms__c,
                AccountId, Account.Name, OrderNumber,
                Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, 
                LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, 
                Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,Order.NG_Shipment_ID__c, 
                (Select Id, Name From Pick_Tickets__r)
                FROM Order WHERE (Status = 'Order Being Fulfilled') 
                And (NOT Status like '%Cancelled%') and 
                OrderNumber in: orderNumbers];
            ordersProcessed = orders.size();
            system.debug('<< ORDRES OBF and OPF >> '+orders);
           	
        }//IF - NHG SHipments exists
    //3.
            // Find SF shipments created already for an order.
  //4. Load (Associate)  Orders with their Order Line Items and update TotalFillableItems Calculation for Pick Ticket generation
          try{
        		for(Order someOrder : orders){
                	OrderNumberToOrder.put(someOrder.OrderNumber,someOrder);
                 }//FOR  
   //5. Get all the pick tickets for every order and NG SHipment Response record
                for(NGUtilityClasses.Shipment aShipmentResponse : ShipmentResponses){
                    String orderNumber = NGShipIDToNgOrderIDs.get(aShipmentResponse.shipmentID);  
                    if(OrderNumberToOrder.get(orderNumber) != null){
                        Order someOrder = OrderNumberToOrder.get(orderNumber);
                        //We don't want to process the same shipment ID twice for an order (We already have a pick ticket for this shipment ID).
                        system.debug('<< IF -  NGShipIDToSFShipID  == NULL >> '+NGShipIDToSFShipID.get(aShipmentResponse.shipmentID));
                        someOrder.Status = 'Order Cancelled';
                    }
                    // system.debug('<< Ln : 207 aShipmentResponse.shipmentID ? >> '+aShipmentResponse.shipmentID +'<< someOrder.OrderNumber >>'+srShipmentIDToOrderMap.get(aShipmentResponse.shipmentID).OrderNumber);     
            	}//For 
              	if(orders.size() > 0){
                	system.debug('<< ln: 342 A - ORDERS  >> '+orders);
                	upsert orders;
            	} 
           }catch(SObjectException ex){
                system.debug('There was an exception that occurred while processing Order Numbers. Check the SOQL statements or Http response. '+ex.getMessage());
                system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            }
      }// _ MEthod Execute 
   
   
  /************************************************************
  * finsh() - Method sends a diagnostic email to the SF admins
  *************************************************************/
  global void finish(Database.BatchableContext BC){
    AsyncApexJob apexBatchResult = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: BC.getJobId()
        ];
    
        // Generate email body
        String emailBody = ' Apex Batch Cancelled Newgistics Shipment objects  processed: '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
        
        emailBody += 'NG Shipment Responses processed: '+ShipmentResponses.size()+'\n\n';
        emailBody += 'Orders processed : '+ordersProcessed+'\n\n';
         //3. Get User Ids for the Acocunt Team Updates Group.
            Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN (
                                    SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'SF Administrator')]);
            
            
            List<String> userEmail = new List<String>();
            //We need to make sure that the Test coverage will work when testing emails otherwise a REQUIRED_FIELD_MISSING, Missing exception will occur.
            if(Test.isRunningTest()){
                User tUser=[Select Email from User where Name Like 'MyAwana%' Limit 1];
                userEmail.add(tUser.Email);
            }else{
                    userEmail.add('SFApps@awana.org'); 
                	userEmail.add('sarahst@awana.org');
            }
            List<String> sendTo = new List<String>();
            sendTo.addAll(userEmail);
        // Send email
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('TEST ORG: Processes Newgistics Shipments');
        mail.setSubject('TEST ORG: Batch to Processes Newgistics Shipments: ' + apexBatchResult.Status);
        mail.setPlainTextBody('TEST ORG: Batch Process has completed\n\n' + emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
  }// Method finish
}//Class