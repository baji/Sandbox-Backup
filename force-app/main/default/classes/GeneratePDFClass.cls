global class GeneratePDFClass {
    static webservice Id GenerateCustomPDF(Id recordId){
        
        PageReference defaultPage = new PageReference('/apex/GeneratePDF'); 
        defaultPage.getParameters().put('contactId',recordId); 
        Blob pageData;
        if(!Test.isRunningTest()){
            pageData = defaultPage.getContentAsPDF();
        } else {
            pageData = Blob.valueOf('This is a test.');
        }
        //create attachment and assign to Contact
        Attachment att = new Attachment(
                                ParentId=recordId,
                                Body=pageData,
                                Name='TestAttach ' + DateTime.now().formatLong() + '.pdf'
                            );
        insert att;
        return att.Id;
    }
}