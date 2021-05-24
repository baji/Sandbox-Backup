@RestResource(urlMapping='/NextOrderNumber/*')
global class NextOrderNumberRestService {
    
    /*
    @HttpGet
    global static String sendOrderNumber() {
      try
      {
        List<Order> o = [select Id,OrderNumber,Name from Order ORDER BY OrderNumber Desc Limit 5];
        system.debug('**********'+o[0]);
        return o[0].Name;
      }
      Catch(Exception e){
            return String.valueOf(e);
      }
    }
    */
    global class MyClass {
        public String Success;
        public String OrderNumber;
        public String Error;

        public MyClass(String s, String i, String e) {
            this.Success = s;
            this.OrderNumber = i;
            this.Error = e;
        }
    }
    @HttpPost
    global static MyClass GetNextOrderNumber(string Prefix, string AccountCustomerNumber)
    {
        string NextOrderNumber = null;
        
        // If the Prefix argument is blank, default it to O for Order.
        if(Prefix == null || Prefix == '') { 
            Prefix = 'O'; 
        }
        
        // If the AccountCustomerNumber argument is blank, return Success as false and an error message. 
        if(AccountCustomerNumber == null || AccountCustomerNumber == '') { 
            //return 'Account Customer Number is required.';
            MyClass obj = new MyClass('false', '','Account Customer Number is required. ');
            return obj;
        }
        
        try
        {
            // Call the NextOrderNumber web service, passing the Prefix and AccountCustomerNumber arguments.
            // If an error occurs in the NextOrderNumber web service, return Success as false and an error message. 
            NextOrderNumber = NextOrderNumber(Prefix,AccountCustomerNumber);
        } 
        catch(Exception exc) { 
            //return 'An error occurred while generating the next order number. ';
            MyClass obj = new MyClass('false', '','An error occurred while generating the next order number. ');
            return obj;
        }
        
        // If the Order number (or name) returned by the NextOrderNumber web service is not blank.
        if(NextOrderNumber != null) 
        {
            // and the Order number (or name) length is greater than 1, return Success as true and the new Order number. 
            if(NextOrderNumber.length() > 1) { 
                    //return 'Successfully generated a new order number '+NextOrderNumber;
                    MyClass obj = new MyClass('true', NextOrderNumber,'');
                    return obj;
                } 
        }
        
        // Otherwise (else), return Success as false, an error message, and the new Order number.
        //return 'An unknown error occurred while generating the next order number. ';
        MyClass obj = new MyClass('false', '','An unknown error occurred while generating the next order number. ');
        return obj;
    }

global static string NextOrderNumber(string Prefix, string AccountCustomerNumber)
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
}