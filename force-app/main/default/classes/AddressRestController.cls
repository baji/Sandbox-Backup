@RestResource(urlMapping='/Address/*')
global class AddressRestController{
    @HttpPost
    global static String updateAddress(String conId,String accountId,String otherStreet,String otherCity,String otherState,String otherPostalCode,String otherCountry,String mailingStreet,String mailingCity, String mailingState, String mailingPostalCode, String mailingCountry,String billingStreet,String billingCity,String billingState,String billingPostalCode,String billingCountry,String shippingStreet,String shippingCity,String shippingState,String shippingPostalCode,String shippingCountry) {
      try{
          Contact addressUpdate;
          Account accountAaddressUpdate;
          if(conId != null){
          
              addressUpdate = [SELECT Id,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry  from Contact WHERE Id =: conId];
               
              if(otherStreet != null){
                  addressUpdate.OtherStreet = otherStreet;
              }
              if(otherCity != null){
                  addressUpdate.OtherCity = otherCity;
              }
              if(otherState != null){
                  addressUpdate.OtherState = otherState;
              }
              if(otherPostalCode != null){
                  addressUpdate.OtherPostalCode = otherPostalCode;
              }
              if(otherCountry != null){
                  addressUpdate.OtherCountry = otherCountry;
              }
              
              if(mailingStreet != null){
                  addressUpdate.MailingStreet = mailingStreet;
              }
              if(mailingCity != null){
                  addressUpdate.MailingCity = mailingCity;
              }
              if(mailingState != null){
                  addressUpdate.MailingState = mailingState;
              }
              if(mailingPostalCode != null){
                  addressUpdate.MailingPostalCode = mailingPostalCode;
              }
              if(mailingCountry != null){
                  addressUpdate.MailingCountry = mailingCountry;
              }
              update addressUpdate;             
              }//IF conId  
              
               if(accountId != null){
      
              accountAaddressUpdate = [SELECT Id,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry From Account WHERE Id =: accountId];
               
              if(BillingStreet != null){
                  accountAaddressUpdate.BillingStreet = billingStreet;
              }
              if(BillingCity != null){
                  accountAaddressUpdate.BillingCity = billingCity;
              }
              if(BillingState != null){
                  accountAaddressUpdate.BillingState = billingState;
              }
              if(BillingPostalCode != null){
                  accountAaddressUpdate.BillingPostalCode = billingPostalCode;
              }
              if(BillingCountry != null){
                  accountAaddressUpdate.BillingCountry = billingCountry;
              }
              
              if(ShippingStreet != null){
                  accountAaddressUpdate.ShippingStreet = shippingStreet;
              }
              if(ShippingCity != null){
                  accountAaddressUpdate.ShippingCity = shippingCity;
              }
              if(ShippingState != null){
                  accountAaddressUpdate.ShippingState = shippingState;
              }
              if(ShippingPostalCode != null){
                  accountAaddressUpdate.ShippingPostalCode = shippingPostalCode;
              }
              if(ShippingCountry != null){
                  accountAaddressUpdate.ShippingCountry = shippingCountry;
              }
              update accountAaddressUpdate;
              }//IF accountId
              
                     
              return 'Success';
          }//try  
      catch(Exception e)
      { 
          return String.valueOf(e);
      }
      
      
           
   }//method

}//class