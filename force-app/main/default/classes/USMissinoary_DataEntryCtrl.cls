/***********************************************************************************************************************************************
    Programmer: Shaik Baji
    Company:    Awana
    Contact:   shaikbaji.a@ecgroup-intl.com
    Project:    USMissionary_DataEntryCtrl to allow missionaries to update tasks,account,contacts, and MA opportuntys
    Original:   10/9/2013  - Uses a UserID inorder to get a reset password
     ***********************************************************************************************************************************************/

public class USMissinoary_DataEntryCtrl {

   

   
    //Getters & Setters , variables
    public List<Account> con_dis{get;set;}    
    public List<Contact> sconList{get;set;}
    public List<Opportunity> soppList{get;set;}
    public List<Task> staskList{get;set;}
    public id s{get;set;}
    public id sc{get;set;}
    public id oppId{get;set;}
    public id taskId{get;set;}
    public id radioConId{get;set;}
    public id radioOppId{get;set;}
    public String Err { get; set; }
    public list<Account> searchResults{get;set;}
    public list<Account> searchResultspmm{get;set;}
    public Profile prfl;
    public List<Profile> plist;
    public boolean editbtn{get;set;}
    public boolean tablehide{get;set;}
    public boolean acceditbtn{get;set;}
    public boolean acctablehide{get;set;}
    public boolean oppeditbtn{get;set;}
    public boolean oppeditbtntype{get;set;}
    public boolean opptablehide{get;set;}
    public boolean taskeditbtn{get;set;}
    public boolean tasktablehide{get;set;}
     //Address variables
    public boolean addtablehide{get;set;}
    public boolean addeditbtn{get;set;}
    //end of address variables
    
    public String accName;
        
    
    public RecordType arecord = new RecordType();            // Account Registration record types
    public RecordType marecord = new RecordType();           //Ministry Advancement Opportnity Record Type
    public String opprecord = null;
    public String maopprecord = null;
    
    //added for to find opportunity Type
    public String oppType{get;set;}
    
    public PageReference getSelected() {            
        radioConId = ApexPages.currentPage().getParameters().get('rid');
        return null;
    }
    public PageReference getSelectedopp() {            
        radioOppId = ApexPages.currentPage().getParameters().get('opid');
        return null;
    }
    
    //address Methods
    public PageReference addEdit(){
         addtablehide = true;
         addeditbtn = true;
        return null;
     }
    public PageReference canaddEdit(){
       if(addtablehide == true ||addeditbtn == true){
            
            addtablehide = false;
            addeditbtn = false;          
        }
        return null; 
    } 
     //end of address methods
     
    /*************************************************************************************
    canEdit: Toggles the visibility of the edit button for the USMissionary_DataEntry page.
    **************************************************************************************/
    public PageReference canEdit(){
        if(acctablehide == true ||acceditbtn == true){
            
            acctablehide = false;
            acceditbtn = false;          
        }
        return null;
     }   
     
    /*************************************************************************************************
    conCancel: Toggles the visibility of the Contact cancel button for the USMissionary_DataEntry page.
    **************************************************************************************************/ 
    public PageReference conCancel(){
        if(tablehide == true || editbtn == true){
            
           tablehide = false;
           editbtn = false;           
        }         
         return null;
    }
    
    /****************************************************************************************************
    oppCancel: Toggles the visibility of the opportunity edit button for the USMissionary_DataEntry page.
    *****************************************************************************************************/ 
    public PageReference oppCancel(){
        if(opptablehide == true || oppeditbtn == true){
            
           opptablehide = false;
            oppeditbtn = false;                       
        }         
         return null;
    }
    
    /****************************************************************************************************
    oppCancel: Toggles the visibility of the opportunity  cancel button for the USMissionary_DataEntry page.
    *****************************************************************************************************/ 

