/***************************************************************************************************************************************************************************************
    Programmer: Ayesha
    Company:    Awana
    Contact:    ayesha@infoglen.com
    Project:    Awana
    Description: Display list of related Orders in the Product Detail Page 
    Created:    11/07/2017 - ProductRelatedOrdersExtension  
    Caller:   Product Orders    
***************************************************************************************************************************************************************************************/

public with sharing class ProductRelatedOrdersExtension {
    public list<OrderItem> OrdItemList;
    
    public ProductRelatedOrdersExtension(ApexPages.StandardSetController controller) {
        total_size = [SELECT count() FROM OrderItem WHERE 
                                                (Product2Id = :ApexPages.currentPage().getParameters().get('id') AND 
                                                (order.status = 'Order Submitted' OR order.status = 'Order Confirmed' OR order.status = 'Order Being Fulfilled'))]; //set the total size in the constructor
    
    }
 
   
   private integer counter=0;  //keeps track of the offset
   private integer list_size=20; //sets the page size or number of rows
   public integer total_size; //used to show user the total size of the list

   // Queries all the related orders of particular product
   public list<OrderItem> getOrdItemList(){
      try {
         OrdItemList = [SELECT OrderId,order.Name,order.Status,Order.TotalOrderQuantity__c,Order.TotalAmount,Order.Created_Date_Time__c,Order.Purchase_Order__c,Product2Id 
                                                FROM OrderItem WHERE 
                                                (Product2Id = :ApexPages.currentPage().getParameters().get('id') AND 
                                                (order.status = 'Order Submitted' OR order.status = 'Order Confirmed' OR order.status = 'Order Being Fulfilled'))Order By order.Name
                                                limit :list_size 
                                offset :counter];

         return OrdItemList;
      } catch (QueryException e) {
         ApexPages.addMessages(e);   
         return null;
      }
   }

   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      return null;
   }

   public PageReference Previous() { //user clicked previous button
      counter -= list_size;
      return null;
   }

   public PageReference Next() { //user clicked next button
      counter += list_size;
      return null;
   }

   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, list_size);
      return null;
   }

   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }

   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
   }

   public Integer getTotal_size() {
      return total_size;
   }

   public Integer getPageNumber() {
      return counter/list_size + 1;
   }

   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
}