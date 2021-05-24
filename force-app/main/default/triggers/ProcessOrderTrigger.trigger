/*
Purpose - Trigger to handle all operations which happens after update. 
code of OpportunityAfterUpdate trigger which was on Opportunity has been merged in this code as well. 
Author - Darshan Chhajed.
Updated: 06/11/2018 - <ASP-1177> - Added an additional check for Has_Downloadable for WOO COmmerce (Tw)
Updated: 07/26/2018 - <ASP-1196> - Updated conditional on Order Total Amount so that no duplicate CC Invoice emails would be sent on $0 orders.
Updated: 12/04/2018 - <NEW-25,33> - Added new If condition to handle firing status of Before Update for Orders saving the Shipment ID returned from Newgistics
Updated: 01/17/2019 - <NEW-59>  - Added updates to check for On Hold orders so that these will not be sent to Newgistics.
Updated: 02/13/2019 - <NEW-99>  - Added updates to check for Orders with On Hold Status need to process when set to Confirmed.
*/
trigger ProcessOrderTrigger on Order (after delete, after insert, after update,after undelete, before update) {
    
    Boolean RunTrigger =  true;
    Awana_Settings__c custSetting =  Awana_Settings__c.getValues('RunProcessOrderTrigger');
    if(custSetting!=null)
        RunTrigger = Boolean.valueOf(custSetting.value__c);
    system.debug('NGSearch-'+checkRecursive.batchStatus);
    if(RunTrigger && checkRecursive.batchStatus!='NGSearch')
    { 
          /*if(Trigger.isInsert && Trigger.isAfter){
            for(Order o :Trigger.New){ 
                OrderTriggerHandler.handleAfterInsertEvent();                   
                
            }  
            }*/
    
        if(Trigger.isUpdate && Trigger.isAfter){
            /*Variable Declaration*/
            list<Messaging.SingleEmailMessage> emailTobeSent = new list<Messaging.SingleEmailMessage>();
            list<ID> AdvocateOrderIDs = new list<ID>();
            list<ID> StoreORCCOrderIDs = new list<ID>();
            List<ID> AwanaStoreOrderIds = new LIst<ID>();
            list<OrderItem> AdvocateOLIs = new list<OrderItem>();
            list<ID> mozoOppIDs = new list<ID>();   
            list<ID> mozoAccountIds = new list<ID>();
            list<Order> DropShipOpps = new list<Order>();
            Map<Id,Order> mozoMap = new Map<Id,Order>();
            Integer opp_limit = Trigger.new.size();
            map<Id,Id> orderToOCRMap = new map<Id,Id>();
            map<Id,Id> chargentOrderToOrder = new map<Id,Id>(); 
            map<String,String> develoeprNameToIdMap  = new map<String,String>();
            //List<Product2> productList = new List<Product2>(); //MR-2
            system.debug('**Executing Trigger**');
            list<EmailTemplate> emailTemplateLst = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('Email_Credit_Card_Receipt','Email_Credit_Receipt','EmailInvoiceReceipt')];
            list<Order_Contact_Role__c> orderContactRoleLst = [SELECT Id,Contact__c,Order__c FROM Order_Contact_Role__c WHERE Order__c IN :Trigger.New];
            system.debug('<< CONTACT ROLE LIST >> '+orderContactRoleLst);
            
            list<OrgWideEmailAddress> orgEmailIdLst = [select id,Address from OrgWideEmailAddress where Address = 'donotreply@awana.org' limit 1];
            Map<id,Datetime> OpptyMap = new map<id,Datetime>();
            
            try{
                
                //Collecting Order Contact Role
                for(Order_Contact_Role__c OCR : orderContactRoleLst){
                    orderToOCRMap.put(OCR.Order__c,OCR.Contact__c); 
                }   
                for(EmailTemplate eTemplate : emailTemplateLst){
                    develoeprNameToIdMap.put(eTemplate.DeveloperName,eTemplate.Id);                 
                } 
                for(Order o :Trigger.New){
                    system.debug('Inside Trigger New');
                    //Update Chargent Order Amount Funcationlity
                    chargentOrderToOrder.put(O.Chargent_Order__C,O.Id);
                    // If the order status is Order Invoiced then the related donations are updated with stage as Posted
                    // Beginning of Woo Commerce functionality --Added by Ayesha-- 12th July'18
                    if((Trigger.oldMap.get(O.id).Status!='Order Invoiced' && O.Status =='Order Invoiced')&& o.opportunityid!=null){
                        
                        OpptyMap.put(o.opportunityid,o.lastmodifieddate);
                    }
                    // End of woo commerce code
                    //SEND EMAIL FUNCTIONALITY
                    system.debug('<< NEW REG LEVEL>>> '+o.Account.Registration_Level__c);  
                    if(emailTemplateLst!=null && emailTemplateLst.size()>0){
                        if(Trigger.oldMap.get(O.id).Status!='Order Confirmed' && O.Status =='Order Confirmed' && O.TotalAmount > 0.99 && O.Company__c =='Awana') //O.Payment_Terms__c=='Credit Card' Commenting this condition since we need an email for all types of payment
                        {
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(O.ExtraEmail__c !='' && O.ExtraEmail__c!=null){
                                list<String> emailIdLst =  O.ExtraEmail__c.Split(',');
                                if(emailIdLst!=null && emailIdLst.size()>0){   
                                    mail.toAddresses = emailIdLst;
                                }
                                if(O.Payment_Terms__c=='Credit Card')
                                    mail.setTemplateId(develoeprNameToIdMap.get('Email_Credit_Card_Receipt'));
                                else if(O.Payment_Terms__c=='Sales Credit')
                                    mail.setTemplateId(develoeprNameToIdMap.get('Email_Credit_Receipt'));
                                else if(O.Payment_Terms__c=='Net 30')
                                    mail.setTemplateId(develoeprNameToIdMap.get('EmailInvoiceReceipt'));
                                system.debug('<< PAY TERMS >> '+O.Payment_Terms__c +'<< MAIL OBJ >>' +mail);
                                if(orgEmailIdLst!=null && orgEmailIdLst.size()>0)
                                    mail.setOrgWideEmailAddressId(orgEmailIdLst.get(0).Id);
                                mail.setTargetObjectId(orderToOCRMap.get(O.Id));
                                mail.setWhatId(o.ID);
                                system.debug(' MAIL SHOULD BE ADDED '+mail);
                                emailTobeSent.add(mail); //Add eamil to be sent in a list  
                            }
                            
                        }
                    }
                    system.debug('<<PAY TYPE >>'+O.Payment_Terms__c);
                    //0.<ASP-874> -  If we have Downloadables then wait until they are invoced before we sendout the emails.
                    system.debug('<< OLD STATE>> '+Trigger.oldMap.get(O.Id).Status+' << NEW STATE>> '+O.Status+' << HAS DOWNLOADS>> '+O.Has_Downloads__c+' << SOURCE >> '+O.Opportunity_Source__c);
                    if((Trigger.oldMap.get(O.Id).Status == 'Order Submitted' && O.Status.contains('Confirmed') && O.Has_Downloads__c == true) && (O.Opportunity_Source__c == 'Awana Store'  || O.Opportunity_Source__c == 'Customer Service')){
                        // WOO Comm doesn't save Downloadable URLs so we have o update the order line items 
                        if(O.Opportunity_Source__c == 'Awana Store'){
                            AwanaStoreOrderIds.add(O.Id);
                        }
                        StoreORCCOrderIDs.add(O.Id);
                        
                        system.debug('<<CUSTOMER SERVICE ORDER>> '+StoreORCCOrderIDs);
                        system.debug('<<AWANA STORE ORDER>> '+AwanaStoreOrderIds);
                    }
                    
                    //1. Process any Advocate Tool Kit Orders (Source = 'Advocacy') for Invoiced orders.
                    if((Trigger.oldMap.get(O.Id).Status == 'Order Being Fulfilled' && O.Status.contains('Invoiced') ) && O.Opportunity_Source__c == 'Advocacy' ){
                        AdvocateOrderIDs.add(O.Id);  
                    } 
                    else{ //2. MOZO products IF goes here to check on  Sales Credit  or Registration based on Order Confirmed Status. Make sure Registration Product has something in it.
                        
                        system.debug( '<< Trigger.old[indx].Status>>  '+Trigger.oldMap.get(O.Id).Status+' << Trigger.new[indx].Status>>  '+O.Status + 'Registration_Product__c '+O.Registration_Product__c); 
                        
                        if(Trigger.oldMap.get(O.id).Status == 'Order Submitted' && O.Status == 'Order Confirmed' && (O.Registration_Product__c != null && O.Registration_Product__c != '')){      
                            //Do all the necessary Conditions and start stuffing the Opportunities into the mozo Opportunity list if Registration product contains.. R1 - R4 ...
                            // ... which the WF writes to with values of R1 - R4. Initially it's null.
                            //We need to get the account Ids as well as Ids from MOZO opportunities in order to grab the Registration Product. 
                            mozoAccountIds.add(O.AccountId) ;   
                            mozoOppIDs.add(O.Id);
                            mozoMap.put(O.AccountId,O);
                            system.debug('<<MOZOACCTIDS>> '+mozoAccountIds+' <<MOZOIDs>> '+mozoOppIDs);
                            // Now check US Org Opportunities to see if the Description contains Race Date Is and then add this to a loop.
                            
                        }//If Status = Confirmed...
                        system.debug('<< DROP SHIP OPP >> '+O.Description);
                        if(O.Description != null && O.Description.contains('Race Date is')  &&  (Trigger.oldMap.get(O.id).Status == 'Order Open' && O.Status == 'Order Submitted')){
                            if(O.Order_Submitted__c != null){
                                DropShipOpps.add(O);
                            }
                        }
                        //MR-1 Changes started. By : Urvashi Dagara
                        system.debug('MR--1-debug1'+o.status);
                        system.debug('MR--1-debug1'+Trigger.oldMap.get(o.id).Status); // Added by Anvesh
                        //system.debug('checkRecursive.runOnceOrderSubmit==>'+checkRecursive.runOnceOrderSubmit());
                        if((Trigger.oldMap.get(O.id).Status != 'Order Submitted' && o.status == 'Order Submitted' && o.status != 'Order Confirmed' && o.status != 'Order Being Fulfilled' && o.Payment_Terms__c != 'PrePay' && checkRecursive.runOnceOrderSubmit()) || (o.status == 'Order Cancelled') ){                                                                               
                            system.debug('inside==>'+checkRecursive.runOnceOrderSubmit());
                            OrderTriggerHandler.handleAfterUpdateEvent();
                            system.debug('Inside'+o.status); // Added by Anvesh
                        }           
                        //MR-1 Changes end
                    }// Else
                      
                }//LOOP
                
                
                // Beginning of woo commerce logic -- added by Ayesha -- 12th July`18
                if(OpptyMap.size()>0){
                    List<opportunity> opList = new List<opportunity>();
                    for(opportunity opt:[select id,name,StageName from opportunity where id in:OpptyMap.keyset() and recordtype.name = 'Donation' and StageName='Pre Post']){
                        opt.StageName = 'Posted';
                        opt.closedate = Date.valueof(OpptyMap.get(opt.id));
                        opList.add(opt);        
                    }
                    if(opList!=null && opList.size()>0){
                        Database.update(opList,false);
                    }
                }
                // End of Woo commerce Logic
                // if we have a list of Ccare orders we must get the downloadables  and also their Contact Role members passed for sending emails
                system.debug('<< SEND DOWNLOAD EMAILS >> '+StoreORCCOrderIDs.size());
                
                if(StoreORCCOrderIDs.size() > 0){
                    // Check the Source to see if it is Awana Store and then process the order line items for said order
                    if(AwanaStoreOrderIds.size() > 0){
                        ProcessDownloadURLsForStore.updateOrderItems( AwanaStoreOrderIds);
                    }
                    SendDownloadableEmails.handler(StoreORCCOrderIDs,orderToOCRMap,orgEmailIdLst);
                }
                
                //If we have a few R4 purchases then check if their accounts were signed up for Free Trial and cancel the trial.
                // If we have Mozo opportunities then process via remote procedure call to UpdateMozoAccounts class.
                
                //update chargent order of an order with total amount
                list<ChargentOrders__ChargentOrder__c> cOrders = [SELECT Id, ChargentOrders__Subtotal__c   FROM ChargentOrders__ChargentOrder__c  WHERE Id IN:chargentOrderToOrder.KeySet()];
                for(ChargentOrders__ChargentOrder__c cOrder : cOrders){
                    cOrder.ChargentOrders__Subtotal__c = Trigger.NewMap.get(chargentOrderToOrder.get(cOrder.Id)).TotalAmount;
                }
                update cOrders; //update sutotal of chargent amounts. 
                system.debug('<<MOZO OPPS SIZE>> '+mozoOppIDs.size());
                if(mozoOppIDs.size() > 0){
                    //Get Acounts that match the opportunity Account Ids .
                    //List<Account> mozoAccounts = [Select Id,Mozo_Free_Trial_ContactID__c,Mozo_Trial_Status__c,Cast_Iron_Bypass__c,Mozo_Trial_End_Date__c,Registration_Date__c,Registration_Status__c, Registration_Level__c, Date_Inactive__c,Status__c from Account WHERE Id in: mozoAccountIds and RecordType.Name in ('Canada Church','US Organization') ]; 
                    system.debug('**mozoAccountIds**'+mozoAccountIds);
                    List<Account> mozoAccounts = [Select Id,Cast_Iron_Bypass__c,Registration_Date__c,Registration_Status__c, Registration_Level__c,MOZO_Expiration_Date__c, Date_Inactive__c,Status__c, Mozo_Trial_Status__c FROM Account WHERE Id in: mozoAccountIds and RecordType.Name in ('Canada Church','US Organization') ]; 
                    system.debug('<<MOZOACCOUNTS>> '+mozoAccounts);
                    UpdateMozoAccounts.handler(mozoAccounts,mozoMap);
                }//IF
                
                system.debug('<<ADVOCATE ORDER SIZE>> '+AdvocateOrderIDs.size());
                if(AdvocateOrderIDs.size() > 0){
                    // Grab 1 FRT line item for each Opportunity
                    AdvocateOLIs = [Select Id, OrderId,Price_of_Discount__c,Description, Order.Name,Order.AccountId,PricebookEntry.Product2.ProductCode, PriceBookEntry.UnitPrice, UnitPrice, ListPrice, TotalPrice, Line_Type__c,Order.Opportunity_Source__c, Order.Shipping_Carrier__c, Order.Shipping_Type__c, Order.Shipping_Code__c
                                    From OrderItem WHERE orderId in :AdvocateOrderIDs and Line_Type__c = 'F - Freight' order by createddate];
                    
                    if(AdvocateOLIs != null && AdvocateOLIs.size() > 0){
                        
                        AdvocacySupplyShipCharge.handler(AdvocateOLIs); 
                    }//IF
                    
                }//IF
                //<ASP-214> Now check to see if we have any drop ship opportunities with descriptions matching the 'Race Date is' string pattern...
                if(DropShipOpps.size() > 0){
                    DropShipUtility.SendEmailCheckRaceDate(DropShipOpps);
                }
                if(emailTobeSent!=null && emailTobeSent.size()>0 && OrderEntryServices.hasProcessOrderTriggerRan()){
                    Messaging.sendEmail(emailTobeSent);   
                    system.debug('**Sending an Email**');
                }
                // << Add call out of orders to Newgistics here >>
            }catch(Exception e){
                system.debug('Exception Occured'+e.getStackTraceString()+'  MSG-'+e.getMessage());
            } 
        }//end if Is after update
        /*
Purpose - Trigger to summarize the Order total to the Account level. This is done as we can not create roll up field for Order in Account.
Order_Amount_Summary__c , Previous_FY_Order_Summary__c and Current_FY_Order_Summary__c fields will be updated in the Account record.
Author - Mayur Soni.
*/
        Set<id> accountIds = new Set<id>();
        List<Account> accountsToUpdate = new List<Account>();
        
        if (!Trigger.isDelete) {
            for (Order item : Trigger.new){
                if(item.AccountId != null)
                    accountIds.add(item.AccountId);
            }
        }     
        
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Order item : Trigger.old){
                if(item.AccountId != null)
                    accountIds.add(item.AccountId);
            }
            
        }
        //Added by CK to avoid recursive execution of below code.
        //Moving this logic to OrderTriggerHandler after update as this is not going to call.
        if(checkRecursive.runOnce()){
            if(Trigger.isUpdate && Trigger.isBefore){
                system.debug('here-- to check--');
                Integer allUpdatedOdrers = Trigger.new.size();
                List<String> orderIds = new  List<String>();    
                
                for(Integer cnt = 0; cnt < allUpdatedOdrers; cnt++){
                    system.debug('ANV:'+Trigger.old[cnt].Order_Hold__c+'--'+Trigger.new[cnt].Order_Hold__c+'--'+Trigger.old[cnt].Status+'--'+Trigger.new[cnt].Status);
                    // NEW-25: make call outs to the Newgistics service for orders that have just been swicth to Order Confirmed.
                    if((Trigger.old[cnt].Status == 'Order Submitted'  && Trigger.new[cnt].Status == 'Order Confirmed' && Trigger.new[cnt].Order_Hold__c == false ) 
                       ||
                       (Trigger.old[cnt].Status == 'Order on Hold'  && Trigger.new[cnt].Status == 'Order Confirmed' )
                       ||
                       (Trigger.old[cnt].Order_Hold__c == true && Trigger.new[cnt].Order_Hold__c == false && Trigger.new[cnt].Status == 'Order Confirmed')){    
                           system.debug('here-- to check2--');
                           IDHelper ih = new IDHelper(Trigger.new[cnt].Id);
                           orderIds.add(JSON.serialize(ih));
                           if(!System.isFuture() && !System.isBatch()){ 
                               PostShipmentRequest.postOrders(orderIds);
                           }
                       }
                }
            }          
            //write your code here            
        }//CK: checkRecursive 
    }
}