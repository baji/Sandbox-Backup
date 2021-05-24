public without sharing class MigrationUtility {
    
    public static map<String,String> getAccountData(list<string> accountOldIds){
        list<Account> accountLst = [SELECT Id,Source_Account_Rec_Id__c FROM Account WHERE Source_Account_Rec_Id__c IN :accountOldIds];
        map<String,String> accountOldIdToNewIdMap = new map<String,String>();
        for(Account Acc : accountLst){
            accountOldIdToNewIdMap.put(Acc.Source_Account_Rec_Id__c,Acc.Id);
        }
        return accountOldIdToNewIdMap;
    }
    public static map<String,String> getUserData(list<string> sourceUserRecordId){
        list<User> userList = [SELECT Id,Source_User_Rec_Id_c__c FROM User WHERE Source_User_Rec_Id_c__c IN :sourceUserRecordId AND isActive=true];
        map<String,String> userOldIdToNewIdMap = new map<String,String>();
        for(User usr : userList){
            userOldIdToNewIdMap.put(usr.Source_User_Rec_Id_c__c,usr.Id);
        }
        return userOldIdToNewIdMap;
    }
    public static map<String,String> getPriceBookData(list<string> priceBookOldIds){
        list<Pricebook2> PriceBookList = [SELECT Id,Source_Pricebook_Rec_Id__c FROM Pricebook2 WHERE Source_Pricebook_Rec_Id__c IN :priceBookOldIds];
        map<String,String> returnMap = new map<String,String>();
        for(Pricebook2 PB : PriceBookList){
            returnMap.put(PB.Source_Pricebook_Rec_Id__c,PB.Id);
        }
        return returnMap;
    }
     public static map<String,String> getCampaignData(list<string> CampaignsToFetch){
        list<Campaign> CampaignList = [SELECT Id,Source_Campaign_Record_Id__c FROM Campaign WHERE Source_Campaign_Record_Id__c IN :CampaignsToFetch];
        map<String,String> returnMap = new map<String,String>();
        for(Campaign Camp : CampaignList){
            returnMap.put(Camp.Source_Campaign_Record_Id__c,Camp.Id);
        }
        return returnMap;
    }
     public static map<String,String> getProductData(list<string> productsToFetch){
        list<Product2> ProductLst = [SELECT Id,Source_Product2_Id__c FROM Product2 WHERE Source_Product2_Id__c IN :productsToFetch];
        map<String,String> returnMap = new map<String,String>();
        for(Product2 Prod : ProductLst){
            returnMap.put(Prod.Source_Product2_Id__c,Prod.Id);
        }
        return returnMap;
    }
    
}