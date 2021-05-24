/******************************************************************************************************************
Programmer:         Ayesha
Contact:            ayesha@infoglen.com
Project:            DRM 
Original:           7/19/2018  - To test Convio Gift Class
****************************************************************************************************************************/

@isTest
public class Test_ConvioGiftclass {
    @testSetup 
    static void createAccount() {
        // Create common test accounts and opportunities
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteDRMAccountTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        Account acc = testObjects.NewGenericAccount();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        acc.name = 'TestAccount1';
        acc.recordtypeid = RecordTypeIdAccount;
        acc.constituent_id__c = '34739';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        Id RecordTypeIdAccountHH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Church').getRecordTypeId();
        acc1.name = 'TestAccount2';
        acc1.recordtypeid = RecordTypeIdAccountHH;
        acc.constituent_id__c = '9900';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        Contact cn = new contact(firstname = 'Ms',lastname = 'sai',constituent_id__c='89534');
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
    }
    static String str = 'CONS_ID,CONS_TITLE,LAST_NAME,FIRST_NAME,MIDDLE_NAME,PRIMARY_EMAIL,'+
                        'EMAIL_OPT_IN,CONS_PHONE,HOME_STREET1,HOME_STREET2,HOME_CITY,HOME_STATEPROV,'+
                        'HOME_ZIP,HOME_COUNTRY,MEMBER_ID,CAMPAIGN_NAME,FORM_NAME,LEVEL_NAME,TRANSACTION_ID,'+
                        'TOTAL_ADDITIONAL_GIFT_AMOUNT,PAYMENT_PLAN,DONATION_DATE,DONATION_TYPE,PAYMENT_METHOD,'+
                        'RP_REFERENCE_NUMBER,RP_AMOUNT_PER_PERIOD,RP_FREQUENCY_LABEL,RP_PROJECTED_AMOUNT,RP_PROJECTION_METHOD,'+
                        'RP_STATUS,RP_NUM_COMPLETED_PAYMENTS,RP_NUM_FAILED_PAYMENTS,RP_LAST_PAYMENT_DATE,RP_NEXT_PAYMENT_DATE,'+
                        'RP_END_DATE,DESIGNEE_NAME,ACCOUNTING_CODE,TOTAL_DESIGNATED_AMOUNT,ROW_NO,ROW_COUNT,TOTAL_GIFT_AMOUNT\n 1307333,'+
                        'Mrs.,Noden,Marcia,,halmarcia1@verizon.net,Yes,,4 Ash Tree Lane,,Hockessin,DE,19707-9284,United States,34739,'+
                        'Responsive Forms,Wconvio,Donor Entered Amount,431981,0,Sustaining,7/1/2018,Sustaining Gift,Visa,AX0NFEA32FE4,50,Monthly,600,'+
                        'Unlimited ($ Per Year),Active,11,0,7/1/2018,8/1/2018,,"North America - United States :: Northeast (CT,DE,MA,ME,NH,NJ,NY,PA,RI,VT) :: Brian & Joanelle Lunger",'+
                        'U222,50,1,1,50\n 1300319,Mrs.,Stevenson,Tami,,jvstevenson@gmail.com,No,708-204-1675,715 Littleton Tr,,Elgin,IL,60120-7003,United States,9900,Responsive Forms,'+
                        'Wconvio,Donor Entered Amount,431966,0,Sustaining,7/1/2018,Sustaining Gift,MasterCard,AC1N0AD0205B,50,Monthly,600,Unlimited ($ Per Year),Active,5,0,7/1/2018,7/31/2018,,'+
                        '"North America - United States :: Mid-America (IN,KY,MI,OH,WV) :: Mike & Kris Reed",U322,50,1,1,50\n 1005657,Mr.,Moore,Denver,,dmbuilder1@msn.com,Yes,(941)776-0808,'+
                        '11818 71st St E,,Parrish,FL,34219-8597,USA,89534,Awana Missions,Wconvio,Donor Entered Amount,432032,0,Sustaining,7/1/2018,Sustaining Gift,Visa,VLFA7D942342,10,Monthly,'+
                        '120,Unlimited ($ Per Year),Active,69,0,7/1/2018,8/1/2018,,Commander College,U219COMM,10,1,1,10 \n 1164392,Mr.,Karn,Nathan,,nkarn@atlanticbb.net,No,(814)696-1542,1410 Spruce St,,'+
                        'Hollidaysburg,PA,16648-2340,USA,737893,Awana Missions,Wconvio,Donor Entered Amount,432033,0,Sustaining,7/1/2018,Sustaining Gift,Visa,VSJAA388C5F9,110,Monthly,1320,Unlimited ($ Per Year),'+
                        'Active,66,0,7/1/2018,8/1/2018,,"Missionaries - U.S. - Fuller, Marlin",U232,20,1,4,110\n 1164392,Mr.,Karn,Nathan,,nkarn@atlanticbb.net,No,(814)696-1542,1410 Spruce St,,Hollidaysburg,PA,'+
                        '16648-2340,USA,737893,Awana Missions,Wconvio,Donor Entered Amount,432033,0,Sustaining,7/1/2018,Sustaining Gift,Visa,VSJAA388C5F9,110,Monthly,1320,Unlimited ($ Per Year),Active,66,0,'+
                        '7/1/2018,8/1/2018,,Adopt-a-Club - Pakistan,PK001,20,2,4,110\n 1164392,Mr.,Karn,Nathan,,nkarn@atlanticbb.net,No,(814)696-1542,1410 Spruce St,,Hollidaysburg,PA,16648-2340,USA,737893,'+
                        'Awana Missions,Wconvio,Donor Entered Amount,432033,0,Sustaining,7/1/2018,Sustaining Gift,Visa,VSJAA388C5F9,110,Monthly,1320,Unlimited ($ Per Year),Active,66,0,7/1/2018,8/1/2018,,'+
                        'Adopt-a-Club - Liberia,LR001,30,3,4,110\n 1164392,Mr.,Karn,Nathan,,nkarn@atlanticbb.net,No,(814)696-1542,1410 Spruce St,,Hollidaysburg,PA,16648-2340,USA,737893,Awana Missions,Wconvio,'+
                        'Donor Entered Amount,432033,0,Sustaining,7/1/2018,Sustaining Gift,Visa,VSJAA388C5F9,110,Monthly,1320,Unlimited ($ Per Year),Active,66,0,7/1/2018,8/1/2018,,"Missionaries - U.S. - Moss,'+
                        'Lanty - Pennsylvania",U328,40,4,4,110'  ; 
    public static String[] csvFileLines;
    public static Blob csvBlob;
    public static testMethod void testprocessConvioGift(){
        test.startTest();
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 8;
        insert bCS1;
        Convio_Batch__c cv = new Convio_Batch__c();
        cv.name = 'Test - Aye';
        insert cv;
        System.Assert(cv.Id != null, 'Convio Record is not inserted');
        csvBlob = Blob.valueOf(str);
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'Receipt.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Receipt-' +System.now().format('yyyy-MM-dd') + '.csv'; // Display name of the files
        conVer.VersionData = csvBlob; 
        insert conVer;
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
        cDe.LinkedEntityId = cv.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        try{
            insert cDe; 
        }
        catch(exception e){
        }
        PageReference pageRef = Page.Process_Convio_Batch;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(cv);
        ApexPages.currentPage().getParameters().put('Id',cv.Id);
        ConvioGiftclass cgClass = new ConvioGiftclass(sc);
        cgClass.processConvioGift();
        test.stopTest();
    }
    public static testMethod void testprocessConvioGiftMethod2(){
        test.startTest();
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 8;
        insert bCS1;
        Convio_Batch__c cv = new Convio_Batch__c();
        cv.name = 'Test - Aye';
        insert cv;
        System.Assert(cv.Id != null, 'Convio Record is not inserted');
        csvBlob = Blob.valueOf(str);
        PageReference pageRef = Page.Process_Convio_Batch;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(cv);
        ApexPages.currentPage().getParameters().put('Id',cv.Id);
        ConvioGiftclass cgClass = new ConvioGiftclass(sc);
        cgClass.processConvioGift();
        cgClass.redirectConvio();
        test.stopTest();
    }
    public static testMethod void testprocessConvioGiftMethod3(){
        test.startTest();
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 8;
        insert bCS1;
        Convio_Batch__c cv = new Convio_Batch__c();
        cv.name = 'Test - Aye';
        insert cv;
        System.Assert(cv.Id != null, 'Convio Record is not inserted');
        csvBlob = Blob.valueOf(str);
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ConvioBatch.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'ConvioBatch-' +System.now().format('yyyy-MM-dd') + '.csv'; // Display name of the files
        conVer.VersionData = csvBlob; 
        insert conVer;
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
        cDe.LinkedEntityId = cv.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        try{
            insert cDe; 
        }
        catch(exception e){
        }
        PageReference pageRef = Page.Process_Convio_Batch;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(cv);
        ApexPages.currentPage().getParameters().put('Id',cv.Id);
        ConvioGiftclass cgClass = new ConvioGiftclass(sc);
        cgClass.processConvioGift();
        cgClass.checkBatchStatus();
        test.stopTest();
    }
    public static testMethod void testprocessConvioGiftMethod4(){
        test.startTest();
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 8;
        insert bCS1;
        Convio_Batch__c cv = new Convio_Batch__c();
        cv.name = 'Test - Aye';
        insert cv;
        System.Assert(cv.Id != null, 'Convio Record is not inserted');
        csvBlob = Blob.valueOf(str);
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ConvioBatch.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'ConvioBatch-' +System.now().format('yyyy-MM-dd') + '.csv'; // Display name of the files
        conVer.VersionData = csvBlob; 
        insert conVer;
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
        cDe.LinkedEntityId = cv.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        try{
            insert cDe; 
        }
        catch(exception e){
        }
        PageReference pageRef = Page.Process_Convio_Batch;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(cv);
        ApexPages.currentPage().getParameters().put('Id',cv.Id);
        GenerateConvioGifts coBatch = new GenerateConvioGifts(cv.Id); 
        Id batchprocessid = database.executeBatch(coBatch,1); 
        ConvioGiftclass cgClass = new ConvioGiftclass(sc);
        cgClass.processConvioGift();
        System.abortJob(batchprocessid);
        checkRecursive.batchStatus = 'Holding';
        cgClass.checkBatchStatus();
        checkRecursive.batchStatus = 'Processing';
        cgClass.checkBatchStatus();
        checkRecursive.batchStatus = 'Completed';
        cgClass.checkBatchStatus();
        checkRecursive.batchStatus = 'Complete';
        cgClass.checkBatchStatus();
        test.stopTest();
    }
}