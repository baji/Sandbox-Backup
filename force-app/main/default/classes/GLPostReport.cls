/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    03/19/2018 - <CRM - 130> To Generate the GL Post Report
***************************************************************************************************************************************************************************************************************************************** **************/

public class GLPostReport{
    public Date FromDate{get;set;}
    public Set<Id> setOpportunityId;
    public List<Opportunity> listNoDebitNumber{get;set;}
    public List<Opportunity> listOppWithoutChild{get;set;}
    public List<Opportunity> setNoCreditNummber{get;set;}
    public List<Opportunity> listNotMatchOppAmount{get;set;}
    public List<Gift_Adjustments__c> listGiftAjustment{get;set;}
    public List<GAU_Allocation_Adjustment__c> listAllocationAdjustment{get;set;}
    //public DateTime dayStartTime;
    //public DateTime dayEndTime;
    public String fDate;
    public GLPostReport(ApexPages.StandardController controller) {}   
    public void PostMethod(){
        Map<String,String> glDebitAccNumber = new Map<String,String>();
        Map<String,List<npsp__Allocation__c>> mapAllocations = new Map<String,List<npsp__Allocation__c>>();
        Set<Id> setOppId = new Set<Id>();
        boolean isInside = false;
        fDate = Apexpages.currentPage().getParameters().get('fromDate');              
        FromDate = fDate!=''?date.valueOf(Apexpages.currentPage().getParameters().get('fromDate')):null;
        //dayStartTime = DateTime.newInstance(FromDate.year(), FromDate.month(), FromDate.day(), 00, 00, 00);
        //dayEndTime = DateTime.newInstance(FromDate.year(), FromDate.month(), FromDate.day(), 23, 00, 00);
        try{
            getValidate();
            //Fetching all debit account numbers based on combination of gift type and gift sub type 
            for(GL_Debit_Account_Detail__c obj : [SELECT Id,Gift_type__c,Gift_sub_type__c,Debit_Account_Number__c FROM GL_Debit_Account_Detail__c]){
                String key = obj.Gift_type__c+'-'+obj.Gift_sub_type__c;
                glDebitAccNumber.put(key,obj.Debit_Account_Number__c);
            }
            //Querying all gift allocations based on opportunity close date selected in UI and isPosted false 
            for(npsp__Allocation__c obj : [SELECT Id,Credit_Account_Number__c,OpportunityBatchNumber__c,npsp__General_Accounting_Unit__c,npsp__Amount__c,npsp__Opportunity__c,npsp__Opportunity__r.Gift_Type__c,npsp__Opportunity__r.Gift_SubType__c,npsp__Opportunity__r.closedate FROM npsp__Allocation__c  WHERE npsp__Opportunity__r.closedate=:FromDate AND npsp__Opportunity__r.stageName = 'Posted' AND npsp__Opportunity__r.isPosted__c=false AND npsp__Opportunity__c NOT IN : setOpportunityId]){
                
                String key = obj.OpportunityBatchNumber__c+'-'+obj.npsp__Opportunity__r.Gift_Type__c+'-'+obj.npsp__Opportunity__r.Gift_SubType__c;
                if(mapAllocations.containsKey(key)){
                    for(npsp__Allocation__c all: mapAllocations.get(key)){
                        if(all.npsp__General_Accounting_Unit__c == obj.npsp__General_Accounting_Unit__c){
                            all.npsp__Amount__c = (all.npsp__Amount__c==null)?obj.npsp__Amount__c:(all.npsp__Amount__c+obj.npsp__Amount__c);
                            isInside = true;
                        }
                    }
                    if(isInside == false){
                        mapAllocations.get(key).add(obj);
                    } 
                }else{
                    mapAllocations.put(key,new List<npsp__Allocation__c>());
                    mapAllocations.get(key).add(obj);
                }
                isInside = false;
            }  
            
            String todayDate = System.now().date().format();
            string header = 'JOURNAL, DATE , DESCRIPTION, LINE_NO,ACCT_NO,LOCATION_ID,DEPT_ID,MEMO,DEBIT,CREDIT,GLENTRY_PROJECTID \n';
            string finalstr = header;
            Integer i= 1;
            
            //Querying list of opportunities which close date selected in UI and to update as ispoted=true and extraction date as extracted date
            //Put all opportunities in map with key as gift type and sub type
            List<Opportunity> listOppUpdate = [SELECT Id,Gift_Type__c,Gift_SubType__c,CloseDate,Apsona_Batch__r.Batch_Number__c,isPosted__c FROM Opportunity WHERE stageName = 'Posted' AND Gift_Type__c!= null AND Gift_SubType__c!=null AND CloseDate=:FromDate AND isPosted__c=false AND Id Not IN :setOpportunityId];
            for(Opportunity obj :listOppUpdate){
                String key = obj.Gift_Type__c+'-'+obj.Gift_SubType__c;
                obj.isPosted__c = true;
                obj.GL_Extraction_Date__c = system.today();
            }
            //Query opportunities which close date selected in UI and grouping based on gift type and sub type 
            //Creating csv string with opportunity and related GAU Allocations 
            for(AggregateResult agg: [SELECT SUM(Amount) Amount,Gift_Type__c,Gift_SubType__c,Apsona_Batch__r.Batch_Number__c batchNumber FROM Opportunity WHERE stageName = 'Posted' AND isPosted__c=false AND Gift_Type__c!= null AND Gift_SubType__c!=null AND CloseDate=:FromDate AND Id Not IN :setOpportunityId GROUP BY Gift_Type__c,Gift_SubType__c,Apsona_Batch__r.Batch_Number__c]){
                String key1 = String.valueOf(agg.get('Gift_Type__c'))+'-'+String.valueOf(agg.get('Gift_SubType__c'));
                String key = String.valueOf(agg.get('batchNumber'))+'-'+key1;   
                String AccountNumber = glDebitAccNumber.containsKey(key1)?glDebitAccNumber.get(key1):' ';
                String Description = 'Salesforce Batches '+FromDate.format();
                string recordString = 'DE'+','+FromDate.format()+','+Description+','+i+','+AccountNumber.substringAfterLast('.')+','+AccountNumber.substringBefore('.')+','+AccountNumber.substringBetween('.')+','+'Donation Batch # '+String.valueOf(agg.get('batchNumber'))+','+((Decimal)agg.get('amount')).setScale(2)+','+' '+','+' '+'\n';
                finalstr = finalstr +recordString;
                if(mapAllocations.containsKey(key)){
                    for(npsp__Allocation__c obj : mapAllocations.get(key)){
                        String CreditAccNumber = obj.Credit_Account_Number__c!=null?obj.Credit_Account_Number__c:'';
                        string recordString1 = 'DE'+','+FromDate.format()+','+'Salesforce Batches '+FromDate.format()+','+(i+1)+','+CreditAccNumber.substringAfterLast('.')+','+CreditAccNumber.substringBefore('.')+','+CreditAccNumber.substringBetween('.')+','+'Donation Batch # '+String.valueOf(agg.get('batchNumber'))+','+' '+','+((Decimal)obj.npsp__Amount__c).setScale(2)+','+' '+'\n';
                        finalstr = finalstr +recordString1;
                        i++;
                    }
                } 
                i++;
            }
            //Creating date time which is used to query adjustment records based on this date time 
            
            String dateFormatString = 'MM/dd/yyyy';
            Set<Id> setAjustOppId = new Set<Id>();
            Set<Id> setAdjustId = new Set<Id>();
            Set<Id> setAllocAdjustId = new Set<Id>();
            List<Gift_Adjustments__c> listGiftAdjustUpdate = [SELECT Id,Opportunity__c,isPosted__c,Current_Amount__c,Previous_Amount__c,CreatedDate,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Opportunity__r.GL_Debit_Account_Number__c,Batch_No__c,GL_Post_Date__c,Adjustment_Date__c FROM Gift_Adjustments__c WHERE GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted'AND Adjustment_Date__c =: FromDate AND Opportunity__c Not IN : setOpportunityId AND Id NOT IN : listGiftAjustment];
            
            for(Gift_Adjustments__c obj : listGiftAdjustUpdate){
                obj.isPosted__c = true;
                obj.GL_Post_Date__c = system.today();
                setAjustOppId.add(obj.Opportunity__c);
                setAdjustId.add(obj.Id);
            }

            //Querying Gift Allocation Adjustments with created date as selected in UI and preparing csv string 
            List<GAU_Allocation_Adjustment__c> listGAUAdjust = [SELECT Id,Opportunity__c,isPosted__c,GL_Post_Date__c,CreatedDate,Credit_Account_Number__c,Amount__c,Previous_Amount__c,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Adjustment_Date__c FROM GAU_Allocation_Adjustment__c WHERE GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted' AND Adjustment_Date__c =: FromDate AND Opportunity__c Not IN : setOpportunityId AND Id Not IN : listAllocationAdjustment];
            
            for(GAU_Allocation_Adjustment__c obj : listGAUAdjust){
                obj.isPosted__c = true;
                obj.GL_Post_Date__c = system.today();
                setAjustOppId.add(obj.Opportunity__c);
                setAllocAdjustId.add(obj.Id);
            }
             //Querying Gift Adjustments across mutiple days with created date as selected in UI and preparing csv string 
            List<Gift_Adjustments__c> listGiftAdjustUpdateMultipleDay = [SELECT Id,Opportunity__c,isPosted__c,Current_Amount__c,Previous_Amount__c,CreatedDate,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Opportunity__r.GL_Debit_Account_Number__c,Batch_No__c,GL_Post_Date__c FROM Gift_Adjustments__c WHERE GL_Post_Date__c = null AND  Opportunity__r.stageName = 'Posted' AND Opportunity__c Not IN : setOpportunityId AND Id NOT IN : listGiftAjustment AND Id Not IN : setAdjustId AND Opportunity__c IN : setAjustOppId];
            
            for(Gift_Adjustments__c obj : listGiftAdjustUpdateMultipleDay){
                obj.isPosted__c = true;
                obj.GL_Post_Date__c = system.today();
            }
             //Querying Gift Allocation Adjustments across multiple days with created date as selected in UI and preparing csv string 
            List<GAU_Allocation_Adjustment__c> listGAUAdjustMultipleDay = [SELECT Id,Opportunity__c,isPosted__c,GL_Post_Date__c,CreatedDate,Credit_Account_Number__c,Amount__c,Previous_Amount__c,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Opportunity__r.Apsona_Batch__r.Batch_Number__c FROM GAU_Allocation_Adjustment__c WHERE GL_Post_Date__c = null AND  Opportunity__r.stageName = 'Posted' AND Opportunity__c Not IN : setOpportunityId AND Id Not IN : listAllocationAdjustment AND Id Not IN : setAllocAdjustId AND Opportunity__c IN : setAjustOppId];
            
            for(GAU_Allocation_Adjustment__c obj : listGAUAdjustMultipleDay){
                obj.isPosted__c = true;
                obj.GL_Post_Date__c = system.today();
            }

            
            // //Query all Gift adjustments which created date as selected in UI and preparing csv string 
            // List<AggregateResult> listOppAggResult = [SELECT SUM(Current_Amount__c)CurrentAmount,SUM(Previous_Amount__c)PreviousAmmount,Opportunity__r.Gift_Type__c giftType,Opportunity__r.Gift_SubType__c giftSubType FROM Gift_Adjustments__c WHERE GL_Post_Date__c = null AND CreatedDate>:dayStartTime AND CreatedDate<:dayEndTime GROUP BY Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c];
            
            for(Gift_Adjustments__c obj : listGiftAdjustUpdate){
                if(obj.Previous_Amount__c > 0){
                    String key = obj.Opportunity__r.Gift_Type__c +'-'+obj.Opportunity__r.Gift_SubType__c;
                    String AccountNumber = obj.Opportunity__r.GL_Debit_Account_Number__c;
                    string recordString = 'DE'+','+FromDate.format()+','+'Salesforce Batches '+(obj.CreatedDate).date().format()+','+i+','+AccountNumber.substringAfterLast('.')+','+AccountNumber.substringBefore('.')+','+AccountNumber.substringBetween('.')+','+'Donation Batch # '+obj.Batch_No__c+','+' '+','+(obj.Previous_Amount__c).setScale(2)+','+' '+'\n';
                    finalstr = finalstr +recordString;
                    i++;
                }           
            }
            
            for(Gift_Adjustments__c obj : listGiftAdjustUpdate){
                if(obj.Current_Amount__c > 0){
                    String key = obj.Opportunity__r.Gift_Type__c +'-'+obj.Opportunity__r.Gift_SubType__c;
                    String AccountNumber = obj.Opportunity__r.GL_Debit_Account_Number__c;
                    string recordString1 = 'DE'+','+FromDate.format()+','+'Salesforce Batches '+(obj.CreatedDate).date().format()+','+i+','+AccountNumber.substringAfterLast('.')+','+AccountNumber.substringBefore('.')+','+AccountNumber.substringBetween('.')+','+'Donation Batch # '+obj.Batch_No__c+','+(obj.Current_Amount__c).setScale(2)+','+' '+','+' '+'\n';
                    finalstr = finalstr +recordString1;
                    i++;
                }   
            }

            for(GAU_Allocation_Adjustment__c obj : listGAUAdjust){                                  
                if(obj.Previous_Amount__c > 0){
                    String CreditAccNumber = obj.Credit_Account_Number__c!=null?obj.Credit_Account_Number__c:' ';
                    String key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                    String allDate = FromDate.format();
                    Decimal PreviousAmmount = obj.Previous_Amount__c>0?(Decimal)obj.Previous_Amount__c:0;
                    string recordString = 'DE'+','+allDate+','+'Salesforce Batches '+allDate+','+i+','+CreditAccNumber.substringAfterLast('.')+','+CreditAccNumber.substringBefore('.')+','+CreditAccNumber.substringBetween('.')+','+'Donation Batch # '+obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c+','+PreviousAmmount.setScale(2)+',' +' '+','+' '+'\n';
                    finalstr = finalstr +recordString;
                    i++;                     
                    obj.GL_Post_Date__c = system.today();
                }
                           
            }
           
            for(GAU_Allocation_Adjustment__c obj : listGAUAdjust){
                if(obj.Amount__c > 0){
                    String CreditAccNumber = obj.Credit_Account_Number__c!=null?obj.Credit_Account_Number__c:' ';
                    String key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                    String allDate = FromDate.format();  
                    string recordString1 = 'DE'+','+allDate+','+'Salesforce Batches '+allDate+','+i+','+CreditAccNumber.substringAfterLast('.')+','+CreditAccNumber.substringBefore('.')+','+CreditAccNumber.substringBetween('.')+','+'Donation Batch # '+obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c+','+' '+','+((Decimal)obj.Amount__c).setScale(2)+','+' '+'\n';
                    finalstr = finalstr +recordString1;
                    i++;
                }  
            }

            //Adjust gift for mutiiple days
            for(Gift_Adjustments__c obj : listGiftAdjustUpdateMultipleDay){
                if(obj.Previous_Amount__c > 0){
                    String key = obj.Opportunity__r.Gift_Type__c +'-'+obj.Opportunity__r.Gift_SubType__c;
                    String AccountNumber = obj.Opportunity__r.GL_Debit_Account_Number__c;
                    string recordString = 'DE'+','+FromDate.format()+','+'Salesforce Batches '+(obj.CreatedDate).date().format()+','+i+','+AccountNumber.substringAfterLast('.')+','+AccountNumber.substringBefore('.')+','+AccountNumber.substringBetween('.')+','+'Donation Batch # '+obj.Batch_No__c+','+' '+','+(obj.Previous_Amount__c).setScale(2)+','+' '+'\n';
                    finalstr = finalstr +recordString;
                    i++;
                }            
            }
             //Adjust gift for mutiiple days
            for(Gift_Adjustments__c obj : listGiftAdjustUpdateMultipleDay){
                 if(obj.Current_Amount__c > 0){
                    String key = obj.Opportunity__r.Gift_Type__c +'-'+obj.Opportunity__r.Gift_SubType__c;
                     String AccountNumber = obj.Opportunity__r.GL_Debit_Account_Number__c;
                     string recordString1 = 'DE'+','+FromDate.format()+','+'Salesforce Batches '+(obj.CreatedDate).date().format()+','+i+','+AccountNumber.substringAfterLast('.')+','+AccountNumber.substringBefore('.')+','+AccountNumber.substringBetween('.')+','+'Donation Batch # '+obj.Batch_No__c+','+(obj.Current_Amount__c).setScale(2)+','+' '+','+' '+'\n';
                    finalstr = finalstr +recordString1;
                    i++;
                 }   
            }

            //Adjust allocation for mutiiple days
            for(GAU_Allocation_Adjustment__c obj : listGAUAdjustMultipleDay){
                if(obj.Previous_Amount__c > 0){
                    String CreditAccNumber = obj.Credit_Account_Number__c!=null?obj.Credit_Account_Number__c:' ';
                    String key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                    String allDate = FromDate.format();
                    Decimal PreviousAmmount = obj.Previous_Amount__c>0?(Decimal)obj.Previous_Amount__c:0;
                    string recordString = 'DE'+','+allDate+','+'Salesforce Batches '+allDate+','+i+','+CreditAccNumber.substringAfterLast('.')+','+CreditAccNumber.substringBefore('.')+','+CreditAccNumber.substringBetween('.')+','+'Donation Batch # '+obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c+','+PreviousAmmount.setScale(2)+',' +' '+','+' '+'\n';
                    finalstr = finalstr +recordString;
                    i++;                     
                    obj.GL_Post_Date__c = system.today(); 
                }                                             
            }
            //Adjust allocation for mutiiple days
            for(GAU_Allocation_Adjustment__c obj : listGAUAdjustMultipleDay){
                if(obj.Amount__c > 0){
                   String CreditAccNumber = obj.Credit_Account_Number__c!=null?obj.Credit_Account_Number__c:' ';
                    String key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                    String allDate = FromDate.format();  
                    string recordString1 = 'DE'+','+allDate+','+'Salesforce Batches '+allDate+','+i+','+CreditAccNumber.substringAfterLast('.')+','+CreditAccNumber.substringBefore('.')+','+CreditAccNumber.substringBetween('.')+','+'Donation Batch # '+obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c+','+' '+','+((Decimal)obj.Amount__c).setScale(2)+','+' '+'\n';
                    finalstr = finalstr +recordString1;
                    i++; 
                } 
            }

            String glName;
            for(GL_Post_Report__c obj : [SELECT Id,Name,GL_Extraction_Date__c FROM GL_Post_Report__c WHERE GL_Extraction_Date__c=:FromDate Order By createdDate Desc LIMIT 1]){
                glName=obj.Name;
            } 
            //Creating new GL post record and adding csv as attachment
            List<String> dateSplit = fDate.split('-');
            String fileFormatDate = dateSplit[0]+dateSplit[1]+dateSplit[2];
            String csvFileName;
            GL_Post_Report__c gl = new GL_Post_Report__c();
                if(glName==null)
                    gl.name = fileFormatDate+'-'+'01';
                else{
                    Integer numberValue = Integer.valueOf(glName.substringAfterLast('-'))+1;
                    gl.name = fileFormatDate+'-'+(numberValue>=10?String.valueOf(numberValue):('0'+String.valueOf(numberValue)));
                }
                csvFileName = gl.name;
                gl.GL_Extraction_Date__c = FromDate;
            Database.insert(gl,false);
            
            /*Attachment att = new Attachment();
                att.Name = csvFileName+'.csv';
                att.body = Blob.valueOf(finalstr);
                att.ContentType = 
                att.parentId = gl.id;
                att.ContentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            Insert att;*/
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = 'GLPostReport.csv'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = csvFileName+'.csv'; // Display name of the files
            conVer.VersionData = Blob.valueOf(finalstr); 
            
            try{
                insert conVer;
            }
            catch(exception e){
            }
            // First get the content document Id from ContentVersion
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = gl.id; // you can use objectId,GroupId etc
            cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cDe.Visibility = 'AllUsers';
            try{
                insert cDe;
            }
            catch(exception e){
            }
            //Updating Opportunity,Gift Adjustment and Gift Allocation Adjustment with Extracted date
            if(gl.Id != null){  
    
                update listOppUpdate; //Update Gl Extraction date with today date and Is posted = true for Opportunity
                system.debug('listOppUpdate----------'+listOppUpdate);
                Database.update(listGiftAdjustUpdate,false);//Update Gl Extraction date with today date and Is posted = true for Adjust Gift
                Database.update(listGAUAdjust,false); //Update Gl Extraction date with today date and Is posted = true for Adjust Allocation 
                Database.update(listGiftAdjustUpdateMultipleDay,false); // Update Gl Extraction date with today date and Is posted = true for Adjust gift multiple days
                Database.update(listGAUAdjustMultipleDay,false); //Update Gl Extraction date with today date and Is posted = true for for Adjust allocation mutiiple days

                //Not required as per new functionality
                //List<Gift_Adjustments__c> listGiftAdjustDelete = [SELECT ID,Opportunity__c FROM Gift_Adjustments__c WHERE Opportunity__c IN : listOppUpdate];
                //if(!listGiftAdjustDelete.isEmpty())
                   // Delete listGiftAdjustDelete;
                //Not required as per new functionality
                //List<GAU_Allocation_Adjustment__c> listGiftAllAdjustDelete = [SELECT ID,Opportunity__c FROM GAU_Allocation_Adjustment__c WHERE Opportunity__c IN : listOppUpdate];
                //if(!listGiftAllAdjustDelete.isEmpty())
                    //Delete listGiftAllAdjustDelete;

                String Message = 'File successfully extracted click <a href="/'+gl.Id+'">Here</a> to open file';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Message));
            }
        }catch(Exception exp){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Opps.. something went worng please contact your system administrator'));
        }
        
    }
    
