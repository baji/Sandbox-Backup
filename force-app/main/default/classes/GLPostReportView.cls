/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    03/19/2018 - <CRM - 130> To Generate the GL Post Report
***************************************************************************************************************************************************************************************************************************************** **************/
public class GLPostReportView {
    public Date FromDate{get;set;}
    public Map<String,List<npsp__Allocation__c>> mapAllocations{get;set;}
    public List<OpprtunityWraper> listOppWrap{get;set;}
    public List<OppGiftAdjustMent> listGiftAdjustMent{get;set;}
    public List<OppGiftAdjustMent> listPreviousGiftAdjustMent{get;set;}
    public List<oppGAuAllocationAdjustment> listAllocationAdjust{get;set;}
    public List<oppGAuAllocationAdjustment> listAllPreviousAdjust{get;set;}
    public String todayDate{get;set;}
    public Decimal oppTotalAmount{get;set;}
    public Decimal allocationTotlAmount{get;set;}
    //public DateTime dayStartTime;
    //public DateTime dayEndTime;
    
    public List<Opportunity> listNoDebitNumber{get;set;}
    public List<Opportunity> listOppWithoutChild{get;set;}
    public List<Opportunity> setNoCreditNummber{get;set;}
    public List<Opportunity> listNotMatchOppAmount{get;set;}
    public List<GAU_Allocation_Adjustment__c> listAllocationAdjustment{get;set;}
    public List<Gift_Adjustments__c> listGiftAjustment{get;set;}
    public Set<Id> setOpportunityId{get;set;}
    public Set<String> setOpppId;
    public Set<String> batchNo{get;set;}
    public Map<Id,Gift_Adjustments__c> mapGidtAllocation{get;set;}
    public Map<String,List<OppAllAdjustMent>> mapBatchAllocation{get;set;}
    public GLPostReportView(){
        string fDate = Apexpages.currentPage().getParameters().get('FromDate');      
        FromDate = fDate!=''?date.valueOf(Apexpages.currentPage().getParameters().get('FromDate')):null;
        //dayStartTime = DateTime.newInstance(FromDate.year(), FromDate.month(), FromDate.day(), 00, 00, 00);
       //dayEndTime = DateTime.newInstance(FromDate.year(), FromDate.month(), FromDate.day(), 23, 00, 00); 
    }
    
