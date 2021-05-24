/******************************************************************************************************************
    Programmer:         Tony Williams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            SFDC-63 (JIRA) Controller for Affiliated Contacts Page
    Original:           4/30/2013 - Displays only Pastor and Commander contacts on the inLine AffiliationContactPage
    Updated:            08/16/2017 - <ASP-139> Updated SOQL query to only allow Current Staff sorted by Church Role and then ...
                                                ... Awana Roles which include Awana Ministry Directores (Commanders).
  *****************************************************************************************************************/ 


public class AffiliationContactExtension {
     Account CurrentAccount = null;
    List<npe5__Affiliation__c> pcAffiliations = null;
    public List<npe5__Affiliation__c> affContacts = null;
    public Integer pcAffiliationLimit = 10;
    //Used to setup the data view for Current Affilated Contact Staff
    public ApexPages.StandardSetController SetController { get;set; }
    
    //Define our getter and setter methods for the Affiliation Contacts via the controller whose members are  Awana Ministry Directors.
    public Integer getSetControllerPageSize() { if(SetController != null) { return SetController.getPageSize(); } else { return 0; } }
    public Integer getSetControllerPageNumber() { if(SetController != null) { return SetController.getPageNumber(); } else { return 0; } }
    public Integer getSetControllerResultSize() { if(SetController != null) { return SetController.getResultSize(); } else { return 0; } }
    public Integer getpcAffiliationSize() { if(affContacts != null) { return affContacts.size(); } else { return 0; } }
    public List<npe5__Affiliation__c> getpcAffiliations() { return pcAffiliations; }
    public Integer getpcAffiliationLimit() { return pcAffiliationLimit; }
    public void setpcAffiliationLimit(Integer value) { pcAffiliationLimit=value; }
    
    
    public AffiliationContactExtension(ApexPages.StandardController controller) {
        CurrentAccount = (Account)controller.getRecord();
        //pcAffiliations = [SELECT Id,Name, Full_Name__c, Church_Role__c,Awana_Role_Text__c,Authorized_Purchaser__c,npe5__Status__c,Mozo_User_Level__c,Organization_Owner__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Current' and npe5__Organization__c =: CurrentAccount.Id and Awana_Role_Text__c like '%Pastor%' and Awana_Role_Text__c like '%Commander%'];
        String Query = 'SELECT Id,Name, npe5__Contact__c,npe5__Contact__r.FirstName,npe5__Contact__r.LastName, Church_Role__c,Awana_Role_Text__c,Authorized_Purchaser__c,   npe5__Status__c,Mozo_User_Level__c,Organization_Owner__c FROM npe5__Affiliation__c WHERE npe5__Status__c =  \'Current\' and  npe5__Organization__c = '+ '\''+CurrentAccount.Id+'\''+' and '+
        '( Awana_Role__c INCLUDES(\'Commander\',\'Awana Ministry Director \')) ORDER BY Church_Role__c,Awana_Role_Text__c ASC';
        SetController = new ApexPages.StandardSetController(
            Database.getQueryLocator(Query)
        );
        pcAffiliations = SetController.getRecords();
        SetController.setPageSize(pcAffiliationLimit);
        system.debug('<< SETCONTROLLER >> '+pcAffiliations);
        affContacts = SetController.getRecords();
        system.debug('<< AFFCONTACTS >> '+affContacts); 
    }
    
    /* 
     * Method:  GetHasPreviousOrders
     * Output:  Index to the start of the previous batch of records to load based on page limit else null if at the end of result set.
     * Purpose: When user clicks on the pagination 'Previous >' link, it prepares the page to retrieve the limit number of next records 
     * SOQL:    3
     * SOQL:    3
     * DML:     0
    */
    public Boolean GetHasPreviousRecords(){ 
        if(SetController!=null){
            return SetController.getHasPrevious();
        }else{
            return false;
        } 
    }
    /* 
     * Method:  QueryPreviousRecords
     * Output:  a result set containing the previous bacth of records to look at in the list of affiliated contacts..
     * Purpose: Queries for more previous records within a result set from the current record based on a page limit (number of records to display).
     * SOQL:    3
     * DML:     0
    */
    public PageReference QueryPreviousRecords(){
        SetController.previous();
        affContacts = SetController.getRecords();
        return ApexPages.currentPage();
    }
     /* 
     * Method:  GetHasNextRecords
     * Output:  Index to the start of the next batch of records to load based on page limit else null if at the end of result set.
     * Purpose: When user clicks on the pagination 'Next >' link, it prepares the page to retrieve the limit number of next records 
     * SOQL:    3
     * DML:     0
    */
    public Boolean GetHasNextRecords(){ 
        if(SetController!=null){
            return SetController.getHasNext();
        }else{
            return false;
        } 
    }
    
    /* 
     * Method:  QueryNextRecords
     * Output:  a result set containing the next bacth of records to look at in the list of affiliated contacts..
     * Purpose: Queries for more successive records within a result set from the current record based on a page limit (number of records to display).
     *           
     * SOQL:    3
     * DML:     0
    */
    public PageReference QueryNextRecords(){
        SetController.next();
        affContacts = SetController.getRecords();
        return ApexPages.currentPage();
    }
}