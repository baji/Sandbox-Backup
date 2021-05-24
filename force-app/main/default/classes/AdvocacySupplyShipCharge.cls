/***************************************************************************************************************************************************************************************
    Programmer: Tony W.
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    <Advocacy>
    Description: Create a Shipping Charge Opportunity against Advocacy Department (43)  
    Created:    10/24/2014 - AdvocacySupplyShipCharge
    Caller:   OpportunityAfterUpdate
***************************************************************************************************************************************************************************************/

public class AdvocacySupplyShipCharge {
  public class AdvocacySupplyException extends Exception{}
  public static void handler(List<OrderItem> AdvocateOLIs){ 
    OrderEntryServices.Result r;
    List<order> Orders = new List<order>();
    //Awana Application will be the Created By user and owner of the Opportunity
    User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
    List<Account> AdvocateDept = [Select Id,Default_Shipping_Address__c,BillingStreet,BillingState,BillingPostalCode, BillingCountry, BillingCity,Shipping_Address_Book__c, Shipping_Last_Name__c, Shipping_First_Name__c, ShippingStreet,ShippingState,ShippingPostalCode, ShippingCountry,ShippingCity  from Account WHERE Mailing_Address_Book__c = '43' LIMIT 1];
    system.debug('ADVOCATE Dept.: '+AdvocateDept);
    //String version of ID Type aID
    String aID = String.valueOf(AdvocateDept[0].Id); 
    //Get Contact Purchaser of Advocacy Dept.
    npe5__Affiliation__c PurchaserId = [Select npe5__Contact__c from npe5__Affiliation__c where Authorized_Purchaser__c = true and npe5__Organization__c =: AdvocateDept[0].Id limit 1];            
    system.debug('PURCHASERID: '+PurchaserId.npe5__Contact__c);
    Contact purchaserContact = [Select Id, FirstName, LastName,MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity from Contact where Id =: String.valueOf(PurchaserId.npe5__Contact__c) limit 1];
    String cID = String.valueOf(purchaserContact.Id);
    system.debug('ADVOCAY CONTACT (Shelley Welch): '+purchaserContact );
    // Verify if the Advocacy Checkbox checked and if so then look for freight by creating a SOQL that looked only for Advocascy
    
    try{
      Integer IDX;
      for(OrderItem oli : AdvocateOLIs){
       
            // compre Account ID of Contact with Acocunt ID of Opportnity oli.Opportunity.AccountId
            r = OrderEntryServices.CreateAffiliateOrder(cID,'Partner Price book','Order',System.Today(),'Awana',aID);
            System.debug('>>.Response : '+r);
                 if(r.Success){     
                    Order autoOrder = (Order)r.ObjectOutput;
                    system.debug('<<Saved Order >> '+autoOrder); 
                    autoOrder.Type = 'Shipping';
                    autoOrder.Order_Type__c = 'SO';
                    autoOrder.Shipping_Address__c = AdvocateDept[0].Default_Shipping_Address__c;
                    autoOrder.Ship_to_Name__c = purchaserContact.FirstName +' '+ purchaserContact.LastName;
                    autoOrder.Ship_to_First_Name__c = purchaserContact.FirstName;
                    autoOrder.Ship_to_Last_Name__c =  purchaserContact.LastName;
                    autoOrder.Shipping_Street__c = String.valueOf(AdvocateDept[0].ShippingStreet);
                    autoOrder.Shipping_City__c = AdvocateDept[0].ShippingCity;
                    autoOrder.Shipping_State__c =  AdvocateDept[0].ShippingState;
                    autoOrder.Shipping_Zip_Code__c = AdvocateDept[0].ShippingPostalCode;
                    autoOrder.Shipping_Country__c = 'UNITED STATES';
                    /*autoOrder.ChargentSFA__Billing_First__c = purchaserContact.FirstName;
                    autoOrder.ChargentSFA__Billing_Last__c = purchaserContact.LastName;
                    autoOrder.ChargentSFA__Billing_Email__c = 'advocacyorders@awana.org';*/
                    //autoOrder.Owner.Id = ouser.Id;
                    autoOrder.Payment_Terms__c = 'Internal';
                    autoOrder.Shipping_Type__c = oli.Order.Shipping_Type__c; 
                    autoOrder.Shipping_Code__c = oli.Order.Shipping_Code__c;              
                    autoOrder.Shipping_Carrier__c = oli.Order.Shipping_Carrier__c;
                    //autoOrder.Notes__c =' Advocacy Supply Ship Charge for customer order: '+oli.Order.Name;
                    system.debug('<< BEFORE ORDER ITEMS >> '+autoOrder); 
                    //==================Create Opportunity Line Item===============================
                     OrderEntryServices.Result rAdv2 = OrderEntryServices.AddProduct(autoOrder.Id,oli.PricebookEntry.Product2.ProductCode,1,oli.Price_of_Discount__c,0,'',oli.Line_Type__c);
                     OrderEntryServices.Result rAdvTAX  = OrderEntryServices.AddProduct(autoOrder.Id,'57779',1,0,0,'','T - Text Line');
                    //==================Create Opportunity Line Item===============================
                     system.debug('<< AFTER ORDER ITEMS >> '+autoOrder); 
                     //Now Submit Everything for this order by updating the stage name and source...
                     //... and adding it and its 2 line items to their lists. 
                     //autoOrder.Opportunity_Source__c = oli.Opportunity.Opportunity_Source__c;
                     autoOrder.Status = 'Order Submitted'; 
                     Orders.add(autoOrder);   
                     system.debug(' FINISHED CUSTOMER ORDER: '+autoOrder);
                   }//IF - Submit Orders
                   else{
                  //Send an email to the Apex job's submitter notifying of job completion.
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   String[] toAddresses = new String[] {'tonyw@awana.org','jenniferl@awana.org'};
                   mail.setToAddresses(toAddresses);
                   mail.setSubject('Apex Advocacy Errors');
                   mail.setPlainTextBody
                   ('The Apex trigger job was unsuccessful  when creating  Advocacy Tool Kit Supplies Ship Charge opportunity for Contact ' + cID +'  with error: '+r.Message);
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
                }//Else 
              break;
          
      }//FOR
      if (Orders.size() > 0){ // 
            upsert Orders;
          //System.debug('<<ORDERS>> '+Orders);
        }
      
      }//Try
      catch(AdvocacySupplyException e){
        //Send an email to the Apex job's submitter notifying of job completion.
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] {'tonyw@awana.org','jenniferl@awana.org'};
           mail.setToAddresses(toAddresses);
           mail.setSubject('Apex Advocacy Errors');
           mail.setPlainTextBody
           ('The Apex trigger job was unsuccessful  in process for  Advocacy Tool Kit Supplies Ship Charge  with error: '+e.getMessage());
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
      }//Catch  
  } // Handler  
}//CLass