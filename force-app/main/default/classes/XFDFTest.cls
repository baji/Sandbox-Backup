public class XFDFTest{
        private String getXmlString(Contact c)
        {
            String s = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">' +
                '<f href="https://awana--test.my.salesforce.com/resource/0/myform.pdf"/>' +
                '<fields>' +
                '<field name="Name"><value>' + c.firstname + ' ' + c.lastname + '</value></field>' +
                '</fields><ids original="FEBDB19E0CD32274C16CE13DCF244AD2" modified="5BE74DD4F607B7409DC03D600E466E12"/>' +
                '</xfdf>';
 
            return s;
        }       
 
 
 
        public PageReference XFDFInit() {
            Contact c = [SELECT Id, firstname, lastname
                     FROM Contact
                     WHERE id = :ApexPages.currentPage().getParameters().get('id')];
 
        String xmlContent = getXmlString(c);
 
        Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(xmlContent);
            attachment.Name = c.lastname + c.firstname + '.XFDF';
            attachment.ParentId = c.Id;
 
            insert attachment;
 
        PageReference contactPage = new PageReference('/' + c.id);
        contactPage.setRedirect(true);
        return contactPage;
        }
}