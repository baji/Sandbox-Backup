/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    07/17/2018 - Convio Batch Number
***************************************************************************************************************************************************************************************************************************************** **************/


public Class ConvioBatch{
    
    public static apsona_be__Batch__c createCVBatch(){
        Map<String, Batch_Number_Series__c> BatchSeries= Batch_Number_Series__c.getAll();
        Id WCBatchId;
        apsona_be__Batch__c  newApsona = new apsona_be__Batch__c ();
            
            if(BatchSeries.containsKey('Batch Record 1')){   
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
                
                try{
                    update btSeries;
                }
                catch(exception e){
                }
                //Creation of Apsona Batch for Convio
                String st = 'CV';
                newApsona.Batch_Number__c = btSeries.Current_Year__c + '-' + btSeries.Serial_Number__c + '-'+st;
                newApsona.Name = 'ConvioBatch'+' '+ btSeries.Current_Year__c + '-' + btSeries.Serial_Number__c + '-'+st;
                newApsona.IsConvioBatch__c = true;
                List<apsona_be__Batch__c> newApsonaList = new List<apsona_be__Batch__c>();
                newApsonaList .add(newApsona);
                Database.SaveResult[] srList = Database.insert(newApsonaList);
                
                for (Database.SaveResult sr : srList)
                {
                    if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted  opp ID: ' + sr.getId());
                    }
                    else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Batch fields that affected this error: ' + err.getFields());
                    }
                    }
                }
                
            }
        return newApsona;
        
        
    }
}