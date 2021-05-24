@isTest
public class REMigrationOfNotepadsTest{
    @TestSetup
    public static void testDataCreate(){
        
        Awana_Settings__c awanaSettings = new Awana_Settings__c(Name='EnableDeDupCheck',Value__c='false');
        insert awanaSettings;
        Contact con = new Contact(
            lastName='Test last',
            FirstName='Test first',
            Constituent_Id__c = '112233',
            RE_Constit_Rec_Id__c = '1234',
            Constituent_Code__c = 'Individual;Former Board Member',
            Constituent_Solicit_Code__c='No Appeals;Requested No Email',
            Missionary_Salutation__c='Test',
            Major_Donor_Salutation__c='Missionary Test',
            RE_Primary_Addresee__c='Mr. Test',
            RE_Primary_Salutation__c='Test',
            RE_Sub_set__c='B'
        );
        insert con;
        List<Account> accList = [SELECT Id,Name FROM Account WHERE npe01__One2OneContact__c=:con.Id];
        if(!accList.isEmpty()){
            Opportunity opp = new Opportunity(
                                name='Oppty 1',
                                AccountId=accList[0].Id,
                                npsp__Primary_Contact__c = con.Id,
                                closeDate=Date.today(),
                                stagename='Posted',
                                Amount=1000,
                                Gift_Type__c='Cash',
                                Gift_SubType__c='ACH1',
                                Source_Gift_Id__c ='123'
                                );
            insert opp;
        }
    }
    @isTest
    public static void testGiftNotepad(){
        Contact con = [SELECT Id,AccountId,FirstName,Constituent_Code__c FROM Contact WHERE lastName='Test last'];
        Opportunity opp = [SELECT Id,Name,AccountId,Source_Gift_Id__c FROM Opportunity WHERE AccountId=:con.AccountId];
        System.debug('Opportunity data : '+opp);
        
        Awana_Settings__c awanaSettings1 = new Awana_Settings__c(Name='ExecuteNotesTrigger',Value__c='true');
        insert awanaSettings1;
        Awana_Settings__c awanaSettings2 = new Awana_Settings__c(Name='RENotesMigrationParentObjectName',Value__c='Opportunity');
        insert awanaSettings2;
        
        Note noteObj = new Note(
                        Title = opp.Source_Gift_Id__c+'#~#'+'test title',
                        parentId=null,
                        Body = 'This is test note for Gift.' 
                        );
        insert noteObj;
        Note note2 = [SELECT Id,ParentId FROM NOTE WHERE id=:noteObj.Id];
        System.assert(note2.parentId == opp.Id);

    }
    @isTest
    public static void testConstituentNotepad(){
        Contact con = [SELECT Id,AccountId,FirstName,Constituent_Code__c,RE_Constit_Rec_Id__c  FROM Contact WHERE lastName='Test last'];
        
        Account acc = new Account(
                        id=con.AccountId,
                        RE_Constit_Rec_Id__c  ='4567'
                        );
        update acc;
        
        
        Awana_Settings__c awanaSettings1 = new Awana_Settings__c(Name='ExecuteNotesTrigger',Value__c='true');
        insert awanaSettings1;
        Awana_Settings__c awanaSettings2 = new Awana_Settings__c(Name='RENotesMigrationParentObjectName',Value__c='Constituent');
        insert awanaSettings2;
        
        List<Note> noteToInsert = new List<Note>();
        Note noteObj1 = new Note(
                        Title = con.RE_Constit_Rec_Id__c +'#~#'+'test title contact',
                        parentId=null,
                        Body = 'This is test note for Individual Constituent.' 
                        );
        noteToInsert.add(noteObj1);
        Note noteObj2 = new Note(
                        Title = acc.RE_Constit_Rec_Id__c +'#~#'+'test title Account',
                        parentId=null,
                        Body = 'This is test note for Constituent' 
                        );
        noteToInsert.add(noteObj2);
        insert noteToInsert;
        
        Note noteContact = [SELECT Id,ParentId FROM NOTE WHERE title like '%contact%'];
        System.assert(noteContact.parentId == con.Id);

        Note noteAccount = [SELECT Id,ParentId FROM NOTE WHERE title like '%Account%'];
        System.assert(noteAccount.parentId == acc.Id);

    }
}