    public void getData(){
        getValidate();
        oppTotalAmount = 0;
        allocationTotlAmount = 0;
        todayDate = System.now().date().format();
        listOppWrap = new List<OpprtunityWraper>();
        listGiftAdjustMent = new List<OppGiftAdjustMent>();
        listPreviousGiftAdjustMent = new List<OppGiftAdjustMent>();
        listAllocationAdjust = new List<oppGAuAllocationAdjustment>();
        listAllPreviousAdjust = new List<oppGAuAllocationAdjustment>();
        mapAllocations = new Map<String,List<npsp__Allocation__c>>();
        Map<String,String> glDebitAccNumber = new Map<String,String>();
        mapBatchAllocation = new Map<String,List<OppAllAdjustMent>>();
        batchNo = new set<string>();
        boolean isInside = false;
        try{
            //Fetching all debit account numbers based on combination of gift type and gift sub type 
            for(GL_Debit_Account_Detail__c obj1 : [SELECT Id,Gift_type__c,Gift_sub_type__c,Debit_Account_Number__c FROM GL_Debit_Account_Detail__c LIMIT 10000]){
                String key2 = obj1.Gift_type__c+'-'+obj1.Gift_sub_type__c;
                glDebitAccNumber.put(key2,obj1.Debit_Account_Number__c);
            }
            
            //Querying all gift allocations based on opportunity close date selected in UI and isPosted false
            for(npsp__Allocation__c obj : [SELECT Id,npsp__Amount__c,OpportunityBatchNumber__c,npsp__General_Accounting_Unit__c,isSummarize__c,Credit_Account_Number__c,npsp__Opportunity__r.Gift_Type__c,npsp__Opportunity__r.Gift_SubType__c,npsp__Opportunity__r.closedate FROM npsp__Allocation__c  WHERE npsp__Opportunity__r.closedate =: FromDate AND npsp__Opportunity__r.stageName = 'Posted' AND npsp__Opportunity__r.isPosted__c=false AND npsp__Opportunity__c Not IN : setOpportunityId LIMIT 10000]){               
                String key = obj.OpportunityBatchNumber__c+'-'+obj.npsp__Opportunity__r.Gift_Type__c+'-'+obj.npsp__Opportunity__r.Gift_SubType__c;
                if(mapAllocations.containsKey(key)){
                    for(npsp__Allocation__c all: mapAllocations.get(key)){
                        if(all.npsp__General_Accounting_Unit__c == obj.npsp__General_Accounting_Unit__c){
                            all.npsp__Amount__c = (all.npsp__Amount__c==null)?obj.npsp__Amount__c:(all.npsp__Amount__c+obj.npsp__Amount__c);
                            all.isSummarize__c = true;
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
                allocationTotlAmount = allocationTotlAmount + obj.npsp__Amount__c;
            }  
            //Querying list of opportunities which close date selected in UI and to update as ispoted=true and extraction date as extracted date
            //Put all opportunities in map with key as gift type and sub type
            //Refer this map for opp close date and for batch number in aggregate query below
            for(AggregateResult agg: [SELECT SUM(Amount) Amount,Gift_Type__c,Gift_SubType__c,Apsona_Batch__r.Batch_Number__c batchNumber FROM Opportunity WHERE stageName = 'Posted' AND isPosted__c=false AND Gift_Type__c!= null AND Gift_SubType__c!=null AND CloseDate=:FromDate AND Id Not IN : setOpportunityId GROUP BY Gift_Type__c,Gift_SubType__c,Apsona_Batch__r.Batch_Number__c LIMIT 10000]){         
                String key1 = String.valueOf(agg.get('Gift_Type__c'))+'-'+String.valueOf(agg.get('Gift_SubType__c'));                
                //if(mapAllocations.containsKey(key1)){
                    oppTotalAmount = oppTotalAmount + ((Decimal)agg.get('Amount')).setScale(2);
                    OpprtunityWraper opp = new OpprtunityWraper();
                        opp.key = key1;
                        opp.amount = ((Decimal)agg.get('Amount')).setScale(2);
                        opp.debitAccountNumber = glDebitAccNumber.containsKey(key1)?glDebitAccNumber.get(key1):null;
                        opp.batchNumber = String.valueOf(agg.get('batchNumber'));
                        opp.closeDate = FromDate;
                        opp.subKey = String.valueOf(agg.get('batchNumber'))+'-'+key1;
                    listOppWrap.add(opp);
               // }
            }
            //Creating date time which is used to query adjustment records based on this date time 
            //DateTime dayStartTime = DateTime.newInstance(FromDate.year(), FromDate.month(), FromDate.day(), 00, 00, 00);
            //DateTime dayEndTime = DateTime.newInstance(FromDate.year(), FromDate.month(), FromDate.day(), 23, 00, 00);
            Set<Id> setAjustOppId = new Set<Id>();
            Set<Id> setAdjustId = new Set<Id>();
            
            //Query all Gift adjustments which created date as selected in UI  
            for(Gift_Adjustments__c obj : [SELECT ID,Opportunity__c,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Opportunity__r.CloseDate,CreatedDate,Batch_No__c,Current_Amount__c,Previous_Amount__c,Adjustment_Reason__c,Adjustment_Date__c,Batch_Number__c  FROM Gift_Adjustments__c WHERE GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted' AND Adjustment_Date__c =: FromDate AND Opportunity__c Not IN : setOpportunityId AND Id NOt IN : listGiftAjustment order by Batch_Number__c DESC LIMIT 10000]){
                String key1 = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                    setAjustOppId.add(obj.Opportunity__c);
                    setAdjustId.add(obj.Id);
                    
                    if(obj.Previous_Amount__c > 0){                      
                        OppGiftAdjustMent opp1 = new OppGiftAdjustMent();
                            opp1.key = key1;
                            opp1.amount = (obj.Previous_Amount__c).setScale(2);
                            opp1.debitAccountNumber = glDebitAccNumber.containsKey(key1)?glDebitAccNumber.get(key1):null;
                            opp1.batchNumber1 = obj.Batch_No__c;
                            opp1.closeDate = (obj.CreatedDate).date();
                            opp1.postDate = obj.Adjustment_Date__c;
                            opp1.adjustReason = obj.Adjustment_Reason__c;
                        listPreviousGiftAdjustMent.add(opp1);
                        
                        allocationTotlAmount = allocationTotlAmount + obj.Previous_Amount__c;
                        //fill up all map
                        if(!mapBatchAllocation.containsKey(obj.Batch_No__c)){
                            mapBatchAllocation.put(obj.Batch_No__c,new List<OppAllAdjustMent>());
                        }
                        OppAllAdjustMent oAA = new OppAllAdjustMent();
                        oAA.key = opp1.key;
                        oAA.amount = opp1.amount;
                        oAA.debitAccountNumber = opp1.debitAccountNumber;
                        oAA.batchNumber1 = opp1.batchNumber1;
                        oAA.closeDate = opp1.closeDate;
                        oAA.postDate = opp1.postDate;
                        oAA.adjustReason = opp1.adjustReason;
                        mapBatchAllocation.get(obj.Batch_No__c).add(oAA);
                    }
                    if(obj.Current_Amount__c > 0){
                         OppGiftAdjustMent opp2 = new OppGiftAdjustMent();
                            opp2.key = key1;
                            opp2.currentAmount = (obj.Current_Amount__c).setScale(2);
                            opp2.debitAccountNumber = glDebitAccNumber.containsKey(key1)?glDebitAccNumber.get(key1):null;
                            opp2.batchNumber1 = obj.Batch_No__c;
                            opp2.closeDate = (obj.CreatedDate).date();
                            opp2.postDate = obj.Adjustment_Date__c;
                            opp2.adjustReason = obj.Adjustment_Reason__c;
                        listGiftAdjustMent.add(opp2);
                        
                        oppTotalAmount = oppTotalAmount + obj.Current_Amount__c;
                        //fill up all map
                        if(!mapBatchAllocation.containsKey(obj.Batch_No__c)){
                            mapBatchAllocation.put(obj.Batch_No__c,new List<OppAllAdjustMent>());
                        }
                        OppAllAdjustMent oAA = new OppAllAdjustMent();
                        oAA.key = opp2.key;
                        oAA.currentAmount = opp2.currentAmount;
                        oAA.debitAccountNumber = opp2.debitAccountNumber;
                        oAA.batchNumber1 = opp2.batchNumber1;
                        oAA.closeDate = opp2.closeDate;
                        oAA.postDate = opp2.postDate;
                        oAA.adjustReason = opp2.adjustReason;
                        mapBatchAllocation.get(obj.Batch_No__c).add(oAA);
                    }       
                    
            }
            //setAjustOppId.clear();
           // setAdjustId.clear();
           // Set<Id> setAjustOppId1 = new Set<Id>();
            Set<Id> setAdjustId1 = new Set<Id>();
             //Querying Gift Allocation Adjustments with created date as selected in UI 
            
            for(GAU_Allocation_Adjustment__c obj : [SELECT Id,Opportunity__c,Batch_Number__c,GAU_Allocation__c,Credit_Account_Number__c,Amount__c,Previous_Amount__c,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Opportunity__r.CloseDate,CreatedDate,Adjustment_Reason__c,Adjustment_Date__c FROM GAU_Allocation_Adjustment__c WHERE GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted' AND Adjustment_Date__c =: FromDate AND Opportunity__c Not IN : setOpportunityId AND Id Not IN : listAllocationAdjustment AND Opportunity__c Not IN : setOpppId order by Batch_Number__c DESC LIMIT 10000]){
                setAjustOppId.add(obj.Opportunity__c);
                setAdjustId1.add(obj.Id);
                if(obj.Previous_Amount__c >0){
                     oppGAuAllocationAdjustment gaa1 = new oppGAuAllocationAdjustment();
                        gaa1.key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                        gaa1.amount = (obj.Previous_Amount__c >0?obj.Previous_Amount__c:0.00);
                        gaa1.creditAccountNumber = obj.Credit_Account_Number__c;
                        gaa1.batchNumber = obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c;
                        gaa1.closeDate = (obj.CreatedDate).date();
                        gaa1.postDate = obj.Adjustment_Date__c;
                        gaa1.adjustReason = obj.Adjustment_Reason__c;
                    listAllPreviousAdjust.add(gaa1);
                    
                    oppTotalAmount = oppTotalAmount + (obj.Previous_Amount__c >0?obj.Previous_Amount__c:0);
                    //fill up all map
                    if(!mapBatchAllocation.containsKey(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c)){
                        mapBatchAllocation.put(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c,new List<OppAllAdjustMent>());
                    }
                    OppAllAdjustMent oAA = new OppAllAdjustMent();
                    oAA.key = gaa1.key;
                    oAA.amount = gaa1.amount;
                    oAA.creditAccountNumber = gaa1.creditAccountNumber;
                    oAA.batchNumber1 = gaa1.batchNumber;
                    oAA.closeDate = gaa1.closeDate;
                    oAA.postDate = gaa1.postDate;
                    oAA.adjustReason = gaa1.adjustReason;
                    mapBatchAllocation.get(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c).add(oAA);
                }
               if(obj.Amount__c > 0){
                    oppGAuAllocationAdjustment gaa = new oppGAuAllocationAdjustment();
                        gaa.key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;               
                        gaa.creditAccountNumber = obj.Credit_Account_Number__c;
                        gaa.currentAmount = obj.Amount__c;
                        gaa.batchNumber = obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c;
                        gaa.closeDate = (obj.CreatedDate).date();
                        gaa.postDate = obj.Adjustment_Date__c;
                        gaa.adjustReason = obj.Adjustment_Reason__c;
                    listAllocationAdjust.add(gaa); 
                    
                    allocationTotlAmount = allocationTotlAmount + obj.Amount__c; 
                    //fill up all map
                    if(!mapBatchAllocation.containsKey(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c)){
                        mapBatchAllocation.put(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c,new List<OppAllAdjustMent>());
                    }
                    OppAllAdjustMent oAA = new OppAllAdjustMent();
                    oAA.key = gaa.key;
                    oAA.currentAmount = gaa.currentAmount;
                    oAA.creditAccountNumber = gaa.creditAccountNumber;
                    oAA.batchNumber1 = gaa.batchNumber;
                    oAA.closeDate = gaa.closeDate;
                    oAA.postDate = gaa.postDate;
                    oAA.adjustReason = gaa.adjustReason;
                    mapBatchAllocation.get(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c).add(oAA);
               }           
            }
            //Check wether GL Gift Adjustments across multiple days if there show in UI
            for(Gift_Adjustments__c obj : [SELECT ID,Opportunity__c,Opportunity__r.Gift_Type__c,Batch_Number__c,Opportunity__r.Gift_SubType__c,Opportunity__r.CloseDate,CreatedDate,Adjustment_Date__c,Batch_No__c,Current_Amount__c,Previous_Amount__c,Adjustment_Reason__c  FROM Gift_Adjustments__c WHERE GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted' AND Opportunity__c Not IN : setOpportunityId AND Opportunity__c IN :setAjustOppId AND Id NOT IN : setAdjustId AND Id NOt IN : listGiftAjustment order by Batch_Number__c DESC LIMIT 10000]){
                String key1 = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                if(obj.Previous_Amount__c > 0){                      
                        OppGiftAdjustMent opp1 = new OppGiftAdjustMent();
                            opp1.key = key1;
                            opp1.amount = (obj.Previous_Amount__c).setScale(2);
                            opp1.debitAccountNumber = glDebitAccNumber.containsKey(key1)?glDebitAccNumber.get(key1):null;
                            opp1.batchNumber1 = obj.Batch_No__c;
                            opp1.closeDate = (obj.CreatedDate).date();
                            opp1.postDate = obj.Adjustment_Date__c;
                            opp1.adjustReason = obj.Adjustment_Reason__c;
                        listPreviousGiftAdjustMent.add(opp1);
                        
                        allocationTotlAmount = allocationTotlAmount + obj.Previous_Amount__c;
                        //fill up all map
                        if(!mapBatchAllocation.containsKey(obj.Batch_No__c)){
                            mapBatchAllocation.put(obj.Batch_No__c,new List<OppAllAdjustMent>());
                        }
                        OppAllAdjustMent oAA = new OppAllAdjustMent();
                        oAA.key = opp1.key;
                        oAA.amount = opp1.amount;
                        oAA.debitAccountNumber = opp1.debitAccountNumber;
                        oAA.batchNumber1 = opp1.batchNumber1;
                        oAA.closeDate = opp1.closeDate;
                        oAA.postDate = opp1.postDate;
                        oAA.adjustReason = opp1.adjustReason;
                        mapBatchAllocation.get(obj.Batch_No__c).add(oAA);
                    }
                    if(obj.Current_Amount__c > 0){
                         OppGiftAdjustMent opp2 = new OppGiftAdjustMent();
                            opp2.key = key1;
                            opp2.currentAmount = (obj.Current_Amount__c).setScale(2);
                            opp2.debitAccountNumber = glDebitAccNumber.containsKey(key1)?glDebitAccNumber.get(key1):null;
                            opp2.batchNumber1 = obj.Batch_No__c;
                            opp2.closeDate = (obj.CreatedDate).date();
                            opp2.postDate = obj.Adjustment_Date__c;
                            opp2.adjustReason = obj.Adjustment_Reason__c;
                        listGiftAdjustMent.add(opp2);
                        
                        oppTotalAmount = oppTotalAmount + obj.Current_Amount__c;
                        //fill up all map
                        if(!mapBatchAllocation.containsKey(obj.Batch_No__c)){
                            mapBatchAllocation.put(obj.Batch_No__c,new List<OppAllAdjustMent>());
                        }
                        OppAllAdjustMent oAA = new OppAllAdjustMent();
                        oAA.key = opp2.key;
                        oAA.currentAmount = opp2.currentAmount;
                        oAA.debitAccountNumber = opp2.debitAccountNumber;
                        oAA.batchNumber1 = opp2.batchNumber1;
                        oAA.closeDate = opp2.closeDate;
                        oAA.postDate = opp2.postDate;
                        oAA.adjustReason = opp2.adjustReason;
                        mapBatchAllocation.get(obj.Batch_No__c).add(oAA);
                    }

            }
            system.debug('***listPreviousGiftAdjustMentlist2'+listPreviousGiftAdjustMent);
            system.debug('***listGiftAdjustMentlist2'+listGiftAdjustMent);
            //Check wether GL Allocaiton Adjustments across multiple days if there show in UI
            for(GAU_Allocation_Adjustment__c obj : [SELECT Id,Credit_Account_Number__c,Amount__c,Previous_Amount__c,Opportunity__r.Gift_Type__c,Opportunity__r.Gift_SubType__c,Adjustment_Date__c,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Opportunity__r.CloseDate,CreatedDate,Adjustment_Reason__c,Batch_Number__c FROM GAU_Allocation_Adjustment__c WHERE GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted' AND Opportunity__c Not IN : setOpportunityId AND Id Not IN : listAllocationAdjustment AND Id NOT IN :setAdjustId1 AND Opportunity__c IN : setAjustOppId  AND Opportunity__c Not IN : setOpppId order by Batch_Number__c DESC LIMIT 10000]){
                if(obj.Previous_Amount__c >0){
                     oppGAuAllocationAdjustment gaa1 = new oppGAuAllocationAdjustment();
                        gaa1.key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;
                        gaa1.amount = (obj.Previous_Amount__c >0?obj.Previous_Amount__c:0.00);
                        gaa1.creditAccountNumber = obj.Credit_Account_Number__c;
                        gaa1.batchNumber = obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c;
                        gaa1.closeDate = (obj.CreatedDate).date();
                        gaa1.postDate = obj.Adjustment_Date__c;
                        gaa1.adjustReason = obj.Adjustment_Reason__c;
                    listAllPreviousAdjust.add(gaa1);
                    
                    oppTotalAmount = oppTotalAmount + (obj.Previous_Amount__c >0?obj.Previous_Amount__c:0);
                    //fill up all map
                    if(!mapBatchAllocation.containsKey(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c)){
                        mapBatchAllocation.put(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c,new List<OppAllAdjustMent>());
                    }
                    OppAllAdjustMent oAA = new OppAllAdjustMent();
                    oAA.key = gaa1.key;
                    oAA.amount = gaa1.amount;
                    oAA.creditAccountNumber = gaa1.creditAccountNumber;
                    oAA.batchNumber1 = gaa1.batchNumber;
                    oAA.closeDate = gaa1.closeDate;
                    oAA.postDate = gaa1.postDate;
                    oAA.adjustReason = gaa1.adjustReason;
                    mapBatchAllocation.get(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c).add(oAA);
                }
               if(obj.Amount__c > 0){
                    oppGAuAllocationAdjustment gaa = new oppGAuAllocationAdjustment();
                        gaa.key = obj.Opportunity__r.Gift_Type__c+'-'+obj.Opportunity__r.Gift_SubType__c;               
                        gaa.creditAccountNumber = obj.Credit_Account_Number__c;
                        gaa.currentAmount = obj.Amount__c;
                        gaa.batchNumber = obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c;
                        gaa.closeDate = (obj.CreatedDate).date();
                        gaa.postDate = obj.Adjustment_Date__c;
                        gaa.adjustReason = obj.Adjustment_Reason__c;
                    listAllocationAdjust.add(gaa); 
                    
                    allocationTotlAmount = allocationTotlAmount + obj.Amount__c; 
                    //fill up all map
                    if(!mapBatchAllocation.containsKey(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c)){
                        mapBatchAllocation.put(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c,new List<OppAllAdjustMent>());
                    }
                    OppAllAdjustMent oAA = new OppAllAdjustMent();
                    oAA.key = gaa.key;
                    oAA.currentAmount = gaa.currentAmount;
                    oAA.creditAccountNumber = gaa.creditAccountNumber;
                    oAA.batchNumber1 = gaa.batchNumber;
                    oAA.closeDate = gaa.closeDate;
                    oAA.postDate = gaa.postDate;
                    oAA.adjustReason = gaa.adjustReason;
                    mapBatchAllocation.get(obj.Opportunity__r.Apsona_Batch__r.Batch_Number__c).add(oAA);
               }           
            }
            batchNo.addall(mapBatchAllocation.keyset());
        }catch(Exception exp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Opps.. something went worng please contact your system administrator');
            ApexPages.addMessage(myMsg);
        }
        
        
    }
    //Check for execption records 
    public void getValidate(){
        Decimal allAmount = 0;
        setOpportunityId = new Set<Id>();
        listNoDebitNumber = new List<Opportunity>();
        listOppWithoutChild = new List<Opportunity>();
        setNoCreditNummber = new List<Opportunity>();
        listNotMatchOppAmount = new List<Opportunity>();
        listAllocationAdjustment = new List<GAU_Allocation_Adjustment__c>();
        mapGidtAllocation = new Map<Id,Gift_Adjustments__c>();
        listGiftAjustment = new List<Gift_Adjustments__c>();
        setOpppId = new Set<String>();
        for(Opportunity obj : [SELECT Id,Name,npsp__Primary_Contact__c,Gift_Id__c,AccountConstituentId__c,ContactConstituentId__c,Amount,GL_Debit_Account_Number__c,Apsona_Batch__r.Batch_Number__c, (SELECT Id,Name,Credit_Account_Number__c,npsp__Amount__c FROM npsp__Allocations__r) FROM Opportunity WHERE stageName = 'Posted' AND CloseDate=:FromDate AND isPosted__c=false]){
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

        for(Gift_Adjustments__c obj : [SELECT Id,Opportunity__c,Opportunity__r.Gift_Id__c,Opportunity__r.Total_Allocation_Amount__c,Opportunity__r.Amount,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Opportunity__r.AccountConstituentId__c,Opportunity__r.ContactConstituentId__c,Adjustment_Date__c FROM Gift_Adjustments__c WHERE Adjustment_Date__c =: FromDate AND GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted']){
            if(obj.Opportunity__r.Amount != obj.Opportunity__r.Total_Allocation_Amount__c){
                listGiftAjustment.add(obj);
                setOpppId.add(obj.Opportunity__c);
                mapGidtAllocation.put(obj.Opportunity__c,obj);
            }
        }

        for(GAU_Allocation_Adjustment__c obj : [SELECT Id,Opportunity__r.Gift_Id__c,Opportunity__r.Total_Allocation_Amount__c,Opportunity__r.Amount,Opportunity__r.Apsona_Batch__r.Batch_Number__c,Opportunity__r.AccountConstituentId__c,Opportunity__r.ContactConstituentId__c,Adjustment_Date__c FROM GAU_Allocation_Adjustment__c WHERE Adjustment_Date__c =: FromDate AND Opportunity__c Not IN : setOpppId AND GL_Post_Date__c = null AND Opportunity__r.stageName = 'Posted']){
            if(obj.Opportunity__r.Amount != obj.Opportunity__r.Total_Allocation_Amount__c){
                listAllocationAdjustment.add(obj);
            }
        }
        
    }
    
    public class OpprtunityWraper{
        public String key{get;set;}
        public Decimal amount{get;set;}
        public String debitAccountNumber{get;set;}
        public String batchNumber{get;set;}
        public Date closeDate{get;set;}
        public String subKey{get;set;}
    }
    
    public class OppGiftAdjustMent{
        public String key{get;set;}
        public Decimal amount{get;set;}
        public String debitAccountNumber{get;set;}
        public Decimal currentAmount{get;set;}
        public String batchNumber1{get;set;}
        public Date closeDate{get;set;}
        public Date postDate{get;set;}
        public String adjustReason{get;set;}
    }
    public class OppAllAdjustMent{
        public String key{get;set;}
        public String creditAccountNumber{get;set;}
        public Decimal amount{get;set;}
        public String debitAccountNumber{get;set;}
        public Decimal currentAmount{get;set;}
        public String batchNumber1{get;set;}
        public Date closeDate{get;set;}
        public Date postDate{get;set;}
        public String adjustReason{get;set;}
    }
    
    public class oppGAuAllocationAdjustment{
        public String key{get;set;}
        public Decimal amount{get;set;}
        public String creditAccountNumber{get;set;}
        public Decimal currentAmount{get;set;}
        public String batchNumber{get;set;}
        public Date closeDate{get;set;}
        public Date postDate{get;set;}
        public String adjustReason{get;set;}
    }

}