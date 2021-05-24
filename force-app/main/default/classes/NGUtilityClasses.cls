/*****************************************************************************************************************************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Newgistics
    Description:    Class
    Original:       12/14/2018 - <NEW-28> - Class used to store the latest NG Shipment responses which were queried from SFDC.  
        -- Execute Batch -- 
  Called By: BatchSearchNewgisticsShipmentsScheduler job = new BatchSearchNewgisticsShipmentsScheduler(); ID batchprocessid = Database.executeBatch(job, 1); 
 ********************************************************************************************************************************************************/
public class NGUtilityClasses {
    //global DateTime currentDate;
  
    public class Warehouse{
        public String id;
        public String name;
        public String address;
        public String city;
        public String state;
        public String postalCode;
        public String country;
    }//Warehouse
    
    public class DeliveryExcept{
        public String timeStamp;
        public String notes;
    }
    
    public class CustomFields{
        public String salesTax;
        public String shipping;
        public String total;
        
    }
    
    public class Fee{
        public String type;
        public String amount;
        public String notes;
    }//Fee
    
    public class BackorderedItem{
        public String id;
        public String newShipmentId;
        public String description;
        public String sku;
        public Integer qty = 0;
       // public List<CustomFields> acustomerfld = new List<CustomFields>();
        public Boolean isCancelled = false;  
    }// BackorderedItem
    
    public class AssemblyItem{
        public String id;
        public String sku ;
        public String upc;
        public String description;
        public String lot;
        public Integer qty;
      //  public List<CustomFields> acustomerfld = new List<CustomFields>();
    }// AssemblyItem
  
    public class Item{
        public String id;
        public String sku ;
        public String upc;
        public String description;
        public String lot;
        public Double qty;
        public List<CustomFields> acustomerfld = new List<CustomFields>();
    }// Item
    
	public class NGPackage{
    	public String id;
        public String  trackingNumber;
        public String weight;
       	public  String billableWeight;
        public String height ;
        public String width;
        public String depth;
        public List<Item> items = new List<Item>();
	}
    public class Shipment{
        public Integer bocnt = 0;
        public Integer itemcnt = 0;
        public String shipmentID;
		public String id;
        public String clientName;
        public String orderID;
        public String purchaseOrder;
        public String name;
    	public String firstname;
        public String lastname;
        public String company;
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public String email;
         public String phone;
        public String orderTimeStamp;
        public String receivedTimestamp;
        public String shipmentStatus;
        public String orderType;
        public String ShippedDate;
        public String ExpectedDeliveryDate;
        public String DeliveredTimestamp;
        public DeliveryExcept aDeliveryExcept = new DeliveryExcept();
        public Warehouse aWarehouse;
        public String shipMethod;
        public String shipMethodCode;
        public String tracking;
        public String trackingUrl;
        public String weight;
        public String postage;
        public Boolean giftwrap = false;
        public List<CustomFields> customFields;
        public List<Fee> fees;
       public List<BackorderedItem> backorderItems;
        public List<Item> items;
        public List<NGPackage> packages;
        public String status;
        
    } //Shipment
}