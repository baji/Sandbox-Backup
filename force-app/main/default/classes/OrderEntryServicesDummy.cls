/**************************************************************************************************************************************************************************************************************** 
    Programmer: Matthew Keefe
    Developer:  Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Order Entry in Salesforce
    Created:    07/26/2010
    Updated:    08/30/2010 - Fixed Errors with duplicate naming when Credits (C) were created
    Updated:    10/01/2010 - Added CalculateFreight method, Fixed an error with TestNextOrderNumber 
    Updated:    10/01/2010 - Changed CalculateFreight to return decimal, Tweaked TestCalculateFreight
    Updated:    11/03/2010 - Added a result class to return complex webservice results
    Updated:    06/03/2011 - Added Order Entry functionality for OrderEntry4.page, and SubmitCompleteOrder webservice
    Updated:    06/13/2011 - Added some documentation
    Updated:    11/10/2011 - (TW) Added code to CalculateOrderEntryStage to make sure that  Finish Order/Submit button until Taxes are calculated for sales credits.
    Updated:    12/01/2011 - (TW) Made Kidz Matter (KM) changes  to OrderEntry functionality for Create Order, GetOrderedPriceBooks, and SaveOrder.
    Updated:    02/16/2012  - (TW) Removed KM prefixes, added Opportunity Company field, added Accout object multi-select pick lists for  multiple catalog companies.
    Updated:    02/27/2012  - (TW) Added KM Gateway.
    Updated:    03/13/2012  - (TW) Added KM Subscription checking for K!Magazine and Kitchen and added new test method to test subscriptions.
    Updated:    03/27/2012 -  (TW) Update the AddSubscription method to include Renewal feature.
    Updated:    05/27/2012 -  (TW) Update the AddSubscription method to exclude Renewal feature.
    Updated:    06/1/2012 -  (TW) Added the GetSubscription method to access renewal subscriptions for page.
    Updated:    06/7/2012 -  (TW) Added the SaveSubscription method to save renewals.(could not do it with JQUery.)
    Updated:    08/13/2012 - (TW) - Added Shipping Address for new subscriptions.
    Updated:    08/28/2012 - (TW) - Removed Last Issue Sent assignment for New Subscriptions.
    Updated:    09/06/2012 - (TW) - Added a WHERE clause to filter only on Active productsfor webservice FindProduct()
    Updated:    09/08/2012 TW  - Re-Added the Hold validation for ordering contacts  which was earlier commented out.
    Updated:    10/11/2012 - Added a Check on method OrderEntryStage  where Credit Balance = 0 authorization is approved because the transaction is a 77780 discount of 100% (Fullsubscription discount).
    Updated:    01/22/2013 - Adding the updates for MENA PrePay in Calculate Freight and prohibiting backorders for MENA churches.
    Updated:    01/27/2013 - Stopping orders from being shipped with Credit Card failures.
    Updated:    04/24/2013 - Check for Payment Term = To Be Billed and if so return a value of $0 freight cost
    Updated:    05/13/2013 - Updated code to make sure that if KM account is a Business Unit , it's payment type should be Internal 
    Updated:    05/21/2013 - Added PreOrder Handling value to Line Item which will be used in Pick Ticket.
    Updated:    06/06/2013 - Added 'Customer Service' to Opportunity Source field in SubmitOrder method
    Updated:    07/03/2013 - Added update to allow $0 Freight for missionaries where Shipping Type = 'Pickup'.
    Updated:    07/26/2013 - Added Price Discount unit discount and promo codes to AddProduct() method.
    Updated:    08/06/2013 -  Added firstname , lastname and address validation to method UpdateOrderShipping() to avoid 'null' values in Ship-to-Name and Address Line 1 in Addres object. 
    UPdated:    08/09/2013 - Added a check for Gateway.ChargentBase__Active__c in SaveOrder() method.
    Updated:    08/13/2013 - Revised the Price Discount unit discount and promo codes to AddProduct() method.
    Updated:    12/18/2013 - REvised AuthorizeCreditCard method to acocunt for American Express 15 didgit card numbers 
    Updated:    01/01/2014 - Created two new Methods for SSO - 1) FindAffiliateContact and 2) CreateAffilateOrder
    UPdated:    02/18/2014 - Created a couple new methods for SSO 
    UPdated:    05/28/2014 - In CalculateFreightOnOpportunity, user Order.Shipping insetad of ORder.Account.Shipping
    Updated:    06/17/2014 - Added Category PriceBook Category for Record Type = 'Business' in webservice  GetPriceBookByCompany'
    Updated:    06/18/2014 - Added Missionary  PriceBook Category for Record Type = 'Business Unit' in webservice  GetPriceBookByCompany'
    Updated:    06-19-2014 -  Updated GetOrderAmount() method to send corrected order amounts back to JavaScript to display the correct Order Totals on Order Entry page.
    Updated:    06/26/2014 - Removed Type checking for US Organization church and adding  Catalog Price Book for International Churches for GetPriceBookByCompany method.
    Updated:    06/26/2014 - Updated CreateOrder() method to be able to create Contact Role for the MENA (International) and KM Canada and All KM Church contacts when placing an order. 
    Updated:    07/01/2014 - Updated Create Order Method to also include the KM Account Record Types and check for their KM Contact Roles so that we can avoid making the contacts Account Purchasers.
    Updated:    07/02/2014 - Updated UpdateOrderSHippingAddress() Method to replace null first name with 'To:' then Shipping dept. won't have to deal with "NULL" written on their shipping labels.
    Updated:    07/03/2014 - Updated  GetPriceBookByCompany() methods so that OE Webservice GetPriceBookByCompany will use Account ID instead of Name to search on. 
    Updated:    07/22/2014 - <FRT RESCONTRUCT> Added CalcultaeFrieghtByWeight(), ProcessLIneItems(), and added paramteres for CalcultaeFreightOnOpportunity
    Updated:    07/22/2014 - <FRT RECONTSRUCT> commented out obsolete methods GetPriceBook(), GetOrderedPriceBook(), GetPriceBookByAccount(), SubmitApproval()
    Updated:    09/04/2014 - <FRT RECONTSRUCT> Added Estimated Weight Calculation for ConsolidateDuplicateLineItems() as well as added Estimated Weight to SOQL Query for GetOrderLineItems()   
    Updated:    09/11/2014 - <FRT RECONTSRUCT> Updated code to use 19% MENA Calculation for FRT + $35 while all non-MENA International entities are at $0. 
    Updated:    09/18/2014 - <FRT RECONTSRUCT> Updated SaveOrder() method to remove tax after calculating dynamic FRT to avoid Uncommitted Rollback Errors from PB Integration.
    Updated:    09/23/2014 - <FRT RECONTSRUCT>  Updated the WSDL call to include parameter Customer ID( Mailing Address Book) to the service port method.
    Updated:    10/03/2014 - <FRT RECONTSRUCT>  Updated the query for MENA countries in CalculateFreightOnOpportunity() method to give a list result of countries just in case there is no country that matches the Order Shipping Country.
    Updated:    10/16/2014 - <ADVOCACY> Updated the AddProduct() SOQL QUERY  statement  - which verifies if a certain product exists - with "isActive = true" within the WHERE clause because we don;t want to list inactive products.
    Updated:    04/07/2015 - <MOZO> Added Upgrade_Level__c field to the query in method GetOrderLineItems() so that Java Script Mozo Upgrade method can access it.   
    UPdated:    04/10/2015 - <MOZO> Created web service GetUpgradeRate which retrieves the Upgrade Price and Upgrade Level from JScript Client and updates the Opp. Line Item with these values.
    Updated:    05/12/2015 - <MOZO> Updated web service GetUpgradeRate in order to retrieved and saved reduced price based on the Upgrade Price minus the discount.
    Updated     10/12/2015 - <APP DEV>  GetPricebookByCompany(): Removed the extra check for Type = Individual , added additional phrase for the SOQL clause that filters for the Employee Pricebook
    Updated:    11/18/2015 - <APP DEV> Added the new Send Suite (SS) WSDL for FRT so that both Demandware aand Order Entry will having correct, matching tax amounts from SS.
    Updated:    11/08/2016 - <SFDC_247> Updated loadAffiliations and GetPricebookByCompany to allow Business Unit Affiliation's ability to purchase as Employee or Missionary only for Authorized and non-Authorized Purchasers.
    Updated:    12/01/2016 - <CE_48> Bug Fix: GetPricebookByCompany to allow Business Unit Awana International Canada orders to again use Missionary Price Book.
    Updated:    02/10/2017 - <CE_82> - Added new Price Book handler code for customer CDB ("Christian Price Book Distributors") in GetPriceBookByCompany
    Updated:    05/25/2017 - <ASP-109> - Added new Price Book handler code for customer LifeWay Books ("LifeWay") in GetPriceBookByCompany
    Updated:    06/13/2017 - Emergency fix due to incorrect condition for Christian Book Distributors, LLC not giving correct Price Book of "CBD Pricebook" but "Catalog Price Book" instead.
    Updated:    08/04/2017 - <CW-8> - Allow Canadian Missionaries to bypassorder fulfillment (Go straight to Invoice) and getting the OrderType value Frm JavaScript to SubmitOrder() webservice
    Updated:    02/13/2018 - <ASP-789> - Added Order Line Item Product2.Family in order to disallow OE manual orders for Advocacy Items when that Product Family name is 'Cause Marketing'
    Updated:    02-21-2018 - <ASP-915> - Updated getPriceBookByCompany to also check for Household Accounts.
    Updated:    03-09-2018 - <ASP 874> - Added in Add Product method the new LineItem.Downloadable_URL__c so that Order can cound its downloadables fopr sending out URL Emails
    Updated:    04-04-2018 - <ASP-1051> - Fixed in OrderEntry.CalculateStage method: Credit Card Orders cannot be submitted when the Promo Code option is used on a line item
    Updated:    04-26-2018 - <CW-17> - Removed the Canada Parasoft Invoicing in SubmitOrder so that Canadian orders can go through order Fulfillment for Internal Office 4
    Updated:    1/2/2019 - <NEW-36> - Updated freight caluclation process using salesforce shipping Rate, Shipping Zone objects.
    Updated:    1/3/2019 - <NEW-25,28>  - Updated AdProduct process to add the calculated tax to the Order's Tax field on the Order Detail Record for NG service to accept. 
    Updated:    1/16/2019 - <NEW-55,8>  - Updated SubmitOrder method to update the order after it assigned the order's Shipping Type to the Order's Shipping Code.
    Updated:    1/26/2019 - <NEW-55,8>  - Created UpdateBillingPhone to update the order's Billing Phone.
    Updated:    4/16/2020 - <SMS-133,164> - Changes to incorporate Partner Price book where other role is Employee or Missionary
    Updated:    4/27/2020 - <WB-20,27>  - Whitebox related changes to incorporate price book option based on shipping type.
*****************************************************************************************************************************************************************************************************************************************/

