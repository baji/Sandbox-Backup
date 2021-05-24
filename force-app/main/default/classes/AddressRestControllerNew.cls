@RestResource(urlMapping='/AddAddress/*')
global class AddressRestControllerNew{
    @HttpPost
    global static String insertAddress(String addressType,String contactId,String accountId,String street,String city,String state,String zip,String country)
    {
      try{
          Contact newContactAddress;
          Account newAccountAddress;
         
              if(accountId != null)
              {   
                  newAccountAddress = [select Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry From Account where Id=:accountId]; 
                    
                  if(addressType == 'Billing'){
                      if(street != null){
                          newAccountAddress.BillingStreet = street;
                      }
                      if(city != null){
                          newAccountAddress.BillingCity = city;
                      }
                      if(state != null){
                          newAccountAddress.BillingState = state;
                      }
                      if(zip != null){
                          newAccountAddress.BillingPostalCode = zip;
                      }
                      if(country != null){
                          newAccountAddress.BillingCountry = country;             
                      }
                     upsert newAccountAddress;
                  }
                  if(addressType == 'Shipping'){
                      if(street != null){
                          newAccountAddress.ShippingStreet = street;
                      }
                      if(city != null){
                          newAccountAddress.ShippingCity = city;
                      }
                      if(state != null){
                          newAccountAddress.ShippingState = state;
                      }
                      if(zip != null){
                          newAccountAddress.ShippingPostalCode = zip;
                      }
                      if(country != null){
                          newAccountAddress.ShippingCountry = country;             
                      }
                     upsert newAccountAddress;
                  }
             }     
            if(contactId != null)
            {   
                  newContactAddress = [select Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry From Contact where Id=:contactId]; 
                    
                  if(addressType == 'Mailing'){
                      if(street != null){
                          newContactAddress.MailingStreet = street;
                      }
                      if(city != null){
                          newContactAddress.MailingCity = city;
                      }
                      if(state != null){
                          newContactAddress.MailingState = state;
                      }
                      if(zip != null){
                          newContactAddress.MailingPostalCode = zip;
                      }
                      if(country != null){
                          newContactAddress.MailingCountry = country;             
                      }
                     upsert newContactAddress;
                  }
                  if(addressType == 'Other'){
                      if(street != null){
                          newContactAddress.OtherStreet = street;
                      }
                      if(city != null){
                          newContactAddress.OtherCity = city;
                      }
                      if(state != null){
                          newContactAddress.OtherState = state;
                      }
                      if(zip != null){
                          newContactAddress.OtherPostalCode = zip;
                      }
                      if(country != null){
                          newContactAddress.OtherCountry = country;             
                      }
                     upsert newContactAddress;
                  }
             }          
          return 'Success';
          }//try  
      catch(Exception e)
      { 
          return String.valueOf(e);
      }
      
      
           
    }//method

}