/*
* Name  : GAUUSMissionaryChange
* Usage : This trigger will update IsUSMissionaryChanged__c field on GAU object when Missionary__c field value is changed. 
*         Using IsUSMissionaryChanged__c field, a schedule batch will be run to update all GAU Allocation Owner under the GAU. 
*Developer : Mayur Soni (mayur@infoglen.com)
*/
trigger GAUUSMissionaryChange on npsp__General_Accounting_Unit__c (before update,after update) {
    
    Awana_Settings__c myCS1 = Awana_Settings__c.getall().get('ExecuteGAUUSMissionaryChange');
    String myCCVal = myCS1.Value__c;
    if(myCCVal!=null && Boolean.valueOf(myCCVal)){
        if(Trigger.isBefore){
            for(npsp__General_Accounting_Unit__c gau : Trigger.new){
                npsp__General_Accounting_Unit__c oldGAU = Trigger.oldMap.get(gau.id);
                if(gau.Missionary__c!=null && oldGAU.Missionary__c!=gau.Missionary__c){
                    gau.IsUSMissionaryChanged__c=true;
                }
            }
        }
        //if any US missioanry is changed, schedule a batch to update allocation owners
        if(Trigger.isAfter){
            if(ScheduleGAUAllocationBatch.runOnceAllocationOwner()){
                ScheduleGAUAllocationBatch.invokeBatch();
            }
        }    
    }
    
}