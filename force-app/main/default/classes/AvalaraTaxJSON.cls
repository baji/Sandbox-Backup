/*
Purpose :  This Class constructs a JSON which is input ot Avalara System. We have eliminated the callout to cast iron and direcrly calling 
Avalara System from Salesforce. 
Author : Darshan Chhajed.
*/

public class AvalaraTaxJSON {
string code;
public string companyCode{get;set;}
string type;
string AvalaraCurrentDataTime;
string customerCode; 
string Avalara_Commit;
address addresses;
list<lineItem> lines;   
    public class address{
        public AddressCls ShipFrom;
        public AddressCls ShipTo;
    }
    public class AddressCls{
        string line1;
        string city;
        string region;
        string country;
        string postalCode;
        public AddressCls(string line, string city, string reg, string country, string zipCode){
            this.line1 = line;
            this.city = city;
            this.region = reg;
            this.country = country;
            this.postalCode = zipCode;
        }
    }
    public class lineItem{
        public string Avalara_SeqNumber;
        public decimal quantity;
        public decimal amount;
        public string description;
        public string itemCode;
        public  lineItem(string num,decimal qunt, decimal amt,string itemCode, string des){
            this.Avalara_SeqNumber = num;
            this.quantity = qunt;
            this.amount =amt;
            this.description = des;
            this.itemCode = itemcode;  
            
        }
    }
    //SF-188
    public AvalaraTaxJSON(string orderId,Decimal freightCharge){
        
        string isoCode;
        //Constructing JSON with OrderLine Items
        lines = new list<LineItem>();
        list<Order> orderLst = [SELECT ID, Name,Shipping_Street__c, Shipping_City__c,Shipping_State__c, Shipping_Zip_Code__c, Shipping_Country__c, TempOrderNumber__c, LastModifiedById, Error_Log__c,Account.IntacctID__c, Company__c,
                                (SELECT Line_Type__c, PricebookEntry.Product2Id, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name, Quantity, TotalPrice, Quantity_Given_Away__c FROM Order.OrderItems) FROM Order WHERE ID = :string.escapeSingleQuotes(orderId)];
        if(orderLst!=null&& orderLst.size()>0){
            Order Ord= orderLst.get(0);
            if(Ord.Shipping_Country__c!=null && Ord.Shipping_Country__c.toLowerCase().contains('united states') || Ord.Shipping_Country__c.toLowerCase().contains('canada')){
                list<Country__c> countryObj = [SELECT ISO_Code__c FROM Country__c WHERE Name = :Ord.Shipping_Country__c];
                if(countryObj!=null && countryObj.size()>0){
                    isoCode = countryObj.get(0).ISO_Code__c;
                    
                }
                Awana_Settings__c custSetting =  Awana_Settings__c.getValues('AvalaraTaxCompany');
                if(custSetting!=null)
                    this.companyCode = custSetting.value__c;
                else
                    this.companyCode = 'awana1-sb2'; //default value
                this.code = Ord.TempOrderNumber__c;
                this.customerCode = Ord.Account.IntacctID__c;
                this.type = 'SalesOrder'; 
                this.AvalaraCurrentDataTime = String.valueOf(system.now());
                this.Avalara_Commit = 'false'; 
                addresses = new address();
                addresses.ShipFrom = new AddressCls('1 East Bode RD','Streamwood','IL','US','60107'); //Default Address Present in Cast iron
                addresses.ShipTo = new AddressCls(Ord.Shipping_Street__c,Ord.Shipping_City__c,Ord.Shipping_State__c,isoCode,Ord.Shipping_Zip_Code__c);
                integer itr =1;
                for(OrderItem oli : Ord.OrderItems){
                    if(itr==1){
                        decimal newTotal = Oli.TotalPrice+freightCharge;
                        lines.add(new LineItem(string.valueOf(itr),oli.Quantity,newTotal,oli.PricebookEntry.Product2.ProductCode,oli.PricebookEntry.Product2.Name));     
                    }else{
                        lines.add(new LineItem(string.valueOf(itr),oli.Quantity,Oli.TotalPrice,oli.PricebookEntry.Product2.ProductCode,oli.PricebookEntry.Product2.Name));                   
                    }                   
                    itr++;
                }
                system.debug('lines--'+lines);
            }
        }
    }
    
    public AvalaraTaxJSON(string orderId){
        
        string isoCode;
        //Constructing JSON with OrderLine Items
        lines = new list<LineItem>();
        list<Order> orderLst = [SELECT ID, Name,Shipping_Street__c, Shipping_City__c,Shipping_State__c, Shipping_Zip_Code__c, Shipping_Country__c, TempOrderNumber__c, LastModifiedById, Error_Log__c,Account.IntacctID__c, Company__c,
                                (SELECT Line_Type__c, PricebookEntry.Product2Id, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name, Quantity, TotalPrice, Quantity_Given_Away__c FROM Order.OrderItems) FROM Order WHERE ID = :string.escapeSingleQuotes(orderId)];
        if(orderLst!=null&& orderLst.size()>0){
            Order Ord= orderLst.get(0);
            if(Ord.Shipping_Country__c!=null && Ord.Shipping_Country__c.toLowerCase().contains('united states') || Ord.Shipping_Country__c.toLowerCase().contains('canada')){
                list<Country__c> countryObj = [SELECT ISO_Code__c FROM Country__c WHERE Name = :Ord.Shipping_Country__c];
                if(countryObj!=null && countryObj.size()>0){
                    isoCode = countryObj.get(0).ISO_Code__c;
                    
                }
                Awana_Settings__c custSetting =  Awana_Settings__c.getValues('AvalaraTaxCompany');
                if(custSetting!=null)
                    this.companyCode = custSetting.value__c;
                else
                    this.companyCode = 'awana1-sb2'; //default value
                this.code = Ord.TempOrderNumber__c;
                this.customerCode = Ord.Account.IntacctID__c;
                this.type = 'SalesOrder'; 
                this.AvalaraCurrentDataTime = String.valueOf(system.now());
                this.Avalara_Commit = 'false'; 
                addresses = new address();
                addresses.ShipFrom = new AddressCls('1 East Bode RD','Streamwood','IL','US','60107'); //Default Address Present in Cast iron
                addresses.ShipTo = new AddressCls(Ord.Shipping_Street__c,Ord.Shipping_City__c,Ord.Shipping_State__c,isoCode,Ord.Shipping_Zip_Code__c);
                integer itr =1;
                for(OrderItem oli : Ord.OrderItems){
                    lines.add(new LineItem(string.valueOf(itr),oli.Quantity,Oli.TotalPrice,oli.PricebookEntry.Product2.ProductCode,oli.PricebookEntry.Product2.Name));                   
                    itr++;
                }
            }
        }
    }
    
}