    public PageReference oppTypeCancel(){
        if(opptablehide == true || oppeditbtntype == true){
            
           opptablehide = false;               
           oppeditbtntype = false;
        }         
         return null;
    }
    /****************************************************************************************************
    taskCancel: Toggles the visibility of the task cancel button for the USMissionary_DataEntry page.
   *****************************************************************************************************/ 
     public PageReference taskCancel(){
        if(tasktablehide == true || taskeditbtn == true){
            
           tasktablehide = false;
           taskeditbtn = false;           
        }         
         return null;
    }
    
   /****************************************************************************************************
    accedit: Toggles the visibility of the Account edit button for the USMissionary_DataEntry page.
   *****************************************************************************************************/ 
    public PageReference accedit(){
        acctablehide = true;
        acceditbtn = true;
        return null;
    }
   
   /****************************************************************************************************
    oppedit: Toggles the visibility of the Opportunity edit button based on Opportunity Type
   *****************************************************************************************************/  
    public PageReference oppedit(){
  // If thisis a Ministry  Connection or Donation type, don;t allow any editing by missionaries.
        if(oppType == 'Ministry Connection' || oppType == 'Donation')
        {
            opptablehide = true;
            oppeditbtn = false;
            oppeditbtntype = true;
        }
        else
        {
            opptablehide = true;
            oppeditbtn = true;
            oppeditbtntype = false;
        }
        return null;
    }
    
   /****************************************************************************************************
    taskCancel: Toggles the visibility of the task edit button for the USMissionary_DataEntry page.
   *****************************************************************************************************/ 
    public PageReference taskedit(){
        tasktablehide = true;
        taskeditbtn = true;
        return null;
    }
    public PageReference edit(){
        tablehide = true;
        editbtn = true;
        return null;
    }
    //constructor
    public USMissinoary_DataEntryCtrl() {
    
     arecord = [SELECT Id from RecordType where name = 'Orders' limit 1]; 
     opprecord = String.valueOf(arecord.Id);
     
     marecord = [SELECT Id from RecordType where name = 'Ministry Advancement' limit 1]; 
     maopprecord = String.valueOf(marecord.Id);
    }    
    /*      ******* searching values  ************  */  
    //Account Name or Customer ID search string
    public string searchText {
        get
        {  
            if(searchText==null) {  return searchText;  }
            
            else { return searchText; }                
        }  
        set;
    }
     //City Search string
     public string searchtextCID {
        get
        {  
            if(searchtextCID==null) {  return searchtextCID;  }
            
            else { return searchtextCID; }                
        }  
        set;
    }
    //State Search string
    public string state {
        get
        {  
            if(state==null) {  return state;  }
            
            else { return state; }                
        }  
        set;
    }
    
    public Boolean inactiveCheckbox {
        get
        {  
            if(inactiveCheckbox==false) {  return inactiveCheckbox;  }
            
            else { return inactiveCheckbox; }                
        }  
        set;
    }
       
    //End of searching values
    
