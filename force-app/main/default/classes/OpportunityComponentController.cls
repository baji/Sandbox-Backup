public class OpportunityComponentController {

    @AuraEnabled
    public static List<opportunity> getOpportunityList(Id ParentId){
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        List<opportunity> opList = new list<opportunity>([SELECT Name,Amount,Apsona_Batch__c,Batch_Number_External_Id__c,CreatedDate,Fund_With_Amount__c 
                                                          FROM Opportunity WHERE RecordTypeId  =: donationRecordTypeId 
                                                          AND (accountid=:ParentId OR npsp__Primary_Contact__c=:ParentId) 
                                                          order by createdDate DESC]);
        return opList;
    }
    
}