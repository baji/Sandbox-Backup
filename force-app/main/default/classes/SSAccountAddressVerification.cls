/**************************************************************************************************************************************************************************************************************** 
    Programmer: Urvashi Dagara
    Developer:  Urvashi Dagara
    Company:    Infoglen
    Contact:    urvashi.dagara@infoglen.org
    Created:    08/19/2019 - <SMS-52> - Controller extension for standard controller Account which is used on SSAccountAddressVerification visualforce page and support the page actions. 
  ***************************************************************************************************************************************************************************************************************************************** **************/

public class SSAccountAddressVerification {
    
    Public Account acc {get;set;}
    Public string accVal {get;set;}
    public boolean showEditBilling {get;set;}
    public boolean showEditShipping {get;set;}
    public boolean showEditPhysical {get;set;}
    public boolean showEditMailing {get;set;}
    Public boolean showSuccessMsg {get;set;}
    Public boolean showErrorMsg {get;set;}
    
    //Defining constructor.
    public SSAccountAddressVerification(ApexPages.StandardController controller) {       
        
        //Fetching page account record.
        this.acc = (Account)controller.getRecord();    
        
        acc = [SELECT Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Billing_Address_Validation_Status__c,Billing_Address_Validation_Timestamp__c,
               ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Shipping_Address_Validation_Status__c,Shipping_Address_Validation_Timestamp__c,
               Physical_Street_1__c,Physical_Street_2__c,Physical_City__c,Physical_State__c,Physical_Zip__c,Physical_County__c,PhysicalCountry__c,
               Physical_Address_Validation_Timestamp__c,Physical_Address_Validation_Status__c,Mailing_Street_1__c,Mailing_Street_2__c,Mailing_City__c,Mailing_State_Province__c,
               Mailing_Zip_Postal_Code__c,Mailing_Country__c,Mailing_County__c,Mailing_Address_Validation_Status__c,Mailing_Address_Validation_Timestamp__c
               FROM Account WHERE Id =: acc.id];    
        
        //Setting page variables.
        showEditBilling = false;
        showEditShipping = false;
        showEditPhysical = false;
        showEditMailing = false;
        showSuccessMsg = false;
        showErrorMsg = false;
    }
    
    //This function is setting flag which is used on page.
    public void showBillEdit() {
        showSuccessMsg = false;
        showErrorMsg = false;
        showEditBilling = true;
    }
    
    //This function is setting flag which is used on page.        
    public void showShipEdit() {
        showSuccessMsg = false;
        showErrorMsg = false;
        showEditShipping = true;
    }
    
    //This function is setting flag which is used on page.
    public void showPhysEdit() {
        showSuccessMsg = false;
        showErrorMsg = false;
        showEditPhysical = true;
    }
    
    //This function is setting flag which is used on page.
    public void showMailEdit() {
        showSuccessMsg = false;
        showErrorMsg = false;
        showEditMailing = true;
    }
    
    //This function is setting flags which are used on page.
    public void hideBillEdit() {
        showSuccessMsg = false;
        showErrorMsg = false;
        showEditBilling = false;
        showEditShipping = false;
        showEditPhysical = false;
        showEditMailing = false;
    }

    //This function saves the account address information which is updated on page.
    public void saveAccount() {
        
        Savepoint sp = Database.setSavepoint();
        acc = (Account)JSON.deserialize(accVal,Account.class);        
        try{
            //This is quick hack. Need to update later.
            if(showEditShipping && (acc.ShippingCountry == 'US' || acc.ShippingCountry == 'USA')){
                acc.ShippingCountry = 'United States';                
            }else if(showEditPhysical && (acc.PhysicalCountry__c == 'US' || acc.PhysicalCountry__c == 'USA')){
                acc.PhysicalCountry__c = 'United States';
            }else if(showEditMailing && (acc.Mailing_Country__c == 'US' || acc.Mailing_Country__c == 'USA')){
                acc.Mailing_Country__c = 'United States';
            }
            
            update acc; 
            
            if(showEditBilling){
                acc.Billing_Address_Validation_Status__c = 'Verified';
                acc.Billing_Address_Validation_Timestamp__c = system.now();
            }else if(showEditShipping){
                acc.Shipping_Address_Validation_Status__c = 'Verified';
                acc.Shipping_Address_Validation_Timestamp__c = system.now();
            }else if(showEditPhysical){
                acc.Physical_Address_Validation_Status__c = 'Verified';
                acc.Physical_Address_Validation_Timestamp__c = system.now();
            }else if(showEditMailing){
                acc.Mailing_Address_Validation_Status__c = 'Verified';
                acc.Mailing_Address_Validation_Timestamp__c = system.now();
            }
            
            //not updating this fields at line no: 85. Updating  account again.
            update acc;
            
            acc = [SELECT Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Billing_Address_Validation_Status__c,Billing_Address_Validation_Timestamp__c,
                   ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Shipping_Address_Validation_Status__c,Shipping_Address_Validation_Timestamp__c,
                   Physical_Street_1__c,Physical_Street_2__c,Physical_City__c,Physical_State__c,Physical_Zip__c,Physical_County__c,PhysicalCountry__c,
                   Physical_Address_Validation_Timestamp__c,Physical_Address_Validation_Status__c,Mailing_Street_1__c,Mailing_Street_2__c,Mailing_City__c,Mailing_State_Province__c,
                   Mailing_Zip_Postal_Code__c,Mailing_Country__c,Mailing_County__c,Mailing_Address_Validation_Status__c,Mailing_Address_Validation_Timestamp__c
                   FROM Account WHERE Id =: acc.id];    
            
            showSuccessMsg = true; 
            showErrorMsg = false;
            showEditBilling = false;
            showEditShipping = false;
            showEditPhysical = false;   
            showEditMailing = false;
        }
        catch(exception e){
            showSuccessMsg = false;
            showErrorMsg = true;
            system.debug('e--'+e);
            Database.rollback(sp);            
        }        
    }
}