    /*   ************** search Method***************  */
   public PageReference search(){
    //If we only want to search for active churches ...
    if(inactiveCheckbox == false)
    {
     
     system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+inactiveCheckbox); 
     //... If the Account name and City are null , grab the first 1000 active US Organizatonal churches
     if( (searchText == null || searchText.trim().equals('')) &&  (searchtextCID == null || searchtextCID.trim().equals('')) &&  (state != null && !state.trim().equals('')) )
       {
       
          // searchResults = new List<Account>();          
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Physical_City__c LIKE \'' + searchtextCID + '%\')'                        
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        + 'And (Status__c = \'Added\' or Status__c = \'Prospect\' or Status__c = \'Ready To Activate\')'
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           
          // Else we found no active churches
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }  
       
     //If the Account name and State entered are null but the city is not, grab the first 1000 active US Organizatonal churches with that city.
     else if( (searchText == null || searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) &&  (state == null || state.trim().equals('')) )
       {
       
          // searchResults = new List<Account>();          
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Physical_City__c LIKE \'' + searchtextCID + '%\')'                        
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        + 'And (Status__c = \'Added\' or Status__c = \'Prospect\' or Status__c = \'Ready To Activate\')'
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           
          
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }  
       
       //If the Account name is null but the City  and State are not empty, grab the first 1000 active US Organizatonal churches with that criteria. 
      else if( (searchText == null || searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) &&  (state != null &&  !state.trim().equals('')) )
       {
       
         //  searchResults = new List<Account>();          
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Physical_City__c LIKE \'' + searchtextCID + '%\')'                        
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        + 'And (Status__c = \'Added\' or Status__c = \'Prospect\' or Status__c = \'Ready To Activate\')'
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           
          
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       } 
       
       //If the Account name or ID, City, and State are not empty, grab the first 1000 active US Organizatonal churches  with that criteria
       else if( (searchText != null &&  !searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) &&  (state != null &&  !state.trim().equals('')) )
       {
          // searchResults = new List<Account>();
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Name LIKE \'' + searchText + '%\' OR Mailing_Address_Book__c LIKE \'' + searchText + '%\')'
                        + 'And (Physical_City__c LIKE \'' + searchtextCID + '%\' )'
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        + 'And (Status__c = \'Added\' or Status__c = \'Prospect\' or Status__c = \'Ready To Activate\')'
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       } 
       
       //If Account Name or ID not empty and  
       else if( (searchText != null &&  !searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) )
       {
          // searchResults = new List<Account>();
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Name LIKE \'' + searchText + '%\' OR Mailing_Address_Book__c LIKE \'' + searchText + '%\')'
                        + 'And (Physical_City__c LIKE \'' + searchtextCID + '%\' )'
                        + 'And (Physical_State__c LIKE \'' + state + '%\' or Physical_State__c = null)'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        + 'And (Status__c = \'Added\' or Status__c = \'Prospect\' or Status__c = \'Ready To Activate\')'
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       } 
       else if(searchText != null &&  !searchText.trim().equals('') )
       {
          // searchResults = new List<Account>();
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Name LIKE \'' + searchText + '%\' OR Mailing_Address_Book__c LIKE \'' + searchText + '%\')'
                        + 'And (Physical_City__c LIKE \'' + searchtextCID + '%\' or Physical_City__c = null)'
                        + 'And (Physical_State__c LIKE \'' + state + '%\' or Physical_State__c = null)'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        + 'And (Status__c = \'Added\' or Status__c = \'Prospect\' or Status__c = \'Ready To Activate\')'
                        +' Order By Name,Physical_City__c,Physical_State__c Limit 1000';
           
           searchResults = Database.query(qry);
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }
       
      } 
      else if(inactiveCheckbox == true)
      {
          system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+inactiveCheckbox);
       if( (searchText == null || searchText.trim().equals('')) &&  (searchtextCID == null || searchtextCID.trim().equals('')) &&  (state != null && !state.trim().equals('')) )
       {
       
          // searchResults = new List<Account>();          
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Physical_City__c LIKE \'' + searchtextCID + '%\')'                        
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        //+ 'And Status__c = \'Added\''
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           
          
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }  
       
     
     else if( (searchText == null || searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) &&  (state == null || state.trim().equals('')) )
       {
       
         //  searchResults = new List<Account>();          
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Physical_City__c LIKE \'' + searchtextCID + '%\')'                        
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        //+ 'And Status__c = \'Added\''
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           
          
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }  
       
