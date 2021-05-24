/*****************************************
    Programmer: Matthew Keefe
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Order Entry in Salesforce
    Updated:    10/27/2009
    Note   :    This class requires API version 12
 *****************************************/

global class registration 
{
    WebService static string nextRegistrationNumber(string prefix)
    {
        string regnum = null;
        Boolean createNewEntry = false;
        //System.debug('------Test--in registration method');
        // for testing only
        //string prefix = 'US'; // other valid values are: EC, ECCM, ZW, CA, etc.
    
        // get the last registration number
        /*List<Account> last_account = [SELECT Id, Mailing_Address_Book__c, Registration_Number__c 
                            FROM Account 
                            WHERE Registration_Number__c LIKE :prefix+'%' 
                            AND Registration_Number__c < :prefix+'A' // this makes sure the next character is a number
                            AND Registration_Number__c != null 
                            AND IsDeleted = false 
                             // AND IsPersonAccount = false registration numbers are not generated for person accounts
                            AND Mailing_Address_Book__c != null 
                            ORDER BY Registration_Number__c DESC 
                            NULLS LAST 
                            LIMIT 1];
        //System.debug('****New Query ***** '+prefix);                    
          */
          //By Mayur:
          //List<Church_Registration__c> last_account = [select Id,Last_Registration_Number__c from Church_Registration__c where Name = 'RegistrationSettings'];
          //By Mayur - new custom setting to get Registration number for each Country
          List<Account_Registration_Number__c> last_account = [SELECT Id,Last_Registration_Number__c,Name FROM Account_Registration_Number__c where name like :prefix];
        if(last_account.size() > 0)
        {
            //regnum = last_account[0].Registration_Number__c;
            regnum = last_account[0].Last_Registration_Number__c;
        }
        else
        {
            // generate a new registration number (after processed, the number will be [prefix]000001)
            regnum = prefix;
            
            //If Country not found in custom setting, add new entry in custom setting
            createNewEntry = true; 
            
            if(prefix.length() < 8)
            {
                // standard length is 8 characters; add the appropriate number of zeros
                for(Integer i=0;i<(8-prefix.length());i++) { regnum = regnum + '0'; }
            }
            else
            {
                regnum = regnum + '0000';
            }
            
        }

        // get the (normally two-digit) registration number prefix (country)
        
        string regnum_country = regnum.substring(0,prefix.length());
        string regnum_last = regnum.substring(prefix.length(),regnum.length());
        Integer regnum_next_integer = Integer.valueOf(regnum_last)+1;
        string regnum_next = String.valueOf(regnum_next_integer);
        
        //Mayur
        /*string regnum_country = prefix;//regnum.substring(0,prefix.length());
        string regnum_last =  regnum;//regnum.substring(prefix.length(),regnum.length());
        Integer regnum_next_integer = Integer.valueOf(regnum_last)+1;
        string regnum_next = String.valueOf(regnum_next_integer);
        */
        // pad with the correct number of zeros
        //   if the last registration number is longer than the next registration number
        //   because converting between string and integer sometimes truncates zeros 
        if(regnum_next.length() < regnum_last.length())
        {
            // get the correct number of zeros (max) to add to the next registration number
            Integer max = (regnum_last.length()-regnum_next.length());
            
            // pad with zeros until max is reached 
            for(Integer i=0;i<max;i++) { regnum_next = '0'+regnum_next; }
        }

        // put the registration number back together with the country code
        string compiledRegNum = (regnum_country + regnum_next);   
        if(last_account.size() > 0){
            updateLastRegistrationNumber(last_account[0].Id, compiledRegNum);
        }
        if(createNewEntry ==true){
            createLastRegistrationEntry(prefix,compiledRegNum);
        }
        //system.debug(compiledRegNum);
        return compiledRegNum;
    }
    
    WebService static string nextCustomerNumber()
    {
        string cn_last = null;
        
        // get the last address book number 
        List<Church_Registration__c> last_account = [select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'];
        
        if(last_account.size() > 0)
        {
            cn_last = last_account[0].Last_Customer_Number__c;
        }
        else
        {
            // generate a new customer number (after processed, the number will be 0000001)
            cn_last = '0000000';
        }
        
        // change the string to an integer
        Integer cn_last_integer = Integer.valueOf(cn_last);
        
        // add 1 to the integer and convert it back to a string
        string cn_next = string.valueOf(cn_last_integer + 1);
        
        // pad with the correct number of zeros
        //   if the last customer number is longer than the next customer number
        //   because converting between string and integer sometimes truncates zeros 
        if(cn_next.length() < cn_last.length())
        {
            // get the correct number of zeros (max) to add to the next customer number
            Integer max = (cn_last.length()-cn_next.length());
            
            // pad with zeros until max is reached 
            for(Integer i=0;i<max;i++) { cn_next = '0'+cn_next; }
        }
        
        if(last_account.size() > 0)
        {
            updateLastCustomerNumber(last_account[0].Id, cn_next);
        }

        return cn_next;
    }

    //@future // execute this at some point in the very near future.. runs as a separate process..
    // this is needed because there's a MIXED_DML_OPERATION Error 
    //  (meaning that a setup object and a non-setup object cannot be updated or inserted as a part of the same trigger)
    //@future is not needed if the API version is 12
    private static void updateLastCustomerNumber(string last_id, string last_number)
    {
        Church_Registration__c last_account = [select Last_Customer_Number__c from Church_Registration__c where Id=:last_id];
        last_account.Last_Customer_Number__c = last_number;
        update last_account;
    }
    
    //Mayur
    private static void updateLastRegistrationNumber(string last_id, string last_number)
    {
        Account_Registration_Number__c last_account = [select Id,Last_Registration_Number__c from Account_Registration_Number__c where Id=:last_id];
        last_account.Last_Registration_Number__c = last_number;
        update last_account;
    }
    
    //Mayur
    private static void createLastRegistrationEntry(String prefix,String regNumber){
        Account_Registration_Number__c reg = new Account_Registration_Number__c(
                                            Name=prefix,Last_Registration_Number__c =regNumber
                                            );
        insert reg;
    }
    public static testMethod void NextRegistrationNumberTest()
    {
        Test.startTest();
        
        string reg_test_1 = 'x'; reg_test_1 = nextRegistrationNumber('US'); system.debug('Registration Test 1: '+reg_test_1);
        System.assert(  reg_test_1.length() > 2, 
                        'Error: Registration Number was not properly generated for prefix \"US\". Registration Number Test: '+reg_test_1);
        
        string reg_test_2 = 'x'; reg_test_2 = nextRegistrationNumber('AE'); system.debug('Registration Test 2: '+reg_test_2);
        System.assert(  reg_test_2.length() > 2, 
                        'Error: Registration Number was not properly generated for prefix \"AE\". Registration Number Test: '+reg_test_2);
        
        string reg_test_3 = 'x'; reg_test_3 = nextRegistrationNumber('ECCM'); system.debug('Registration Test 3: '+reg_test_3);
        System.assert(  reg_test_3.length() > 4, 
                        'Error: Registration Number was not properly generated for prefix \"ECCM\". Registration Number Test: '+reg_test_3);
        
        string reg_test_4 = 'x'; reg_test_4 = nextRegistrationNumber('XX'); system.debug('Registration Test 4: '+reg_test_4);
        System.assert(  reg_test_4.length() > 2, 
                        'Error: Registration Number was not properly generated for prefix \"XX\". Registration Number Test: '+reg_test_4);
                        
        string reg_test_5 = 'x'; reg_test_5 = nextRegistrationNumber('ABCDEFGHIJ'); system.debug('Registration Test 5: '+reg_test_5);
        System.assert(  reg_test_5.length() > 10, 
                        'Error: Registration Number was not properly generated for prefix \"ABCDEFGHIJ\". Registration Number Test: '+reg_test_5);

        Test.stopTest();
    }
    
    public static testMethod void FirstNextCustomerNumberTest()
    {
        Test.startTest();

        // *** First Next Customer Number Test
        string cust_test_1 = nextCustomerNumber();
        System.assert((cust_test_1.length() > 6), 'Error: Customer Number was not properly generated. Customer Number Test: '+cust_test_1);

        Test.stopTest();
    }
    
    public static testMethod void SecondNextCustomerNumberTest()
    {
        Test.startTest();
        
        // *** Second Next Customer Number Test
        // display/debug the last account
        string last_account_number = [select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'].Last_Customer_Number__c;
        system.debug('*** Last Account Customer Number (after start): '+last_account_number);
        
        // try again
        string cust_test_2 = nextCustomerNumber();
        
        Test.stopTest();
        
        // display/debug the last account
        // this happens outside of the Test.startTest() and Test.stopTest() to allow the @future to complete
        last_account_number = [select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'].Last_Customer_Number__c;
        system.debug('*** Last Account Customer Number (after stop, should be +1 compared to previous): '+last_account_number);
        
    }
    
    public static testMethod void ThirdNextCustomerNumberTest()
    {
        Test.startTest();

        // *** Third Next Customer Number Test
        // try calling the method to update the last customer number directly
        string cust_test_3 = nextCustomerNumber();
        updateLastCustomerNumber([select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'].Id, cust_test_3);

        Test.stopTest();
    }

    public static testMethod void FourthNextCustomerNumberTest()
    {
        Test.startTest();

        // *** Fourth Next Customer Number Test
        // test the nextCustomerNumber method where there is no Church_Registration__c named Max
        List<Church_Registration__c> last_accounts = [select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'];
        
        if(last_accounts.size() > 0)
        {
            for(Church_Registration__c last_account : last_accounts) { delete last_account; }
        }
        
        string cust_test_4 = nextCustomerNumber();

        Test.stopTest();
    }
    
    public static testMethod void CreateNewAccounts()
    {
        Test.startTest();
        List<Account> acctsToInsert =new List<Account>();
        string last_account_number = [select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'].Last_Customer_Number__c;
        system.debug('*** Last Account Customer Number (after start): '+last_account_number);
        
        Account a = new Account(Name='New International Church of Test 101', PhysicalCountry__c='AE');
        Account b = new Account(Name='New International Church of Test 102', PhysicalCountry__c='AE');
        Account c = new Account(Name='New International Church of Test 103', PhysicalCountry__c='AE');
        acctsToInsert.add(a);
        acctsToInsert.add(b);
        acctsToInsert.add(c);
        /*
        insert a;
        insert b;
        insert c;
        */
        insert acctsToInsert;
        
        
        last_account_number = [select Last_Customer_Number__c from Church_Registration__c where Name = 'RegistrationSettings'].Last_Customer_Number__c;
        system.debug('*** Last Account Customer Number (after stop): '+last_account_number);
        Test.stopTest();
    }
    
    
}