public class SearchShipmentRequestBKUP{
	public  List<NGUtilityClasses.Shipment> ShipmentResponses= new List<NGUtilityClasses.Shipment>(); 
    public SearchShipmentRequestBKUP(String xml){
        ShipmentResponses = traverseXMLIterate(xml);
 	}
    
     /*******************************************************************************
      traverseXMLIterate:
    1.Parses the Post Shipment Response message 
   *******************************************************************************/    
    private static List<NGUtilityClasses.Shipment> traverseXMLIterate(String xml) {
        List<NGUtilityClasses.Shipment> ShipmentResponses = new List<NGUtilityClasses.Shipment>();    // pro
    	NGUtilityClasses.Shipment   ShipmentResponse; 
        List<NGUtilityClasses.Shipment> verifiedShipments = new List<NGUtilityClasses.Shipment>();
        NGUtilityClasses NG = new NGUtilityClasses();
        NGUtilityClasses.Warehouse warehouse;
        NGUtilityClasses.Shipment buildShipment = new NGUtilityClasses.Shipment();
        NGUtilityClasses.Fee ngFees = new NGUtilityClasses.Fee();
        NGUtilityClasses.BackorderedItem boInfo = new NGUtilityClasses.BackorderedItem();
        NGUtilityClasses.Item itemInfo = new NGUtilityClasses.Item();
        NGUtilityClasses.NGPackage pkgInfo = new NGUtilityClasses.NGPackage();
        NGUtilityClasses.DeliveryExcept deliveryException;
        NGUtilityClasses.CustomFields customFlds = new NGUtilityClasses.CustomFields();
        List<NGUtilityClasses.Item> itemInfoList = new List<NGUtilityClasses.Item>();
        List<NGUtilityClasses.BackorderedItem> boInfoList = new List<NGUtilityClasses.BackorderedItem>();
  		Dom.Document doc = new Dom.Document();
  		doc.load(xml);
  		String name = doc.getRootElement(). getName();
        system.debug('<<  HEAD TAG >> '+name);
		//<Shipments Tag>
  		for (Dom.XmlNode node : doc.getRootElement().getChildElements()){// Shipments
            buildShipment = new NGUtilityClasses.Shipment();
            Boolean foundItemComponents = false;
            if(node.getName() == 'Shipment'){
                //buildShipment.backorderItems = new List<NGUtilityClasses.BackorderedItem>();
                buildShipment.items = new List<NGUtilityClasses.Item>();
                buildShipment.packages = new List<NGUtilityClasses.NGPackage>();
                buildShipment.shipmentID = node.getAttributeValue('id', '');   
                system.debug('<< >> '+buildShipment.shipmentID);
            }//<SHipment> Tag
            for(Dom.XmlNode shipmentTag : node.getChildElements()){ // Shipment Loop
          	  	if(shipmentTag.getName() == 'ClientName'){
                	buildShipment.clientName = shipmentTag.getText();
            	}
             	if(shipmentTag.getName() == 'OrderID'){
                	buildShipment.orderID = shipmentTag.getText();
            	}    
             	if(shipmentTag.getName() == 'Company'){
                	buildShipment.company = shipmentTag.getText();
            	}
            	if(shipmentTag.getName() == 'Name'){
                	buildShipment.name = shipmentTag.getText();
            	} 
            	if(shipmentTag.getName() == 'FirstName'){
                	buildShipment.firstname = shipmentTag.getText();
            	}
            	if(shipmentTag.getName() == 'LastName'){
                	buildShipment.lastname = shipmentTag.getText();
            	}
            	if(shipmentTag.getName() == 'Address1'){
                	buildShipment.address1 = shipmentTag.getText();
            	} 
            	if(shipmentTag.getName() == 'Address2'){
                	if(shipmentTag.getText() != null){
                		buildShipment.address2 = shipmentTag.getText();
                	}
            	}
            	if(shipmentTag.getName() == 'City'){
                	buildShipment.city = shipmentTag.getText();
            	} 
            	if(shipmentTag.getName() == 'State'){
                	buildShipment.state = shipmentTag.getText();
            	}
            	if(shipmentTag.getName() == 'PostalCode'){
                	buildShipment.postalCode = shipmentTag.getText();
            	}      
            	if(shipmentTag.getName() == 'Country'){
                	buildShipment.country = shipmentTag.getText();
            	} 
            	if(shipmentTag.getName() == 'Email'){
                	if(shipmentTag.getText() != null){
                		buildShipment.email = shipmentTag.getText();
                	}
            	}   
            	if(shipmentTag.getName() == 'Phone'){
                	if(shipmentTag.getText() != null){
                		buildShipment.phone = shipmentTag.getText();
                	}
            	}    
            	if(shipmentTag.getName() == 'ExpectedDeliveryDate'){
                	buildShipment.ExpectedDeliveryDate = shipmentTag.getText();
            	}     
            	if(shipmentTag.getName() == 'OrderTimestamp'){
                	buildShipment.orderTimeStamp = shipmentTag.getText();
            	}
             	if(shipmentTag.getName() == 'ReceivedTimestamp'){
                	buildShipment.receivedTimestamp = shipmentTag.getText();
            	}
            	if(shipmentTag.getName() == 'OrderType'){
                    buildShipment.orderType = shipmentTag.getText();
            	}
            	if(shipmentTag.getName() == 'ShippedDate'){
                	buildShipment.ShippedDate = shipmentTag.getText();
            	} 
                if(shipmentTag.getName() == 'ExpectedDeliveryDate'){
                	buildShipment.ExpectedDeliveryDate = shipmentTag.getText();
            	}   
            	if(shipmentTag.getName() == 'DeliveredTimestamp'){
                	buildShipment.DeliveredTimestamp = shipmentTag.getText();
            	}  
                
            	if(shipmentTag.getName() == 'ShipMethod'){
               		buildShipment.tracking = shipmentTag.getText(); 
            	}
                if(shipmentTag.getName() == 'ShipMethodCode'){
               		buildShipment.tracking = shipmentTag.getText(); 
            	}
            	if(shipmentTag.getName() == 'Tracking'){
               		buildShipment.tracking = shipmentTag.getText(); 
            	}
            	if(shipmentTag.getName() == 'TrackingUrl'){
               		buildShipment.trackingUrl = shipmentTag.getText(); 
            	}
             	if(shipmentTag.getName() == 'Weight'){
               		buildShipment.weight = shipmentTag.getText();
            	}
                if(shipmentTag.getName() == 'Postage'){
               		buildShipment.postage = shipmentTag.getText();
            	} 
                if(shipmentTag.getName() =='GiftWrap'){
                    if(shipmentTag.getText().trim() !=null){
                        buildShipment.giftwrap = Boolean.valueOf(shipmentTag.getText().trim());
                    }
                }/*
            	if(shipmentTag.getName() == 'BackorderedItems'){ // get topmost tag <BackorderItems>
                    
                //get <BackorderItem> child tag
               		for(Dom.XmlNode boTag : shipmentTag.getChildElements()){ 
                        boInfo = new NGUtilityClasses.BackorderedItem();
                    	boInfo.id = boTag.getAttributeValue('id', '');
                    	boInfo.newShipmentId = boTag.getAttributeValue('newShipmentID', '');
                    	for(Dom.XmlNode subBO : boTag.getChildElements()){
                    		if(subBO.getName() == 'SKU' ){
                        		boInfo.sku = subBO.getText();
                            	system.debug('<< BO - SKU >> '+  subBO.getText());
                    		}
                    		if(subBO.getName() == 'Description' ){
                        		boInfo.description = subBO.getText();
                    		}
                    		if(subBO.getName() == 'Quantity' ){
                       			boInfo.qty = Integer.valueOf(subBO.getText());
                    		}
                        	if(subBO.getName() == 'IsCancelled' ){
                    		}
                        	system.debug('<< BOS PICKED >> '+boInfo);
                       	 	buildShipment.backorderItems.add(boInfo);
                           
                	} // BO sublist   
	        	}//<BackorderItem>
            }//Parent tag <BackOrderItems
               */
            if(shipmentTag.getName() == 'Items'){ // get topmost tag <BackorderItems>
                //get <Item> child tag
                
                for(Dom.XmlNode itemTag : shipmentTag.getChildElements()){ 
                    itemInfo  = new NGUtilityClasses.Item();
                    itemInfo.id =itemTag.getAttributeValue('id', '');
                    for(Dom.XmlNode subItem : itemTag.getChildElements()){
                    	if(subItem .getName() == 'SKU' ){
                        	itemInfo.sku = subItem.getText();
                            system.debug(' << SKU >> '+itemInfo.sku );
                    	}
                    	if(subItem.getName() == 'UPC' ){
                        	itemInfo.upc = itemTag.getText();
                    	}
                    	if(subItem.getName() == 'Description' ){
                        	itemInfo.description = subItem.getText(); 
                            system.debug(' << DESCRIPTION >> '+itemInfo.description );
                    	}
                        if(subItem.getName() == 'Lot' ){
                        	itemInfo.lot = itemTag.getText();
                        	system.debug('<< ITEMS - LOt >> '+   subItem.getText()); 
                    	}
						if(subItem.getName() == 'Qty' ){
                        	itemInfo.qty = Integer.valueOf(subItem.getText());
                            system.debug(' << QTY >> '+itemInfo.qty );
                            system.debug('<< ITEMS PICKED >> '+itemInfo);
                      		buildShipment.items.add(itemInfo);
                        }
                  	} // Item sublist           
	        	}//<Item>   
            }//Parent tag <Items>

           if(shipmentTag.getName() == 'Packages'){ // get topmost tag <BackorderItems>               
                //get <Packages> child tag
               		for(Dom.XmlNode pkgTag : shipmentTag.getChildElements()){ 
                        pkgInfo= new NGUtilityClasses.NGPackage();
                    	pkgInfo.id= pkgTag .getAttributeValue('id', '');
                    	for(Dom.XmlNode subPKG : pkgTag .getChildElements()){
                    		if(subPKG.getName() == 'TrackingNumber' ){
                        		pkgInfo.trackingNumber = subPKG.getText();
                            	system.debug('<< PKG - TRACKING # >> '+  subPKG.getText());
                    		}
                    		if(subPKG.getName() == 'Weight' ){
                        		pkgInfo.weight = subPKG.getText();
                    		}
                    		if(subPKG.getName() == 'BillableWeight' ){
                       			pkgInfo.billableWeight =subPKG.getText();
                    		}
                        	if(subPKG.getName() == 'Height' ){
								pkgInfo.height = subPKG.getText();
                    		}
							if(subPKG.getName() == 'Width' ){
								pkgInfo.width = subPKG.getText();
                    		}
							if(subPKG.getName() == 'Depth' ){
								pkgInfo.depth = subPKG.getText();
                    		}
                            
                        	system.debug('<< PKGS PICKED >> '+pkgInfo);
                       	 	
                	} // PKG sublist  
                        buildShipment.packages.add(pkgInfo);
	        	}//<Package>
            }//Parent tag <Packages>
    	}// <Shipment> Loop
             system.debug('<< BUILD SHIPMENTS >> '+buildShipment);// Finished product of allthe budiling for this shipment
              	 
          verifiedShipments.add(buildShipment);  
	}// <Shipments> loop
   	
   	system.debug('<< VERIFIED SHIPMENTS >> '+verifiedShipments);
  	return verifiedShipments;
  	}
}