      else if( (searchText == null || searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) &&  (state != null &&  !state.trim().equals('')) )
       {
       
         //  searchResults = new List<Account>();          
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Physical_City__c LIKE \'' + searchtextCID + '%\')'                        
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        //+ 'And Status__c = \'Added\''
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           
          
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }  
       else if( (searchText != null &&  !searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) &&  (state != null &&  !state.trim().equals('')) )
       {
         //  searchResults = new List<Account>();
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Name LIKE \'' + searchText + '%\' OR Mailing_Address_Book__c LIKE \'' + searchText + '%\')'
                        + 'And (Physical_City__c LIKE \'' + searchtextCID + '%\' )'
                        + 'And (Physical_State__c LIKE \'' + state + '%\' )'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                       // + 'And Status__c = \'Added\''
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }  
       else if( (searchText != null &&  !searchText.trim().equals('')) &&  (searchtextCID != null &&  !searchtextCID.trim().equals('')) )
       {
         //  searchResults = new List<Account>();
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Name LIKE \'' + searchText + '%\' OR Mailing_Address_Book__c LIKE \'' + searchText + '%\')'
                        + 'And (Physical_City__c LIKE \'' + searchtextCID + '%\' )'
                        + 'And (Physical_State__c LIKE \'' + state + '%\' or Physical_State__c = null)'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        //+ 'And Status__c = \'Added\''
                        +'Order By Name Limit 1000';
           
           searchResults = Database.query(qry);
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       } 
       else if(searchText != null &&  !searchText.trim().equals('') )
       {
         //  searchResults = new List<Account>();
          Err = '';
                                   
            String qry =  'Select Id, Name,Physical_State__c,Physical_City__c '
                        +'from Account'
                        +' where (Name LIKE \'' + searchText + '%\' OR Mailing_Address_Book__c LIKE \'' + searchText + '%\')'
                        + 'And (Physical_City__c LIKE \'' + searchtextCID + '%\' or Physical_City__c = null)'
                        + 'And (Physical_State__c LIKE \'' + state + '%\' or Physical_State__c = null)'
                        + 'And (RecordType.Name like \'%US Organization%\')'
                        //+ 'And Status__c = \'Added\''
                        +' Order By Name,Physical_City__c,Physical_State__c Limit 1000';
           
           searchResults = Database.query(qry);
           if(searchResults != null && searchResults.isEmpty())
           {
                Err  = 'Records not found for your search';
           }          
       }
      }
       else
       {
           searchResults = null;
           Err = 'Please enter the String to search';
       }
       
       return null;
     
     
    }
   
    // Account Details    
    public List<Account> getnewm()
    {
      con_dis = [select Id,Name,Phone,Fax,Website,Mailing_Address_Book__c,
                    Physical_City__c,Physical_Zip__c,Physical_State__c,Denomination__c,
                    Registration_Number__c,Registration_Date__c,Status__c,Date_Inactive__c,Language__c,
                    Account_On_Hold__c,Hold_Comments__c,OwnerId,BillingCity,BillingState,BillingPostalcode,BillingStreet,Billing_County__c,
                    ShippingCity,ShippingPostalcode,ShippingState,Mailing_City__c,Mailing_State_Province__c,Mailing_Zip_Postal_Code__c,
                    ShippingStreet,Shipping_County__c,Physical_Street_1__c,Physical_County__c,Mailing_Street_1__c,Mailing_County__c,
                    Mailing_Country__c,ShippingCountry,
                    Church_Attendance__c,Primary_Ethnic_Group__c,Primary_Moves_Manager__c,Primary_Moves_Manager__r.Id,Commander__r.Id,
                    Commander__c,BillingCountry,PhysicalCountry__c
                    From Account where id=:s];
      return con_dis ;
    } 
        
    public Account act;
    public Account getAct() {
        if(s == null){
            return null;
        }
        else{
            
            act = [select Id,Name,Phone,Fax,Website,Mailing_Address_Book__c,
                    Physical_City__c,Physical_Zip__c,Physical_State__c,Denomination__c,
                    Registration_Number__c,Registration_Date__c,Status__c,Date_Inactive__c,Language__c,
                    Account_On_Hold__c,Hold_Comments__c,OwnerId,BillingCity,BillingState,BillingPostalcode,BillingStreet,Billing_County__c,
                    ShippingCity,ShippingPostalcode,ShippingState,Mailing_City__c,Mailing_State_Province__c,Mailing_Zip_Postal_Code__c,
                    ShippingStreet,Shipping_County__c,Physical_Street_1__c,Physical_County__c,Mailing_Street_1__c,Mailing_County__c,
                    Church_Attendance__c,Primary_Ethnic_Group__c,Primary_Moves_Manager__c,Primary_Moves_Manager__r.Id,Commander__r.Id,
                    Commander__c,BillingCountry,PhysicalCountry__c
                    From Account where id=:s];
            return act;
        }    
    }   
    
    //Get Contacts if the contact list is not null.
    public List<Contact> getCons() {
        if(s == null){        
        return null;
     }
     else
     {
        //system.debug('@@@@@@***************@@@@@'+s);
         List<Contact> conList = [select Id,Name,Email,HomePhone,MobilePhone,Church_Role__c,Awana_Role__c,Active__c                                 
                                 From Contact where Account.Id = :s ORDER By Name ASC];
        return conList;
     }
    }  
    
    //Contact Details
    public List<Contact> getScon() {
        if(sc == null){        
        return null;
     }
     else
     {
        //system.debug('@@@@@@***************@@@@@'+sc);
        sconList = [select Id,LastName,FirstName,Email,MobilePhone,Church_Role__c,Awana_Role__c,CurrencyIsoCode,
                    Title,Mail_Code__c,Gender__c,Active__c,OwnerId,Phone,Fax,Alternate_Email_Address__c,HasOptedOutOfEmail,
                    Home_Address_Book__c,Home_County__c,Church_Role_Status__c,AreaRole__c,
                    HomePhone,OtherPhone,
                    OtherStreet,OtherCity,OtherState,OtherPostalcode,OtherCountry
                    From Contact where Id = :sc];
        return sconList;
     }
    }  
    
    public Contact cnt;
     public Contact getCnt() {
        if(sc == null){
            return null;
        }
        else{            
            cnt = [select Id,LastName,FirstName,Email,MobilePhone,Church_Role__c,Awana_Role__c,CurrencyIsoCode,
                    Title,Mail_Code__c,Gender__c,Active__c,OwnerId,Phone,Fax,Alternate_Email_Address__c,HasOptedOutOfEmail,
                    Home_Address_Book__c,Home_County__c,Church_Role_Status__c,AreaRole__c,
                    HomePhone,OtherPhone,
                    OtherStreet,OtherCity,OtherState,OtherPostalcode,OtherCountry
                    From Contact where Id = :sc];
            return cnt;
        }    
    }   
    
    
    //Opportunities
    public List<Opportunity> getOpps() {
        if(s == null){        
        return null;
     }
     else
     {
        //system.debug('@@@@@@***************@@@@@'+s);
         List<Opportunity> oppList = [select Id,Name,OwnerId,Created_Date_Time__c,Probability,Type,CloseDate,StageName,Country__c,Interest__c,Region__c From Opportunity 
                                      where Account.Id = :s 
                                      and (RecordTypeId =: opprecord or RecordTypeId =: maopprecord)];
        return oppList;
     }
    }  
   
    //opp Details
    public List<Opportunity> getSinopp(){
    
        if(oppId == null){
            return soppList;
        }
        else{            
            soppList = [select Id,Name,OwnerId,Created_Date_Time__c,Probability,Type,CloseDate,StageName,Country__c,Interest__c,Region__c From Opportunity where Id =: oppId];
            return soppList;
        }
    }  
    
     public Opportunity optnew;
     public Opportunity getOptnew() {
        if(oppId == null){
            return null;            
        }
        else{
            //system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^opp type you clicked is-- '+oppType);            
            optnew = [select Id,Name,OwnerId,Created_Date_Time__c,Interest__c,Region__c,Country__c,Project_Code__c,Probability,Type,CloseDate,StageName, 
                      (select ContactId from OpportunityContactRoles Limit 1)
                      From Opportunity where Id =: oppId];
            return optnew;
        }    
    }   
    public OpportunityContactRole opprole; 
    public OpportunityContactRole getOpprole() {
        if(oppId == null){
            return null;
        }
        else{          
                //opprole = [select Id,ContactId From OpportunityContactRole where OpportunityId =: oppId];             
                List<OpportunityContactRole> opprolelist = [select Id,ContactId From OpportunityContactRole where OpportunityId =: oppId];
                if(opprolelist.isEmpty())
                {
                    opprole = new OpportunityContactRole(OpportunityId = oppId);
                    return opprole;
                }
                else
                {
                    opprole = [select Id,ContactId From OpportunityContactRole where OpportunityId =: oppId Limit 1];
                    return opprole;
                }
            //return opprole;
        }    
    }   
    
     public OpportunityTeamMember oppteam; 
    public OpportunityTeamMember getOppteam() {
        if(oppId == null){
            return null;
        }
        else{          
                //opprole = [select Id,ContactId From OpportunityContactRole where OpportunityId =: oppId];             
                List<OpportunityTeamMember> oppteamlist = [select Id,TeamMemberRole,UserID From OpportunityTeamMember where OpportunityId =: oppId];
                if(oppteamlist.isEmpty())
                {
                    oppteam = new OpportunityTeamMember(OpportunityId = oppId);
                    return oppteam;
                }
                else
                {
                    oppteam = [select Id,TeamMemberRole,UserID From OpportunityTeamMember where OpportunityId =: oppId Limit 1];
                    return oppteam;
                }
            //return opprole;
        }    
    }   
    
    
    //List of Tasks
    
    public List<Task> getTasks() {
        if(s == null){        
        return null;
     }
     else
     {   
         list<string> idString = new list<string>();
         list<Opportunity> oppIds= [Select Id from opportunity where Account.Id =:s ];
         list<Contact> conIds = [Select Id from Contact where Account.Id =:s ];
         
         for(Opportunity op:oppIds)
         {
             idString.add(op.id);
         }
         
        idString.add(s);
        
            
         //List<Task> taskList = [select Id,OwnerId,whoId,whatId,Subject,Type,ActivityDate,Priority,Status From Task where whatid = :s];
         
         List<Task> taskList = [select Id,OwnerId,whoId,whatId,Subject,ActivityDate,Priority,Status,Type From Task 
                               //where whatid IN (select Id From Opportunity where Account.Id =:s)];
                               where whatid IN: idString or whoid IN: conIds];
        return taskList;
     }
    }  
    //Single Task Details 
    public List<Task> getEdittask() {
        //system.debug('********************************************************'+taskId);
        if(taskId == null){        
        return staskList;
     }
     else
     {       
         staskList = [select Id,OwnerId,whoId,whatId,Subject,Type,ActivityDate,Priority,Status From Task where Id = :taskId];
        return staskList;
     }
    }  
    
     public Task tasknew;
     public Task getTasknew() {
        if(taskId == null){
            return null;
        }
        else{            
             tasknew = [select Id,OwnerId,whoId,whatId,Subject,Type,ActivityDate,Priority,Status From Task where Id = :taskId];
            return tasknew;
        }    
    }   
      
    // Account Update method 
    public PageReference updateAccount()
    {
        system.debug('*************************************************************'+act);
        if(act<>null)
        update act ;
        acctablehide = false;
        acceditbtn = false;
        return null;
    }  
    public PageReference update1()
    {
         //system.debug('*************************************************************'+con_dis);
        if(con_dis<>null)
        update con_dis ;
        acctablehide = false;
        acceditbtn = false;
        return null;
    } 
    
    //Contact Update method
    public PageReference update2()
    {
        if(cnt<>null)
        update cnt;
        tablehide = false;
        editbtn = false;
        return null;
    }
    //Address Update method
    public PageReference updateAddress()
    {       
        if(act<>null)
        update act ;
        addtablehide = false;
        addeditbtn = false;        
        return null;
    }
    
    //Opportuniy Update
     public PageReference oppUpdate()
    {
        system.debug('^^^^^^^^^^^^^^^^^^^^^11111111111^^^^^^^^^^^^^^^^^^^^^^'+optnew);
        //if(optnew == null)
        //optnew = null;
        //if(optnew<>null)
        //else
        if(optnew != null)
        {
        //update optnew;
         
          if(optnew.closeDate == null){
             date newDate = system.today().adddays(14);
          optnew.closeDate = newDate;
          }
          else{
              date newDate = optnew.closeDate.adddays(14);
          optnew.closeDate = newDate;
          } 
          update optnew; 
         }                   
         //system.debug('^^^^^^^^^^^^^^^^^^^^^^^2222222222222^^^^^^^^^^^^^^^^^^^^'+opprole.contactId);  
           //if(opprole.contactId != null)
           if(opprole == null)
           {
              //system.debug('^^^^^^^^^^^^^^^^^^^^3333333333333^^^^^^^^^^^^^^^^^^^^^^^'+opprole.contactId);  
               //upsert opprole;
               opprole = null;
           }
           else
           {
               //system.debug('^^^^^^^^^^^^^^^^^^^^Controller came^^^^^^^^^^^^^^^^^^^^^^^'+opprole.contactId); 
               //opprole = null;
               if(opprole.contactId == null)
               {
                   opprole = null;
               }
               else
               {
               upsert opprole;
               }
           }
            
        // upsert opprole;
        opptablehide = false;
        oppeditbtn = false;
        oppeditbtntype = false;
        return null;
    }    
    public PageReference taskUpdate()
    {
        if(tasknew<>null)
            update tasknew;
        tasktablehide = false;
        taskeditbtn = false;
        return null;
    } 
    //Add Contact Block
    Contact con;
    public Contact getCon(){
        if(con == null){
            con = new Contact(Active__c=true);
        } 
        return con;
    }    
    
       
    //contact save method
    public PageReference conSave(){
        con.AccountId = s;                
        //system.debug('*****************************************'+con);
        
         if(con.LastName == null){
            con.lastName='LastName';
        }
        else{
            con.lastName=con.LastName;
            
        }
        insert con;
        con = null;
        return null;
    }    
    
    //Add Opportunity block
    Opportunity opp;
    
    OpportunityContactRole role;
    public OpportunityContactRole getRole(){
        if(role == null){
            role = new OpportunityContactRole();
        }
        return role;
    }
    
    OpportunityTeamMember otm;
    public OpportunityTeamMember getOtm(){
        if(otm == null){
            otm = new OpportunityTeamMember();
        }
        return otm;
    }
 /*   OpportunityTeamMember otm1;
    public OpportunityTeamMember getOtm1(){
        if(otm1 == null){
            otm1 = new OpportunityTeamMember();
        }
        return otm1;
    }
    
   */ 
    
     public Opportunity getOpp(){
        if(opp == null){
            opp = new Opportunity(RecordTypeId=maopprecord);
            opp.Name = 'MA-';
            //role = new OpportunityContactRole();
            //otm = new OpportunityTeamMember();
        }
        return opp;
    }    
    //Opportunity save method    
    public PageReference oppSave(){
          opp.AccountId = s;
         
          if(opp.closeDate == null){
              date newDate = system.today().adddays(14);
          opp.closeDate = newDate;
          }
          else{
              date newDate = opp.closeDate.adddays(14);
          opp.closeDate = newDate;
          }
          if(opp.stageName == null){
              opp.stageName = 'Prospecting';
          }
          else{
              opp.stageName = opp.stageName;
          }
          
          system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+otm.TeamMemberRole+'---'+otm.UserId);
          insert opp;
          
          //oppcontactrole insert
          if(opp.id<> null){
          role.opportunityId = opp.id;
              if(role.contactId == null)
              {
                  role = null;
              }
              else{
                  insert role;
              }
          
          }
          
          
          //opportunity team member insert
          if(opp.id<> null){
            otm.opportunityId = opp.id;
            //otm.OpportunityAccessLevel = 'Read';
            if(otm.TeamMemberRole == null && otm.UserId == null)
            {
                otm = null;
            }
            else
            {
                insert otm;
            }
        
          }
          opp = null;
          role = null;
          otm = null;
          //otm1 = null;
          
          return null;
      }     
    
        
    //Add Task Block
      Task mytask;
      public Task getMytask(){
          if(mytask == null){
              mytask = new Task();
          }
          return mytask;
      }
    //Task Save Method   
    public PageReference taskSave(){
             
        insert mytask;
        mytask = null;
        return null;
      }   
    
      
 
}