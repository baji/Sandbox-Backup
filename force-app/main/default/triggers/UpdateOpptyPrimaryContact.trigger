trigger UpdateOpptyPrimaryContact on OpportunityContactRoleChangeEvent (after insert) {
    set<id> ocrIDs = new set<id>();
    
    new UpdateOpptyPrimaryContactHandler().UpdateOppSoftCredit(Trigger.New);
    
    /*for(OpportunityContactRoleChangeEvent e : trigger.new){
        EventBus.ChangeEventHeader changeEventHeader = e.ChangeEventHeader;
        //Checking if the if the record is created or updated
        system.debug(changetype);
        if(changeEventHeader.changetype == 'CREATE' || changeEventHeader.changetype == 'UPDATE'){
            if(changeEventHeader.getRecordIds().size()==1)
                ocrIDs.add(changeEventHeader.getRecordIds()[0]);
        }
    }*/
    
    
}