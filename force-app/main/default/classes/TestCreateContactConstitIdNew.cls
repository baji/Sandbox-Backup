@IsTest
public class TestCreateContactConstitIdNew{

public static testMethod void CreateConstitutId(){
        List<contact> conList = new List<Contact>();
        conList.add(new Contact(LastName='Baji',FirstName='Basha',LeadSource='Test'));
        
        
        ConstitIdSeries__c  setting = new ConstitIdSeries__c();
        setting.Name = 'ConstitIdStartNumber';
        setting.ConstitSeriesNo__c = 1500000;
        
        insert setting;
        Test.startTest();
        ConstituentIDContactNew.contactInsert(conList);
        insert conList;
        Test.stopTest();
    }
}