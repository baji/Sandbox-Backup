public class UpdateOpptyPrimaryContactHandler {
    
    /*public static void setPrimaryContact(set<id> ocrIDs){
        Opportunity[] oppsToUpdate = new Opportunity[]{};
        list<OpportunityContactRole> ocRoles = new list<OpportunityContactRole>([Select ContactID,OpportunityId,Opportunity.Soft_Credit_Contact__c, Role from OpportunityContactRole where Role=:'Soft Credit' and ID in:ocrIDs]);
        set<id> oppIDs = new set<id>(); 
        for(OpportunityContactRole ocr: ocRoles)
            oppsToUpdate.add(new opportunity(id = ocr.OpportunityId, Soft_Credit_Contact__c=ocr.ContactId));

        if(oppsToUpdate.size()>0)
            update oppsToUpdate;
    }*/
    
    public void UpdateOppSoftCredit(List<OpportunityContactRoleChangeEvent> changeEvents) {
        Set<String> oppContactRoleIds = new Set<String>();
        for (OpportunityContactRoleChangeEvent evt : changeEvents) {
            EventBus.ChangeEventHeader header = evt.ChangeEventHeader;
            oppContactRoleIds.addAll(new Set<String>(header.recordids));
        }
        list<OpportunityContactRole> ocRoles = new list<OpportunityContactRole>([Select ContactID,OpportunityId, Role from OpportunityContactRole where Role=:'Soft Credit' and ID in:oppContactRoleIds]);
    }
}