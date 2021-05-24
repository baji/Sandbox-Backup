/****************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Affiliation After Update (Initially created for Advocacy project)
    Created:    10/07/2014
	Updated: 	12-17-2017 - ( Mayur Soni(mayur@infoglen.com) - CRM REWRITE) This code is used for DRM. When Organization to Organization affilitions. 
							This will create reciprocal affiliation record. Advocacy Kits are no longer used.
	Updated: 	10-09-2018 - <ASP-1443> - Removed all traced of DW and Advocacy beause we're not using them anymore.
    Conditions:  As contact is mandatory field in affiliation, we will set a default Contact in the record. (Mayur)
 --------------------------------------
 
 *******************************************************************************************************************************************/

trigger AffiliationAfterUpdate on npe5__Affiliation__c(after update, after insert,after delete) {
    if (Trigger.isAfter) { //( || Trigger.isUpdate)
        if (checkRecursive.runOnce()) { //to check for recursive as we are inserting same object data
            Map <Id, npe5__Affiliation__c> relatedOrgVsAffiliation = new Map <Id, npe5__Affiliation__c> ();
            if (Trigger.isInsert) {
                for (npe5__Affiliation__c aff: Trigger.New) {
                    if (aff.Related_Account__c != null) {
                        relatedOrgVsAffiliation.put(aff.Related_Account__c, aff);
                    }
                }
                if (!relatedOrgVsAffiliation.isEmpty()) {
                    List <npe5__Affiliation__c> recipAffToInsert = new List <npe5__Affiliation__c> ();
                    for (Id orgId: relatedOrgVsAffiliation.keySet()) {
                        npe5__Affiliation__c aff = relatedOrgVsAffiliation.get(orgId);
                        npe5__Affiliation__c recipAff = new npe5__Affiliation__c();
                        recipAff.npe5__Organization__c = aff.Related_Account__c;
                        recipAff.Related_Account__c = aff.npe5__Organization__c;
                        recipAff.npe5__Contact__c = aff.npe5__Contact__c;
                        recipAff.Organization_Relation__c = aff.Organization_Reciprocal_Relation__c;
                        recipAff.Organization_Reciprocal_Relation__c = aff.Organization_Relation__c;
                        recipAffToInsert.add(recipAff);

                    }
                    insert recipAffToInsert;
                    System.debug('recipAffToInsert : ' + recipAffToInsert);
                }
            }
            if (Trigger.isUpdate) {
                //if Related Organization is changed
                Set <Id> oldRelatedAccountIds = new Set <Id> ();
                Set <Id> oldOrgAccountIds = new Set <Id> ();
                Map <String, npe5__Affiliation__c> accVsAffiliationMap = new Map <String, npe5__Affiliation__c> ();
                for (npe5__Affiliation__c aff: Trigger.New) {
                    npe5__Affiliation__c oldAff = Trigger.oldMap.get(aff.Id);
                    if (aff.Related_Account__c != null && oldAff.Related_Account__c != aff.Related_Account__c) {
                        relatedOrgVsAffiliation.put(aff.Related_Account__c, aff);
                        oldRelatedAccountIds.add(oldAff.npe5__Organization__c);
                        oldOrgAccountIds.add(oldAff.Related_Account__c);
                        String key = oldAff.Related_Account__c + '#' + oldAff.npe5__Organization__c;
                        accVsAffiliationMap.put(key, oldAff);
                    }
                }
                if (!relatedOrgVsAffiliation.isEmpty()) {
                    List <npe5__Affiliation__c> recipAffToInsert = new List <npe5__Affiliation__c> ();
                    for (Id orgId: relatedOrgVsAffiliation.keySet()) {
                        npe5__Affiliation__c aff = relatedOrgVsAffiliation.get(orgId);
                        npe5__Affiliation__c recipAff = new npe5__Affiliation__c();
                        recipAff.npe5__Organization__c = aff.Related_Account__c;
                        recipAff.Related_Account__c = aff.npe5__Organization__c;
                        recipAff.npe5__Contact__c = aff.npe5__Contact__c;
                        recipAff.Organization_Relation__c = aff.Organization_Reciprocal_Relation__c;
                        recipAff.Organization_Reciprocal_Relation__c = aff.Organization_Relation__c;
                        recipAffToInsert.add(recipAff);
                    }
                    insert recipAffToInsert;
                    System.debug('recipAffToInsert : ' + recipAffToInsert);
                }
                //delete Affiliation whose Related Account is changed
                if (!oldRelatedAccountIds.isEmpty() && !oldOrgAccountIds.isEmpty()) {
                    List <npe5__Affiliation__c> deleteAffiliations = new List <npe5__Affiliation__c> ();
                    for (npe5__Affiliation__c aff: [SELECT Id, npe5__Organization__c, Related_Account__c FROM npe5__Affiliation__c WHERE npe5__Organization__c IN: oldOrgAccountIds AND Related_Account__c IN: oldRelatedAccountIds]) {
                        String key = aff.npe5__Organization__c + '#' + aff.Related_Account__c;
                        if (accVsAffiliationMap.containsKey(key)) {
                            deleteAffiliations.add(aff);
                        }
                    }
                    if (!deleteAffiliations.isEmpty())
                        DELETE deleteAffiliations;

                }
                //if relation type is changed
                Map <String, npe5__Affiliation__c> orgVsAffiliationMap = new Map <String, npe5__Affiliation__c> ();
                Set <Id> relatedAccountId = new Set <Id> ();
                Set <Id> orgAccountId = new Set <Id> ();
                for (npe5__Affiliation__c aff: Trigger.New) {
                    npe5__Affiliation__c oldAff = Trigger.oldMap.get(aff.Id);
                    if (aff.Related_Account__c!=null && (oldAff.Organization_Relation__c != aff.Organization_Relation__c || oldAff.Organization_Reciprocal_Relation__c != aff.Organization_Reciprocal_Relation__c)) {
                        String key = aff.Related_Account__c + '#' + aff.npe5__Organization__c;
                        orgVsAffiliationMap.put(key, aff);
                        relatedAccountId.add(aff.npe5__Organization__c);
                        orgAccountId.add(aff.Related_Account__c);
                    }
                }
                if (!orgVsAffiliationMap.isEmpty()) {
                    List <npe5__Affiliation__c> affiliationToUpdate = new List <npe5__Affiliation__c> ();
                    for (npe5__Affiliation__c aff: [SELECT Id, npe5__Organization__c, Related_Account__c, Organization_Relation__c, Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c IN: orgAccountId AND Related_Account__c IN: relatedAccountId]) {
                        String key = aff.npe5__Organization__c + '#' + aff.Related_Account__c;
                        if (orgVsAffiliationMap.containsKey(key)) {
                            npe5__Affiliation__c affMain = orgVsAffiliationMap.get(key);
                            aff.Organization_Relation__c = affMain.Organization_Reciprocal_Relation__c;
                            aff.Organization_Reciprocal_Relation__c = affMain.Organization_Relation__c;
                            affiliationToUpdate.add(aff);
                        }
                    }
                    if (!affiliationToUpdate.isEmpty()) {
                        update affiliationToUpdate;
                    }
                }
            }
        }
        //DELETE scenario
        if(Trigger.isDelete){
            Set<Id> oldOrgAccountIds = new Set<Id>();
            Set<Id> oldRelatedAccountIds = new Set<Id>();
            Map<String,npe5__Affiliation__c> accIdVsAffiliation = new Map<String,npe5__Affiliation__c>();
            for(npe5__Affiliation__c aff : Trigger.old){
                if(aff.Related_Account__c !=  null){
                    oldOrgAccountIds.add(aff.Related_Account__c);
                    oldRelatedAccountIds.add(aff.npe5__Organization__c);
                    String key = aff.Related_Account__c+'#'+aff.npe5__Organization__c;
                    accIdVsAffiliation.put(key,aff);
                }
            }
            if(!accIdVsAffiliation.isEmpty()){
                List<npe5__Affiliation__c> deleteAffiliations = new List<npe5__Affiliation__c>();
                for(npe5__Affiliation__c aff : [SELECT Id, npe5__Organization__c, Related_Account__c FROM npe5__Affiliation__c WHERE npe5__Organization__c IN: oldOrgAccountIds AND Related_Account__c IN: oldRelatedAccountIds]){
                    String key = aff.npe5__Organization__c + '#' + aff.Related_Account__c;
                    if (accIdVsAffiliation.containsKey(key)) {
                        deleteAffiliations.add(aff);
                    }
                }
                if(!deleteAffiliations.isEmpty())
                    DELETE deleteAffiliations;
            }
        }
    }
}