global class OrderEntryServicesDummy
{   
    /* 
     * Result Object
     * Purpose: The result object is returned from many of the webservices (or methods) contained within OrderEntryServicesUpdated;
     *          it's purpose is to allow complex data to be returned. There are numerous constructors for creating new instances simply.
     *          Each constructor calls the SetResultVariables method to properly set each of the variables to be returned.
     *          Primarily, the Success variable is most important; a true value indicates that the webservice fully completed successfully;
     *          a false value indicates that some part of the webservice failed.
     */
    global class Result
    {
        // variables
        
        webservice boolean Success; // Indicates success or failure of the method or web service for which the result is being returned
        webservice string Message; // A message describing the result
        webservice string StringOutput; // An output string value
        webservice decimal DecimalOutput; // An output decimal value
        webservice List<decimal> ListDecimalOutput; // An output list of decimal values
        webservice sObject ObjectOutput; // An output Salesforce Object 
        webservice List<sObject> ListObjectOutput; // An output list of Salesforce objects
        webservice List<String> ListStringOutput; //An output list of string objects used to intermix related SObjects (SSO)
        // constructors
        global Result() { SetResultVariables(false,null,null,null,null,null,null,null); }
        
        global Result(boolean SetSuccess) { // set success only 
            SetResultVariables(SetSuccess,null,null,null,null,null,null,null); }
        
        global Result(boolean SetSuccess, string SetMessage) { 
            SetResultVariables(SetSuccess,SetMessage,null,null,null,null,null,null); }
        
        global Result(boolean SetSuccess, string SetMessage, string SetStringOutput) { 
            SetResultVariables(SetSuccess,SetMessage,SetStringOutput,null,null,null,null,null); }
                
        global Result(boolean SetSuccess, string SetMessage, decimal SetDecimalOutput) { 
            SetResultVariables(SetSuccess,SetMessage,null,SetDecimalOutput,null,null,null,null); }
         //SSO 
         global Result(boolean SetSuccess, string SetMessage, List<String> SetListStringOutput) { 
            SetResultVariables(SetSuccess,SetMessage,null,null, SetListStringOutput,null,null,null); }
        
        global Result(boolean SetSuccess, string SetMessage, sObject SetObject) { 
            SetResultVariables(SetSuccess,SetMessage,null,null,null,null,SetObject,null); }
        
        global Result(boolean SetSuccess, string SetMessage, List<sObject> SetListObjects) { 
            SetResultVariables(SetSuccess,SetMessage,null,null,null,null,null,SetListObjects); }
        
        global Result(boolean SetSuccess, string SetMessage, List<decimal> SetListDecimals) { 
            SetResultVariables(SetSuccess,SetMessage,null,null,null,SetListDecimals,null,null); }
        
        global Result(boolean SetSuccess, string SetMessage, string SetStringOutput, sObject SetObject) { 
            SetResultVariables(SetSuccess,SetMessage,SetStringOutput,null,null,null,SetObject,null); }
        
        global Result(boolean SetSuccess, string SetMessage, decimal SetDecimalOutput, sObject SetObject) { 
            SetResultVariables(SetSuccess,SetMessage,null,SetDecimalOutput,null,null,SetObject,null); }
        
        global Result(boolean SetSuccess, string SetMessage, string SetStringOutput, decimal SetDecimalOutput, sObject SetObject) { 
            SetResultVariables(SetSuccess,SetMessage,SetStringOutput,SetDecimalOutput,null,null,SetObject,null); }
        
        // logic
        private void SetResultVariables(boolean SetSuccess, string SetMessage, string SetStringOutput, decimal SetDecimalOutput, List<String> SetListStringOutput, List<decimal> SetListDecimalOutput, sObject SetObject, List<sObject> SetListObjects) {
        //  success (1)           message (2)           string (3)                      decimal (4)                 List string(5)      list decimal (6)                          sObject (7) list sObject (8)
            Success = SetSuccess; Message = SetMessage; StringOutput = SetStringOutput; DecimalOutput = SetDecimalOutput; ListDecimalOutput = SetListDecimalOutput; ObjectOutput = SetObject; ListObjectOutput = SetListObjects; ListStringOutput = SetListStringOutput; }
    }
    /* 
     * Method:  hasProcessOrderTriggerRan
     * Purpose: This methods stops the recursion of ProcessOrderTrigger. 
       Author:  Darshan Chhajed.     
    */
    private static boolean processOrderTriggerRan = true;
    public static boolean hasProcessOrderTriggerRan(){
        if(processOrderTriggerRan){
            processOrderTriggerRan=false;
            return true;
        }else
            return processOrderTriggerRan;
    }
    
    /* 
     * Method:  GetNextOrderNumberByAccountId
     * Inputs:  string Prefix - The prefix for the order number. Typically this is O for Order or C for Credit.
     *          string AccountSalesforceId - The Salesforce ID of the Account for which to get the next Order Number.
     * Output:  Result Object containing Success, Message, and the Next Order Number in string format.
     * Purpose: Enables getting the next order number by supplying the Salesforce ID of an Account. (See GetNextOrderNumber Purpose.)
     * SOQL:    2
     * DML:     0
     */
    webservice static Result GetNextOrderNumberByAccountId(string Prefix, string AccountSalesforceId)
    {
        // Find the specified Account using the AccountSalesforceId.
        List<Account> accounts = [Select Id, Mailing_Address_Book__c From Account Where Id = :AccountSalesforceId];
        
        // If an Account was found 
        if(!accounts.isEmpty())
        {
            // Call the GetNextOrderNumber web service and pass the provided Prefix argument and the Customer Number (Mailing_Address_Book__c) for the found Account. 
            return GetNextOrderNumber(Prefix, accounts[0].Mailing_Address_Book__c);
        }
        // Otherwise (else) 
        else
        {
            // Return Success as false and an error message. 
            return new Result(false,'The Account Salesforce Id provided is invalid. ');
        }
    }
    
    /* 
     * Method:  GetNextOrderNumber
     * Inputs:  string Prefix - The prefix for the order number. Typically this is O for Order or C for Credit.
     *          string AccountCustomerNumber - The Customer Number of the Account for which to get the next Order Number.
     * Output:  Result Object containing Success, Message, and the Next Order Number in string format.
     * Purpose: Gets the next Order Number (or Name) for the Account specified. 
     *          Order Numbers are in the format: Prefix-CustomerNumber-OrderNumber. 
     *          For example if prefix is O and the customer number is 123456, the Order Number (or Name) would be O-123456-0.
     *          (See NextOrderNumber Purpose.)  
     * SOQL:    1
     * DML:     0
     */
    webservice static Result GetNextOrderNumber(string Prefix, string AccountCustomerNumber)
    {
        string NextOrderNumber = null;
        
        // If the Prefix argument is blank, default it to O for Order.
        if(Prefix == null) { Prefix = 'O'; }
        
        // If the AccountCustomerNumber argument is blank, return Success as false and an error message. 
        if(AccountCustomerNumber == null) { return new Result(false,'Account Customer Number is required. '); }
        
        try
        {
            // Call the NextOrderNumber web service, passing the Prefix and AccountCustomerNumber arguments.
            // If an error occurs in the NextOrderNumber web service, return Success as false and an error message. 
            NextOrderNumber = NextOrderNumber(Prefix,AccountCustomerNumber);
        } catch(Exception exc) { return new result(false,'An error occurred while generating the next order number. '); }
        
        // If the Order number (or name) returned by the NextOrderNumber web service is not blank.
        if(NextOrderNumber != null) 
        {
            // and the Order number (or name) length is greater than 1, return Success as true and the new Order number. 
            if(NextOrderNumber.length() > 1) { 
                return new Result(true,'Successfully generated a new order number',NextOrderNumber); } 
        }
        
        // Otherwise (else), return Success as false, an error message, and the new Order number.
        return new Result(false,'An unknown error occurred while generating the next order number. ',NextOrderNumber);
    }
    
    /*
     *     IMPORTANT: This webservice should not be called directly, use GetNextOrderNumber(string Prefix, string AccountCustomerNumber) instead
     * 
     * Method:  NextOrderNumber
     * Inputs:  string Prefix - The prefix for the order number. Typically this is O for Order or C for Credit.
     *          string AccountCustomerNumber - The Customer Number of the Account for which to get the next Order Number.
     * Output:  The Next Order Number in string format (or blank).
     * Purpose: This webservice contains no validation and does not return a Result object with variables for Success and Message. 
     *          If an error occurs, a default Salesforce exception message will be thrown, or a null value will be returned. 
     *          GetNextOrderNumber should be called instead. 
     * SOQL:    1
     * DML:     0
     *
     *     IMPORTANT: This webservice should not be called directly, use GetNextOrderNumber(string Prefix, string AccountCustomerNumber) instead
     */
    webservice static string NextOrderNumber(string Prefix, string AccountCustomerNumber)
    {
        // Initialize variables.
        // Set the LastOrderNumber to zero. (If it is not updated by selecting the max order number, it will stay 0.)
        Integer lastOrderNumber = 0;
        Integer tempOrderNumber = 0;
        string orderPrefixSOQLMatchPhrase = Prefix+'-%';
        string orderCustomerNumberMatchPhrase = '%-'+AccountCustomerNumber+'-%';
        
        // Find all Orders (excluding Order History and Credit History records) for the Account having the Customer Number provided in the AccountCustomerNumber argument.
        List<Order> orders = 
            [Select Id, Name From Order Where Account.Mailing_Address_Book__c = :AccountCustomerNumber and (NOT Name like 'OH%') and (NOT Name like 'CH%') and Name like:orderCustomerNumberMatchPhrase];
        
        // If Order(s) were found
        if(orders.size() > 0)
        {
            // Loop through all Orders.
            for(Order o : orders)
            {
                try // Try to find the suffix (Order Number) of the Order Name
                {
                    if(o.Name.lastIndexOf('-')>0)
                    {
                        // If a suffix was found 
                        tempOrderNumber = Integer.valueOf(o.Name.substring(o.Name.lastIndexOf('-')+1,o.Name.length()));
                        
                        // If the Integer value of the suffix is greater than 0 or the last suffix found (whichever is greater)
                        // Set the LastOrderNumber to the suffix.
                        if(tempOrderNumber > lastOrderNumber) { lastOrderNumber = tempOrderNumber; }
                        
                        // Reset TempOrderNumber variable.
                        tempOrderNumber = 0;
                    }
                }
                catch(Exception exc) // If next order number calculations failed
                {
                    // Set the LastOrderNumber to the number of Orders found.
                    lastOrderNumber = orders.size()-1;
                    system.debug(exc);
                }
            }
            
            // Add one to the LastOrderNumber to get the next Order number
            lastOrderNumber++;
        }
        
        // Return the Prefix, a dash, the Account Customer Number, another dash, and the next Order number. (example: O-123456-1 or C-123456-2)
        return Prefix + '-' + AccountCustomerNumber + '-' + lastOrderNumber;
    }
    
    /*
     * Method:  CreateAffiliateOrder
     * Inputs:  string ContactId - The Salesforce ID of a Contact. This is used to lookup an Account.
     *          string PriceBookName - The name of the price book to use. Most commonly this value will be Catalog Price Book.
     *          string OrderType - Determines whether the Order is an Sales Order or a Credit. Valid values are Order or Credit.
     *          Date OriginalOrderDate - The date the original order was placed (used for credits only). 
     *                              If the OrderType is Credit the OriginalOrderDate is required, otherwise it should be null.
     * Output:  Result Object containing Success and Message (at minimum) and the new Opportunity if the Order was successfully created.
     * Purpose: Creates a new Order from the arguments specified. Finds the Contact and related Account based on ContactId, the Pricebook based on PriceBookName, and 
     *            sets the Payment Terms based on OrderType and sets the OriginalOrderDate if the OrderType is Credit.  
     * SOQL:    4
     * DML:     2
     * UPDATED FOR MIGRATION OF OPPORTUNITY TO ORDER
     */
    webservice static Result CreateAffiliateOrder(string ContactId, string PriceBookName, string OrderType, Date OriginalOrderDate,String Company, String AffiliateId)
    {
        system.debug('CREATEAFFILIATIONORDER'+ContactId);
        system.debug(PriceBookName);
        system.debug(OrderType);
        system.debug(OriginalOrderDate);
        system.debug(' Affiliate Account Id ' + AffiliateId);
        
        // Configuration Variables
        String c_PriceBookName = 'Catalog Price Book';
        String c_InitialStageName = 'Order Open';
        
        npe5__Affiliation__C OrderingContact = null;
        List<npe5__Affiliation__c> MatchingContacts = [Select npe5__Contact__c, npe5__Contact__r.Name, npe5__Contact__r.FirstName, npe5__Contact__r.LastName, npe5__Contact__r.Phone, npe5__Contact__r.Email, npe5__Organization__c,npe5__Organization__r.Name, 
              npe5__Organization__r.Account_on_Hold__c, npe5__Organization__r.Hold_Comments__c, npe5__Organization__r.Undeliverable_Mailing__c, npe5__Organization__r.Undeliverable_Shipping__c, npe5__Organization__r.Mailing_Address_Book__c, 
              npe5__Organization__r.BillingStreet,  npe5__Organization__r.BillingCity, npe5__Organization__r.BillingPostalCode, npe5__Organization__r.BillingState, npe5__Organization__r.BillingCountry, npe5__Organization__r.Billing_County__c, 
                npe5__Organization__r.ShippingStreet, npe5__Organization__r.ShippingCity, npe5__Organization__r.ShippingPostalCode, npe5__Organization__r.ShippingState, npe5__Organization__r.ShippingCountry, npe5__Organization__r.Shipping_County__c, 
              npe5__Organization__r.RecordType.Name, npe5__Organization__r.Default_Terms__c, npe5__Organization__r.Default_Shipping_Address__c, npe5__Organization__r.CurrencyISOCode
            From npe5__Affiliation__c Where npe5__Contact__c = :ContactId and npe5__Organization__c =: AffiliateId];
        
          system.debug('Matching Contacts: '+MatchingContacts);
       
        
        // If the Contact is not found, return Success as false and an error message. 
        if(MatchingContacts.size() < 1) {
            return new Result(false,
                'Create Order failed. The ContactId provided could not be found; please provide a valid 15 or 18 character ContactId. '); 
        }
        
        OrderingContact = MatchingContacts[0];
        
        system.debug(OrderingContact.npe5__Organization__r.Mailing_Address_Book__c);
        
        // If the related Account has a blank Customer Number (Mailing_Address_Book__c), 
        if(OrderingContact.npe5__Organization__r.Mailing_Address_Book__c == null) {
            return new Result(false,
                'Create Order failed. The Account associated with the Contact provided does not have a valid Customer Number (or Mailing Address Book Number). '); }
        
        // If the related Account is on hold (Account_on_Hold__c == true), return Success as false and an error message with the hold comments (Hold_Comments__c). 
      //TW: 09-10-12: Re-added the contact on hold validation.
        if(OrderingContact.npe5__Organization__r.Account_on_Hold__c) {
            return new Result(false,
                'Create Order failed. The Account associated with the Contact provided is on hold and is currently not allowed to place orders. Account Hold Comments: '
                    + OrderingContact.npe5__Organization__r.Hold_Comments__c); }
        
        // Get all pricebooks and find the pricebook to use for the Order by comparing the pricebook name to the provided PriceBookName argument. 
        List<PriceBook2> PriceBooks = [SELECT Id, Name FROM PriceBook2 WHERE isActive = true ORDER BY Name ASC];
        PriceBook2 PriceBook = null;
        
        string PriceBookNames = ''; // PriceBookNames is for an error message to list the available price books
        
        for(PriceBook2 pb : PriceBooks) 
        {
            PriceBookNames += pb.Name + ', ';
            if(PriceBookName != null)
            {
                if(pb.Name.toLowerCase().contains(PriceBookName.toLowerCase())) { PriceBook = pb; }
            }
        }
        
        // Remove last comma & space (2 chars) for returning if there is an error.
        PriceBookNames = PriceBookNames.substring(0,PriceBookNames.length()-2);
        
        system.debug('PriceBook: '+PriceBook);
        
        // If the pricebook was not found, return Success as false and an error message stating all valid pricebooks.
        if(PriceBook == null) {
            return new Result(false,
                'Create Order failed. PriceBookName is required; please provide a valid PriceBookName. Valid Price Books are: ' + PriceBookNames + '. '); }
        
        // Validate the provided OrderType argument. If OrderType is not Order or Credit, return Success as false and an error message.
        if(OrderType == null || (OrderType.toLowerCase().trim() != 'order' && OrderType.toLowerCase().trim() != 'credit')) {
            return new Result(false,
                'Create Order failed. OrderType is required; please provide a valid OrderType. Valid Order Types are: Order, Credit. '); } 
        // If the provided OrderType argument is Credit and the provided OriginalOrderDate argument is blank, return Success as false and an error message.
        if(OrderType.toLowerCase().contains('credit') && OriginalOrderDate == null) {
            return new Result(false,
               'Create Order failed. OriginalOrderDate is required for Credit OrderType; please provide a valid OriginalOrderDate. '); }
       string OrderPrefix = 'O';
       
        string OrderPaymentTerms = OrderingContact.npe5__Organization__r.Default_Terms__c; 
        if(OrderType.toLowerCase().contains('credit')) { 
          OrderPrefix = 'C'; 
          OrderPaymentTerms = 'Sales Credit'; 
        }
        /*
            Creating Order in Order Object.
        */       
        Order salesOrder = new Order();
        Opportunity Order = new Opportunity(); //this is for reference of old code- we are not inserting it in database.
        Order.StageName = c_InitialStageName;
        salesOrder.Status = c_InitialStageName; 
        Order.CloseDate = Date.Today();
        salesOrder.effectiveDate = Date.Today();
        Order.PriceBook2Id = PriceBook.Id;
        salesOrder.PriceBook2Id = PriceBook.Id;
        Order.Has_Discounts__c = false;
        //salesOrder.PriceBook2.Name = PriceBookName;
        Order.CurrencyIsoCode='US';
        salesOrder.CurrencyIsoCode='US';
        //Tw: 2-12-2012 Added comnpany field for opportunity and removed the old Kidz Matter naming conventikons for prefix.
        Order.Company__c = Company;
        salesOrder.Company__c = Company;
        
        //TW 5-13-2013:  Updated code to make sure that if KM account is a Businkess Unit , it's payment type should be Internal
        system.debug('<< ORDER ACCOUNT RECORD TYPE >> '+OrderingContact.npe5__Organization__c);
        List<RecordType> acctType = [SELECT Name from RecordType where SObjectType = 'Account' and Id =: OrderingContact.npe5__Organization__r.RecordTypeId];      
        // END: TW 5-13-2013: 
       
       //SSO  Set the Order AccountId from the found Contact AccountId.
        salesOrder.AccountId = OrderingContact.npe5__Organization__c;
        
        // Generate a new order name for this Order by calling the OrderEntryServicesDummy.GetNextOrderNumber webservice. 
        //   Send O as the OrderPrefix if the provided OrderType argument is Order, or Send C as the OrderPrefix if the provided OrderType is Credit.
        Result NextOrderNameResult = OrderEntryServicesDummy.GetNextOrderNumber(OrderPrefix, OrderingContact.npe5__Organization__r.Mailing_Address_Book__c);
        salesOrder.Name = NextOrderNameResult.StringOutput;
        
        // Set the appropriate Currency ISO Code (USD or CAD) to the Ordering Account Currency ISO Code.
        salesOrder.CurrencyISOCode = OrderingContact.npe5__Organization__r.CurrencyIsoCode;
        
        // Set the default payment terms (Credit Card, Net 30, etc.) according to the Account Default Payment Terms or to Sales Credit if the provided OrderType argument is Credit.
        salesOrder.Payment_Terms__c = OrderPaymentTerms;
       
        // If the provided OrderType argument is Credit, set the Original Order Date (Original_Order_Date__c) of the Order to the provided OriginalOrderDate argument.
        if(OrderType.toLowerCase().contains('credit')) { salesOrder.Original_Order_Date__c = OriginalOrderDate; }
        system.debug('*** ORIGINAL ORDER DATE: ***'+salesOrder.Original_Order_Date__c);
        
        
        // Set the credit card detail for the Order from the Contact (ChargentSFA__Billing_First__c, ChargentSFA__Billing_Last__c,   //ChargentSFA__Billing_Phone__c, ChargentSFA__Billing_Email__c, ChargentSFA__Card_Name__c).
        
        result res = OrderEntryServicesDummy.createChargentOrder();
        ChargentOrders__ChargentOrder__c cOrder;
        if(res!=null && res.Success){
            cOrder = (ChargentOrders__ChargentOrder__c)res.ObjectOutput;
            cOrder.ChargentOrders__Billing_First_Name__c = OrderingContact.npe5__Contact__r.FirstName;
            cOrder.ChargentOrders__Billing_Last_Name__c = OrderingContact.npe5__Contact__r.LastName;
            cOrder.ChargentOrders__Billing_Phone__c = OrderingContact.npe5__Contact__r.Phone;
            cOrder.ChargentOrders__Billing_Email__c = OrderingContact.npe5__Contact__r.Email;
            salesOrder.Chargent_Order__c = cOrder.Id;
        }
        // Set the Order first name,last name and Email from the Contact (Ship_to_First_Name__c, Ship_to_Last_Name__c).
        salesOrder.Billing_Email__c = OrderingContact.npe5__Contact__r.Email;
        salesOrder.Billing_Phone__c = OrderingContact.npe5__Contact__r.Phone;
        salesOrder.Ship_to_First_Name__c = OrderingContact.npe5__Contact__r.FirstName;
        salesOrder.Ship_to_Last_Name__c = OrderingContact.npe5__Contact__r.LastName;
        
        system.debug(OrderingContact.npe5__Organization__r.BillingCountry);
        
        //SF-121 Changes
        /* If the Account Billing Country is blank set the Order Billing Country (ChargentSFA__Billing_Country__c) to UNITED STATES.
        //if (OrderingContact.npe5__Organization__r.BillingCountry == null || OrderingContact.npe5__Organization__r.BillingCountry == '')
        //{
            //OrderingContact.npe5__Organization__r.BillingCountry = 'UNITED STATES';
        //}*/
        
        // Validate Account Billing Address
        if (
            // SF-121 Change -- need to check for all country.
                // If the Account Billing Address (BillingStreet, BillingCity, BillingPostalCode, BillingState) is not blank 
                //   and is not undeliverable (Undeliverable_Mailing__c)
                OrderingContact.npe5__Organization__r.BillingCountry != null &&
                OrderingContact.npe5__Organization__r.BillingStreet != null && 
                OrderingContact.npe5__Organization__r.Undeliverable_Mailing__c != true && 
                OrderingContact.npe5__Organization__r.BillingCity != null && 
                OrderingContact.npe5__Organization__r.BillingPostalCode != null && 
                OrderingContact.npe5__Organization__r.BillingState != null
            ) 
        
        {
            // Copy the Account Billing Address to the Order Billing Address (ChargentSFA__Billing_Address__c, etc.)
            cOrder.ChargentOrders__Billing_Address__c = OrderingContact.npe5__Organization__r.BillingStreet;
            cOrder.ChargentOrders__Billing_City__c = OrderingContact.npe5__Organization__r.BillingCity;
            cOrder.ChargentOrders__Billing_Zip_Postal__c = OrderingContact.npe5__Organization__r.BillingPostalCode;
            cOrder.ChargentOrders__Billing_State__c = OrderingContact.npe5__Organization__r.BillingState;
            cOrder.ChargentOrders__Billing_Country__c = OrderingContact.npe5__Organization__r.BillingCountry;
            cOrder.ChargentOrders__Billing_State_Province__c = OrderingContact.npe5__Organization__r.Billing_County__c;
        }
        else
        {
            string CreateOrderBillingAddressErrorMessage = 'Error: The Billing Address for the account provided is not valid. '
                + 'Either the address is marked as undeliverable or the Billing Street, Billing City, Billing State/Province, Billing Zip/Postal Code, or Billing Country are not complete.';
            
            // Set the error log (Error_Log__c) on the Order to the error message, and insert the Order.  
            salesOrder.Error_Log__c = CreateOrderBillingAddressErrorMessage;
            insert salesOrder;
            update cOrder;
            return new Result(false, CreateOrderBillingAddressErrorMessage);
        }
        
     
        
        // Set the default Shipping Type (Shipping_Type__c) to Standard
        salesOrder.Shipping_Type__c = 'Standard';
        
        // Get the default Shipping Address from the Account (Default_Shipping_Address__c).
        List<Address__c> DefaultShippingAddresses = [Select Id, Name, First_Name__c, Last_Name__c, 
            Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, Country__c, 
            Intacct_Address_ID__c, Default_Shipping_Address__c, Account__c 
            From Address__c Where Id = :OrderingContact.npe5__Organization__r.Default_Shipping_Address__c];
        
        // If the Default Shipping Address Street is not blank
        if(DefaultShippingAddresses.size() > 0)
        {
            // If the Shipping Street Address is not blank
            if (DefaultShippingAddresses[0].Address_Line_1__c != null) 
            {
                if (DefaultShippingAddresses[0].Address_Line_1__c.trim() != '')
                {
                    // Copy the Default Shipping Address to the Opportunity 
                    // (Shipping_Address__c - Salesforce ID lookup to Address__c object, 
                    // Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Zip_Code__c, Shipping_County__c, Shipping_Country__c)
                    salesOrder.Shipping_Address__c = DefaultShippingAddresses[0].Id; 
                    salesOrder.Shipping_Street__c = DefaultShippingAddresses[0].Address_Line_1__c;
                    if(DefaultShippingAddresses[0].Address_Line_2__c != null) {
                        salesOrder.Shipping_Street__c += '\n' + DefaultShippingAddresses[0].Address_Line_2__c; }
                    salesOrder.Shipping_City__c = DefaultShippingAddresses[0].City__c;
                    salesOrder.Shipping_State__c = DefaultShippingAddresses[0].State__c;
                    salesOrder.Shipping_Zip_Code__c = DefaultShippingAddresses[0].Zip_Code__c;
                    salesOrder.Shipping_County__c = DefaultShippingAddresses[0].County__c;
                    salesOrder.Shipping_Country__c = DefaultShippingAddresses[0].Country__c;
                }
            }
        }
        
        // Try to Find Orders with the same name and insert the Order.
        try 
        {
            // Find Orders with the same name. (There should never be any, but just in case.)
            List<Order> SameNameOrders = [Select Id From Order Where Name = :salesOrder.Name]; 
            
            // If there are no same name Orders
            if(SameNameOrders.size() <= 0)
            {
                // Insert the Order
                insert salesOrder; 
                update cOrder;
                // Insert the Contact Role for the Opportunity
                insert new Order_Contact_Role__c(Contact__c = OrderingContact.npe5__Contact__r.Id, Order__c = salesOrder.Id);
                
                
            } 
            else
            {
                
                system.debug('<< SAME ORDER FOR HISTORY OF ORDERS >> '+SameNameOrders);
                // If there were same name Orders, return Success as false and an error message. 
                return new Result(false,'Create Order failed. An order with that name already exists. ');
            }
        }
        catch(Exception exc) 
        {
            // If there was an error inserting the order, return Success as false and an error message.
            return new Result(false,
                'Create Order failed. An error occurred while inserting the order. Error: '+exc.getMessage()); 
        }
        
        // Return Success as true and return the Opportunity (Order).
        //boolean SetSuccess, string SetMessage, string SetStringOutput, decimal SetDecimalOutput, sObject SetObject
        return new Result(true,'Success; created a new order.',null,null,salesOrder);
    }

    /* 
     * Method:  CreateOrder
     * Inputs:  string ContactId - The Salesforce ID of a Contact. This is used to lookup an Account.
     *          string PriceBookName - The name of the price book to use. Most commonly this value will be Catalog Price Book.
     *          string OrderType - Determines whether the Opportunity is an Order or a Credit. Valid values are Order or Credit.
     *          Date OriginalOrderDate - The date the original order was placed (used for credits only). 
     *                              If the OrderType is Credit the OriginalOrderDate is required, otherwise it should be null.
     * Output:  Result Object containing Success and Message (at minimum) and the new Opportunity if the Order was successfully created.
     * Purpose: Creates a new Order from the arguments specified. Finds the Contact and related Account based on ContactId, the Pricebook based on PriceBookName, and 
     *            sets the Payment Terms based on OrderType and sets the OriginalOrderDate if the OrderType is Credit.  
     * SOQL:    4
     * DML:     2
     * UPDATED FOR MIGRATION OF OPPORTUNITY TO ORDER
     */
    webservice static Result CreateOrder(string ContactId, string PriceBookName, string OrderType, Date OriginalOrderDate,String Company)
    {
        system.debug('*ContactId*'+ContactId);
        system.debug(PriceBookName);
        system.debug(OrderType);
        system.debug(OriginalOrderDate);
        
        // Configuration Variables
        String c_PriceBookName = 'Catalog Price Book';
        String c_InitialStageName = 'Order Open';
        
        Contact OrderingContact = null;
        
        // Find the Contact record using the provided ContactId. 
        List<Contact> MatchingContacts = [Select Id, Name, FirstName, LastName, Phone, Email, AccountId, Account.Name, 
            Account.Account_on_Hold__c, Account.Hold_Comments__c, Account.Undeliverable_Mailing__c, Account.Undeliverable_Shipping__c, Account.Mailing_Address_Book__c, 
            Account.BillingStreet,  Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Account.BillingCountry, Account.Billing_County__c, 
            Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingCountry, Account.Shipping_County__c, 
            Account.RecordType.Name, Account.Default_Terms__c, Account.Default_Shipping_Address__c, Account.CurrencyISOCode
            From Contact Where Id = :ContactId];
        
        system.debug(MatchingContacts);
        
        
        // If the Contact is not found, return Success as false and an error message. 
        if(MatchingContacts.size() < 1) {
            return new Result(false,'Create Order failed. The ContactId provided could not be found; please provide a valid 15 or 18 character ContactId. '); }
        
        OrderingContact = MatchingContacts[0];
        
        system.debug(OrderingContact.Account.Mailing_Address_Book__c);
        
        // If the related Account has a blank Customer Number (Mailing_Address_Book__c), 
        if(OrderingContact.Account.Mailing_Address_Book__c == null) {
            return new Result(false,
                'Create Order failed. The Account associated with the Contact provided does not have a valid Customer Number (or Mailing Address Book Number). '); }
        
        // If the related Account is on hold (Account_on_Hold__c == true), return Success as false and an error message with the hold comments (Hold_Comments__c). 
      //TW: 09-10-12: Re-added the contact on hold validation.
        if(OrderingContact.Account.Account_on_Hold__c) {
            return new Result(false,
                'Create Order failed. The Account associated with the Contact provided is on hold and is currently not allowed to place orders. Account Hold Comments: '
                    + OrderingContact.Account.Hold_Comments__c); }
        
        // Get all pricebooks and find the pricebook to use for the Order by comparing the pricebook name to the provided PriceBookName argument. 
        List<PriceBook2> PriceBooks = [SELECT Id, Name FROM PriceBook2 WHERE isActive = true ORDER BY Name ASC];
        PriceBook2 PriceBook = null;
        
        string PriceBookNames = ''; // PriceBookNames is for an error message to list the available price books
        
        for(PriceBook2 pb : PriceBooks) 
        {
            PriceBookNames += pb.Name + ', ';
            if(PriceBookName != null)
            {
                if(pb.Name.toLowerCase().contains(PriceBookName.toLowerCase())) { PriceBook = pb; }
            }
        }
        
        // Remove last comma & space (2 chars) for returning if there is an error.
        PriceBookNames = PriceBookNames.substring(0,PriceBookNames.length()-2);
        
        system.debug('PriceBook: '+PriceBook);
        
        // If the pricebook was not found, return Success as false and an error message stating all valid pricebooks.
        if(PriceBook == null) {
            return new Result(false,
                'Create Order failed. PriceBookName is required; please provide a valid PriceBookName. Valid Price Books are: ' + PriceBookNames + '. '); }
        
        // Validate the provided OrderType argument. If OrderType is not Order or Credit, return Success as false and an error message.
        if(OrderType == null || (OrderType.toLowerCase().trim() != 'order' && OrderType.toLowerCase().trim() != 'credit')) 
        {
            return new Result(false,
                'Create Order failed. OrderType is required; please provide a valid OrderType. Valid Order Types are: Order, Credit. '); } 
        // If the provided OrderType argument is Credit and the provided OriginalOrderDate argument is blank, return Success as false and an error message.
        if(OrderType.toLowerCase().contains('credit') && OriginalOrderDate == null) {
            return new Result(false,
               'Create Order failed. OriginalOrderDate is required for Credit OrderType; please provide a valid OriginalOrderDate. '); }
       string OrderPrefix = 'O';
       
        string OrderPaymentTerms = OrderingContact.Account.Default_Terms__c; 
        if(OrderType.toLowerCase().contains('credit')) { OrderPrefix = 'C'; OrderPaymentTerms = 'Sales Credit'; }
               
        Order Ord = new Order();
        Ord.Status = c_InitialStageName;
        Ord.effectiveDate = Date.Today();
        Ord.PriceBook2Id = PriceBook.Id;
        //Tw: 2-12-2012 Added comnpany field for opportunity and removed the old Kidz Matter naming conventikons for prefix.
        Ord.Company__c = Company;
        //TW 5-13-2013:  Updated code to make sure that if KM account is a Businkess Unit , it's payment type should be Internal
        system.debug('<< ORDER ACCOUNT RECORD TYPE >> '+OrderingContact.Account);
        List<RecordType> acctType = [SELECT Name from RecordType where SObjectType = 'Account' and Id =: OrderingContact.Account.RecordTypeId];
   
        // END: TW 5-13-2013: 
        
        // Set the Order AccountId from the found Contact AccountId.
        Ord.AccountId = OrderingContact.AccountId;
        
        // Generate a new order name for this Order by calling the OrderEntryServicesDummy.GetNextOrderNumber webservice. 
        //   Send O as the OrderPrefix if the provided OrderType argument is Order, or Send C as the OrderPrefix if the provided OrderType is Credit.
        Result NextOrderNameResult = OrderEntryServicesDummy.GetNextOrderNumber(OrderPrefix, OrderingContact.Account.Mailing_Address_Book__c);
        Ord.Name = NextOrderNameResult.StringOutput;
        
        // Set the appropriate Currency ISO Code (USD or CAD) to the Ordering Account Currency ISO Code.
        Ord.CurrencyISOCode = OrderingContact.Account.CurrencyIsoCode;
        
        // Set the default payment terms (Credit Card, Net 30, etc.) according to the Account Default Payment Terms or to Sales Credit if the provided OrderType argument is Credit.
        Ord.Payment_Terms__c = OrderPaymentTerms;
       
        // If the provided OrderType argument is Credit, set the Original Order Date (Original_Order_Date__c) of the Order to the provided OriginalOrderDate argument.
        if(OrderType.toLowerCase().contains('credit')) { Ord.Original_Order_Date__c = OriginalOrderDate; }
        
        // Set the credit card detail for the Order from the Contact (ChargentSFA__Billing_First__c, ChargentSFA__Billing_Last__c, ChargentSFA__Billing_Phone__c, ChargentSFA__Billing_Email__c, ChargentSFA__Card_Name__c).
        result res = OrderEntryServicesDummy.createChargentOrder();
        ChargentOrders__ChargentOrder__c cOrder;
        if(res!=null && res.Success){
           cOrder = (ChargentOrders__ChargentOrder__c)res.ObjectOutput;
           cOrder.ChargentOrders__Billing_First_Name__c = OrderingContact.FirstName;
           cOrder.ChargentOrders__Billing_Last_Name__c = OrderingContact.LastName;
           cOrder.ChargentOrders__Billing_Phone__c = OrderingContact.Phone;
           cOrder.ChargentOrders__Billing_Email__c = OrderingContact.Email;
           Ord.Chargent_Order__c = cOrder.Id;
        }
        // Set the Order first name,last name and email from the Contact (Ship_to_First_Name__c, Ship_to_Last_Name__c).
        Ord.Billing_Email__c = OrderingContact.Email;
        Ord.Billing_Phone__c = OrderingContact.Phone;
        Ord.Ship_to_First_Name__c = OrderingContact.FirstName;
        Ord.Ship_to_Last_Name__c = OrderingContact.LastName;
        
        system.debug(OrderingContact.Account.BillingCountry);
        
        // If the Account Billing Country is blank set the Order Billing Country (ChargentSFA__Billing_Country__c) to UNITED STATES.
        if (OrderingContact.Account.BillingCountry == null || OrderingContact.Account.BillingCountry == '')
        {
            OrderingContact.Account.BillingCountry = 'UNITED STATES';
        }
        
        // Validate Account Billing Address
        if (
            ( // UNITED STATES CASE
                // If the Account Billing Address (BillingStreet, BillingCity, BillingPostalCode, BillingState) is not blank 
                //   and is not undeliverable (Undeliverable_Mailing__c)
                OrderingContact.Account.BillingCountry.toLowerCase().trim() == 'united states' &&
                OrderingContact.Account.BillingStreet != null && 
                OrderingContact.Account.Undeliverable_Mailing__c != true && 
                OrderingContact.Account.BillingCity != null && 
                OrderingContact.Account.BillingPostalCode != null && 
                OrderingContact.Account.BillingState != null
            ) ||
            ( // INTERNATIONAL CASE
                // If the Account Billing Address (BillingStree) is not blank 
                //   and is not undeliverable (Undeliverable_Mailing__c)
                OrderingContact.Account.BillingCountry.toLowerCase().trim() != 'united states' &&
                OrderingContact.Account.Undeliverable_Mailing__c != true && 
                OrderingContact.Account.BillingStreet != null
            )
           )
        {
            // Copy the Account Billing Address to the Order Billing Address (ChargentSFA__Billing_Address__c, etc.)
           cOrder.ChargentOrders__Billing_Address__c = OrderingContact.Account.BillingStreet;
            cOrder.ChargentOrders__Billing_City__c = OrderingContact.Account.BillingCity;
            cOrder.ChargentOrders__Billing_Zip_Postal__c = OrderingContact.Account.BillingPostalCode;
            cOrder.ChargentOrders__Billing_State__c = OrderingContact.Account.BillingState;
           cOrder.ChargentOrders__Billing_Country__c = OrderingContact.Account.BillingCountry;
            Ord.Billing_County__c = OrderingContact.Account.Billing_County__c;
        }
        else
        {
            string CreateOrderBillingAddressErrorMessage = 'Error: The Billing Address for the account provided is not valid. '
                + 'Either the address is marked as undeliverable or the Billing Street, Billing City, Billing State/Province, Billing Zip/Postal Code, or Billing Country are not complete.';
           
            // Set the error log (Error_Log__c) on the Order to the error message, and insert the Order.  
            Ord.Error_Log__c = CreateOrderBillingAddressErrorMessage;
            insert Ord;
            update cOrder;
            
            return new Result(false, CreateOrderBillingAddressErrorMessage);
        }

        // Set the default Shipping Type (Shipping_Type__c) to Standard
        Ord.Shipping_Type__c = 'Standard';
        
        // Get the default Shipping Address from the Account (Default_Shipping_Address__c).
        List<Address__c> DefaultShippingAddresses = [Select Id, Name, First_Name__c, Last_Name__c, 
            Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, Country__c, 
            Intacct_Address_ID__c, Default_Shipping_Address__c, Account__c 
            From Address__c Where Id = :OrderingContact.Account.Default_Shipping_Address__c];
        
        // If the Default Shipping Address Street is not blank
        if(DefaultShippingAddresses.size() > 0)
        {
            // If the Shipping Street Address is not blank
            if (DefaultShippingAddresses[0].Address_Line_1__c != null) 
            {
                if (DefaultShippingAddresses[0].Address_Line_1__c.trim() != '')
                {
                    // Copy the Default Shipping Address to the Opportunity 
                    // (Shipping_Address__c - Salesforce ID lookup to Address__c object, 
                    // Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Zip_Code__c, Shipping_County__c, Shipping_Country__c)
                    Ord.Shipping_Address__c = DefaultShippingAddresses[0].Id; 
                    Ord.Shipping_Street__c = DefaultShippingAddresses[0].Address_Line_1__c;
                    if(DefaultShippingAddresses[0].Address_Line_2__c != null) {
                        Ord.Shipping_Street__c += '\n' + DefaultShippingAddresses[0].Address_Line_2__c; }
                    Ord.Shipping_City__c = DefaultShippingAddresses[0].City__c;
                    Ord.Shipping_State__c = DefaultShippingAddresses[0].State__c;
                    Ord.Shipping_Zip_Code__c = DefaultShippingAddresses[0].Zip_Code__c;
                    Ord.Shipping_County__c = DefaultShippingAddresses[0].County__c;
                    Ord.Shipping_Country__c = DefaultShippingAddresses[0].Country__c;
                }
            }
        }
        
        // Try to Find Orders with the same name and insert the Order.
        try 
        {
            // Find Orders with the same name. (There should never be any, but just in case.)
            List<Order> SameNameOrders = [Select Id From Order Where Name = :Ord.Name]; 
            
            // If there are no same name Orders
            if(SameNameOrders.size() <= 0)
            {
                // Insert the Order
                insert Ord;
                update cOrder;
                // Insert the Contact Role for the Opportunity
        //TW 1-1-2004: Removing insertion of contact roles since NPN Starter Pack uses triggers to create a contact roles for Individual accounts
               system.debug('ORDER CONTACT ACCOUNT TYPE: >>'+OrderingContact.Account.RecordType.Name);
                system.debug('ORDER CONTACT NAME: >>'+OrderingContact.Id);
                if(OrderingContact.Account.RecordType.Name == 'Household Account' || OrderingContact.Account.RecordType.Name == 'International Church' || OrderingContact.Account.RecordType.Name == 'Canada Church' || OrderingContact.Account.RecordType.Name == 'KM Church'  ){
                  insert new Order_Contact_Role__c(Contact__c = OrderingContact.Id, Order__c = Ord.Id);
                }
            } 
            else
            {
                // If there were same name Orders, return Success as false and an error message. 
                return new Result(false,'Create Order failed. An order with that name already exists. ');
            }
        }
        catch(Exception exc) 
        {
            // If there was an error inserting the order, return Success as false and an error message.
            return new Result(false,
                'Create Order failed. An error occurred while inserting the order. Error: '+exc.getMessage()); 
        }
        
        // Return Success as true and return the Opportunity (Order).
        //boolean SetSuccess, string SetMessage, string SetStringOutput, decimal SetDecimalOutput, sObject SetObject
        return new Result(true,'Success; created a new order.',null,null,Ord);
    }
    
    /* 
     * Method:  CalculateOrderEntryStage
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the Order Entry Stage
     *            0 - Order has not been saved or could not be found.
     *            1 - Order exists and/or it has been saved.
     *            2 - Order has a delivery charge line.
     *            3 - Order has a tax charge line.
     *            4 - Order has been authroized if it is a credit card order, or Order does not need to be authorized.
     * Purpose: Gets, or calculates, the proper stage of Order entry. This is useful for hiding or displaying the current order 
     *            progress through the interface. 
     * SOQL:    4
     * DML:     0
     */
    webservice static Result CalculateOrderEntryStage(string orderId)
    {
        // Initialize variables that indicate whether or not delivery charges and tax charges have been calculated
        //   and whether the credit card has been authorized.
        boolean hasFreight = false;
        boolean hasTax = false;
        boolean hasAuth = false;
        
        // The five (or six) stages
        // 0 - not saved or could not find order
        // 1 - saved
        // 2 - delivery calculated
        // 3 - tax calculated
        // 4 - credit card order authorized
        // 5 - order submitted
        // Initialize Order entry stage, and set it to zero, indicating that the Order has not yet been found (yet).
        integer orderEntryStage = 0;
        
        // Call the GetOrder webservice to find the Order using the provided OpportunitySalesforceId argument.
        Order ordr = OrderEntryServicesDummy.GetOrder1(orderId);
        
        // If an Order was not found, return failure (Success as false) and an error message. 
        if(ordr == null) { 
            return new Result(false,'Please supply a valid Opportunity (15 or 18 character) Salesforce Id. '); }
        
        // Otherwise (Order has been found), set the Order entry stage variable to one.
        orderEntryStage = 1; // order exists and has been saved
        
        // If the Payment Terms on the Order is not blank
        if(ordr.Payment_Terms__c != null)
        {
            // If the payment terms is set to Sales Credit 
            if(ordr.Payment_Terms__c.toLowerCase().contains('sales credit')) {
                //TW:11-10-2011: If we have not calculated sales tax then display this button first.    
               //Otherwise display the Submit button.
                if(orderEntryStage < 3){
                    return new Result(true, 'Order stage calculated for ' + ordr.Name
                    + '. This order is a Sales Credit order so calculate the sales tax.', 3); }
                else{
                // Return Success as true, a message, and an Order entry stage of 4 (allowing Finish/Submit Order). 
                return new Result(true, 'Order stage calculated for ' + ordr.Name
                    + '. This order is a Sales Credit order and does not require delivery/freight or tax line items.', 4); }
            }
           
                             
        }
        
        string returnMessage = 'Order stage calculated for '+ordr.Name+'. ';
        
        // If the Order has products
        if(ordr.OrderLineItemCount__c>0)
        {
            // Find all products for the Order.
            List<OrderItem> items = OrderEntryServicesDummy.GetOrderLineItems1(orderId);
            
            // For each product, check to see if the Line Type (OpportunityLineItem.Line_Type__c) starts with F or T.
            for(OrderItem i : items)
            {
                if(i.Line_Type__c.toLowerCase().startsWith('f')) { hasFreight = true; }
                if(i.Line_Type__c.toLowerCase().startsWith('t')) { hasTax = true; }
            }
        }
        
        // If the Order has a delivery charge (product with a Line Type of F), set the Order entry stage to two.
        if(hasFreight) { returnMessage += ', has a delivery charge line item'; orderEntryStage = 2; }
        // If the Order has a delivery charge and a tax charge (products with a Line Type of F and T), set the Order entry stage to three.
        if(hasTax && hasFreight) { returnMessage += ', has a tax charge line item'; orderEntryStage = 3; }
        //MENA: If hasFrieght and isMENA set Order Entry Stage to 4 (allowing Finish/S ubmit Order in the interface - skip the tax calculation))
        // If the Payment Terms on the Order is not blank
        system.debug('hasFreight-'+hasFreight+' hasTax-'+hasTax+' payment terms-'+ordr.Payment_Terms__c);
        if(ordr.Payment_Terms__c != null)
        {
            // If Payment Terms is Credit Card
            if(ordr.Payment_Terms__c.toLowerCase().contains('credit card') && ordr.TotalAmount != 0)
            {
                double total_authorization_amount = 0; 
                
                // Call the GetTransactions web service using the OpportunitySalesforceId argument provided.
                List<ChargentOrders__Transaction__c> transactions = GetTransactions(ordr.Chargent_Order__r.Id); 
                system.debug('transactions-'+JSON.serialize(transactions));
                for(ChargentOrders__Transaction__c t : transactions)
                {
                    // If the Transaction is an authorization (ChargentSFA__Type__c)
                    system.debug('<< T CHARENGENT ORDERS AUTHORIZATION >> '+t.ChargentOrders__Type__c);
                    if(t.ChargentOrders__Type__c == 'Authorization')
                    {
                        // If the Transaction response status (ChargentSFA__Response_Status__c) is not blank
                        if(t.ChargentOrders__Response_Status__c != null)
                        {
                            // And the Transaction response status contains approved
                            if(t.ChargentOrders__Response_Status__c.toLowerCase().contains('approved')) 
                            {
                                // Set the variable that indicates whether or not there is an authorization to true.
                                // Add the Transaction amount (ChargentSFA__Amount__c) to the total authorization amount.
                                hasAuth = true; total_authorization_amount += t.ChargentOrders__Amount__c;
                                system.debug('<< T. Chargent Orders Amount ?>> '+t.ChargentOrders__Amount__c);
                            }
                        }
                        
                        // If the transaction response message is not blank
                        if(t.ChargentOrders__Response_Message__c != null)
                        {
                            // And the transaction response message contains approved
                            if(t.ChargentOrders__Response_Message__c.toLowerCase().contains('approved')) {
                                // Set the variable that indicates whether or not there is an authorization to true.
                                // This will only happen if the Transaction response status is also approved, but it is
                                // a catch all, if they are ever different.
                                hasAuth = true;}
                                                         
                        }
                   }
                }
                //TW: 10-10-2012 Also Add a state where Credit Balance = 0.
                system.debug('<< ORDER TOTAL AMOUNT >> '+Ordr.TotalAmount);
                if(Ordr.TotalAmount == 0){
                  hasAuth = true;
                  returnMessage += ', has been authorized for 100% discount.';
                }
                system.debug('hasAuth-'+hasAuth);
                // If the Order has an approved authorization Transaction 
                if(hasAuth) 
                {
                    // If the total authorization amount is not greater than or equal to the Order amount, 
                    // Set the variable that indicates whether or not there is an authorization to false preventing
                    // Finish/Submit Order. 
                    if(total_authorization_amount >= Math.floor(Ordr.TotalAmount)) { returnMessage += ', has been authorized'; system.debug('ARE WE IN THE IF of HASAUTH? '+total_authorization_amount);}
                    else { hasAuth = false; system.debug('ARE WE IN THE ELSE of HASAUTH? '+total_authorization_amount);} 
                }
                //TW: 1-31-2013; Need to Catch Credit Card Payments with no Transactions.
                // If the Order has an approved authorization Transaction, a delivery charge Line, and a Tax Line, 
                // Set the Order entry stage to four (allowing Finish/S ubmit Order in the interface).
               if( Ordr.Payment_terms__c.toLowerCase().contains('credit card') &&  hasAuth && hasFreight && hasTax) { orderEntryStage = 4; }
            }
            else
            {
                // Otherwise (else) (if the payment terms are not credit card), 
                // If the Order has a delivery charge and a tax charge, 
                // Set the Order entry stage to four (an approved authorization Transaction is not needed).
                if(orderEntryStage >= 3 && hasFreight && hasTax ) { orderEntryStage = 4; }
            }
            system.debug('<<ORDER STAGE =>> '+orderEntryStage );
            system.debug('<<Has Auth =>> '+hasAuth+' <<Has FRT =>> '+hasFreight+' <<Has TAX =>> '+hasTax );
        }
        
        if(returnMessage.lastIndexOf(',')>0) { returnMessage = returnMessage.replaceAll('(.*),','$1, and'); }
        
        // Return Success as true and return the Order entry stage.
        return new Result(true,returnMessage,orderEntryStage);
    }
    /*
        Purpose: Validates Shipping Address on Orders and Billing Address on Chargent Billing Address.
        Author : Darshan Chhajed.
    */
    webservice static Result ValidateOrderAddress(Order Ordr)
    {
        system.debug(Ordr.Chargent_Order__r.ChargentOrders__Billing_Country__c);
        // If the Order Shipping Country is blank (Shipping_Country__c)
        // Return failure (Success as false) and an error message.
        if(Ordr.Shipping_Country__c == null) 
        { 
            return new Result(false, 'The shipping address for the Opportunity (Order) is not valid. Country is required. '); 
        }
        
        // If the Shipping Country is UNITED STATES
        if(Ordr.Shipping_Country__c.toLowerCase().trim() == 'united states')
        {
            // If the Order Shipping Street, City, State, or Zip Code are blank
            // (Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Zip_Code__c)
            if (Ordr.Shipping_Street__c == null ||
                Ordr.Shipping_City__c == null ||
                Ordr.Shipping_State__c == null ||
                Ordr.Shipping_Zip_Code__c == null)
            {
                // Return failure (Success as false) and an error message.
                return new Result(false, 'The shipping address for the Opportunity (Order) is not valid. The first address line, city, state, and postal code (zip) are required. ');
            }
        }
        // Otherwise (else)
        else
        {
            // If the Order Shipping Street is blank (Shipping_Street__c)
            if (Ordr.Shipping_Street__c == null)
            {
                // Return failure (Success as false) and an error message.
                return new Result(false, 'The shipping address for the Opportunity (Order) is not valid. The first address line is required. ');
            }
        }
        if(Ordr.Chargent_Order__r.ChargentOrders__Billing_Country__c == null) 
        { 
            return new Result(false, 'The billing address for the  Order is not valid. Country is required. '); 
        }
        // If the Billing Country is UNITED STATES
        if(Ordr.Chargent_Order__r.ChargentOrders__Billing_Country__c.toLowerCase().trim() == 'united states')
        {
            // If the Order Billing Street, City, State, or Zip Code are blank  
            // (ChargentSFA__Billing_Address__c, ChargentSFA__Billing_City__c, ChargentSFA__Billing_State__c, ChargentSFA__Billing_Zip__c)
            if (Ordr.Chargent_Order__r.ChargentOrders__Billing_Address__c == null ||
                Ordr.Chargent_Order__r.ChargentOrders__Billing_City__c == null ||
                Ordr.Chargent_Order__r.ChargentOrders__Billing_State__c == null ||
                Ordr.Chargent_Order__r.ChargentOrders__Billing_Zip_Postal__c == null)
            {
                // Return failure (Success as false) and an error message.
                return new Result(false, 'The billing address for the Order is not valid. The first address line, city, state, and postal code (zip) are required. ');
            }
        }
        // Otherwise (else)
        else
        {
            // If the Order Billing Street is blank (ChargentSFA__Billing_Address__c)
            if (Ordr.Chargent_Order__r.ChargentOrders__Billing_Address__c == null)
            {
                // Return failure (Success as false) and an error message.
                return new Result(false, 'The billing address for the Order is not valid. The first address line is required. ');
            }
        }   
        // Otherwise, return Success and a Message
        return new Result(true, 'Successfully validated shipping address are not blank. ');

    }
   
    /* 
     * Method:  MenaBackOrders
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Opportunity. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
     */
   webservice static Boolean MenaBackOrders(String OrderId)
   {
     string ShippingType = null;
     Boolean mena_backorders = false;
     // Find all Lines for the Order using the OpportunitySalesforceId argument provided.
          List<OrderItem> Lines = [Select Id, UnitPrice, TotalPrice, Line_Type__c,Quantity, PricebookEntry.Product2.Name, 
               Order.AccountId, Order.Account.Mailing_Address_Book__c, Quantity_Backordered__c ,Estimated_Weight__c,
              Order.TotalAmount, Order.Shipping_Type__c, Order.Pricebook2.Name 
              From OrderItem Where OrderId = :OrderId];
        
          // If Lines were found
          if(Lines.size() > 0)  
          { 
              // Set the ShippingType to the Order Shipping Type (Shipping_Type__c).
              ShippingType = Lines[0].Order.Shipping_Type__c; 
            
              // For each Line on the Order
              //TW: 8-06-2012:  Update needed to fix DML limitation problem for huge orders. Need to  store items in a list of ...
              // OpportunityLineItem and then only do 
              for(OrderItem li : Lines)
              {
                  if (li.Quantity_Backordered__c > 0)
                  {
                     mena_backorders = true; // Since this is a United States Country Process we don;t need to check this line here.
                      system.debug('Quantity Backordered = '+li);
                  }
              }//LOOP
          }
     return mena_backorders;
   }
    
    /*/* 
     * Method:  CalculateFreightOnOpportunity
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Opportunity. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
     */
     /*
  webservice static Result CalculateFreightOnOpportunity(string OrderId,string WeightFreightMsg,decimal WeightFreightCost,String ShipCode)
     {
       system.debug('<<WeightFreightMsg>> '+WeightFreightMsg+'<<WeightFreightCost>> '+WeightFreightCost);
      
     Order Ordr = OrderEntryServicesDummy.GetOrder1(OrderId);
        
                   
         decimal MissionaryFreightTotal = 0;
                // If the Ordering Country is not US then give the flat Misisonary price rate.
        if(!Ordr.Shipping_Country__c.toLowerCase().contains('united states') && Ordr.Shipping_Country__c != null && !Ordr.Shipping_Country__c.toLowerCase().contains('canada'))
        {   
          List<Country__c> MeenaCountry = new List<Country__c>();
          MeenaCountry = [Select Region__c from Country__c where Name =:  Ordr.Shipping_Country__c Limit 1];
          if(MeenaCountry.size() == 0){
            
            return new Result(true, 'Success', 0);
          }
            return new Result(true, 'Success', 0);
        }
       
        system.debug('ACCOUNT SHIPPING ADDRESS: '+Ordr.Shipping_Country__c);
       //TW: 4-24-2013: Check for Payment Term = To Be Billed and if so return a value of 0 freight cost
        if(Ordr.Payment_Terms__c == 'To Be Billed'){
          return new Result(true, 'Success', 0);
        }

        if(WeightFreightMsg == 'Non-Stock' ){
            return new Result(true, 'Success', 0.0);
        }
        //********************************New code to caluclate Freight ********************************************
        //Fetch the zone using shipping zipcode
        System.debug('Freight Calculation started');
        
        Materials_Weight_Percentage_Increase__c mwpi = [select Materials_Weight_Percentage__c from Materials_Weight_Percentage_Increase__c];
        
        String zip_zone;
        Boolean apo = FALSE;
        if(Ordr.Shipping_Country__c != null){
            if(Ordr.Shipping_Country__c == 'CANADA' || Ordr.Shipping_Country__c == 'Canada' || Ordr.Shipping_Country__c == 'canada'){
                zip_zone = '1';
            }
            else if(Ordr.Shipping_Country__c.toLowerCase() != 'canada' && Ordr.Shipping_Country__c.toLowerCase() != 'united states' && 
                    Ordr.Shipping_City__c != 'FPO' && Ordr.Shipping_City__c != 'APO')
            {
                zip_zone = '99';
                return new Result(true, 'Success', 0);
            }
            else if(Ordr.Shipping_City__c == 'FPO' || Ordr.Shipping_City__c == 'APO'){
                zip_zone = '1';
                apo = TRUE;
            }
            else{
              if(Ordr.Shipping_Zip_Code__c != null)
              {
                    zip_zone = Ordr.Shipping_Zip_Code__c.left(3);
                    Shipping_Zone__c sz = [select Id,Zone__c from Shipping_Zone__c where ZIP_Prefix__c =: zip_zone];
                    zip_zone = sz.Zone__c;
                
              }
            } 
        }
        
        //Fetch the shipping rate using estimated weight in Order
        Decimal final_shipping_rate;
        Integer box_count = 1;
        Decimal remain_weight;
        Decimal estimated_weight;
        Decimal final_price;
        Decimal new_weight;
        Decimal SAC = 0.0;
        Decimal EAC = 0.0;
        Decimal NAC = 0.0;
        Decimal EcoAC = 0.0; //added for new shipping type - Economy for canada 
        Decimal PAC = 0.0; //added for new shipping type - Priority for canada 
        
        Decimal margin = 0.0;
        Integer indv_box_weight;
        Decimal accessorial_charge;
        Decimal sub_total;
        Decimal total_margin;
        
        if(Ordr.Estimated_Weight__c != null){
            system.debug('**********Shipping Zone********'+zip_zone);
            system.debug('**********Shipping type********'+Ordr.Shipping_Type__c);
            system.debug('**********Order Estimated Weight********'+Ordr.Estimated_Weight__c);
            system.debug('**********Shipping Country********'+Ordr.Shipping_Country__c);
            system.debug('**********APO Value********'+apo);
            
            new_weight = (Ordr.Estimated_Weight__c*mwpi.Materials_Weight_Percentage__c)+Ordr.Estimated_Weight__c;
            system.debug('**********Final Estimated Weight********'+new_weight);
            
            //Fetch custom setting values like margin,accessorial_charge
            Awana_Shipping_Charges__c asch = [select Id,Standard_Accessorial_Charge__c,Nextday_Accessorial_Charge__c,Margin__c,Expedited_Accessorial_Charge__c,Box_Weight__c,Flat_Rate__c From Awana_Shipping_Charges__c];
            
            Awana_CANADA_Shipping_Charges__c acsch = [select Id,Standard_Accessorial_Charge__c,Overnight_Accessorial_Charge__c,Economy_Accessorial_Charge__c,Priority_Accessorial_Charge__c,Margin__c,Expedited_Accessorial_Charge__c,Box_Weight__c From Awana_CANADA_Shipping_Charges__c];
            
            if(Ordr.Estimated_Weight__c == 0.00){
                return new Result(true, 'Success', 0);
            }
            if((Ordr.Estimated_Weight__c >= 0.001 && Ordr.Estimated_Weight__c <= 0.999) && (Ordr.Shipping_Type__c == 'Standard')){
                system.debug('********** Inside Flat ********');
                return new Result(true, 'Success', asch.Flat_Rate__c.setScale(2));
            }
            else{
                estimated_weight = new_weight;
            }
           
            system.debug('**********Final Estimated Weight********'+estimated_weight);
            System.debug('********** Final Freight'+final_shipping_rate.setScale(2));
            return new Result(true, 'Success', final_shipping_rate.setScale(2));
        }
        
        System.debug('Freight Calculation End');
        
        //Else default to stock
        return new Result(true, 'Success', WeightFreightCost);
      }*/
      
    
    /* 
     *     IMPORTANT: This webservice should not be called directly, use CalculateFreightDetail(string ShippingType, decimal Amount) instead
     * 
     * Method:  CalculateFreight
     * Inputs:  string ShippingType - The shipping type selected by the user (typically Standard, Two Day, or One Day)
     *          decimal Amount - The Amount for which to calculate freight (typically this would be the amount of the summed stock line items)
     * Output:  A decimal value for the delivery charge (freight amount).
     * Purpose: This is an old version of the CalculateFreightDetail web service. All of the logic has been moved to that web service in  
     *            order to return a result object rather than just a decimal value. With a result object, a success value and message can be 
     *            returned as well.
     * SOQL:    
     * DML:     
     * 
     *     IMPORTANT: This webservice should not be called directly, use CalculateFreightDetail(string ShippingType, decimal Amount) instead
     *          
     */
    webservice static decimal CalculateFreight(string ShippingType, decimal Amount)
    {
        // Call the CalculateFreightDetail web service.
        Result r = CalculateFreightDetail(ShippingType, Amount);
        // If the CalculateFreightDetail web service succeeded, return the Decimal Output of the Result returned.
        if(r.Success) { return r.DecimalOutput; } else { return 0; }
    }
    
    /* 
     * Method:  CalculateFreightDetail
     * Inputs:  string ShippingType - The shipping type selected by the user (typically Standard, Two Day, or One Day)
     *          decimal Amount - The Amount for which to calculate freight (typically this would be the amount of the summed stock line items)
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: This web service replaces the previous CalculateFreight web service. It is used to simply calculate freight for a given amount
     *            by looking up the Shipping Cost data for a given shipping type.
     * SOQL:    1
     * DML:     0
     */
    webservice static Result CalculateFreightDetail(string ShippingType, decimal Amount)
    {
        // If the ShippingType argument provided is blank, set the ShippingType to the default value (Standard). 
        if(ShippingType == null || ShippingType == '') { ShippingType = 'Standard'; }
        
        // If Amount is blank, set the Amount to the default value (0).
        if(Amount == null) { Amount = 0; }
        
        // Set the Amount to the absolute value Amount argument provided. 
        Amount = Math.abs(Amount);
        
        // Find the Shipping Cost record (Shipping_Cost__c) where the Minimum Order Value is less than or equal to the Amount 
        // and the Maximum Order Value is greater than or equal to the Amount.
        List<Shipping_Cost__c> ShippingCosts = Database.Query(
            ' SELECT Standard__c, Two_Day__c, One_Day__c FROM Shipping_Cost__c ' + 
            ' WHERE Minimum_Order_Value__c <= '+String.valueOf(Amount) + 
            ' AND Maximum_Order_Value__c >= '+String.valueOf(Amount)+' LIMIT 1 ');
        
        system.debug(ShippingCosts);
        
        Shipping_Cost__c ShippingCost = null;
        
        // If a Shipping Cost record was not found for that Amount, return failure (Success as false) and an error message. 

 
        if(ShippingCosts.size() > 0) { ShippingCost = ShippingCosts[0]; }
        else { return new Result(false,'There was an error getting freight. No Shipping Cost records were found.'); }
        
        // If the Shipping Type argument provided contains Pickup, return Success as true, and zero as the calculated delivery/freight charge.
        if(ShippingType.toLowerCase().contains('pickup')) {
            return new Result(true,'Success',0); }
        // If the Shipping Type argument provided contains Standard, return Success as true, and the Standard Shipping Cost as the calculated delivery/freight charge.
        else if(ShippingType.toLowerCase().contains('standard')) {
            return new Result(true,'Success',ShippingCost.Standard__c); }
        // If the Shipping Type argument provided contains Two, return Success as true, and the Two Day Shipping Cost as the calculated delivery/freight charge.
        else if(ShippingType.toLowerCase().contains('two')) {
            return new Result(true,'Success',ShippingCost.Two_Day__c); }
        // If the Shipping Type argument provided contains One, return Success as true, and the One Day Shipping Cost as the calculated delivery/freight charge.
        else if(ShippingType.toLowerCase().contains('one')) {
            return new Result(true,'Success',ShippingCost.One_Day__c); }
        // If the Shipping Type argument is something other than Pickup, Standard, One, or Two, 
        // return Success as true, and the Standard Shipping Cost as the calculated delivery/freight charge.
        else {
            return new Result(true,'Success',ShippingCost.Standard__c); }
    }
    
     /* 
     * Method:  CalculateTaxOnOpportunity
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated tax charge.
     * Purpose: This web service invokes the Tax2Wsdl web service to calculate tax on an Order. 
     * SOQL:    1
     * DML:     0
     * SF-188
     */
    webservice static Result CalculateTaxOnOpportunityNonUs(string OrderId,Decimal economyFreight,Decimal PriorityFreight)
    {
        system.debug('economyFreight--'+economyFreight);
        system.debug('PriorityFreight--'+PriorityFreight);
        
        List<decimal> allTaxAmount = new List<decimal>();        
        // Try to
        try
        {
            // Convert the OpportunitySalesforceId argument provided to a Salesforce ID
            ID TempId = OrderId;
        // If converting fails, return failure and an error message.
        } catch(Exception ex) {  return new Result(false,'Please supply a valid Order (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage());  }
        
        try 
        {
            Decimal tax;
            if(economyFreight != null){
                tax = 0.00;
                tax = avalaraTaxJSONHelper(OrderId,economyFreight);
                allTaxAmount.add(tax.setScale(2));
            }
            if(PriorityFreight != null){
                tax = 0.00;
                tax = avalaraTaxJSONHelper(OrderId,PriorityFreight);
                allTaxAmount.add(tax.setScale(2));
            }
            if(tax == null){
                return new Result(false,'The Order must have a valid Shipping Country before calculating tax OR Country must be United States Or Canada');
            }
                system.debug('allTaxAmount--'+allTaxAmount);
                return new Result(true,'Success, tax amount calculated',allTaxAmount);
  
        }
        // If an error occurred getting tax
        catch (Exception ex)
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred when getting tax from the tax system. Error:'+ex.getMessage());
        }

        
        
    }
    
    //SF-188
    webservice static Result CalculateTaxOnOpportunityUS(string OrderId,Decimal standardFreight,
                                                          Decimal expeditedFreight,Decimal nextDayFreight
                                                          )
    {
        system.debug('standardFreight--'+standardFreight);
        system.debug('expeditedFreight--'+expeditedFreight);
        system.debug('nextDayFreight--'+nextDayFreight);
        
        List<decimal> allTaxAmount = new List<decimal>();        
        // Try to
        try
        {
            // Convert the OpportunitySalesforceId argument provided to a Salesforce ID
            ID TempId = OrderId;
        // If converting fails, return failure and an error message.
        } catch(Exception ex) {  return new Result(false,'Please supply a valid Order (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage());  }
        
        try 
        {
            Decimal tax;
            if(standardFreight != null){ 
                tax = 0.00;
                tax = avalaraTaxJSONHelper(OrderId,standardFreight);
                allTaxAmount.add(tax.setScale(2));
            }
            if(expeditedFreight != null){
                tax = 0.00;
                tax = avalaraTaxJSONHelper(OrderId,expeditedFreight);
                allTaxAmount.add(tax.setScale(2));
            }
            if(nextDayFreight != null){
                tax = 0.00;
                tax = avalaraTaxJSONHelper(OrderId,nextDayFreight);
                allTaxAmount.add(tax.setScale(2));
            }           
            if(tax == null){
                return new Result(false,'The Order must have a valid Shipping Country before calculating tax OR Country must be United States Or Canada');
            }

                return new Result(true,'Success, tax amount calculated',allTaxAmount);
  
        }
        // If an error occurred getting tax
        catch (Exception ex)
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred when getting tax from the tax system. Error:'+ex.getMessage());
        }

    }
   //SF-188
        public static Decimal avalaraTaxJSONHelper(String OrderId,Decimal freightCharge) {
            Decimal TaxAmount = 0;
            AvalaraTaxJSON Obj = new AvalaraTaxJSON(OrderId,freightCharge);
            if(Obj.companyCode != null || Obj.companyCode !='') {
                string jsonData = JSON.serialize(Obj);
                jsonData = jsonData.replace('AvalaraCurrentDataTime','date');
                jsonData = jsonData.replace('Avalara_Commit','commit');
                jsonData = jsonData.replaceAll('Avalara_SeqNumber','number');
                system.debug(jsonData);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:AvalaraTax');
                req.setBody(jsonData);
                req.setHeader('Content-Type','application/json');
                req.setMethod('POST'); 
                HttpResponse res = h.send(req);
                system.debug(res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                        (parser.getText() == 'totalTax')) {
                            parser.nextToken();
                            TaxAmount = parser.getDecimalValue();
                        }
                }
                system.debug('TaxAmount--'+TaxAmount);
                return TaxAmount;
            } else{
                return 0.00;
            }  
       
            }
    
    
    
    
    
    /* 
     * Method:  CalculateTaxOnOpportunity
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated tax charge.
     * Purpose: This web service invokes the Tax2Wsdl web service to calculate tax on an Order. 
     * SOQL:    1
     * DML:     0
     */
    /* 
    webservice static Result CalculateTaxOnOpportunity(string OrderId)
    {

        decimal TaxAmount = null;        
        // Try to
        try
        {
            // Convert the OpportunitySalesforceId argument provided to a Salesforce ID
            ID TempId = OrderId;
        // If converting fails, return failure and an error message.
        } catch(Exception ex) {  return new Result(false,'Please supply a valid Order (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage());  }
        
        try 
        {
            // Initialize the tax variable to zero.
            TaxAmount = 0;
            AvalaraTaxJSON Obj = new AvalaraTaxJSON(OrderId);
            if(Obj.companyCode != null || Obj.companyCode !='') {
                string jsonData = JSON.serialize(Obj);
                jsonData = jsonData.replace('AvalaraCurrentDataTime','date');
                jsonData = jsonData.replace('Avalara_Commit','commit');
                jsonData = jsonData.replaceAll('Avalara_SeqNumber','number');
                system.debug(jsonData);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:AvalaraTax');
                req.setBody(jsonData);
                req.setHeader('Content-Type','application/json');
                req.setMethod('POST'); 
                HttpResponse res = h.send(req);
                system.debug(res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                        (parser.getText() == 'totalTax')) {
                            parser.nextToken();
                            TaxAmount = parser.getDecimalValue();
                        }
                }
                system.debug('TaxAmount--'+TaxAmount);
                return new Result(true,'Success, tax amount calculated',TaxAmount);
            }
            else 
                return new Result(false,'The Order must have a valid Shipping Country before calculating tax OR Country must be United States Or Canada');
        }
        // If an error occurred getting tax
        catch (Exception ex)
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred when getting tax from the tax system. Error:'+ex.getMessage());
        }
        
        // Otherwise, return Success as true and the Tax Amount calculated by the tax web service.*/
        //return new Result(true,'Success, tax amount calculated',TaxAmount);
    //}*/
   
    
    
  //TW: 2-12-2012 getting price book by company name for Company controller
  /* 
     * Method:  GetCompanies
     * Inputs:  string AccountSalesforceId - The Salesforce ID of an Account. 
     * Output:  A result object containing Success, a message, and a list of Pricebook (Pricebook2) records.
     * Purpose: To get a Compnay name for an Account.
     * SOQL:    2
     * DML:     0
     */
    webservice static Result GetCompanies(string ContactId,string Accountid)
    {    
        
        List<Company__c> companies = new List<Company__c>(); 
        String order = 'Name ASC';
        
        if(string.isNotBlank(Accountid)){
            List<npe5__Affiliation__c> aff = [Select Other_Role__c,npe5__Organization__r.Mailing_Address_Book__c,npe5__Organization__r.Name from npe5__Affiliation__c where npe5__Contact__c =: ContactId and npe5__Organization__r.Id =: AccountId limit 1 ];        
            
            if(!aff.isEmpty() && aff.size() > 0){
                
                if(aff[0].Other_Role__c == 'Canada' && (aff[0].npe5__Organization__r.Name == 'Awana International Canada' || aff[0].npe5__Organization__r.Mailing_Address_Book__c == '4'))
                    order = 'Name DESC';
               
            }
        }
            string querystr = 'Select Id,Name From Company__c Order By '+ order;
            companies = database.query(querystr);
        
        
       
        // If an Account was found
        if(!companies.isEmpty())
        {
            // Call the GetOrderedPriceBooks web service passing the Account Record Type Name as an argument and return the result from it.
            //return GetOrderedPriceBooks(accounts[0].Company__c);
             // Return success, a message, and the list of Ordered Pricebooks
          return new Result(true, 'Success, Company found.', companies); 
        
        }
        else
        {
          return new Result(false,'No Companies were found.');
        }
    }
 
  //TW: 2-13-2012 New Method to get price books by company.
      /* 
     * Method:  GetPriceBookByCompany
     * Inputs:  string CompanyName - The Record Type of an Account (typically Individual, Missionary, Employee, US Church, or Canada Church).
     * Output:  A result object containing Success, a message, and a list of Pricebook (Pricebook2) records.
     * Purpose: To get an ordered list of Pricebooks for a specific Account Record Type. In order to default a picklist value (at Create Order), 
     *            the Pricebook list must be sorted properly with the default value at the top.
     * SOQL:    1
     * DML:     0
     */
   webservice static Result GetPriceBookByCompany(string ContactId, string RecTypIdOrRecTypeName, string Type, string AffID)
    {  
        system.debug('RECORDYTYPE: '+RecTypIdOrRecTypeName+' WITH TYPE: '+Type ); 
        String AffRecordType = ''; // Recordtype Name
        String RegLvl = '';
        system.debug('AffID---'+AffID);
        List<String> bookString = new List<String>();
        npe5__Affiliation__c aff = new npe5__Affiliation__c();
        boolean isPriceBookBlank = true;
        //RecTypIdOrRecTypeName is assigned to  Type to hold the Record Type Name for non-Affiliated Contacts (.i.e Household Accounts) or Affiliation Ids (US Orgs)
        //Type is generally used to hold Account Type but for Household Accounts we will be using Record Type Name
        if(Type=='Individual' || Type=='Household Account'){
            RecTypIdOrRecTypeName = Type;
        }
        if((RecTypIdOrRecTypeName != 'Individual' && RecTypIdOrRecTypeName !='Household Account') ){
          List<RecordType> rectype = [Select Name from RecordType where Id =: RecTypIdOrRecTypeName limit 1];
          AffRecordType = String.valueOf(rectype[0].Name);
          
          //Get organization ID from Contact because we need to get the Membership Level to make sure they are now Non-Member (NM)
          aff = [Select npe5__Organization__r.Registration_Level__c,Authorized_Purchaser__c,npe5__Organization__r.Name,Other_Role__c from npe5__Affiliation__c where npe5__Contact__c =: ContactId and npe5__Organization__r.Id =: AffID limit 1 ];
          system.debug('ORGANIZATION NAME: '+aff.npe5__Organization__r.Name+' ORGANIZATION ID: '+aff.npe5__Organization__r.Id);
          RegLvl = String.valueOf(aff.npe5__Organization__r.Registration_Level__c);
          system.debug('<<REGISTRATION LEVEL>>: '+RegLvl+'<< ORG ID>> '+AffID);
          system.debug('<< IS AUTHORIZED? >>> '+aff);
        }else{
          AffRecordType = RecTypIdOrRecTypeName;
          system.debug('We SHOUL BE HERE FOR HOUSE ACCOUNTS');
        }        
        List<PriceBook2> CompanyPriceBooks = new List<PriceBook2>();
        String whichPBook = 'No Price Book';
        system.debug('<< RECTYPE: >>'+AffRecordType);
        system.debug('CONTACT: '+ContactId);
        
        if((AffRecordType == 'US Organization' || AffRecordType == 'Household Account') && (RegLvl != 'R0' && RegLvl != null)){
          bookString.clear();
             whichPBook = 'Catalog Price Book';
             bookString.add(whichPBook);
         }
         
         if(RegLvl == 'R0' || RegLvl == '' || RegLvl == null){
          bookString.clear();
             whichPBook = 'Retail Pricebook';
             bookString.add(whichPBook);
             system.debug('bookString--'+bookString);
             
         }
         
        if(AffRecordType =='Business'){
            bookString.clear();
            whichPBook = 'Catalog Price Book';
            system.debug('<<ORGANIZATION NAME >> '+aff.npe5__Organization__r.Name);
           if (aff.npe5__Organization__r.Name.contains('Christian Book Distributors, LLC')){ // Just testing this name string for now - fake name
               whichPBook = 'Distributor-60';
               
           }
           if (aff.npe5__Organization__r.Name == 'LifeWay'){ // Just testing this name string for now - fake name
            whichPBook = 'Distributor-55';
           }
           if (aff.npe5__Organization__r.Name == 'Calvary Community Journey Resource Center'){ // Just testing this name string for now - fake name
            whichPBook = 'Retailer-40';
           }
            bookString.add(whichPBook);
         }
        //TW_9/1/2016: We need to add Employee PB to any Business unit where missionary Price Books couldbe selected
        //
         if(AffRecordType =='Business Unit') {
           if(aff.Authorized_Purchaser__c == true ){             
             if(aff.Other_Role__c == 'Canada' && (aff.npe5__Organization__r.Name == 'Awana International Canada' || aff.npe5__Organization__r.Mailing_Address_Book__c == '4')){
                 bookString.clear();
                  for( PriceBook2 PriceBook : [SELECT Id, Name FROM PriceBook2 Where isActive = true and Name in ('Catalog Price Book','Retail Pricebook') Order By Name ASC]){                      
                      CompanyPriceBooks.add(PriceBook);
                      bookString.add(PriceBook.Name);   
                      isPriceBookBlank = false;               
                  }
             }else if(aff.Other_Role__c=='Missionary' || aff.Other_Role__c== 'Employee'){
                 bookString.clear();
                 PriceBook2 PriceBook = [SELECT Id, Name FROM PriceBook2 Where isActive = true and Name = 'Partner Price book'];
                 CompanyPriceBooks.add(PriceBook);
                 bookString.add(PriceBook.Name); 
                 isPriceBookBlank = false;
             }
        
           }// Is Authorized?
           system.debug('<< ROLE: >>'+aff.Other_Role__c);
           system.debug('<< PURCHASER: >>'+aff.Authorized_Purchaser__c);
            if(CompanyPriceBooks.size() == 0 && (aff.Other_Role__c== 'Employee' ||  aff.Other_Role__c== 'Missionary')){
              bookString.clear();
              whichPBook = 'Partner Price book';
              bookString.add(whichPBook);
            }
            
            
         }// IF - Business Unit
       
        if(AffRecordType == 'International Church'){
          bookString.clear();
             whichPBook = 'Catalog Price Book';
             bookString.add(whichPBook);
         }
       
         // 1x1 Accounts
         if(AffRecordType == 'Individual'){
           system.debug('<< IN 1X1 SECTION >>');
           List<npe5__Affiliation__c> EmployeeORAwana = new List<npe5__Affiliation__c>();
             EmployeeORAwana = [Select npe5__Organization__r.RecordType.Name, Other_Role__c,npe5__Status__c from npe5__Affiliation__c Where
             npe5__Organization__r.RecordType.Name='Business Unit' and
             (Other_Role__c ='Employee' or Other_Role__c ='Missionary')
             and npe5__Status__c = 'Current'
             and npe5__Contact__r.Id =: ContactId Limit 1];
               
           if(EmployeeORAwana.size() > 0){
             whichPBook = 'Partner Price book';
             bookString.add(whichPBook);
           }
           else{
             bookString.clear();
             whichPBook = 'Retail Pricebook';
             bookString.add(whichPBook);
             system.debug('bookString--'+bookString);
           }
         }
       system.debug('WHICH BOOK : '+ whichPBook);
       if(whichPBook != 'No Price Book' && isPriceBookBlank){
         system.debug('<< bookString >>> '+bookString);
           CompanyPriceBooks.clear();
           for(PriceBook2 PriceBook : [SELECT Id, Name FROM PriceBook2 Where isActive = true and Name in: bookString ORDER By Name ASC]){           
            CompanyPriceBooks.add(PriceBook);
           }
      }      
      system.debug('CompanyPriceBooks: '+CompanyPriceBooks);   
      // Return success, a message, and the list of Ordered Pricebooks
      return new Result(true, 'Success, PriceBooks found.', CompanyPriceBooks);  
   }
    //END 
    
    /* 
     * Method:  AddProduct
     * Inputs:  string SalesforceOpportunityId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     *          string ProductCodeOrSalesforceId - The 15 or 18 character Salesforce ID of a Product or the five digit Product Code.
     *          decimal ProductQuantity - The quantity of the Product to add.
     *          decimal ProductPrice - (Optional) The price of the Product. If provided, this price will over-ride the Product Unit Price. 
     *          string ProductCustomLineType - (Optional) The Line Type of the Product. Typically this is S - Stock Inventory Item or N - Non-Stock
     * Output:  A result object containing Success, a message, and the Opportunity Line Item created.
     * Purpose: To add an Opportunity Line Item (Product) to an Opportunity (Order). After some validation of the inputs, a Pricebook Entry is found using the 
     *            Product Code or Salesforce Id provided. If found, a new Opportunity Line Item is created on the Opportunity.
     * SOQL:    2
     * DML:     3
     */
    webservice static Result AddProduct(string orderId, string ProductCodeOrSalesforceId, 
        decimal ProductQuantity, decimal ProductPrice, decimal PriceDiscount, string PromoCode, string ProductCustomLineType)
    {
        system.debug('<<PRICE OF DISCOUNT BEFORE >> '+PriceDiscount);
        system.debug('<<PRODCUT OF SF ID >> '+ProductCodeOrSalesforceId);
        system.debug('<< PRODUCT PRICE >> '+ProductPrice);
        // If either the Salesforce Opportunity Id argument provided or the Product Code / Product Salesforce Id argument provided is blank
        if(orderId == null || ProductCodeOrSalesforceId == null)
        {
            // Return failure and an error message. 
            return new Result(false,'Please supply both a valid Salesforce Opportunity Id and a valid Salesforce Product Code.');
        }
        
        // If the Product Quantity argument provided is blank
        // Set the Product Quantity to a default value of one
        if(ProductQuantity == null) { ProductQuantity = 1; }
        
        string OriginalProductCodeOrSalesforceId = ProductCodeOrSalesforceId;
        
        // Call the Get Order web service (OrderEntryServicesDummy.GetOrder) using the Opportunity Salesforce Id provided. 
        Order Ordr = OrderEntryServicesDummy.GetOrder1(orderId);
        // If an Order was not found, return failure and an error message.
        if(Ordr == null) { return new Result(false,'Please supply a valid Opportunity (15 or 18 character) Salesforce Id.'); }
        
        // Otherwise (an Order was found)
        if(Ordr != null)
        {
            // Try to
            try
            {
                // Convert the provided Product Code or Product Salesforce Id argument to a Salesforce Id
                ID ValidId = ProductCodeOrSalesforceId;
            }
            // If an error occurred while converting to a Salesforce Id
            // The Product Code or Product Salesforce Id argument must be either a Product search term or a Product Code.
            catch(Exception exc)
            {
                List<Product2> products = null;
                
                // If the Product Code or Product Salesforce Id argument is only numbers
                if(Pattern.matches('[0-9]*',ProductCodeOrSalesforceId.trim()))
                {
                    // And if it is not five digits or more
                    if(!Pattern.matches('[0-9]{5}[0-9]*',ProductCodeOrSalesforceId.trim()))
                    {
                        // Return failure and an error message. The product number (or code) provided needs to be 5 digits.
                        return new Result(false,'The product number (or code) provided needs to be 5 digits.');
                    }
                    
                    products = [Select Id From Product2 Where  isActive = true and ProductCode = :ProductCodeOrSalesforceId];
                }
                // Otherwise (else) (Product Code is not only numbers)
                else
                {
                    // Call the Find Product web service to get a list of Products that match the provided Product Code or Product Salesforce Id argument.
                    products = OrderEntryServicesDummy.FindProduct(ProductCodeOrSalesforceId);
                }
                
                // If one or more Products were found
                // Over-write the Product Code or Product Salesforce Id argument with the first returned Product Salesforce Id
                if(!products.isEmpty()) { ProductCodeOrSalesforceId = products[0].Id; }
            }
            
            // Find the full data for the Product by looking up the Pricebook Entry using the Product Salesforce Id and the Opportunity (Order) Pricebook Id. 
            PriceBookEntry ProductPriceBookEntry = null;
            //system.debug('Ordr.PriceBook2Id---'+Ordr.PriceBook2Id);
            //system.debug('ProductCodeOrSalesforceId---'+ProductCodeOrSalesforceId);
            List<PriceBookEntry> MatchingPriceBookEntries = 
                [Select Id, Name, PriceBook2.Id, Product2.ProductCode, Product2.Name,Product2.No_of_Issues__c,Product2.List_Price__c,Product2.Downloadable_Product_URL__c,
                    UnitPrice, Product2.Description, Product2.Quantity__c, Product2.preOrder_backOrder_Handling__c,Product2.Weight__c, 
                    Product2.Line_Type__c, Product2.IsActive, Product2.Non_Inventory_Item__c 
                From PriceBookEntry 
                Where PriceBook2.Id = :Ordr.PriceBook2Id     
                And Product2.Id = :ProductCodeOrSalesforceId 
                And IsActive = true];
            
            //string ProductCode = MatchingPriceBookEntries.Product2.ProductCode;
            if(!MatchingPriceBookEntries.isEmpty()) { ProductPriceBookEntry = MatchingPriceBookEntries[0]; }
            system.debug('<< 2 -- PRODUCT PRICE >> '+ProductPrice);
            // If a Pricebook Entry was found
            if(ProductPriceBookEntry != null)
            {
                // If the associated product (to the Pricebook Entry) is not blank.
                if(ProductPriceBookEntry.Product2 != null)
                {
                    // If there is less than one product in stock (zero or less Quantity__c on Product2).
                    if(ProductPriceBookEntry.Product2.Quantity__c <= 0)
                    {
                        // If the preOrder_backOrder_Handling__c field is set to none (meaning none can be pre-ordered or back-ordered). 
                        if(ProductPriceBookEntry.Product2.preOrder_backOrder_Handling__c == 'none')
                        {
                            // Return failure and an error message.
                            return new Result(false,'That product ("'+OriginalProductCodeOrSalesforceId+'") is out of stock. ' 
                                + 'It could not be added to the Opportunity.'); 
                        }
                    }
                }
                
                String SetLineType = null;
                
                // If a Custom Line Type argument was not provided (if it is blank) 
                if(ProductCustomLineType == null) {
                    // Use the Line Type of the Product on the found Pricebook Entry
                    SetLineType = ProductPriceBookEntry.Product2.Line_Type__c;
                // Otherwise (else)
                // Use the Custom Line Type argument provided
                } else { SetLineType = ProductCustomLineType; }
                
                
                // If the Order Payment Terms is not blank
                if(Ordr.Payment_Terms__c != null)
                {
                    // If the Order Payment Terms is Sales Credit
                    
                    if(Ordr.Payment_Terms__c.toLowerCase().contains('sales credit'))
                    {  
                        // If the Product Price is greater than zero
                        if(ProductPrice > 0)
                        { // Set the Product Price to the negative value of the Product Price
                            ProductPrice = ProductPrice * -1;
                        }
                    }//TW 8-10-13 Get Discounted product price by deducting unit price discount from PriceBook Unit price if not Freight discount, else set Price Discount as $0.00
                    
                   else{
                            if(PriceDiscount != null && PriceDiscount > 0){
                                    if(PriceDiscount > 0){
                                        ProductPrice = ProductPrice - (PriceDiscount);
                                    }                            
                                    
                            }
                            else{
                                PriceDiscount = 0;
                                
                            }
                    }
                }
                // Create a new Opportunity Line Item using the provided or set arguments (for Quantity, PricebookEntryId, UnitPrice, OpportunityId, and Line_Type__c)
               //TW: 8-13-2013 : Added conditionalLine Item Discount to update Promo Code (including Free Shipping)
              system.debug('<<PRICE OF DISCOUNT BEFORE OLI>> '+PriceDiscount );
              //TW: 04-01-2014: UPdated the UnitPrice Assignment in the following Line item code to contain the Pricebook's unit price and not the default catalog price.
          if(ProductPricebookEntry.Product2.Weight__c == null){ProductPricebookEntry.Product2.Weight__c = 0;}
          OrderItem LineItem = new OrderItem(
                        Quantity            = ProductQuantity, 
                        PricebookEntryId    = ProductPriceBookEntry.Id, 
                        OrderId       = ordr.Id, 
                        Line_Type__c        = SetLineType,
                        Price_of_Discount__c = PriceDiscount,
                        UnitPrice = ProductPrice,
                        Promo_Code__c =PromoCode,
                        Downloadable_Product_URL__c =  ProductPriceBookEntry.Product2.Downloadable_Product_URL__c,
                        PreOrder_Backorder_Handling__c= ProductPriceBookEntry.Product2.PreOrder_Backorder_Handling__c,
                        Estimated_Weight__c = ProductPricebookEntry.Product2.Weight__c * ProductQuantity
                    );
               if(SetLineType.toLowerCase().startsWith('f')  || SetLineType.toLowerCase().startsWith('t') ){
                   LineItem.UnitPrice = ProductPrice;
               }
               system.debug('<< ADDPRODUCT>> Estimated Price per Item: '+LineItem.Estimated_Weight__c);
               system.debug('<< DOWNLOADABLE>> '+ProductPriceBookEntry.Product2.Downloadable_Product_URL__c);
                system.debug('<<PREORDER>> '+ProductPriceBookEntry.Product2.PreOrder_Backorder_Handling__c+' FOR ORDER: '+Ordr.Name);
                system.debug('<<PRICE OF DISCOUNT>> '+LineItem.Price_of_Discount__c );
                system.debug('<<SALES PRICE>> '+LineItem.UnitPrice);
                // If the line type is freight (delivery)
                if(LineItem.Line_Type__c.toLowerCase().startsWith('f'))
                {
                    // Call the GetOrderLineItems web service
                    List<OrderItem> AllOrderLineItems = GetOrderLineItems1(Ordr.Id);
                    
                    // For each Line Item found
                    
                    for(OrderItem FindLineItem : AllOrderLineItems)
                    {
                       // If the Line Type starts with F (for Freight)
                        if(FindLineItem.Line_Type__c.toLowerCase().startsWith('f')) 
                        {
                            //TW: 8-13-2013 : This segment for Discount and Promo Code helps to display the FRT discount list price in O.E.
                            if(PriceDiscount > 0){
                                system.debug('ORIGINAL FRT PRICE: '+FindLineItem.UnitPrice);
                                LineItem.UnitPrice = FindLineItem.UnitPrice - PriceDiscount;
                            }
                           
                            // Try to delete the Line Item.
                            try { delete FindLineItem; } catch(Exception ex) { }
                        }
                    }
                }
                
                // If the line type is tax
                if(LineItem.Line_Type__c.toLowerCase().startsWith('t'))
                {
                    // Call the GetOrderLineItems web service
                    List<OrderItem> AllOrderLineItems = GetOrderLineItems1(Ordr.Id);
                    
                    // For each Line Item found
                    for(OrderItem FindLineItem : AllOrderLineItems)
                    {
                        // If the Line Type starts with T (for Tax)
                        if(FindLineItem.Line_Type__c.toLowerCase().startsWith('t')) 
                        {
                            // Try to delete the Line Item.
                            try { delete FindLineItem; } catch(Exception ex) { }
                        }
                    }
                    
                    
                }
                 else{
                   LineItem.UnitPrice = ProductPrice;
                   system.debug('<< 3 -- PRODUCT PRICE >> '+ProductPrice);
                 }
                // Note: The Line Type will always be only one of the previous two conditions. 
                //   Efficiency is not hindered by having two separate IF statements with a call to a web service in each.
                
                  // Save (Insert) the new Opportunity Line Item.
                insert LineItem;
                system.debug('<<ADDPRODUCT-LI>> '+LineItem);
                //<ASP-874> - If the line item's product child has a downloadable url string then update the Order's Has Downloadable Items field to true
                
                // Call the GetOrderLineItems web service to find the newly saved Line Item. 
                List<OrderItem> LineItems = GetOrderLineItems1(LineItem.Id);
                
                // If the Line Item was found, save it in a variable to be returned.
                if(!LineItems.isEmpty()) { LineItem = LineItems[0]; } 
               
                // Return success, a message, and the saved Line Item.
                return new Result(true,'Product ("'+OriginalProductCodeOrSalesforceId+'") Successfully Added. ',LineItem);
            }
            // Otherwise (else) (The Pricebook Entry was not found.)
            else
            {
                // Return failure and an error message.        
                List<Product2> product = new List<Product2>();          
                product = [Select Id,ProductCode From Product2 Where  isActive = true and (Id = :ProductCodeOrSalesforceId OR ProductCode =: ProductCodeOrSalesforceId)];
                if(!product.isempty()){
                    return new Result(false,'An active PriceBook Entry does not exist for Product ("'+product[0].ProductCode+'"). This product cannot be added to this Order. Please contact the Salesforce System Administrator with any questions.'); 
                }else{
                    return new Result(false,'The product you tried to enter ("'+ProductCodeOrSalesforceId+'") does not exist in Salesforce.  This product cannot be added to this Order. Please contact the Salesforce System Administrator with any questions.'); 
                }  
            }
        }
        // Otherwise (else) (The Order was not found)
        else
        {
            // Return failure and an error message.
            return new Result(false,'The Opportunity/Order Id provided is not valid.');
        }
        
        // If there was an unexpected error
        // Return failure and an error message.
        //return new Result(false,'An unexpected error occurred while adding Product:"'+OriginalProductCodeOrSalesforceId+'".');
    }
    
    /* 
     * Method:  RemoveProduct
     * Inputs:  OrderItemId - The Salesforce ID of an OpportunityLineItem. This is used to lookup a Line Item on an Order to remove it.
     * Output:  A result object containing Success and a message
     * Purpose: To remove (delete) a Line Item (Product) from an Order
     * SOQL:    0
     * DML:     1
     * UPDATED FOR MIGRATION OF OPPORTUNITY TO ORDER
     */
    webservice static Result RemoveProduct(string orderItemId)
    {
        ID OrderLineItemSalesforceId = null;
        
        // Try to
        try
        {
            // Convert the OpportunityLineItemSalesforceId argument provided to a Salesforce ID variable.
            OrderLineItemSalesforceId = orderItemId;
        }
        // If there was an error converting
        catch(Exception exc)
        {
            // The OpportunityLineItemSalesforceId argument provided must be invalid or not an ID of a Salesforce record
            // Return the failure and an error message
            return new Result(false,'The Opportunity Line Item (Product) Salesforce Id provided is not valid.');
        }
        
        // If the OpportunityLineItemSalesforceId is not blank
        if(OrderLineItemSalesforceId != null)
        {
            // Initialize a new Line Item variable with the OpportunityLineItemSalesforceId argument provided
            OrderItem Line = new OrderItem(Id=OrderLineItemSalesforceId);
            
            // Try to
            try
            {
                // Delete the Line Item
                delete Line;
            }
            // If there was an error deleting
            catch(Exception exc)
            {
                // Return failure and an error message
                return new Result(false,'An unexpected error occurred while deleting the Opportunity Line Item. Error: '+exc.getMessage());
            }
            
            // Otherwise
            // Return success and a message
            return new Result(true,'Successfully removed the Opportunity Line Item with Id='+OrderLineItemSalesforceId+'.');
        }
        
        // If an unexpected error occurred
        // Return failure and an error message
        return new Result(false,'An unexpected error occurred while deleting the Opportunity Line Item. ');
    }
    
    /* 
     * Method:  RemoveFreightAndTax
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  A result object containing Success and a message
     * Purpose: To call the RemoveSomeProducts web service and sending a list containing the Freight and Tax Line Types.
     * Given the Freight and Tax line types the RemoveSomeProducts web service would remove any existing Freight and/or Tax line.
     * SOQL:    1
     * DML:     1
     * UPDATED FOR MIGRATION OF OPPORTUNITY TO ORDER
     */
    webservice static Result RemoveFreightAndTax(string orderId)
    {
        // Create a new list of strings variable containing the Freight and Tax line types
        List<string> FreightAndTaxLineTypes = new List<string>{'F - Freight','T - Text'};
        
        // Call RemoveSomeProducts web service sending the OpportunitySalesforceId argument provided as well as the list of freight and tax line types.
        // Return the result from the RemoveSomeProducts web service.
        return RemoveSomeProducts(orderId,FreightAndTaxLineTypes);
    }
    
    /* 
     * Method:  RemoveAllProducts
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  A result object containing Success and a message
     * Purpose: To call the RemoveSomeProducts web service sending no Line Types. With no Line Types provided, RemoveSomeProducts removes all Line Items.
     * SOQL:    1
     * DML:     1
     * UPDATED FOR MIGRATION OF OPPORTUNITY TO ORDER
     */
    webservice static Result RemoveAllProducts(string orderId)
    {
        // Call RemoveSomeProducts web service sending the OpportunitySalesforceId argument provided as well as a blank value for line types.
        // Return the result from the RemoveSomeProducts web service.
        return RemoveSomeProducts(orderId, null);
    }
    
    /* 
     * Method:  RemoveSomeProducts
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order
     *          List<string> LineTypes - A list of Line Types for the Line Items (Products) to remove
     * Output:  A result object containing Success and a message
     * Purpose: To remove the products specified by Line Type (in the LineTypes argument provided) or all Line Items (Products) for a given Opportunity.
     * SOQL:    1
     * DML:     1
     * UPDATED FOR MIGRATION OF OPPORTUNITY TO ORDER
     */
    webservice static Result RemoveSomeProducts(string orderId, List<string> LineTypes)
    {
        ID TempOrderId = null; 
        orderId = String.escapeSingleQuotes(orderId);
        
        // Try to
        try
        {
            // Convert the OpportunitySalesforceId argument provided to a Salesforce ID
            TempOrderId = orderId;
        }
        // If converting fails
        catch(Exception exc)
        {
            // Return failure and an error message.
            return new Result(false,'The Opportunity/Order Id provided is not valid.');
        }
        
        // If the OpportunitySalesforceId argument provided is not blank
        if(orderId != null)
        {
            string query = 'Select Id From OrderItem Where OrderId = \''+orderId+'\' ';
            
            // If the list of Line Types argument is not blank
            if(LineTypes != null)
            {
                query += ' and Line_Type__c in (';
                
                // Find all Products that match the Line Types provided in the list of Line Types argument.
                for(string LineType : LineTypes)
                {
                    query += '\''+ LineType +'\',';
                }
                
                query = query.substring(0,query.length()-1); // remove last comma
                
                query += ') ';
            }
            // Otherwise
            // Find all Line Items (Products) for the Opportunity with the Id provided in the OpportunitySalesforceId argument.
            
            system.debug(query);
            List<OrderItem> Lines = Database.query(query);
            system.debug(lines);
            
            // Try to
            try
            {
                // Delete the Line Items (Products) found.
                delete Lines;
            }
            // If an error occurred while trying to delete the Line Items 
            catch(Exception exc)
            {
                // Return failure and an error message.
                return new Result(false,'An unexpected error occurred while deleting Opportunity Line Items for the Opportunity (with Id='+
                    OrderId+'). Error: '+exc.getMessage());
            }
            
            // Otherwise (an error deleting did not occur)
            // Return success and a message.
            return new Result(true,'Successfully removed all Opportunity Line Items ' 
                + (LineTypes == null ? '' : '(with the specified line types)') 
                + ' for the Opportunity (with Id='+orderId+').');
        }
        
        // If an unexpected error occurred
        // Return failure and an error message.
        return new Result(false,'An unexpected error occurred while deleting Opportunity Line Items for the Opportunity (with Id provided). ');
    }
    
    /* 
     * Method:  FindProduct
     * Inputs:  string ProductSearchTerm - The term used to find a product (this could be any field on the Product2 record)
     * Output:  A list of Products (Product2) that were found.
     * Purpose: To find a Product (Product2) by the search term provided.
     * SOQL:    0
     * DML:     0
     */
    webservice static List<Product2> FindProduct(string ProductSearchTerm)
    {
        // Using Salesforce object search language (SOSL), search for the Product.
        // TW: 9-06-2012: Added a WHERE clause in the search filter to only select active products.
        //system.debug(ProductSearchTerm);
        List<List<sObject>> searchList = [FIND :ProductSearchTerm RETURNING Product2 (Id, ProductCode, Name  WHERE IsActive = true Order By Name)];
        //system.debug(searchList);
        return searchList[0]; // Return all found Products, or none, whatever is returned form the search.
    }
    
    /* 
     * Method:  FindProductWithPriceBook
     * Inputs:  string ProductSearchTerm - The term used to find a product (this could be any field on the Product2 record), String pricebook Name which is used in the order
     * Output:  A list of Products (Product2) that were found.
     * Purpose: To find a Product (Product2) by the search term provided.
     * SOQL:    0
     * DML:     0
     * Author:  Mayur Soni
     */
    webservice static List<Product2> FindProductWithPriceBook(string ProductSearchTerm,String pricebookName)
    {
        // Using Salesforce object search language (SOSL), search for the Product.
        // TW: 9-06-2012: Added a WHERE clause in the search filter to only select active products which are added in the given Pricebook id .
        List<Product2> searchList = new List<Product2>();
        if(ProductSearchTerm.isNumeric()){
            searchList = [SELECT Id,ProductCode,Name FROM Product2 WHERE ProductCode=:ProductSearchTerm AND IsActive=true ORDER BY Name]; 
              
        }else{
            String temp = '%'+ProductSearchTerm+'%';
            searchList = [SELECT Id,ProductCode,Name FROM Product2 WHERE Name like :temp AND IsActive=true ORDER BY Name]; 
            
        } 

        return searchList;
    }
   
   /* 
     * Method:  loadAffiliations
     * Inputs:  string Contact ID - The contact associated with an Affiliate
     * Output:  A list of Accounts that were found based on the Affiliates that point to them
     * Purpose: To find an Accounts from the Contact Id provided using their affiliation structures.
     * SOQL:    0
     * DML:     0
     */
     
   webservice static Result loadAffiliations(string ContactId)
   {
       
       List<npe5__Affiliation__c> affiliates = new List<npe5__Affiliation__c>();
      
       RecordType recordBU = [Select Id from RecordType where Name = 'Business Unit' limit 1];
       List<Account> accts = new List<Account>();
       system.debug('Affiliates: '+affiliates);
       List<String> Ids_with_Names = new List<String>();
       String someId_And_Name = '';
       List<String> ids  = new List<String>();      
       for(npe5__Affiliation__c affs :  [Select Authorized_Purchaser__c,Other_Role__c, npe5__Organization__r.Id,npe5__Organization__r.Name,npe5__Organization__r.RecordTypeId,npe5__Organization__r.RecordType.Name  from  npe5__Affiliation__c WHERE npe5__Contact__c =:ContactId and npe5__Status__c = 'Current' and npe5__Organization__r.RecordType.Name != 'International Church']){
         if(affs.Authorized_Purchaser__c == true  || ( affs.npe5__Organization__r.RecordTypeId == recordBU.Id  && (affs.Other_Role__c == 'Missionary' || affs.Other_Role__c =='Employee'))){
            
                ids.add(String.valueOf(affs.npe5__Organization__r.Id));
            
         }
       }
       system.debug('<<IDS:>> '+ids);
       
       if(ids.size() == 0)
       {
          // Return failure and an error message.
         return  new Result(false, 'No Affiliates found');
       }
       accts = [Select Id, Name,Type,RecordTypeId from Account where Id in: ids];
       system.debug('ACCTS DERIVED :'+accts);
       
       if(accts.size() == 0){
         // Return fapilure and an error message.
         return  new Result(false, 'No Affiliates found');
       }
       
       return  new Result(true, 'Found Affiliates for Contact with Id:'+ContactId+'.', accts);
  }
    
   
    /* 
     * Method:  GetAddressCountries
     * Inputs:  None
     * Output:  A result object containing success or failure and a message
     * Purpose: Finds all valid Countries
     * SOQL:    1
     * DML:     0
     */
    webservice static Result GetAddressCountries()
    {
        // Find all Countries listed in the Country__c object 
        List<Country__c> countries = [select Id, Name from Country__c order by name asc];
        
        // If no Countries were found
        // Return failure and an error message
        if(countries.isEmpty()) { return new Result(false,'An unexpected error occurred getting the country names.'); }
        // Otherwise (else)
        // Return success, a message, and the Countries found
        else { return new Result(true,'Success',countries); }
    }
    
    /* 
     * Method:  AddAddress
     * Inputs:  string AccountSalesforceId - The Salesforce ID of an Account
     *          string FirstName - The First Name to record on the new Address 
     *          string LastName - The Last Name to record on the new Address
     *          string AddressLineOne
     *          string AddressLineTwo
     *          string City
     *          string State
     *          string ZipCode
     *          string County
     *          string Country
     * Output:  A result object containing success or failure and a message
     * Purpose: To add a new Address (Address__c) related to an Account.
     * SOQL:    0
     * DML:     1
     */
    webservice static Result AddAddress(string AccountSalesforceId, string FirstName, string LastName, 
        string AddressLineOne, string AddressLineTwo, string City, string State, string ZipCode, string County, string Country)
    {
        // If the Account Salesforce Id, Address Line One, City, State, or Zip Code are blank
        if(AccountSalesforceId == null || AddressLineOne == null || City == null || State == null || ZipCode == null) 
        { 
            // Return failure and an error message
            return new Result(false, 'Account, Address Line One, City, State, and Zip Code must contain a value.'); 
        }
        
        // Try to 
        try
        {
            // Convert the Account Salesforce Id to a Salesforce ID variable
            ID ValidatedAccountId = AccountSalesforceId;
        } 
        // If there was an error converting
        catch(Exception ex) 
        { 
            // Return failure and an error message
            return new Result(false, 'Please supply a valid Account (15 or 18 character) Salesforce Id.'); 
        }
        
        // Create a new Address variable using the arguments provided (Account Salesforce Id, First Name, Last Name, Address Line One, Address Line Two, City, State, Zip Code, County, and Country)
        Address__c new_address = new Address__c(Account__c=AccountSalesforceId, Default_Shipping_Address__c=false, First_Name__c=FirstName, Last_Name__c=LastName,  
            Address_Line_1__c=AddressLineOne, Address_Line_2__c=AddressLineTwo, City__c=City, State__c=State, Zip_Code__c=ZipCode, 
            County__c=County, Country__c=Country);
        
        system.debug('Catching NULL FNAME '+FirstName );
        // Try to
        try
        {
            // Save (insert) the new Address
            insert new_address;
            // If the new Address saved successfully
            // Return success, a message, and the new Address
            return new Result(true,'Success. The Opportunity/Order Billing Address has been updated.',new_address);
        } 
        // If an error occurred while saving the new Address
        catch(Exception ex) 
        { 
            // Return failure and an error message
            return new Result(false, 'An error occurred while adding a new address. Error Message: '+ex.getMessage()); 
        }
        
        // If an unexpected error occurred
        // Return failure and an error message
        //return new Result(false,'An unexpected error occurred while adding a new address.');
    }
    
     /* 
     * Method:  UpdateOrderBillingPhone
     * Inputs:  string SalesforceOrderId - The Salesforce Id of an order. This is used to lookup an Order
     *          string SalesforcePhone - The Salesforce value of an Phone to be copied to the Order
     * Output:  A result object containing success or failure and a message
     * Purpose: To copy the address information stored in an Address record to the Billing Address on an Order.
     * SOQL:    2
     * DML:     1
     */
    webservice static Result UpdateOrderBillingPhone(string OrderId, string SalesforcePhone)
    {
         // Call the GetOrder web service to find the Order using the Salesforce Opportunity Id provided.
        Order Ordr = GetOrder1(orderId);
        // If the Order was not found
        // Return failure and an error message.
        if(Ordr == null) { return new Result(false,'Please supply a valid Order Salesforce Id.'); }
        Ordr.Billing_Phone__c = SalesforcePhone;
        // Try to
        try
        {
            // Save (update) the Order
            update Ordr;
            update Ordr.Chargent_Order__r;
            // If the save was successful
            // Return success and a message
            return new Result(true,'Success. The Order Billing Phone has been updated.',Ordr);
        }
        // If an error occurred while saving the Order
        catch(Exception exc) 
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred while updating the Order Billing Phone. Error Message: '+exc.getMessage());
        }
        
        // If an unexpected error occurred
        // Return failure and an error message.*/
        //return new Result(false,'An unexpected error occurred while updating the Order Billing Phone.');

    }
    /* 
     * Method:  UpdateOrderBillingAddress
     * Inputs:  string SalesforceOpportunityId - The Salesforce Id of an Opportunity. This is used to lookup an Order
     *          string SalesforceAddressId - The Salesforce Id of an Address to be copied to the Order
     * Output:  A result object containing success or failure and a message
     * Purpose: To copy the address information stored in an Address record to the Billing Address on an Order.
     * SOQL:    2
     * DML:     1
     */
    webservice static Result UpdateOrderBillingAddress(string OrderId, string SalesforceAddressId)
    {
        system.debug(orderId);
        system.debug(SalesforceAddressId);
        
        ID OrdrId = null, AddressId = null;
        
        // Try to
        try
        {
            // Convert the Salesforce Opportunity Id and the Salesforce Address Id to Salesforce Ids.
            OrdrId = orderId;
            AddressId = SalesforceAddressId;
        }
        // If an error occurred while converting
        catch(Exception ex)
        {
            // Return failure and an error message
            return new Result(false,'Please supply a valid Order or Address (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage());
        }
        
        // Call the GetOrder web service to find the Order using the Salesforce Opportunity Id provided.
        Order Ordr = GetOrder1(orderId);
        // If the Order was not found
        // Return failure and an error message.
        if(Ordr == null) { return new Result(false,'Please supply a valid Order Salesforce Id.'); }
        
        // Call the GetAddress web service to find the Address using the Salesforce Address Id provided.
        Address__c Address = GetAddress(SalesforceAddressId);
        // If the Address was not found
        // Return failure and an error message.
        if(Address == null) { return new Result(false,'Please supply a valid Address Salesforce Id.'); }
        
        // Copy the Address (Id, First_Name__c, Last_Name__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, and Country__c)
        //   to the Order billing address (Billing_Address__c, ChargentSFA__Billing_First__c, ChargentSFA__Billing_Last__c, ChargentSFA__Billing_Address__c, 
        //   ChargentSFA__Billing_City__c, ChargentSFA__Billing_State__c, ChargentSFA__Billing_Zip__c, Billing_County__c, ChargentSFA__Billing_Country__c)
        Ordr.Billing_Address__c = Address.Id;
        Ordr.Chargent_Order__r.ChargentOrders__Billing_First_Name__c = Address.First_Name__c;
        Ordr.Chargent_Order__r.ChargentOrders__Billing_Last_Name__c = Address.Last_Name__c;
        if(Address.Address_Line_1__c != null && Address.Address_Line_2__c != null) {
            Ordr.Chargent_Order__r.ChargentOrders__Billing_Address__c = Address.Address_Line_1__c + '\n' + Address.Address_Line_2__c; }
        else if(Address.Address_Line_1__c != null) {
            Ordr.Chargent_Order__r.ChargentOrders__Billing_Address__c = Address.Address_Line_1__c; }
        else {
            Ordr.Chargent_Order__r.ChargentOrders__Billing_Address__c = null; }
        Ordr.Chargent_Order__r.ChargentOrders__Billing_City__c = Address.City__c;
        Ordr.Chargent_Order__r.ChargentOrders__Billing_State__c = Address.State__c;
        Ordr.Chargent_Order__r.ChargentOrders__Billing_Zip_Postal__c = Address.Zip_Code__c;
        Ordr.Billing_County__c = Address.County__c;
        Ordr.Chargent_Order__r.ChargentOrders__Billing_Country__c = Address.Country__c;
        
        // Try to
        try
        {
            // Save (update) the Order
            update Ordr;
            update Ordr.Chargent_Order__r;
            // If the save was successful
            // Return success and a message
            return new Result(true,'Success. The Order Billing Address has been updated.',Address);
        }
        // If an error occurred while saving the Order
        catch(Exception exc) 
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred while updating the Order Billing Address. Error Message: '+exc.getMessage());
        }
        
        // If an unexpected error occurred
        // Return failure and an error message.*/
        //return new Result(false,'An unexpected error occurred while updating the Order Billing Address.');
    }
    
    /* 
     * Method:  UpdateOrderShippingAddress
     * Inputs:  string SalesforceOpportunityId - The Salesforce Id of an Opportunity. This is used to lookup an Order.
     *          string SalesforceAddressId - The Salesforce Id of an Address to be copied to the Order
     * Output:  A result object containing success or failure and a message
     * Purpose: To copy the address information stored in an Address record to the Shipping Address on an Order.
     * SOQL:    2
     * DML:     1
     */
    webservice static Result UpdateOrderShippingAddress(string OrderId, string SalesforceAddressId)
    {
        system.debug(OrderId);
        system.debug(SalesforceAddressId);
        
        ID OrdId = null, AddressId = null;
        
        // Try to
        try
        {
            // Convert the Salesforce Opportunity Id and the Salesforce Address Id to Salesforce Ids.
            OrdId = OrderId;
            AddressId = SalesforceAddressId;
        }
        // If an error occurred while converting
        catch(Exception ex)
        {
            // Return failure and an error message
            return new Result(false,'Please supply a valid Order or Address (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage());
        }
        
        // Call the GetOrder web service to find the Order using the Salesforce Opportunity Id provided.
        Order Ord = GetOrder1(OrderId);
        // If the Order was not found
        // Return failure and an error message.
        if(Ord == null) { return new Result(false,'Please supply a valid Order Salesforce Id.'); }
        
        // Call the GetAddress web service to find the Address using the Salesforce Address Id provided.
        Address__c Address = GetAddress(SalesforceAddressId);
        // If the Address was not found
        // Return failure and an error message.
        if(Address == null) { return new Result(false,'Please supply a valid Address Salesforce Id.'); }
        
        // Copy the Address (Id, First_Name__c, Last_Name__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, and Country__c)
        //   to the Order Shipping Address (Shipping_Address__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, Ship_to_Name__c, Shipping_Street__c, 
        //   Shipping_City__c, Shipping_State__c, Shipping_Zip_Code__c, Shipping_County__c, Shipping_Country__c)
        Ord.Shipping_Address__c = Address.Id;
        //TW 3-26-2014:  Remove all nulls from first name 
        if(Address.First_Name__c == null || Address.First_Name__c.contains('null')){Address.First_Name__c='To: ';}
        system.debug('ADDRESS FNAME: '+Address.First_Name__c);
        Ord.Ship_to_First_Name__c = Address.First_Name__c;
        Ord.Ship_to_Last_Name__c = Address.Last_Name__c;
        Ord.Ship_to_Name__c = Address.First_Name__c + ' ' + Address.Last_Name__c;
        if(Address.Address_Line_1__c != null && Address.Address_Line_2__c != null) {
            Ord.Shipping_Street__c = Address.Address_Line_1__c + '\n' + Address.Address_Line_2__c; }
        else if(Address.Address_Line_1__c != null) { 
            Ord.Shipping_Street__c = Address.Address_Line_1__c; }
        else { 
            Ord.Shipping_Street__c = null; }
        Ord.Shipping_City__c = Address.City__c;
        Ord.Shipping_State__c = Address.State__c;
        Ord.Shipping_Zip_Code__c = Address.Zip_Code__c;
        Ord.Shipping_County__c = Address.County__c;
        Ord.Shipping_Country__c = Address.Country__c;
        
        // Try to
        try
        {
            // Save (update) the Order
            update Ord;
            // If the save was successful
            // Return success and a message
            return new Result(true,'Success. The Opportunity/Order Billing Address has been updated.',Address);
        }
        // If an error occurred while saving the Order
        catch(Exception exc) 
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred while updating the Opportunity/Order Billing Address. Error Message: '+exc.getMessage());
        }
        
        // If an unexpected error occurred
        // Return failure and an error message.
        //return new Result(false,'An unexpected error occurred while updating the Opportunity/Order Billing Address.');
    }
    
    /* 
     * Method:  RemoveAddress
     * Inputs:  string SalesforceAddressId - The Salesforce Id of an Address to be copied to the Order
     * Output:  A result object containing success or failure and a message
     * Purpose: To remove an address from displaying in Order Entry.
     * SOQL:    1
     * DML:     1
     */
    webservice static Result RemoveAddress(string SalesforceAddressId)
    {
        // Call the GetAddress web service to find the Address using the Salesforce Address Id provided.
        Address__c Address = GetAddress(SalesforceAddressId);
        // If the Address was not found
        // Return failure and an error message.
        if(Address == null) { return new Result(false,'Please supply a valid Address Salesforce Id.'); }
        
        // Try to
        try
        {
            // Set the Show in Order Entry field on the Address to false
            Address.Show_in_Order_Entry__c = false;
            // Save (update) the Addrss
            update Address;
            // Return success and a message
            return new Result(true, 'Address with Salesforce ID: '+SalesforceAddressId+' has been removed. ');
        }
        // If an error occurred while saving the Address
        // Return failure and an error message.
        catch(Exception ex) { return new Result(false,'An error occurred while removing address with Salesforce ID: '+SalesforceAddressId+'. Error message: '+ex.getMessage()); }
    }
    
    /* 
     * Method:  UpdateCreditCard
     * Inputs:  string SalesforceOrderId - The Salesforce Id of an Opportunity. This is used to lookup an Order
     *          string CreditCardType - Visa, Mastercard, or Discover
     *          string CreditCardName
     *          string CreditCardNumber
     *          string CreditCardMonth - Two digit month
     *          string CreditCardYear - Four digit year
     *          string CreditCardSecurity - Three digit security code
     * Output:  A result object containing success or failure and a message
     * Purpose: To update an Order with the Credit Card information provided.
     * SOQL:    0
     * DML:     1
     */
    webservice static Result UpdateCreditCard(string OrderId, string CreditCardType, string CreditCardName, 
        string CreditCardNumber, string CreditCardMonth, string CreditCardYear, string CreditCardSecurity)
    {
        
        // Try to 
        try
        {
            // Convert the Salesforce Opportunity Id to Salesforce Id.
            ID ValidatedOrderId = OrderId;
        // If there was an error converting
        // Return failure and an error message
        } catch(Exception ex) { return new Result(false,'Please supply a valid Order (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage()); }
        
        // Create an Order variable using the Order ID argument provided 
         Order Ord = OrderEntryServicesDummy.GetOrder1(OrderId);
        
        // Set the Order Payment Terms (Payment_Terms__c) and the Chargent Payment Method (ChargentSFA__Payment_Method__c) to Credit Card.
        Ord.Payment_Terms__c = 'Credit Card';
        Ord.Chargent_Order__r.ChargentOrders__Payment_Method__c =  'Credit Card';
        
        
        // Set the Chargent Card Type (ChargentSFA__Card_Type__c) to the Credit Card Type argument provided. 
        Ord.Chargent_Order__r.ChargentOrders__Card_Type__c = CreditCardType;
        // For each argument provided, if the argument does not contain a * (meaning the field is encrypted)
        // Set the Order Credit Card fields (ChargentSFA__Card_Name__c, ChargentSFA__Card_Number__c, ChargentSFA__Card_Month__c, ChargentSFA__Card_Year__c, ChargentSFA__Card_Security__c) 
        //   to the respective Credit Card arguments provided.
        system.debug('*CreditCardName*'+CreditCardName);

        if(!CreditCardNumber.contains('*')) { Ord.Chargent_Order__r.ChargentOrders__Card_Number__c = CreditCardNumber; }
        if(!CreditCardMonth.contains('*')) { Ord.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c = CreditCardMonth; }
        if(!CreditCardYear.contains('*')) { Ord.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c = CreditCardYear; }

        
        // Try to 
        try
        {
            // Save (update) the Order
            update Ord;
            update Ord.Chargent_Order__r;
        // If an error occurred saving the order
        // Return failure and an error message.
        } catch(Exception ex) { return new Result(false,'The update of Order (with ID='+OrderId+') failed. Error Message: '+ex.getMessage()); }
        
        // Otherwise (save was successful)
        // Return success and a message.
        return new Result(true,'Success, the Credit Card information has been updated. Order Credit Card Year: ' + Ord.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c + '. Input CC Year: ' + CreditCardYear);
    }
    
    /* 
     * Method:  AuthorizeCreditCard
     * Inputs:  string OpportunitySalesforceId - A Salesforce Id of an Opportunity
     * Output:  A result object containing success or failure and a message
     * Purpose: To authorize a Credit Card using Paypal or Authorize.net (depending on the Gateway Id listed on the Opportunity).
     * SOQL:    3
     * DML:     1
     */
    webservice static Result AuthorizeCreditCard(string OrderId) 
    {
        ChargentOrders.TChargentOperations.TChargentResult ccResult;
       
        // Find the Order using the Salesforce Opportunity Id provided. 
        Order Ordr = OrderEntryServicesDummy.GetOrder1(OrderId);
        
        // If an Order was not found
        // Return failure and an error message
        if(Ordr == null) { return new Result(false, 'The Order Id provided was not valid.'); }
        system.debug(Ordr);
        
        //10-19-2012 TW: Calculate Order Entry Stage needs to be called if we have 100% Discount where Amount = 0
         if(Ordr.TotalAmount == 0) {
           CalculateOrderEntryStage(Ordr.Id);
           return new Result(true, '0 Balance Order is valid');
         }
         
        // Get the Line Items for the Order
        List<OrderItem> OrderLines = OrderEntryServicesDummy.GetOrderLineItems1(OrderId);
        
        // If the Credit Card Type (ChargentSFA__Card_Type__c), Number (ChargentSFA__Card_Number__c),
        //   Month (ChargentSFA__Card_Month__c), or Year (ChargentSFA__Card_Year__c) is blank
        if(Ordr.Chargent_Order__r.ChargentOrders__Card_Type__c == null || Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c == null || 
            Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c == null || Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c == null)
        {
          
            // Return failure and an error message
            return new Result(false, 'The credit card data provided is not valid*.');
        }
        
        // If the Credit Card Number is 16 digits, and the Month is 2 digits, and the Year is 4 digits 
         // TW:   12-18-2013: Added 15-digit check for American Express card numbers.
        if ((Pattern.matches('^[0-9*]{16}$',Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c) ||
           Pattern.matches('^[0-9*]{15}$',Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c)) &&
            Pattern.matches('^[0-9*]{1}[0-9*]?$',Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c) && 
            Pattern.matches('^[0-9*]{4}$',Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c) )
        {
            // Call the Authorize Opportunity web service 
            //   (from the Chargent Application ChargentSFA.TChargentOperations.AuthorizeOpportunity_Click(OpportunityId)) to 
            //   authorize the Credit Card listed on the Opportunity.
            system.debug('**Ordr.Chargent_Order__r.ChargentOrders__Subtotal__c**'+Ordr.Chargent_Order__r.ChargentOrders__Subtotal__c);
            
            ccResult = ChargentOrders.TChargentOperations.AuthorizeOrder_Click(Ordr.Chargent_Order__r.Id);
            system.debug('**result**'+ccResult.Message);
            
            // If the Credit Card Authorization Result contains fail 
            if(ccResult.Status.toLowerCase().contains('fail'))
            {  
                // Return failure and the message returned from the Chargent Authorize Opportunity web service
                return new Result(false, ccResult.Message);
            }
            // Otherwise (else)
            else
            {
                // Return success and the message returned from the Chargent Authorize Opportunity web service
                system.debug('CC Result Message: '+ ccResult.Message);
                return new Result(true, ccResult.Message);
            }
        }
        // Otherwise (the Credit Card Number, Month, and Year did not contain the correct number of digits)
        else
        {
            system.debug('CardINvalid');
            // Build an error message indicating which fields caused the error.
            String invalidCCDataNotification = 'Credit Card could not be authorized because invalid Credit Card data. ';
            // TW:   12-18-2013: Added 15-digit check for American Express card numbers.
            if (!Pattern.matches('^[0-9*]{16}$',Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c) || !Pattern.matches('^[0-9*]{15}$',Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c) )
            {
                Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c = '';
                invalidCCDataNotification = invalidCCDataNotification + 'Credit Card Number must contain 16 digits and no dashes or spaces. ';
            }
            if (!Pattern.matches('^[0-9*]{1}[0-9*]?$',Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c))
            {
                Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c = '';
                invalidCCDataNotification = invalidCCDataNotification + 'Credit Card Month must contain 2 digits representing the Credit Card expiration month. ';
            }
            if (!Pattern.matches('^[0-9*]{4}$',Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c))
            {
                Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c = '';
                invalidCCDataNotification = invalidCCDataNotification + 'Credit Card Year must contain 4 digits representing the Credit Card expiration year. ';
            }
           
            // Return failure and an error message
            return new Result(false, invalidCCDataNotification);
        }
    }
    
     /* 
     * Method:  SaveOrder
     * Inputs:  Opportunity CurrentOrder - A full Opportunity record
     * Output:  A result object containing success or failure and a message
     * Purpose: To validate and save the Order provided.
     *            Note: The Save Order web service should not be used to update address information (Billing or Shipping); 
     *            the Update Billing Address or Update Shipping Address web services should be used instead.
     * SOQL:    5
     * DML:     3 
     */
   webservice static Result SaveOrder(Order CurrentOrder, string emailId, string phoneNumber)
    {
        /*MIGRATION FROM OPPORTUNITY TO ORDER*/
        system.debug(CurrentOrder);
        try{
                    Order OldOrder = OrderEntryServicesDummy.GetOrder1(CurrentOrder.Id);
                    CurrentOrder.Chargent_Order__r = OldOrder.Chargent_Order__r;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_Email__c = emailId;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_Phone__c = phoneNumber;

                    if(CurrentOrder.Company__c.toLowerCase().contains('kidzmatter') && CurrentOrder.Payment_Terms__c.toLowerCase().contains('net30'))
                    {
                       return new Result(false, 'Payment terms of Net 30 are not used for Kidzmatter orders.');
                    }
                    // If the Current Order argument (Order) Payment Terms is not Credit Card
                    if(CurrentOrder.Payment_Terms__c != 'Credit Card')
                    {
                        // Clear all Credit Card fields
                        CurrentOrder.Chargent_Order__r.ChargentOrders__Card_Type__c = null;
                        CurrentOrder.Chargent_Order__r.ChargentOrders__Card_Number__c = null;
                        CurrentOrder.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c = null;
                        CurrentOrder.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c = null;
 
                    }
                    // Otherwise (else) (Payment Terms is Credit Card)
                    else
                    {
                        // Default the Payment Method (ChargentSFA__Payment_Method__c) to Credit Card
                       CurrentOrder.Chargent_Order__r.ChargentOrders__Payment_Method__c = 'Credit Card';
                    }
                       // Set credit card gateway (should be set regardless of payment type, does not affect non-cc orders)
                    // If the Order Credit Card Gateway is blank
                    if(CurrentOrder.Chargent_Order__r.ChargentOrders__Gateway__c == null)
                    {
                        // Find all Gateways
                        List<ChargentBase__Gateway__c> Gateways = [select Id,ChargentBase__Active__c, Name from ChargentBase__Gateway__c];
                       
                       
                        // For each Gateway
                       // Check for an existing gateway and if none exist then return an error.
                     system.debug('<<COMPANY NAME?>> '+CurrentOrder.Company__c);
                     for(ChargentBase__Gateway__c Gateway : Gateways)
                        {
                            //TW: 2-24-12 Added new Kidz Matter Gateway check using the new Company field
                            // Separate out the Canada Gateway and the Default Gateway (US)       
                          if(Gateway.Name.toLowerCase().contains('canada') &&  CurrentOrder.Company__c.toLowerCase().contains('canada')) 
                          {   CurrentOrder.Chargent_Order__r.ChargentOrders__Gateway__c  = Gateway.Id; }         
                          if(Gateway.Name.toLowerCase().contains('kidz') && CurrentOrder.Company__c == 'KidzMatter')
                          {   OldOrder.Chargent_Order__r.ChargentOrders__Gateway__c  = Gateway.Id;}
                          if(Gateway.Name.toLowerCase()== 'awana' && CurrentOrder.Company__c.toLowerCase() == 'awana')
                            {   OldOrder.Chargent_Order__r.ChargentOrders__Gateway__c  = Gateway.Id;system.debug('<<AWANA GATEWAY>>'); }    
                           system.debug('<<WHICH GATEWAY?>> '+Gateway);
                        }//FOR
                                
                        
                    }//IF - if(CurrentOrder.ChargentSFA__Gateway__c == null)
                    // If the Order was not found by the Get Order web service
                    // Return failure and an error
                    if(OldOrder == null) { return new Result(false,'Please supply a valid Opportunity Salesforce Id.'); }
                    //9-28-2014 <FRT RECONSTRUCTION>: If Tax line already exists then remove it so we don;t get an Uncomitted Rollback error.
                    
                   //SF-188 -- Commenting this code as it is required to save with TAX.
                    /*List<OrderItem> findTax = [Select Id from OrderItem where PricebookEntry.ProductCode = '57779'  and OrderId =: CurrentOrder.Id limit 1];
                    if(!findTax.isEmpty()){
                      List<OrderItem> OLIs = GetOrderLineItems1(CurrentOrder.Id);
                      List<OrderItem> LinesToDelete = new List<OrderItem>();
                      for(OrderItem anOLI : OLIs){
                        if(anOLI.Line_Type__c.toLowerCase().startsWith('t'))
                            {
                                // Add the Line to the Lines to Delete list.
                                LinesToDelete.add(anOLI);
                            }
                      }
                      if(!LinesToDelete.isEmpty())
                      {
                        // Delete the designated Lines.
                          delete LinesToDelete;
                      }
                    }*/
                    //END -SF-188 commenting.
                     //===========END 9-28-2014 FRT RECONSTRUCTION
                    // Copy the Billing and Shipping Address information from the Order data found in the full data of the Order
                    // Note: The Save Order web service should not be used to update address information (Billing or Shipping); 
                    // the Update Billing Address or Update Shipping Address web services should be used instead.
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_First_Name__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_First_Name__c;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_Last_Name__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_Last_Name__c;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_Address__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_Address__c;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_City__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_City__c;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_State__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_State__c;
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_Zip_Postal__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_Zip_Postal__c;
                    
                    CurrentOrder.Chargent_Order__r.ChargentOrders__Billing_State_Province__c = OldOrder.Chargent_Order__r.ChargentOrders__Billing_State_Province__c;
                    CurrentOrder.Shipping_Street__c = OldOrder.Shipping_Street__c;
                    CurrentOrder.Shipping_City__c = OldOrder.Shipping_City__c;
                    CurrentOrder.Shipping_State__c = OldOrder.Shipping_State__c;
                    CurrentOrder.Shipping_Zip_Code__c = OldOrder.Shipping_Zip_Code__c;
                    CurrentOrder.Shipping_County__c = OldOrder.Shipping_County__c;
                    CurrentOrder.Shipping_Country__c = OldOrder.Shipping_Country__c;
                    //TW: 2-27-2012 Adding new Company fuiled for ORder
                    CurrentOrder.Company__c = OldOrder.Company__c;
                    system.debug(OldOrder);
                   
                    // Validate the Shipping and Billing Addresses of the Order by calling the Validate Order web service and passing the Order as an argument.
                    OrderEntryServicesDummy.Result ValidateResult = OrderEntryServicesDummy.ValidateOrderAddress(CurrentOrder);
                   
                    if(ValidateResult.Success != true)
                    {
                        // Return failure and an error message.
                        return new Result(false,'Saving Order (with Id='+CurrentOrder.Id+') failed. Validate failed. Error Message(s): '+ValidateResult.Message);
                    }
                    // Otherwise
                    Database.saveresult result = null;
                    //FRT Reconstruction:  Make sure that  the shipping type remains fixed once an order has been saved.
                    system.debug(' New SHIP TYPE: '+CurrentOrder.Shipping_Type__c);
                    
                    // Try to
                    try
                    {
                        // Save the Order (update)
                        result = database.update(CurrentOrder);
                        update CurrentOrder.Chargent_Order__r;
                    // If an error occurred while saving the order
                    // Return failure and an error message.
                    } catch(Exception ex) { return new Result(false,'Saving Order (with Id='+CurrentOrder.Id+') failed. Error Message(s): '+ex.getMessage()); } 
                    
                    // If the database result (from saving the order) is blank
                    // Return failure and an error message.
                    if(result == null) {   return new Result(false,'Saving Order (with Id='+CurrentOrder.Id+') failed.'); }
                    
                    system.debug(result);
                     // If the Order was not saved successfully
                    if(!result.isSuccess())
                    {
                        string error_list = '';
                        
                        for(database.error er : result.getErrors())
                        {
                            error_list += er.getMessage() + ' ';
                        }
                        
                        // Return failure and an error message
                        return new Result(false,'Saving Order (with Id='+CurrentOrder.Id+') failed. Error Message(s): '+error_list);
                    }
                    
                    // Otherwise (the order was saved successfully)
                    // Call the Consolidate Duplicate Line Items web service to consolidate any duplicate Products
                    OrderEntryServicesDummy.Result r = OrderEntryServicesDummy.ConsolidateDuplicateLineItems(CurrentOrder.Id);
                    
                    // Call the Get Order web service to get the full data for the updated Order.
                    CurrentOrder = OrderEntryServicesDummy.GetOrder1(CurrentOrder.Id);
                
                    // Return success, a message, and the full data for the Order.
                    return new Result(true, 'Success. Order saved. '+r.Message, CurrentOrder);
                }catch(Exception e)
                {
                    system.debug('*Exception:SaveOrder:Trace'+e.getStackTraceString()+' MSG-'+e.getMessage());
                    return new Result(false,'Exception Occured',e.getMessage());
                }
            //return null;
    }
      
    /* 
     * Method:  ConsolidateDuplicateLineItems
     * Inputs:  string OpportunitySalesforceId - The Salesforce Id of an Order; used to look up an Order
     * Output:  A result object containing success or failure and a message
     * Purpose: To consolidate Order Line Items (Products) that reference the same Product.
     * SOQL:    2
     * DML:     2
     */
    webservice static Result ConsolidateDuplicateLineItems(string orderId)
    {
        Map<String,OrderItem> MappedLines = new Map<String,OrderItem>();
        List<OrderItem> LinesToUpdate = new List<OrderItem>();
        List<OrderItem> LinesToDelete = new List<OrderItem>();
        
        // Call the Get Order Line Items web service to find all Line Items for an Order.
        List<OrderItem> Lines = GetOrderLineItems1(orderId);
        
        // If one or more Line Items were found
        if(!Lines.isEmpty())
        {
            // For each Line Item found
            for(OrderItem Line : Lines)
            {
                // If the Product Code on the Line Item matches any previously found Line Item Product Codes
                if(MappedLines.containsKey(Line.PriceBookEntry.Product2.ProductCode))
                {
                    // Get the previously matched Line Item
                    OrderItem TempLine = MappedLines.get(Line.PriceBookEntry.Product2.ProductCode);
                    // Add the Quantity of the current Line Item to the previously matched Line Item
                    TempLine.Quantity += Line.Quantity; 
                    //FRT RECONSTRUCTION: 9-4-2014 We need to also consolidate weight as well.
                    TempLine.Estimated_Weight__c += Line.Estimated_Weight__c;
                    // If the Unit Price of the current Line Item is not the same as the previously matched Line Item
                    if(Line.PricebookEntry.UnitPrice != Line.UnitPrice) { 
                        TempLine.UnitPrice = Line.UnitPrice; } // Set the Unit Price of the previously matched Line Item to the current Line Item Price.
                    
                    // If the previously matched Line Item (with the added Quantity of the current line item) is less than zero.
                    if(TempLine.Quantity <= 0)
                    {
                        // Set the previously matched Line Item Quantity to negative 1 because Salesforce will not allow a product to have zero Quantity.
                        TempLine.Quantity = -1;
                        
                        // Because the Quantity is less than zero, the Line Item must be removed. Add the previously matched line to the List of Lines to delete.
                        LinesToDelete.Add(TempLine);
                    }
                    
                    // Add the current Line Item to the List of Lines to delete (because it matched a previous line and the Quantity has been added to that line).
                    LinesToDelete.Add(Line);
                }
                // Otherwise (else) (the Product Code of the current Line Item did not match any previous Line Item)
                else
                {
                    // Add the current Line Item to the List of previously found Line Items (for lookup and comparison against all other Line Items).
                    MappedLines.put(Line.PriceBookEntry.Product2.ProductCode,Line);
                }
            }
            
            LinesToUpdate = MappedLines.values().clone();
            
            // For debugging: 
            //for(OpportunityLineItem l : MappedLines.values()) { system.debug('All:'+l); }
            //for(OpportunityLineItem l : LinesToUpdate) { system.debug('Update:'+l); }
            //for(OpportunityLineItem l : LinesToDelete) { system.debug('Delete:'+l); }
            
            // Try to 
            try
            {
                update LinesToUpdate; // Save (update) all Lines
                delete LinesToDelete; // Delete the Line Items in the List of Line Items to delete.
                
                // Return success and a message
                return new Result(true,'Successfully consolidated duplicate line items for the order (with Id='+orderId+').');
            } 
            // If there was an error saving and deleting any Line Items
            catch(Exception ex) { 
                // Return failure and an error message.
                return new Result(false,'An error occurred consolidating duplicate line items for the Order (with Id='+orderId+'). Error: '+ex.getMessage()); }
            
        }
        
        // If an unexpected error occurred
        // Return failure
        return new Result(false);
    }
 
    /* 
     * Method:  SubmitOrder
     * Inputs:  string OpportunitySalesforceId - The Salesforce Id of an Opportunity; used to look up an Order
     * Output:  A result object containing success or failure and a message
     * Purpose: To submit an Order by changing the Stage to Order Submitted
     * SOQL:    1
     * DML:     1
     */
     webservice static Result SubmitOrder(string OrderId, string OrderType)
    {
        // Call the Get Order web service to find the Order using the Salesforce Opportunity Id argument provided. 
        Order Ordr = OrderEntryServicesDummy.GetOrder1(OrderId);
        // If the Order was not found
        // Return failure and an error message.
        if(Ordr == null) { return new Result(false,'The Order Salesforce Id provided is not valid.'); }
        
       // Unless this is a Canadain Missionary order... Set the Order Stage (StageName) to Submitted
       
      
            Ordr.Status = 'Order Submitted';
      
        //TW: 6-6-2013 Adding  'Customer Service' string to  Opportunity Source field before submitting
        Ordr.Opportunity_Source__c = 'Customer Service';
        // Try to
        try
        {
          // Save (update) the Order
            List<OrderItem> OrderLines = OrderEntryServicesDummy.GetOrderLineItems1(Ordr.Id);
            for(OrderItem item : OrderLines){
                if(item.PricebookEntry.Product2 !=null){
                    if(item.PricebookEntry.Product2.ProductCode =='62412') //Update Rush Order
                        Ordr.Rush_Order__c = true;
                }
            }
            //Baji: code to fetch 2 char ISO Code from Countries object basing on Shipping Country
           
            Country__c c = new Country__c();
            c = [select ISO_Code__c from Country__c where Name =: Ordr.Shipping_Country__c];
            //system.debug('ISO Code:'+c.ISO_Code__c);
            Ordr.Shipping_Country_Code__c = c.ISO_Code__c;
            update Ordr;
            system.debug(' AFTER: SHIP TYPE: '+Ordr.Shipping_Type__c);
             
           
            // If the Order was saved successfully
            // Return success and a message
            return new Result(true,'Success. The Order (with Id='+OrderId+') has been submitted (finished).');
        }
        // If an error occurred while saving the Order
        catch(Exception ex) 
        {
            // Return failure and an error message. 
            return new Result(false,'An error occurred while submitting (finishing) the Order. Error Message: '+ex.getMessage());
        }
    }
    
    // begin utility methods
    
    /* 
     * Method:  GetAddresses
     * Inputs:  string AccountSalesforceId - The Salesforce Id of an Account
     * Output:  A list of Address records (List<Address__c>)
     * Purpose: To get a list of Address records for a specified Account
     * SOQL:    1
     * DML:     0
     */
    webservice static List<Address__c> GetAddresses(string AccountSalesforceId)
    {
        // If the Salesforce Account Id argument provided is blank, return blank (null).
        if(AccountSalesforceId == null) { return null; }
        AccountSalesforceId = String.escapeSingleQuotes(AccountSalesforceId);
        
        // Find all Address records related to the Account with the ID specified
        List<Address__c> addresses = [Select Id, Name, Account__c, Default_Shipping_Address__c, First_Name__c, Last_Name__c,  
            Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, Country__c  
            From Address__c Where Account__c = :AccountSalesforceId And Show_in_Order_Entry__c = true order by Last_Name__c ASC ];
        
        // Return the Addresses found (or blank)
        return addresses;
    }
    
    /* 
     * Method:  UpdateAddNewOrderShippingAddress SF-124
     */
    webservice static Result UpdateAddNewOrderShippingAddress(String SalesforceAddressId,String OrderId,String FirstName,String LastName,String LineOne,String LineTwo,String City,
                                                                 String State,String ZipCode,String Country)
    {
        system.debug(OrderId);
        system.debug(SalesforceAddressId);
        
        ID OrdId = null, AddressId = null;
        
        // Try to
        try
        {
            // Convert the Salesforce Opportunity Id and the Salesforce Address Id to Salesforce Ids.
            OrdId = OrderId;
            AddressId = SalesforceAddressId;
        }
        // If an error occurred while converting
        catch(Exception ex)
        {
            // Return failure and an error message
            return new Result(false,'Please supply a valid Order or Address (15 or 18 character) Salesforce Id. Error Message: '+ex.getMessage());
        }
        
        try
        {
        // Call the GetOrder web service to find the Order using the Salesforce Opportunity Id provided.
        Order Ord = GetOrder1(OrderId);
        // If the Order was not found
        // Return failure and an error message.
        if(Ord == null) { return new Result(false,'Please supply a valid Order Salesforce Id.'); }
        
        Account acc = [SELECT Id,Shipping_First_Name__c,Shipping_Last_Name__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Default_Shipping_Address__c
                       FROM Account WHERE Id=: Ord.AccountId];
        
        Address__c Address = new Address__c();
        Address.First_Name__c = FirstName;
        Address.Last_Name__c = LastName;
        Address.Address_Line_1__c = LineOne;
        Address.Address_Line_2__c = LineTwo;        
        Address.City__c = City;
        Address.State__c = State;
        Address.Zip_Code__c = ZipCode;
        Address.Country__c = Country;
        Address.Account__c  =   Ord.AccountId;
        Address.Default_Shipping_Address__c = false;    
        Address.Show_in_Order_Entry__c = true;
        insert Address;
        
        Ord.Shipping_Address__c = Address.Id;        
        Ord.Ship_to_First_Name__c = FirstName;
        Ord.Ship_to_Last_Name__c = LastName;
        Ord.Ship_to_Name__c = FirstName + ' ' + LastName;
        if(LineOne != null && LineTwo != null) {
            Ord.Shipping_Street__c = LineOne + '\n' + LineTwo; 
        }
        else if(LineOne != null) { 
            Ord.Shipping_Street__c = LineOne; }
        else { 
        Ord.Shipping_Street__c = null; }
        Ord.Shipping_City__c = City;
        Ord.Shipping_State__c = State;
        Ord.Shipping_Zip_Code__c = ZipCode;
        //Ord.Shipping_County__c = Address.County__c;
        Ord.Shipping_Country__c = Country;


            // Save (update) the Order
            update Ord;          
            system.debug('Ord--'+Ord);
            // If the save was successful
            // Return success and a message
            /*Address__c updatedWithIntacctId = [SELECT Id,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,City__c,Intacct_Address_ID__c,
                                               State__c,Zip_Code__c, Country__c,Account__c,Default_Shipping_Address__c,Show_in_Order_Entry__c
                                               FROM Address__c WHERE Id=:address.Id];*/
            return new Result(true,'The Order Shipping Address has been updated.',address);
        }
        // If an error occurred while saving the Order
        catch(Exception exc) 
        {
            // Return failure and an error message.
            return new Result(false,'An error occurred while updating Shipping Address. Error Message: '+exc.getMessage());
        }
              
    }
    
     /*SF-188
     * 
     * 
    */
webservice static Result GetShippingTableInfo(string OrderId,string WeightFreightMsg,decimal WeightFreightCost,String ShipCode,String shippingCountry)
     {
       system.debug('<<WeightFreightMsg>> '+WeightFreightMsg+'<<WeightFreightCost>> '+WeightFreightCost);
      
     Order Ordr = OrderEntryServices.GetOrder1(OrderId);
        
        Map<String,Decimal> shipPriceMap = new Map<String,Decimal>();           
        decimal MissionaryFreightTotal = 0;
                // If the Ordering Country is not US then give the flat Misisonary price rate.
        if(shippingCountry != null && !shippingCountry.toLowerCase().contains('united states') && !shippingCountry.toLowerCase().contains('canada'))
        {   
          List<Country__c> MeenaCountry = new List<Country__c>();
          MeenaCountry = [Select Region__c from Country__c where Name =:  shippingCountry Limit 1];
          if(MeenaCountry.size() == 0){
            //shipPriceMap.put('Not Valid',0.0);
            return new Result(true, 'Success', 0.0);
            
          }
          //shipPriceMap.put('Not Valid',0.0);
          return new Result(true, 'Success', 0.0);
        }
        
        system.debug('WeightFreightMsg--'+WeightFreightMsg);
        if(WeightFreightMsg == 'Non-Stock'){
            //shipPriceMap.put('Not Valid',0.0);
            return new Result(true, 'No Freight Charge Applies', 0.0);
        }
        //********************************New code to caluclate Freight ********************************************
        //Fetch the zone using shipping zipcode
        System.debug('Freight Calculation started');
        
        Materials_Weight_Percentage_Increase__c mwpi = [select Materials_Weight_Percentage__c from Materials_Weight_Percentage_Increase__c];
        
        String zip_zone;
        Boolean apo = FALSE;
         try{  
        if(shippingCountry != null){
            if(shippingCountry == 'CANADA' || shippingCountry == 'Canada' || shippingCountry == 'canada'){
                zip_zone = '1';
            }
            else if(shippingCountry.toLowerCase() != 'canada' && shippingCountry.toLowerCase() != 'united states' && 
                    shippingCountry != 'FPO' && shippingCountry != 'APO')
            {
                zip_zone = '99';
                //shipPriceMap.put('Not Valid',0.0);
                return new Result(true, 'Success', 0.0);
            }
            else if(shippingCountry == 'FPO' || shippingCountry == 'APO'){
                zip_zone = '1';
                apo = TRUE;
            }
            else{
              if(Ordr.Shipping_Zip_Code__c != null)
              {
                    zip_zone = Ordr.Shipping_Zip_Code__c.left(3);
                    Shipping_Zone__c sz = [select Id,Zone__c from Shipping_Zone__c where ZIP_Prefix__c =: zip_zone];
                    zip_zone = sz.Zone__c;
                
              }
            } 
        }
         }catch(exception e){
             return new Result(false, 'Address is not valid.', shipPriceMap.values());
         }        
        //Fetch the shipping rate using estimated weight in Order
        Decimal final_shipping_rate;
        Integer box_count = 1;
        Decimal remain_weight;
        Decimal estimated_weight;
        Decimal final_price;
        Decimal new_weight;
        Decimal SAC = 0.0;
        Decimal EAC = 0.0;
        Decimal NAC = 0.0;
        Decimal EcoAC = 0.0; //added for new shipping type - Economy for canada 
        Decimal PAC = 0.0; //added for new shipping type - Priority for canada 
        
        Decimal margin = 0.0;
        Integer indv_box_weight;
        Decimal accessorial_charge;
        Decimal sub_total;
        Decimal total_margin;
        
        if(Ordr.Estimated_Weight__c != null){
            system.debug('**********Shipping Zone********'+zip_zone);
            system.debug('**********Shipping type********'+Ordr.Shipping_Type__c);
            system.debug('**********Order Estimated Weight********'+Ordr.Estimated_Weight__c);
            system.debug('**********Shipping Country********'+Ordr.Shipping_Country__c);
            system.debug('**********APO Value********'+apo);
            
            new_weight = (Ordr.Estimated_Weight__c*mwpi.Materials_Weight_Percentage__c)+Ordr.Estimated_Weight__c;
            system.debug('**********Final Estimated Weight********'+new_weight);
            
            //Fetch custom setting values like margin,accessorial_charge
            Awana_Shipping_Charges__c asch = [select Id,Standard_Accessorial_Charge__c,Nextday_Accessorial_Charge__c,Margin__c,Expedited_Accessorial_Charge__c,Box_Weight__c,Flat_Rate__c From Awana_Shipping_Charges__c];
            
            Awana_CANADA_Shipping_Charges__c acsch = [select Id,Standard_Accessorial_Charge__c,Overnight_Accessorial_Charge__c,Economy_Accessorial_Charge__c,Priority_Accessorial_Charge__c,Margin__c,Expedited_Accessorial_Charge__c,Box_Weight__c From Awana_CANADA_Shipping_Charges__c];
            
            if(Ordr.Estimated_Weight__c == 0.00){
                return new Result(true, 'Success', 0);
            }

            estimated_weight = new_weight;
            system.debug('**********Final Estimated Weight********'+estimated_weight);
          
                        
            //Assign charge values
            if(shippingCountry.toLowerCase() == 'united states'){
                system.debug('**********US********');
                SAC = asch.Standard_Accessorial_Charge__c;
                EAC = asch.Expedited_Accessorial_Charge__c;
                NAC = asch.Nextday_Accessorial_Charge__c;
                margin = asch.Margin__c;
                  
                box_count = Integer.valueOf((estimated_weight/asch.Box_Weight__c).round(roundingMode.UP));
                                    
                system.debug('********Total No OF Boxes: '+box_count);
                indv_box_weight = Integer.valueOf((estimated_weight/box_count).round(roundingMode.UP));
                system.debug('********Individual Box Weight: '+indv_box_weight);
                
                              
                Shipping_Rate__c srStandard = [select Id,Price__c from Shipping_Rate__c where Method__c = 'Standard' and Zone__c =: zip_zone and Weight__c =: String.valueOf(indv_box_weight) and Country__c =: shippingCountry and APO__c =: apo];
                
                Shipping_Rate__c srExpedited = [select Id,Price__c from Shipping_Rate__c where Method__c = 'Expedited' and Zone__c =: zip_zone and Weight__c =: String.valueOf(indv_box_weight) and Country__c =: shippingCountry and APO__c =: apo];
                
                Shipping_Rate__c srNextDay = [select Id,Price__c from Shipping_Rate__c where Method__c = 'Next Day' and Zone__c =: zip_zone and Weight__c =: String.valueOf(indv_box_weight) and Country__c =: shippingCountry and APO__c =: apo];
                
                //final_price = box_count*sr.Price__c;
                Decimal final_priceStandard = box_count*srStandard.Price__c;
                Decimal final_priceExpedited = box_count*srExpedited.Price__c;
                Decimal final_priceNextDay = box_count*srNextDay.Price__c;
                
                
                Decimal accessorial_charge_Standard = final_priceStandard*SAC;
                Decimal accessorial_charge_Expedited = final_priceExpedited*EAC;
                Decimal accessorial_charge_NextDay = final_priceNextDay*NAC;
                
                Decimal sub_totalStandard = final_priceStandard + accessorial_charge_Standard;
                Decimal sub_totalExpedited = final_priceExpedited + accessorial_charge_Expedited;
                Decimal sub_totalNextDay = final_priceNextDay + accessorial_charge_NextDay;                 
            
                Decimal total_marginS = sub_totalStandard*margin;
                Decimal total_marginE = sub_totalExpedited*margin;
                Decimal total_marginN = sub_totalNextDay*margin;
                
                Decimal final_shipping_rateS = final_priceStandard + accessorial_charge_Standard + total_marginS;
                Decimal final_shipping_rateE = final_priceExpedited + accessorial_charge_Expedited + total_marginE;
                Decimal final_shipping_rateN = final_priceNextDay + accessorial_charge_NextDay + total_marginN;
                
                
                if(Ordr.Estimated_Weight__c >= 0.001 && Ordr.Estimated_Weight__c <= 0.999){
                    shipPriceMap.put('Standard',asch.Flat_Rate__c.setScale(2));
                }else{
                    shipPriceMap.put('Standard',final_shipping_rateS.setScale(2));
                }
                shipPriceMap.put('Expedited',final_shipping_rateE.setScale(2));
                shipPriceMap.put('NextDay',final_shipping_rateN.setScale(2));
                
            }
            
            if(shippingCountry.toLowerCase() == 'canada' || shippingCountry.toLowerCase() != 'united states'){
                system.debug('**********CANADA********');
                PAC = acsch.Economy_Accessorial_Charge__c;
                EcoAC = acsch.Priority_Accessorial_Charge__c;
                //OAC = acsch.Overnight_Accessorial_Charge__c;
                margin = acsch.Margin__c;
                  
                box_count = Integer.valueOf((estimated_weight/acsch.Box_Weight__c).round(roundingMode.UP));
                                    
                system.debug('********Total No OF Boxes: '+box_count);
                indv_box_weight = Integer.valueOf((estimated_weight/box_count).round(roundingMode.UP));
                system.debug('********Individual Box Weight: '+indv_box_weight);
                
                //Fetch shipping rates
                system.debug('----'+Ordr.Shipping_Type__c);
                system.debug('----'+zip_zone);
                system.debug('----'+String.valueOf(indv_box_weight));
                system.debug('----'+Ordr.Shipping_Country__c);
                system.debug('--'+apo);
                
                //Shipping_Rate__c sr = [select Id,Price__c from Shipping_Rate__c where Method__c =: Ordr.Shipping_Type__c and Zone__c =: zip_zone and Weight__c =: String.valueOf(indv_box_weight) and Country__c =: Ordr.Shipping_Country__c and APO__c =: apo];
                
                Shipping_Rate__c srEconomy = [select Id,Price__c from Shipping_Rate__c where Method__c = 'Economy' and Zone__c =: zip_zone and Weight__c =: String.valueOf(indv_box_weight) and Country__c =: shippingCountry and APO__c =: apo];
                
                Shipping_Rate__c srPriority = [select Id,Price__c from Shipping_Rate__c where Method__c = 'Priority' and Zone__c =: zip_zone and Weight__c =: String.valueOf(indv_box_weight) and Country__c =: shippingCountry and APO__c =: apo];
                
                //final_price = box_count*sr.Price__c;
                
                Decimal final_priceEconomy = box_count*srEconomy.Price__c;
                Decimal final_pricePriority = box_count*srPriority.Price__c;
                
                Decimal accessorial_charge_Economy = final_priceEconomy*EcoAC;
                Decimal accessorial_charge_Priority = final_pricePriority*PAC;
                
                Decimal sub_totalEconomy = final_priceEconomy + accessorial_charge_Economy;
                Decimal sub_totalPriority = final_pricePriority + accessorial_charge_Priority;
                
                Decimal total_marginEco = sub_totalEconomy*margin;
                Decimal total_marginP = sub_totalPriority*margin;
                
                Decimal final_shipping_rateE = final_priceEconomy + accessorial_charge_Economy + total_marginEco;
                Decimal final_shipping_rateP = final_pricePriority + accessorial_charge_Priority + total_marginP;
                
                shipPriceMap.put('Economy',final_shipping_rateE.setScale(2));
                shipPriceMap.put('Priority',final_shipping_rateP.setScale(2));
            }
       
              
            System.debug('********** Final Freight'+shipPriceMap);
            return new Result(true, 'Success', shipPriceMap.values());
        }
        
        System.debug('Freight Calculation End');
        
        //Else default to stock
        return new Result(true, 'Success', WeightFreightCost);
      }  
    
    
    /* 
     * Method:  GetAddress
     * Inputs:  string AddressSalesforceId - The Salesforce Id of an Address
     * Output:  An Address record (Address__c)
     * Purpose: To get the full data for an Address record
     * SOQL:    1
     * DML:     0
     */
    webservice static Address__c GetAddress(string AddressSalesforceId)
    {
        // If the Salesforce Address Id argument provided is blank, return blank (null).
        if(AddressSalesforceId == null) { return null; }
        AddressSalesforceId = String.escapeSingleQuotes(AddressSalesforceId);
        
        // Find the Address (Address__c) using the provided Salesforce Address Id
        Address__c address = null;
        List<Address__c> addresses = [Select Id, Name, Account__c, Default_Shipping_Address__c, First_Name__c, Last_Name__c,  
            Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, Country__c, 
            (Select Id From Opportunities1__r), (Select Id From Opportunities__r)  
            From Address__c Where Id = :AddressSalesforceId];
        
       if(addresses.size() > 0){
         if(addresses[0].First_Name__c == null || addresses[0].First_Name__c==''){
           addresses[0].First_Name__c ='To: ';
           upsert addresses[0];  
           system.debug('B - ARE WE HERE NULL FNAME '+addresses[0].First_Name__c );
           
         }
       
         system.debug('2 - Catching NULL FNAME '+addresses[0].First_Name__c+' '+addresses[0].Last_Name__c );
       }
        // If an Address was found
        // Return the Address
        if(!addresses.isEmpty()) { address = addresses[0]; }
        return address;
    }
    /*
        Purpose :  This method fetches Order from Id provided. 
        Author : Darshan Chhajed.
    */
    webservice static Order GetOrder1(string orderId)
    {
        
        // If the Salesforce Opportunity Id argument provided is blank
        // Return blank (null).
        if(orderId == null) { return null; }
        orderId = String.escapeSingleQuotes(orderId);
        Order Ordr = null; 
        List<Order> MatchingOrders = [Select Account.Name, 
            Account.Id, 
            Account.RecordType.Name,
            Account.Mailing_Address_Book__c,
            Account.Type,
            Account.ShippingCountry,
            Account_Updated__c,
            Actual_Weight__c,
            BillingCity,
            BillingCountry,
            BillingPostalCode,
            BillingState,
            BillingStreet,
            Billing_Address__c,
            Billing_County__c,
            Campaign_Related_Account__c,
            Cancel_Log__c,
            Chargent_Order__c,
            Chargent_Order__r.ChargentOrders__Billing_First_Name__c,
            Chargent_Order__r.ChargentOrders__Billing_Last_Name__c,
            Chargent_Order__r.ChargentOrders__Billing_Email__c,
            Chargent_Order__r.ChargentOrders__Billing_Phone__c,
            Chargent_Order__r.ChargentOrders__Billing_Address__c,
            Chargent_Order__r.ChargentOrders__Billing_City__c,
            Chargent_Order__r.ChargentOrders__Billing_Zip_Postal__c,
            Chargent_Order__r.ChargentOrders__Billing_State__c,
            Chargent_Order__r.ChargentOrders__Billing_State_Province__c,
            Chargent_Order__r.ChargentOrders__Billing_Country__c,
            Chargent_Order__r.ChargentOrders__Credit_Card_Name__c,
            Chargent_Order__r.ChargentOrders__Card_Number__c,
            //Chargent_Order__r.ChargentOrders__Card_Security_Code__c,
            Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c,
            Chargent_Order__r.ChargentOrders__Card_Type__c,
            Chargent_Order__r.ChargentOrders__Gateway__c,
            Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c,
            Chargent_Order__r.ChargentOrders__Subtotal__c,
            Billing_Address__r.Id, 
            Billing_Address__r.Name, 
            Billing_Address__r.Account__c, 
            Billing_Address__r.Default_Shipping_Address__c, 
            Billing_Address__r.First_Name__c, 
            Billing_Address__r.Last_Name__c, 
            Billing_Address__r.Address_Line_1__c, 
            Billing_Address__r.Address_Line_2__c, 
            Billing_Address__r.City__c, 
            Billing_Address__r.State__c, 
            Billing_Address__r.Zip_Code__c, 
            Billing_Address__r.County__c,  
            Billing_Address__r.Country__c, 
            Shipping_Address__r.Id, 
            Shipping_Address__r.Name, 
            Shipping_Address__r.Account__c, 
            Shipping_Address__r.Default_Shipping_Address__c, 
            Shipping_Address__r.First_Name__c, 
            Shipping_Address__r.Last_Name__c, 
            Shipping_Address__r.Address_Line_1__c, 
            Shipping_Address__r.Address_Line_2__c, 
            Shipping_Address__r.City__c,  
            Shipping_Address__r.State__c, 
            Shipping_Address__r.Zip_Code__c, 
            Shipping_Address__r.County__c,  
            Shipping_Address__r.Country__c,
            Church_Rewards_Sponsored_Church__c,
            Church_Rewards_Total_Points_Gained__c,
            Church_Rewards_Total_Points_Redeemed__c,
            Club_Interest__c,
            Company__c,
            Corp_Currency_Amount__c,
            Country__c,
            Created_Date_Time__c,
            Created_Day__c,
            CurrencyIsoCode,
            Custom_Field_1__c,
            Delivery_Mode__c,
            Description,
            Direct_Ship_Flag__c,
            Discounts__c,
            Donation_Amount__c,
            Donor_Type__c,
            EffectiveDate,
            Error_Log__c,
            ExtraEmail__c,
            Estimated_Weight__c,
            First_Shipment__c,
            Has_Discounts__c,
            Hour_in_Day__c,
            Id,
            Inquiry_ID2__c,
            Intacct_Entity__c,
            Interest__c,
            Invoice_Number__c,
            Last_Activity_Datetime__c,
            MA_Opportunity_Notes__c,
            Name,
            Notes__c,
            Opportunity_Count__c,
            Opportunity_Source__c,
            OrderNumber,
            OrderReferenceNumber,
            Order_Being_Fulfilled__c,
            Order_Number__c,
            Order_Submitted__c,
            Order_Type__c,
            Original_Order_Date__c,
            Override_Order_Type__c,
            OrderLineItemCount__c,
            Package_Shipped__c,
            Payment_Terms__c,
            Pick_Number__c,
            Pick_Ticket_Not_Fulfillable__c,
            Price_Book__r.Name,
            Price_Book__r.Id,
            PriceBook2Id,
            PriceBookName__c,
            Price_Group__c,
            Priority__c,
            Project_Code__c,
            Promo_code__c,
            Purchase_Order__c,
            Region__c,
            Registration_Product__c,
            Rush_Order__c,
            Shipments__c,
            Shipment_Cost__c,
            Shipping_Address__c,
            Shipping_Carrier__c,
            Shipping_City__c,
            Shipping_Code_Old__c,
            Shipping_Code__c,
            Shipping_Country__c,
            Shipping_Country_Code__c,
            Shipping_County__c,
            Shipping_GeoCode__c,
            Shipping_State__c,
            Shipping_Street__c,
            Shipping_Type__c,
            Shipping_Zip_Code__c,
            ShipToContactId,
            Ship_to_First_Name__c,
            Ship_to_Last_Name__c,
            Ship_to_Name__c,
            Status,
            Tax_Area__c,
            TempOrderNumber__c,
            Time_to_Fill__c,
            TotalAmount,
            Type,
            (Select Id, Contact__r.Id, Contact__r.Name From Order_Contact_Roles__r)
            From Order Where Id = :orderId];
        system.debug('<<Matching Order>> '+MatchingOrders);
        // If an Opportunity was found
        // Set an Order variable to the found Opportunity.
        // Otherwise
        // Return blank (null)
        if(!MatchingOrders.isEmpty()) { Ordr = MatchingOrders[0]; } else { return null; }
        system.debug('<<GETORDER GATEWAY>> '+Ordr.Chargent_Order__r.ChargentOrders__Gateway__c);
        // If the Order Credit Card Number is not blank
        if(Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c != null)
        {
            string ccnum = Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c;
            
            // If the Order Credit Card Number is longer than four (4) digits
            if(ccnum.length()>4)
            {
                // Convert all numbers to asterisks (*) except the last four digits of the Credit Card Number.
                Ordr.Chargent_Order__r.ChargentOrders__Card_Number__c = 
                    ccnum.substring(0,ccnum.length()-4).replaceAll('[^-| |/.]','*')+ccnum.substring(ccnum.length()-4,ccnum.length());
            }
        }
        
        // If Credit Card Month, Year, and Security Code are not blank
        // Convert all numbers in the respective fields to asterisks (*)
        if(Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c != null) { 
            Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c = Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Month__c.replaceAll('[^-| |/.]','*'); }
        if(Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c != null) { 
            Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c = Ordr.Chargent_Order__r.ChargentOrders__Card_Expiration_Year__c.replaceAll('[^-| |/.]','*'); }
    
        
        // Return the Order
        return Ordr;
        
    }
    
    
    /*MIGRATION FROM OPPORTUNITY TO ORDER*/
    /*
        Purpose -  It return Order Amount on the Order 
    */
     webservice static Result GetOrderAmounts1(string OrderId)
    {
        // Initilaize (Create) a new List of Amounts (\"?g fxcxdecimals) to contain the different Amounts
        List<Decimal> OrderAmounts = new List<Decimal>();
        
        Decimal TotalAmount = 0;
        Decimal ProductAmount = 0;
        Decimal ShippingAmount = 0;
        Decimal TaxAmount = 0;
        
        // Call the Get Order web service to find the Order using the Salesforce Opportunity Id argument provided.
        Order Ordr = OrderEntryServicesDummy.GetOrder1(OrderId);
        // Call the Get Order Line Items web service to find all of the Order Line Items using the Salesforce Opportunity Id provided.
        List<OrderItem> OrderLines = OrderEntryServicesDummy.GetOrderLineItems1(OrderId);
        
        // If the Order was found
        // Set the Total Amount to the Order Amount (Order.Amount)
        if(Ordr != null) { TotalAmount = Ordr.TotalAmount; }
        // Otherwise
        // Return failure and an error message.
        else { return new Result(false, 'The Opportunity/Order Id provided was not valid.'); }
        
        // If Order Line Items were not found
        // Return failure and an error message.
        // Note: Order Amount would be zero if there are no Line Items.
        if(OrderLines.isEmpty()) { return new Result(false, 'No Line Items were found for the Opportunity/Order Id provided.'); }
        
        // Otherwise
        // For each Line Item found
        for(OrderItem Line : OrderLines)
        {
            // If the Line Item is not blank
            
            // If the Line Item Line Type begins with F
            // Add the Unit Price of the current Line Item to the Shipping Amount
            if(Line.Line_Type__c != null) {
                if(Line.Line_Type__c.startsWith('F')) { ShippingAmount += Line.UnitPrice; } }
            
            // If the Line Item Line Type begins with T
            // Add the Unit Price of the current Line Item to the Tax Amount
            if(Line.Line_Type__c != null) {
                if(Line.Line_Type__c.startsWith('T')) { TaxAmount += Line.UnitPrice; } }
            
            // If the Line Item Line Type does not begin with F or T
            // Add the Unit Price of the current Line Item to the Product Amount
            if(Line.Line_Type__c != null) {
                if(!Line.Line_Type__c.startsWith('F') && !Line.Line_Type__c.startsWith('T')) { ProductAmount += Line.TotalPrice; } }
        }
        
        // Return success, a message, and the List of Amounts
        return new Result(true, 'Successfully calculated Order Amounts.', new List<Decimal> {TotalAmount, ProductAmount, ShippingAmount, TaxAmount});
    }
    
    /*
        MIGRATION FROM OPPORTUNITY TO ORDER
        Purpose : Get List of order items from Order
    */
    
    webservice static List<OrderItem> GetOrderLineItems1(string ItemId)
    {
        List<OrderItem> items = new List<OrderItem>();
        system.debug('OLI ID '+ItemId);
        // Try to
        try
        {
            // Convert the Opportunity or Line Item Salesforce Id argument provided to a Salesforce Id
            ID sfid = ItemId;
            
            // If converting was successful
            // If the Opportunity or Line Item Salesforce Id begins with 006
            if(ItemId.startsWith('801'))
            {
                // The Id is an Opportunity Id.
                // Find all items for the Opportunity using the Salesforce Opportunity Id argument provided.
                //TW 3-13-2012 Added Product Code and Product2.Name, Renewal
               //TW 5-21-2013: Added PreOrder BackOrder Handling for pick tickets on Line Items
               //TW: 7-10-13 Added Price of Discount and Promo Code
               
                items = [Select Id, OrderId, Upgrade_Level__c, PriceBookEntryId, PriceBookEntry.Name, PricebookEntry.Product2.Description, PricebookEntry.Product2.ProductCode,Price_of_Discount__c,Promo_Code__c,Estimated_Weight__c,
                    PricebookEntry.Product2.Id, Quantity, Quantity_Backordered__c, Quantity_Fillable__c, PriceBookEntry.UnitPrice, UnitPrice, ListPrice, TotalPrice, Line_Type__c,PreOrder_BackOrder_Handling__c,Product2.Family 
                    From OrderItem Where OrderId = :sfid order by createddate];
            }
            system.debug('<<PRICE OF DISCOUNT>> '+items );
            // If no Line Items were found (or the Opportunity or Line Item Salesforce Id did not begin with 006)
            if(items.isEmpty())
            {
                // The Id is an Opportunity Line Item Id.
                // Find the full data for the Opportunity Line Item using the Salesforce Opportunity Line Item Id argument provided.
                //TW 3-13-2012 Added Product Code and Product2.Name
                //TW 5-21-2013: Added PreOrder BackOrder Handling for pick tickets on Line Items
                //TW: 6-10-13: Added Price Of Discounts
                items = [Select Id, OrderId, PriceBookEntryId, PriceBookEntry.Name, PricebookEntry.Product2.Description, PricebookEntry.Product2.ProductCode,Price_of_Discount__c,Estimated_Weight__c, 
                    PricebookEntry.Product2.Id, Quantity, Quantity_Backordered__c, Quantity_Fillable__c, PriceBookEntry.UnitPrice,  UnitPrice, ListPrice, TotalPrice, Line_Type__c,PreOrder_BackOrder_Handling__c,Product2.Family
                    From OrderItem Where Id = :sfid order by createddate];
            }
            system.debug('<<PRICE OF DISCOUNT>> '+items );
            system.debug('<<GETOLI>> '+items);
            // Return the found Line Items (or blank)
            return items;
        }
        // If an error occurred while Converting the provided Opportunity or Line Item Salesforce Id to a Salesforce Id or while finding the Line Item(s)
        // Return blank (null) 
        catch (Exception exc) { return null; }
    }
  
    /*MIGRATION FROM OPPORTUNITY TO ORDER*/
    
    webservice static List<ChargentOrders__Transaction__c> GetTransactions(string chargentOrderId)
    {
        // If the Opportunity Salesforce Id argument provided is blank
        // Return blank 
        if(chargentOrderId == null) { return null; }
        chargentOrderId = String.escapeSingleQuotes(chargentOrderId);
        
        // Otherwise
        // Find all Transactions (ChargentSFA__Transaction__c) using the Salesforce Opportunity Id argument provided.
        //TW: 10-12-2012 Added Response_Code and Gateway ID attributes within query so  in order to verify 77780 100% discounts.       
        List<ChargentOrders__Transaction__c> transactions = [select Id, Name, ChargentOrders__Amount__c,ChargentOrders__Response_Status__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Reason_Code__c,
            ChargentOrders__Response_Message__c, ChargentOrders__Type__c 
            from ChargentOrders__Transaction__c where ChargentOrders__Order__c = :chargentOrderId];
        //Add test for ChargentSFA_Response_Message__c.toLowerCase().contains()
        // Return the List of Transactions found (or blank)
        return transactions;
    }
    

    
    /*
     * IMPORTANT: This webservice should be checked with OrderEntry_JavaScript's loadSelectableMozo method to make sure changes are synchronized and identical
     * 
     * Method:  GetMozoProRate
     * Inputs:  string SalesforceOpportunityId - Opportunity ID string.
     *          string UpgradeLevel - The Mozo Upgrade Level access by the OE Java Script Mozo Upgrade Menu which will be placed in the OLI's Upgrade Level field.
     *      <OpporunityLineItem> Line Item - The Line Item created by web service AddProduct which will be updated to recieved the Mozo Upgrade Level and Price .
   * Output:  The Next Order Number in string format (or blank).
     * Purpose: This webservice contains no validation and does not return a Result object with variables for Success and Message. 
     *          If an error occurs, a default Salesforce exception message will be thrown, or a null value will be returned. 
     *          GetNextOrderNumber should be called instead. 
     * SOQL:    2
     * DML:     0
     *
     *     
     */    
    webservice static Result GetUpgradeRate(decimal UpgradePrice, string UpgradeLevel, decimal UpgradeDiscount, string UpgradePromoCode, OrderItem LineItem){
      OrderItem oli = (OrderItem)LineItem;
     
      oli.Upgrade_Level__c = UpgradeLevel;
        oli.UnitPrice = UpgradePrice;
        system.debug('<< UPGRADE LEVEL :>> '+UpgradeLevel+' <<UNIT PRICE>>: '+oli.UnitPrice+' <<Length of UPGRADE LEVEL>>: '+UpgradeLevel.length());
        if(UpgradePromoCode != null && UpgradePromoCode != ''){
          //oli.TotalPrice = UpgradePrice - UpgradeDiscount;
          oli.UnitPrice = UpgradePrice - UpgradeDiscount;
        }
        
      upsert oli;
      system.debug('OLI UPDATED '+oli);
      return new Result(true,'Product ("'+oli.PricebookEntry.Name+'") Successfully Updated. ',oli);
    }

    /*
     * Method:  insertPlainChargentOrder
     * Inputs:  Void
     * Output:  plain Chargent Order
     * Purpose: This webservice contains no validation and does not return a Result object with variables for Success and Message. 
     *          If an error occurs, a default Salesforce exception message will be thrown, or a null value will be returned. 
     *       . 
     * Author:    Darshan Chhajed.
    */ 
    webservice static Result createChargentOrder(){
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        try{
            insert COrder;
            return new Result(true,'Chargent Order', COrder);
        }catch(Exception e){
            system.debug('*Exception:createChargentOrder:Trace:'+e.getStackTraceString()+'  MSG-'+e.getMessage());
        }
        return new Result(false,'Insertsion Failed');
        
    }
    
    //TW: 2-13-2012 New Method to get price books by company.
      /* 
     * Method:  GetAllPriceBooks
     * Inputs:  string AccountSalesforceId - The Id of an Account.
     * Output:  A result object containing Success, a message, and a list of Pricebook (Pricebook2) records.
     * Purpose: To get an ordered list of Pricebooks for a specific Account Record Id in order to allow CCare Overrides for Registration Credits 
     *            the Pricebook list must be sorted in ascending name order.
     * SOQL:    1
     * DML:     0
     */
 webservice static Result GetAllPriceBooks(String AccountSalesforceId){
    // Get latest two Registration Histories when a Credit is selected
    List<Account> acctUSOrg = [Select Id from Account WHERE RecordType.Name = 'US Organization' and Id =: AccountSalesforceId Limit 1];
    if(acctUSOrg.size() > 0){   
        List<Pricebook2> pricebooks = [Select Id, Name from Pricebook2 where isActive = true Order by Name ASC];
        if(pricebooks.size() > 0){
            return new Result(true, 'Success, PriceBooks found.', pricebooks);
        }
    }
            
        return new Result(false, 'Failure, Not a US Org Registered Account.');
  }
   
   /*
     * Method:  resendConfirmationEmail
     * Inputs:  orderId
     * Output:  success /error message as a string
     * Purpose: This method will be called from the button on the Order record. If the order statu is 'Order Confirmed', then this will send the
                order confirmation email to the email id of the associated Contact of the Order which can be found from Order Contact Role recod.
     
     * Author:    Mayur Soni.
    */ 
     webservice static String resendConfirmationEmail(String orderId){
        String retMsg = '';
        String templateName = 'Email_Credit_Card_Receipt';
        list<Messaging.SingleEmailMessage> emailTobeSent = new list<Messaging.SingleEmailMessage>();
        Order orderObj = [SELECT Id,Name,Payment_Terms__c,Status,ExtraEmail__c FROM Order WHERE Id=:orderId LIMIT 1];
        if(orderObj.Payment_Terms__c.equalsIgnoreCase('Sales Credit')) // if the order is sales credit select the sales credit tempalte
            templateName='Email_Credit_Receipt';
        if(orderObj.Payment_Terms__c.equalsIgnoreCase('Net 30')) // if the order is Net 30 select the Invoice email template
            templateName='EmailInvoiceReceipt';
        
        list<EmailTemplate> emailTemplateLst = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:templateName];
        OrgWideEmailAddress orgEmail = [select id,Address from OrgWideEmailAddress where Address = 'donotreply@awana.org'];
        list<Order_Contact_Role__c> orderContactRoleLst = [SELECT Id,Contact__c,Order__c FROM Order_Contact_Role__c WHERE Order__c =:orderId];
        map<Id,Id> orderToOCRMap = new map<Id,Id>();
        try{
          for(Order_Contact_Role__c OCR : orderContactRoleLst){
            orderToOCRMap.put(OCR.Order__c,OCR.Contact__c);  
          }  
          if(emailTemplateLst!=null && emailTemplateLst.size()>0){
            list<String> emailIdLst = new list<String>();
            if(orderObj.ExtraEmail__c !='' && orderObj.ExtraEmail__c!=null){
                emailIdLst =  orderObj.ExtraEmail__c.Split(',');
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(!emailIdLst.isEmpty())
                mail.toAddresses = emailIdLst;
            mail.setTemplateId(emailTemplateLst.get(0).Id);
            mail.setTargetObjectId(orderToOCRMap.get(orderObj.Id));
            mail.setWhatId(orderObj.ID);
            emailTobeSent.add(mail);
            mail.setOrgWideEmailAddressId(orgEmail.Id);
            Messaging.sendEmail(emailTobeSent);
            retMsg = 'Email sent successfully.';
         }
        }catch(Exception e){
          system.debug('Exception Occured'+e.getStackTraceString()+'  MSG-'+e.getMessage());
          retMsg = e.getMessage();
        } 
        return retMsg;
    }
    /*
     * Method:  applyDiscount
     * Inputs:  orderId,list<productIds>, percentage discount, promocode
     * Output:  success /error message as a string
     * Purpose: This method accepts products on which discount should be applied.  
     * Author:    Darshan Chhajed.
    */ 
    webservice static String applyDiscount(String orderId,list<string> productsId,string promocode, decimal discount,boolean isFreeFrieght){
        system.debug('orderid '+orderId +' '+productsId+' '+promocode+' '+discount+' '+isFreeFrieght);
        string returnMsg = '';
        if(orderId == null)
        {
            // Return failure and an error message. 
            returnMsg = 'Error : Please supply both a valid Salesforce Order Id';
        }
        boolean isPromocodeAlreadyApplied = false;
        try{
            decimal dis =0;list<OrderItem> orderItemLst;
            if(!isFreeFrieght)
                orderItemLst = [SELECT Id,Product2Id,UnitPrice,OrderId,Price_of_Discount__c,Promo_Code__c,Product2.Name FROM OrderItem WHERE OrderId=:orderId AND Id IN :productsId];
            else
                orderItemLst = [SELECT Id,UnitPrice,OrderId,Price_of_Discount__c,Promo_Code__c,Product2.Name FROM OrderItem WHERE OrderId=:orderId AND Product2.ProductCode='43490'];  
            system.debug('orderItemLst'+JSON.serialize(orderItemLst));
            if(orderItemLst!=null){
                for(OrderItem item : orderItemLst){
                        system.debug('Promocode'+item.Promo_Code__c);
                        if(item.Promo_Code__c!=null)
                        {
                            isPromocodeAlreadyApplied = true;
                            if(!isFreeFrieght)
                                returnMsg = returnMsg + item.Product2.Name+' ';
                        }
                        else if(discount!=0){
                            system.debug('item.UnitPrice'+item.UnitPrice);
                            dis =  (item.UnitPrice * discount)/100;
                            system.debug('discount calculated'+dis);
                            if(item.UnitPrice - dis >= 0)
                                item.UnitPrice = item.UnitPrice - dis;
                            system.debug('new unit price'+item.unitPrice);
                            item.Price_of_Discount__c = discount; 
                            item.Promo_Code__c = promocode;
                        }    
                    } 
                update orderItemLst;
            }
            else{
                returnMsg =  'Error : No Order Item found with provided Ids';
            }
        }catch(Exception e){
            system.debug('Exception'+e.getStackTraceString()+' MSG-'+e.getMessage());
            return 'Exception Occured'+e.getMessage();
        }
        if(isFreeFrieght && isPromocodeAlreadyApplied)
            returnMsg = 'Free Shipping has already been added.';
        else if(isPromocodeAlreadyApplied)
            returnMsg =  returnMsg + ' for these products, promocodes are already applied';
        else
            returnMsg =  'Promocodes are applied successfully'; 
        return returnMsg;
    }
    
    /*
     * Method:  updateAccBillAddress
     * Inputs:  String accountid,String street,string city,string state,string country,string zipcode.
     * Output:  success /error message as a string
     * Purpose: This method updates billing address for the account.  
     * Author:  Urvashi Dagara.
    * SF-123 */ 
    webservice static result updateAccBillAddress(string accountid,string street,string city,string state,string zipCode, string country){

        string returnMsg = '';
        if(string.isNotBlank(accountid) && string.isNotBlank(street) && string.isNotBlank(city) && string.isNotBlank(state)
          && string.isNotBlank(zipCode) && string.isNotBlank(country)){
            try{
            Account acc = [SELECT Id,BillingStreet,BillingCity,BillingState,BillingCountry,Billingpostalcode
                           FROM Account WHERE Id=:accountid LIMIT 1];
            
              acc.BillingStreet = street;
              acc.BillingCity = city;
              acc.BillingState = state;
              acc.BillingCountry = country;
              acc.BillingPostalCode = zipCode;
              
              
                    update acc;
              }catch(exception e){
                  return new Result(false, 'Failure, Something went wrong. Please contact the Salesforce System Administrator with any questions.');
              }
              
              return new Result(true, 'Address updated successfully. You may continue creating the order.');
          }else{

                return new Result(false, 'Address or Account information is not completed.');
          }
    }
    
    /*
     * Method:  findRealtedStates
     * Inputs:  String countryName
     * Output:  success /error message as a string
     * Purpose: This method return related state name from given country.  
     * Author:  Urvashi Dagara.
     * SF-123
    */ 
    webservice static Result findRealtedStates(String countryName){
        
        List<RelatedCountryState__c> countryVsStateList = [SELECT Abbreviation__c 
                                                           FROM RelatedCountryState__c  
                                                           WHERE CountryName__c =: countryName 
                                                           ORDER BY Abbreviation__c ASC]; 
        
        return new Result(true, 'Success, State found.', countryVsStateList);
    }
    
    
    /*
     * Method:  removeDiscount
     * Inputs:  orderId,list<productIds>
     * Output:  success /error message as a string
     * Purpose: This method remove discounts applied previosuly on products.  
     * Author:    Darshan Chhajed.
    */ 
    webservice static String removeDiscount(String orderId,list<string> productsId){
        string returnMsg='';
        if(orderId == null)
        {
            // Return failure and an error message. 
            returnMsg = 'Error : Please supply both a valid Salesforce Order Id';
        }
         list<OrderItem> orderItemLst = [SELECT Id,Product2Id,UnitPrice,OrderId,ListPrice,Price_of_Discount__c,Promo_Code__c,Product2.Name FROM OrderItem WHERE OrderId=:orderId AND Id IN :productsId];
         
         boolean isPromocodeAlreadyApplied = false;
         for(OrderItem item : orderItemLst){
            if(item.Promo_Code__c=='' || item.Promo_Code__c == null){
                returnMsg = returnMsg + item.Product2.Name;
                isPromocodeAlreadyApplied = true;
            }
            else{
                item.Promo_Code__c='';
                item.UnitPrice = item.ListPrice;
                item.Price_of_Discount__c = 0;
            }
         }
         update orderItemLst;
         if(isPromocodeAlreadyApplied)
            returnMsg= returnMsg + ' NO PROMCODE WERE APPLIED to these products';
         else 
            returnMSG= 'Prmocode removed successfully.';    
        return returnMSG;
    } 
}//Class