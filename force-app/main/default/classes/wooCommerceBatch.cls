/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    05/24/2018 - Woo Commerce Batch Number
***************************************************************************************************************************************************************************************************************************************** **************/


public Class wooCommerceBatch{

    public static void createWCBatch(List<opportunity> opList){
        Map<String, Batch_Number_Series__c> BatchSeries= Batch_Number_Series__c.getAll();
        Id WCBatchId;
        apsona_be__Batch__c  newApsona = new apsona_be__Batch__c ();
        Date YearStartDate = Date.newInstance(System.Today().year(), 1, 1);
        List<apsona_be__Batch__c> todaysBatch= [select id,name,Batch_Number__c from apsona_be__Batch__c where CreatedDate = TODAY and IsWooCommerceBatch__c = true limit 1];
        if(todaysBatch.size()==0){
       
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
                        //Creation of Apsona Batch for Woo Commerce
                        String st = 'WC';
                        newApsona.Batch_Number__c = btSeries.Current_Year__c + '-' + btSeries.Serial_Number__c + '-'+st;
                        newApsona.Name = 'WooCommerceBatch'+' '+ btSeries.Current_Year__c + '-' + btSeries.Serial_Number__c + '-'+st;
                        newApsona.IsWooCommerceBatch__c = true;
                        system.debug('newApsona'+newApsona);
                        List<apsona_be__Batch__c> newApsonaList = new List<apsona_be__Batch__c>();
                        newApsonaList .add(newApsona);
                        Database.SaveResult[] srList = Database.insert(newApsonaList);
                        
                        for (Database.SaveResult sr : srList)
                        {
                            WCBatchId = sr.getId();
                        }
                        
                    }
              }
              for(opportunity op:opList){
                  if(WCBatchId !=null){
                      op.Apsona_Batch__c = WCBatchId ;
                      op.Batch_Number_External_Id__c = newApsona.Batch_Number__c;
                  }
                  else if(todaysBatch.size()!=0){
                      op.Apsona_Batch__c = todaysBatch[0].id;
                      op.Batch_Number_External_Id__c = todaysBatch[0].Batch_Number__c; 
                  }
              }
    }

}