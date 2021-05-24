/*
Purpose - CLass SendDownloadbale  - ASP-874
Description - Coe will handle emailing of Non-Stcok Downloadable links to a client. 
Author - Tony Wiliams.
Called By : ProcessOrder.Trigger
Test Class: SendDownloadableEmails_Test
Updated: 	10-03-2018  -<ASP-1435> -  Removed the for loop that prints multiple duplicate URL Links for an item because its Quantity value is > 1. ONly 1 URL link should be displayed for that item.
Updated: 	10-03-2018  -<ASP-1456> - writes the Catalog Price Book Entry's DOwnloadable URL link to the custom email body instead of the order item Downloadable URL (WOO leaves these null)
*/
public without sharing class SendDownloadableEmails {
    
    public static void handler(List<ID> CustomerServiceOrderIDs,map<Id,Id> orderToOCRMap,list<OrgWideEmailAddress> orgEmailIdLst){
        //Create a map and get all the Line Items by CustomerServiceOrderIDs with product code.
        //Get the downloadbles into a map to pair up with any 
        //Map<Id,String> getOrderNames = new Map<Id,String>([SELECT Id,Name FROM Order where Id in:orderToOCRMap.keySet()]);
        Map<Id,Contact> ordercontact = new Map<Id,Contact>([Select Id, Email,FirstName,LastName FROM  Contact WHERE id in:orderToOCRMap.values()]); 
        //List<OrderItem> getDownloads = [SELECT Id,OrderId,Order.Name, Quantity,PricebookEntry.Product2.Name,PricebookEntry.Product2.Downloadable_Product_URL__c,Downloadable_Product_URL__c FROM OrderItem where Downloadable_Product_URL__c <> null and OrderId in: CustomerServiceOrderIDs];
           List<OrderItem> getDownloads = [SELECT Id,OrderId,Order.Name,Order.OrderNumber, Quantity,PricebookEntry.Product2.Name,PricebookEntry.Product2.Downloadable_Product_URL__c,Downloadable_Product_URL__c FROM OrderItem WHERE PricebookEntry.Product2.Downloadable_Product_URL__c <> NULL and Order.Id =: CustomerServiceOrderIDs];
           
        list<Messaging.SingleEmailMessage> emailTobeSent = new list<Messaging.SingleEmailMessage>();
        List<String> emailIdLst = new List<String>();
        //1 Nested loops must match orderToOCRMap.put(OCR.Order__c,OCR.Contact__c); 
        String output='';
        String OrderName ='';
        system.debug('<< SIZE OF Orders >> '+CustomerServiceOrderIDs.size());
        Integer linecnt = 1;
        for(Id an_orderId : CustomerServiceOrderIDs){
           List<OrderItem> non_stockOLIs = [SELECT Id FROM OrderItem WHERE (Line_Type__c like '% - Non-Stock%' or Line_Type__c like '%P - Donation%' or Line_Type__c like '% - Direct Ship%')  and Order.Id =: an_orderId];  
           
           // Buld up a list of order items per each Order Id;
           //Integer linecnt = 1;
            // As long as we have orders keep building out output string of URLs and Product names
            for(OrderItem itemPerOrder : getDownloads ){
                if(itemPerOrder.OrderId == an_orderId && non_stockOLIs.size()>0)  {
                    //for(Integer i = 0; i < itemPerOrder.Quantity;i++){
                       // output=output+linecnt+'. '+'<a href="'+itemPerOrder.Downloadable_Product_URL__c+'">'+itemPerOrder.PricebookEntry.Product2.Name+'</a><br/>'+'\n';
                    	output=output+'&middot;&nbsp;'+'<a href="'+itemPerOrder.PricebookEntry.Product2.Downloadable_Product_URL__c+'">'+itemPerOrder.PricebookEntry.Product2.Name+'</a><br/>';
                 
                        linecnt++;
                   // }//Qty FOR
                } 
            OrderName = itemPerOrder.Order.OrderNumber; 
            }// INNER LOOP
            //3. Now send email to Contact...
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //... So the  orderToOCRMap.get(an_orderId) returns Contact.Id. Thus ordercontact.get(Contact.Id) returns  corresponding Contact object
            Contact a_ordcontact = ordercontact.get(orderToOCRMap.get(an_orderId)); 
            if(a_ordcontact.Email !='' && a_ordcontact.Email!=null){                
                emailIdLst.add(a_ordcontact.Email);
                if(emailIdLst!=null && emailIdLst.size()>0){   
                    //emailIdLst.add('SFApps@awana.org');
                    mail.setBccAddresses(new String[] {'SFApps@awana.org'});
                    mail.toAddresses = emailIdLst;
                }//... Set up dontreply sender below...
                if(orgEmailIdLst!=null && orgEmailIdLst.size()>0){
                    mail.setOrgWideEmailAddressId(orgEmailIdLst.get(0).Id);  
                }
                mail.setWhatId(an_orderId);
                mail.setSubject('Download Links for Order: '+OrderName);
                String mailifno = '<table style="width:100%">'+
	                               '<tr><td colspan="2"> Thank you for your order of a digital download from Awana. We are grateful for your partnership. Your download instructions can be found below.</td></tr>'+
	                               '<tr><td colspan="2"> <hr> </td></tr>'+
	                               '<tr><td colspan="2"><span style="font-weight:bold;font-size:16px">Download Methods</span> </td></tr>'+
	                               '<tr><td colspan="2"> There are currently two methods available to download your purchase(s). Feel free to use the method that best serves your needs: </td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%"><u><b>MyAwana</b></u>: You can access your digital downloads by visiting the ‘<b><i>MY DIGITAL DOWNLOADS</i></b>’ section of <a href="my.awana.org">my.awana.org</a>. Using myAwana will allow you to see all of your Awana Store digital purchases in one location, and has the added benefit of letting you share your downloads with other leaders affiliated with your church. <b>Please note that this digital product access will be available after the order is invoiced which may take a day or two.</b></td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%"><u><b>Direct</b></u>: Please click or tap the link(s) below. Please note that your link(s) will expire after 7 days from the date of purchase.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;"></td>'+
	                               '<td style="width:95%;padding-left:15px;">'+
	                               output+
	                               '</td></tr>'+
	                               '<tr><td colspan="2"><span style="font-weight:bold;font-size:16px">Next Steps</span> </td></tr>'+
	                               '<tr><td colspan="2">After the download completes, you will need to use an appropriate reader or player on your device to view your content. The player or reader to use will depend upon the type of file you have downloaded. For instance:</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">PDF files can be read using Adobe Acrobat Reader DC (a free PDF reader).</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">EPUB files may require eBook reader software such as Nook, Adobe Digital Edition, or the Kindle App for Windows or Mac.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">HTML files can be opened in any standard web-browser.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">PPT (Powerpoint) files are created for Microsoft Office Powerpoint or Apple Keynote.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">Audio files (MP3 or WAV formats) can be opened in most media players (such as iTunes, Windows Media Player or VLC).</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">Video files (MP4, WMV, MPEG or MOV formats) can be opened in most media players (such as Quicktime (Mac OSX), Windows Media Player (Windows) or VLC.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">&bull;</td>'+
	                               '<td style="width:95%">Some Awana products have multiple files bundled together in a compressed file called a ZIP file. Please use appropriate decompressing software to unzip and separate/extract the files to your device, and then use the applicable reader/player to open the file.</td></tr>'+
	                               '<tr><td colspan="2"> <hr> </td></tr>'+
	                               '<tr><td colspan="2"><span style="font-weight:bold;font-size:16px">Trouble Downloading?</span> </td></tr>'+
	                               '<tr><td colspan="2">If you are having issues accessing your files, please try both download methods above. If you still are experiencing issues, you can try the following:</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">1.&nbsp;</td>'+
	                               '<td style="width:95%">Right-click the link(s) above and choose to <b>"<i>Save File As</i>"</b>, <b>"<i>Save Target As</i>"</b>, or <b>"<i>Download File</i>"</b> (depending on the device and operating system you are using) to ensure you download the file to your desired location.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">2.&nbsp;</td>'+
	                               '<td style="width:95%">Try a different browser (such Google Chrome, Apple Safari, Microsoft Internet Explorer, or Firefox).</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">3.&nbsp;</td>'+
	                               '<td style="width:95%">If on a mobile device or tablet, please try closing/re-opening your application to retry the download.</td></tr>'+
	                               '<tr><td style="width:5%;text-align:right;vertical-align: top;">4.&nbsp;</td>'+
	                               '<td style="width:95%">If you are still experiencing issues, please contact our <b><i>Partner Care Team</i></b> for assistance.</td></tr>'+
	                               '<tr><td colspan="2"> <hr> </td></tr>'+
	                               '<tr><td colspan="2"> If you have any questions about your order, please contact <b>Awana Partner Care @ (866) 292-6227</b>. Our hours are: Mon/Tues/Thurs/Fri: 8:15 a.m. - 4:30 p.m. & Wed: 10:45 a.m. - 4:30 p.m CST. Thank you, again, for partnering in mission with us at Awana. </td></tr>';
	                               
                
                /*
                String mailifno ='<h2>Thank you for your order.</h2>'+
                            '<p><strong>Please follow the instructions below to download your purchase.</strong></p>'+
                            '<p>If you have questions about your order, we\'re happy to take your call:<br/>'+
                            '<span  style=color:red">(866) 292-6227</span> Mon/Tues/Thurs/Fri: 8:15 a.m. - 4:30 p.m. | Wed: 10:45 a.m. - 4:30 p.m CST<br/><br/>'+
                            '<p>To download your purchase, touch the link below while using your mobile device or tablet. After download completes, open book with an e-reader</p>'+
                            '<p>app. Recommended apps: iBooks (Apple devices) or Google Play Books (Android devices).</p>'+
                            '<p>The link(s) below will expire after 7 days.</p><br/>';
                
                String mailinfoBottom = '<br/><p><strong>Trouble downloading?</strong></p>'+
                                        '<p>Right click the link(s) above, choose the best option: "Save File As", "Save Target As", or "Download Linked File." Or try downloading in a different browser like<br/>'+
                                        '<p>Firefox, Chrome or Safari.<p>';
                mail.setHtmlBody(mailifno+output+mailinfoBottom);*/
                mail.setHtmlBody(mailifno);
                emailTobeSent.add(mail); 
            }
        }// LOOP
        if(emailTobeSent!=null && emailTobeSent.size()>0 && OrderEntryServices.hasProcessOrderTriggerRan() && linecnt>1){
            Messaging.sendEmail(emailTobeSent);   
            system.debug('**Sending an Email**');
        } 
    }
}