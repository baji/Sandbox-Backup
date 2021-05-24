/*
 * Purpose : This class contains the future method to create Affiliations when updating the duplicate contact to resolve SELF_REFERENCE_FROM_TRIGGER ERROR in DRM Data migration.
 * Developed By : Mayur Soni (mayur@infoglen.com)
 * Created on : 18-Apr-2018
*/

Public class DRMDuplicateUtil{
    
    @future
    public static void createAffiliations(Set<Id> otherConIds,Set<id> accIds,Set<String> accIdConId){
        Set<String> copyAccConIds = accIdConId.clone();
        List<npe5__Affiliation__c> affiliations = [SELECT Id,npe5__Organization__c,npe5__Contact__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : otherConIds and npe5__Organization__c =:accIds];
        if(!affiliations.isEmpty()){
            for(npe5__Affiliation__c aff : affiliations){
                String key = aff.npe5__Organization__c + '#'+aff.npe5__Contact__c;
                if(copyAccConIds.contains(key)){
                    copyAccConIds.remove(key); //if affiliation exist remove from set
                }
            }
            
            if(!copyAccConIds.isEmpty()){// if Set contains values then affiliations are not there, create new
                List<npe5__Affiliation__c> affiliationsToInsert = new List<npe5__Affiliation__c>();
                for(String key : copyAccConIds){
                    //Contact con = copyContactMap.get(key);
                    List<String> ids = key.split('#');
                    //TO DO : other fields to add in affiliation
                    npe5__Affiliation__c aff = new npe5__Affiliation__c();
                    aff.npe5__Contact__c = ids[1];
                    aff.npe5__Organization__c = ids[0];
                    affiliationsToInsert.add(aff);
                }
                if(!affiliationsToInsert.isEmpty())
                    insert affiliationsToInsert;
            }
        }else{//if no affiliations found create new
            if(!copyAccConIds.isEmpty()){// if map contains values then affiliations are not there, create new
                List<npe5__Affiliation__c> affiliationsToInsert = new List<npe5__Affiliation__c>();
                for(String key : copyAccConIds){
                    //Contact con = copyContactMap.get(key);
                    List<String> ids = key.split('#');
                    //TO DO : other fields to add in affiliation
                    npe5__Affiliation__c aff = new npe5__Affiliation__c();
                    aff.npe5__Contact__c = ids[1];
                    aff.npe5__Organization__c = ids[0];
                    affiliationsToInsert.add(aff);
                }
                if(!affiliationsToInsert.isEmpty())
                    insert affiliationsToInsert;
            }
        }
    }
}