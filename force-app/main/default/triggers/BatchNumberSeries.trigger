/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    05/24/2018 - Batch Number
***************************************************************************************************************************************************************************************************************************************** **************/

trigger BatchNumberSeries on apsona_be__Batch__c (before insert) {
    Map<String, Awana_Settings__c> AwanaSettings = Awana_Settings__c.getAll();
    Map<String, Batch_Number_Series__c> BatchSeries= Batch_Number_Series__c.getAll();
    String myCCVal;
    Date YearStartDate = Date.newInstance(System.Today().year(), 1, 1);
    if(AwanaSettings.containsKey('ExecuteBatchTrigger'))
    {   Awana_Settings__c myCS1 = AwanaSettings.get('ExecuteBatchTrigger');
        myCCVal = myCS1.Value__c;
    }
    if(myCCVal!=null && Boolean.valueOf(myCCVal))
    {
        if(trigger.isBefore  && trigger.isInsert){
            for(apsona_be__Batch__c ap:trigger.new){
            if(!ap.IsWooCommerceBatch__c && !ap.IsConvioBatch__c){
               if(BatchSeries.containsKey('Batch Record 1'))
                    {  
                        Batch_Number_Series__c btSeries = BatchSeries.get('Batch Record 1');
                        Integer sNo =  Integer.valueof(btSeries.Serial_Number__c+1);
                        Integer csYear = Integer.valueOf(btSeries.Current_Year__c);
                        if(system.today().year()==(csYear+1)){
                             btSeries.Serial_Number__c = 1;
                        }
                        else{
                            btSeries.Serial_Number__c = sNo;
                        }
                        
                        btSeries.Current_Year__c = String.valueOf(System.Today().year());
                        ap.Batch_Number__c = btSeries.Current_Year__c + '-' + btSeries.Serial_Number__c;
                        try{
                            update btSeries;
                        }
                        catch(exception e){
                        }
                    }
                }
                }
        }
    }
}