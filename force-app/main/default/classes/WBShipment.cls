public class WBShipment {

	public class Containers {
		public Integer id;
		public Integer shipmentId;
		public String sscc;
		public String weight;
		public String length;
		public String height;
		public String width;
		public String packageCode;
		public List<Items> items;
	}

	public class Items {
		public Integer id;
		public Integer shipmentId;
		public Integer shipmentContainerId;
		public Integer shipQty;
		public Integer skuId;
		public String sku;
		public String upc;
		public String clientSku;
	}

	public class LatestTrackingEvent {
		public String statusCode;
		public String statusDescription;
		public String carrierStatusCode;
		public String carrierStatusDescription;
		public String createdOn;
	}

	public class Shipments {
		public String id;
		public String orderId;
		public String merchantOrderId;
		public String status;
		public String modifiedOn;
		public String shipDate;
		public String carrier;
		public String service;
		public String tracking;
		public String totalWeight;
		public String trackingUrl;
		public List<Containers> containers;
		public LatestTrackingEvent latestTrackingEvent;
		public Boolean isVoided;
	}

	public Integer shipmentCount;
	public List<Shipments> shipments;

	
	public static WBShipment parse(String json) {
		return (WBShipment) System.JSON.deserialize(json, WBShipment.class);
	}
}