    public void getValidate(){
        Decimal allAmount = 0;
        setOpportunityId = new Set<Id>();
        listNoDebitNumber = new List<Opportunity>();
        listOppWithoutChild = new List<Opportunity>();
        setNoCreditNummber = new List<Opportunity>();
        listNotMatchOppAmount = new List<Opportunity>();
        listAllocationAdjustment = new List<GAU_Allocation_Adjustment__c>();
        listGiftAjustment = new List<Gift_Adjustments__c>();
        for(Opportunity obj : [SELECT Id,Name,Account.Constituent_Id__c,npsp__Primary_Contact__r.Constituent_Id__c,Amount,GL_Debit_Account_Number__c,Apsona_Batch__r.Batch_Number__c, (SELECT Id,Name,Credit_Account_Number__c,npsp__Amount__c FROM npsp__Allocations__r) FROM Opportunity WHERE stageName = 'Posted' AND CloseDate=:FromDate AND isPosted__c=false]){
            if(obj.GL_Debit_Account_Number__c == null){
                    listNoDebitNumber.add(obj);
                    setOpportunityId.add(obj.Id);
            }else if(!(obj.npsp__Allocations__r).isEmpty()){
                for(npsp__Allocation__c all : obj.npsp__Allocations__r){
                    if(all.Credit_Account_Number__c == null){
                        setNoCreditNummber.add(obj);
                        setOpportunityId.add(obj.Id);
                    }  
                    allAmount = allAmount + all.npsp__Amount__c;
                }
                if(allAmount > 0 && obj.Amount != allAmount){
                    listNotMatchOppAmount.add(obj);
                    setOpportunityId.add(obj.Id);
                }
                allAmount = 0;
            }else{
                listOppWithoutChild.add(obj);
                setOpportunityId.add(obj.Id);
            }
        }
        for(GAU_Allocation_Adjustment__c obj : [SELECT Id,Opportunity__r.Gift_Id__c,Opportunity__r.Total_Allocation_Amount__c,Opportunity__r.Amount,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Opportunity__r.AccountConstituentId__c,Opportunity__r.ContactConstituentId__c,Adjustment_Date__c FROM GAU_Allocation_Adjustment__c WHERE Adjustment_Date__c =: FromDate AND Opportunity__r.stageName = 'Posted']){
            if(obj.Opportunity__r.Amount > obj.Opportunity__r.Total_Allocation_Amount__c){
                listAllocationAdjustment.add(obj);
            }
        }
        for(Gift_Adjustments__c obj : [SELECT Id,Opportunity__r.Gift_Id__c,Opportunity__r.Total_Allocation_Amount__c,Opportunity__r.Amount,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Opportunity__r.AccountConstituentId__c,Opportunity__r.ContactConstituentId__c,Adjustment_Date__c FROM Gift_Adjustments__c WHERE Adjustment_Date__c =: FromDate AND Opportunity__r.stageName = 'Posted']){
            if(obj.Opportunity__r.Amount != obj.Opportunity__r.Total_Allocation_Amount__c){
                listGiftAjustment.add(obj);
            }
        }
    }
}