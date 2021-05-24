@RestResource(urlMapping='/AffiliationDW/*')
global class DWREAffiliationRESTController {
    @HttpPost
    global static String updateAffiliation(String affiliationId,String licenseLevel) {
        try {
            if(affiliationId != null && affiliationId != '' && affiliationId InstanceOf ID) {
                List<npe5__Affiliation__c> affiliationList = [select Mozo_User_Level__c from npe5__Affiliation__c where id =:affiliationId];
                List<npe5__Affiliation__c> updateList = new List<npe5__Affiliation__c>();
                
                for(npe5__Affiliation__c aff: affiliationList){
                    if(licenseLevel != null && licenseLevel != ''){
                        aff.Mozo_User_Level__c = licenseLevel;
                    } 
                    else {
                        return 'Licence level is blank';
                    }
                    updateList.add(aff);
                }
                update updateList;
                return 'success';
            }
            else {
                return 'Affiliation ID is blank';
            }
        } catch (Exception e) {
            String errorMessage = e.getMessage() + ', Line:' + e.getLineNumber();
            return errorMessage;
        }            
    }
}