public class DonationCounter{
    
    public static void updateDonationCounter(Id oppId){
        Id oppConId;
        system.debug('Opportunity Id: '+oppId);
        //Capture the Opportunity information
        List<Opportunity> op = [SELECT CreatedDate,AccountID,UTM_Source__c,(Select ContactId,Contact.Name From OpportunityContactRoles) FROM Opportunity where Id =: oppId];  
        system.debug('Opportunity Information: '+ op);
        oppConId = (op[0].OpportunityContactRoles).ContactId;
        system.debug('Opportunity ContactRole ContactId: '+oppConId);
        //Check the myawana source
        if(op[0].UTM_Source__c == 'myawana-dev' || op[0].UTM_Source__c == 'myawana-uat'){
            List<Opportunity> op1 = [SELECT Id,First_Donation__c,(Select ContactId,Contact.Name From OpportunityContactRoles where ContactId =: oppConId) FROM Opportunity where (UTM_Source__c =: 'myawana-dev' or UTM_Source__c =: 'myawana-uat') and AccountId =: op[0].AccountId];
            system.debug('Opportunity Count: '+ op1.size());
            
            //Update custom field First_Donation
            if(op1.size() == 1){
                op1[0].First_Donation__c = true;
            }
            //update op1;
            try{
                update op1;
            }
            catch(exception e){
            }
        }
    }
}