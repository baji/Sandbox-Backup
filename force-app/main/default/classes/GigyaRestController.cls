@RestResource(urlMapping='/Gigya/*')
global class GigyaRestController{
    @HttpPost
    global static String updateGigyaUID(String uid,String email)
    {
        List<Contact> emailList = [select Id,Email,Gigya_UID__c from Contact where Email =:email Limit 100];
        List<Contact> upList = new List<Contact>();
        try{
        
        if(uid != null){
            for(Contact c:emailList){                
                c.Gigya_UID__c = uid;
                upList.add(c);
                //update c;
            }
            
            update upList;
        }
        return 'success';
       }
       catch(Exception e){
            return String.valueOf(e);
       }
    }
}