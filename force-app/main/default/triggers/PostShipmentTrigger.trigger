trigger PostShipmentTrigger on Order ( before update) {
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunProcessOrderTrigger');
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        if(checkRecursive.runOnce()){
                Integer allUpdatedOdrers = Trigger.new.size();
                List<String> orderIds = new  List<String>();    
                for(Integer cnt = 0; cnt < allUpdatedOdrers; cnt++){
                    system.debug(Trigger.old[cnt].Status);
                    system.debug(Trigger.new[cnt].Status);
                    // NEW-25: make call outs to the Newgistics service for orders that have just been swicth to Order Confirmed.
                    if(Trigger.old[cnt].Status == 'Order Submitted'  && Trigger.new[cnt].Status == 'Order Confirmed'){    
                        system.debug('<< We are IN >>' );
                        IDHelper ih = new IDHelper(Trigger.new[cnt].Id);
                        orderIds.add(JSON.serialize(ih));
                        PostShipmentRequest.postOrders(orderIds);
                        //PostShipmentRequestBaji.postOrders(orderIds);
                    }
                }
        }
    }
}