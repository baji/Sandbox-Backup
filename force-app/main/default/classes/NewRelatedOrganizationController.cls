public class NewRelatedOrganizationController {
    public String theme{get;set;}
    public String conId{get;set;}
    public NewRelatedOrganizationController(ApexPages.StandardSetController controller) {
        conId = '';
        String contactName = ApexPages.currentPage().getParameters().get('conName');
        List<Contact> con = [SELECT ID,Name FROM Contact Where Name=:contactName]; //FirstName='Contact' AND LastName='DO NOT DELETE'
        if(!con.isEmpty())
            conId = con[0].Id;    
        
    }
    
    public PageReference checkParam(){
        system.debug('theme : '+theme);
        if(theme== 'Theme3'){//if classic
            String prefix = npe5__Affiliation__c.sObjectType.getDescribe().getKeyPrefix(); 
            String conFieldId = ApexPages.currentPage().getParameters().get('conFieldId'); //'CF00Nf4000005YnsT';
            String contactName = ApexPages.currentPage().getParameters().get('conName');//EncodingUtil.urlEncode('Contact DO NOT DELETE', 'UTF-8');
            String accLookupFieldId= ApexPages.currentPage().getParameters().get('accLookupFieldId');//'CF00Nf4000005YnsS';
            String accId = ApexPages.currentPage().getParameters().get('accId');
            String accName = ApexPages.currentPage().getParameters().get('accName');
             // /a0H/e?CF00Nf4000005YnsT=Affiliation+DO+NOT+DELETE&CF00N0v000001sqAn={!Account.Name}&CF00N0v000001sqAn_lkid={!Account.Id}&retURL={!Account.Id}
            String url = '/'+prefix+'/e?'+conFieldId+'='+contactName+'&'+accLookupFieldId+'_lkid='+accId+'&'+accLookupFieldId+'='+accName+'&retURL='+accId;
            System.debug('url : '+ url);
            return new PageReference(url);
        }else{
            System.debug('in lightning');
        }
        return null;
        
    }
    
}