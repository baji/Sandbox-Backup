/******************************************************************************************************************
    Programmer:         Tony Williams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            SFDC-64 (JIRA) Controller for MA Opportunities Page
    Original:           4/30/2013 - Displays all MA Opportunities on the InLine MAOpportunitiesPage.
    Updated:			4/30/2016 - Modified the Test Cases and updated the Query.
 *****************************************************************************************************************/ 


public class MAOpportunitiesExtension {
    
   Account CurrentAccount = null;
    List<Opportunity> MAOpps = null;
    public List<Opportunity> Orders = null;
    public Integer maOrdersLimit = 10;
    //Used to setup the data view for Selected Ministry Advancement Opportunities
    public ApexPages.StandardSetController SetController { get;set; }
    
    //Define out getter and setter methods for the Ministry Advancement Opportunities
    public Integer getSetControllerPageSize() { if(SetController != null) { return SetController.getPageSize(); } else { return 0; } }
    public Integer getSetControllerPageNumber() { if(SetController != null) { return SetController.getPageNumber(); } else { return 0; } }
    public Integer getSetControllerResultSize() { if(SetController != null) { return SetController.getResultSize(); } else { return 0; } }
    public Integer getMAOrdersSize() { if(Orders != null) { return Orders.size(); } else { return 0; } }
    public List<Opportunity> getMAOpps() { return MAOpps; }
    public Integer getMAOrdersLimit() { return maOrdersLimit; }
    public void setMAOrdersLimit(Integer value) { maOrdersLimit=value; }
    
    
    public MAOpportunitiesExtension(ApexPages.StandardController controller) {
      	CurrentAccount = (Account)controller.getRecord();
        RecordType rec = [Select Id From RecordType where Name='Ministry Advancement'];
        //MAOpps = [SELECT Id, Name,Shipping_City__c, Shipping_State__c,Amount,Type,Interest__c,StageName,CreatedDate FROM Opportunity WHERE AccountId = :CurrentAccount.Id and RecordType.Id=:rec.Id ORDER BY CreatedDate DESC];
    	String Query = 'SELECT Id, Name,Shipping_City__c, Shipping_State__c,Amount,Type,Interest__c,StageName,CreatedDate FROM Opportunity WHERE AccountId = '+ '\''+CurrentAccount.Id+'\''+'and RecordType.Id='+'\''+rec.Id+'\''+'ORDER BY CreatedDate DESC';
    	SetController = new ApexPages.StandardSetController(
        	Database.getQueryLocator(Query)
      	);
      	MAOpps = SetController.getRecords();
      	SetController.setPageSize(maOrdersLimit);
      	Orders = SetController.getRecords();
    }
    
	/* 
     * Method:  GetHasPreviousOrders
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Opportunity. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
  	public Boolean GetHasPreviousOrders() 
  	{ 
    	if(SetController!=null){
      		return SetController.getHasPrevious();
      	}else{
      		return false;
      	} 
  	}
  	/* 
     * Method:  QueryPreviousOrders
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an MA Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: isplays MA Opportunity information. 
     * SOQL:    3
     * DML:     0
    */
  	public PageReference QueryPreviousOrders()
  	{
    	SetController.previous();
    	Orders = SetController.getRecords();
    	return ApexPages.currentPage();
  	}
  	 /* 
     * Method:  GetHasNextOrders
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Opportunity. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
  	public Boolean GetHasNextOrders() 
  	{ 
    	if(SetController!=null){
      		return SetController.getHasNext();
      	}else{
      		return false;
      	} 
  	}
  	
  	/* 
     * Method:  QueryNextOrders
     * Inputs:  string OpportunitySalesforceId - The Salesforce ID of an Opportunity. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Opportunity. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
  	public PageReference QueryNextOrders()
  	{
    	SetController.next();
    	Orders = SetController.getRecords();
    	return ApexPages.currentPage();
  	}
  	
	
    public static testMethod void testMAOppExtension() 
    {
    	List<Account> usOrgs = new List<Account>();
		ID recNo = [SELECT ID from RecordType where SOBjectType = 'Account' and Name = 'US Organization'].Id;

		usOrgs .add(new Account(Name='Test2 EV Free Church',RecordTypeId=String.ValueOf(recNo),Type='Church', 
    	Docusign_Contact_Email__c='ppipers@mailinator.com', BillingStreet='1611 N Hermitage Ave# 305',
    	BillingCity='Chicago',BillingState='IL',Billing_County__c='Cook',
    	BillingPostalCode='60622',Phone='773-914-4422', Status__c='Pending',
    	Shipping_First_Name__c=null, Shipping_Last_Name__c='Pipers',
    	
		ShippingCountry ='UNITED STATES',
		Shipping_County__c = 'Cook',
		BillingCountry='UNITED STATES'
		));
		insert usOrgs[0];
		// Create a Contact from Affiliation
		Contact someContact = new Contact(
			FirstName = 'Pat',
			LastName = 'Tester',
			Email = 'pattester@mailinator.com'
		);
		
		upsert someContact;
		npe5__Affiliation__c someAffiliation = new npe5__Affiliation__c( npe5__Organization__c=usOrgs[0].Id, 
		npe5__Contact__c=someContact.Id,
		Awana_Role_Text__c ='Commander',
		Church_Role__c = 'Pastor',
		npe5__Status__c = 'Current',
		Mozo_User_Level__c = 'LMS' );		
		upsert someAffiliation;

		//Create an MAOpportunity
		recNo = [SELECT ID from RecordType where SOBjectType = 'Opportunity' and Name = 'Ministry Advancement'].Id;
		Opportunity someMAOpp = new Opportunity(
		Name='MA-Test2 EV Free Church',
		RecordTypeId=String.ValueOf(recNo),
		Type='Ministry Connection',
		AccountId=someAffiliation.npe5__Organization__c,
		CurrencyIsoCode = 'USD',
		StageName = 'In Progress',
		Region__c='Americ;as',
		CloseDate= system.today());
	 
		upsert someMAOpp;
        
        
        Test.startTest();
        ApexPages.StandardController controller  = new ApexPages.StandardController(usOrgs[0]); 
      	MAOpportunitiesExtension BEC = new MAOpportunitiesExtension(controller);
      	List<Opportunity> MAOpps = BEC.getMAOpps();
      	BEC.GetHasPreviousOrders();
      	BEC.GetHasNextOrders();
      	BEC.getSetControllerPageSize();
      	BEC.getSetControllerPageNumber();
      	BEC.getSetControllerResultSize();
      	system.assertNotEquals(0,BEC.getMAOrdersSize());
      	system.assertNotEquals(0,BEC.getMAOrdersLimit());
      	BEC.setMAOrdersLimit(0);
      	BEC.QueryNextOrders();
      	BEC.QueryPreviousOrders();
      	Test.stopTest();
    }
}