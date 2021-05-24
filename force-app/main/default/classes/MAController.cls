global class MAController {

    public blob Photo{get;set;}
    public String photourl { get; set; }

    public void UploadPhoto() {
        String conid = ApexPages.currentPage().getParameters().get('id');
        Contact c = [select AccountId,Account.Name,FirstName,LastName,Name,Account.Mailing_Address_Book__c,isAgreementSigned__c,imgUrl__c from Contact where Id=: conid];
        photourl = c.imgUrl__c;
        Attachment objA=new Attachment();
            objA.body = photo;
            objA.name = c.Name+'_Sign';
            objA.parentid= c.AccountId;
            objA.ContentType = 'application/png';
            insert objA;
            string Attid= objA.id;
            string attachmentid=Attid.substring(0,15);
            c.imgUrl__c = '/servlet/servlet.FileDownload?file='+attachmentid;
            update c;
            photourl = c.imgUrl__c;

    }
    
    @RemoteAction
    global static String createMA(string conId,string accId) {
        
        npe5__Affiliation__c aff = [select npe5__Contact__r.Name,npe5__Organization__r.Name,npe5__Organization__r.Mailing_Address_Book__c,npe5__Contact__r.isAgreementSigned__c,npe5__Contact__r.imgUrl__c from npe5__Affiliation__c where npe5__Contact__c =: conId and npe5__Organization__c =: accId];
        
        
        Contact con = [select isAgreementSigned__c from Contact where Id=: conId];
        
        if(con.isAgreementSigned__c == false){
            con.isAgreementSigned__c = true;
            update con;
            //https://bajidssk-dev-ed--bajisk.ap15.visual.force.com/apex/AgreementPDF?Id=00390000010vpz8&cId=0019000000yMt1O
            PageReference defaultPage = new PageReference('/apex/MinistryAgreementPDF'); 
            defaultPage.getParameters().put('Id',conId);  
            Blob pageData;
            
            pageData = defaultPage.getContentAsPDF();
            
            //create attachment and assign to Contact
            Attachment att = new Attachment(
                                    ParentId=accId,
                                    Body=pageData,
                                    Name='Agreement ' + DateTime.now().formatLong() + '.pdf'
                                );
            insert att;
            //return att.Id;
            return 'success';
        }
        else{
            return 'Fail';
        }
        
    }
    @RemoteAction
    global static npe5__Affiliation__c checkMA(string conId,string accId) {
        npe5__Affiliation__c aff = [select npe5__Contact__r.Name,npe5__Contact__r.LastModifiedDate,npe5__Organization__r.Name,npe5__Organization__r.Mailing_Address_Book__c,npe5__Contact__r.isAgreementSigned__c,npe5__Contact__r.imgUrl__c from npe5__Affiliation__c where npe5__Contact__c =: conId and npe5__Organization__c =: accId];
        return aff;
        //Contact con = [select Account.Name,FirstName,LastName,Name,Account.Mailing_Address_Book__c,isAgreementSigned__c,imgUrl__c from Contact where Id=: conId and Account.Id=: accId];
        //return con;
        
    }
}