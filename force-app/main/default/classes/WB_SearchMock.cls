@isTest
public class WB_SearchMock implements HttpCalloutMock {
   Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    public WB_SearchMock(Boolean isMockResponseSuccessful){
        this.isMockResponseSuccessful  = isMockResponseSuccessful;
    }
    public HttpResponse respond(HttpRequest rqst) {
            
        HttpResponse fakeResponse = new HttpResponse();
        if (this.isMockResponseSuccessful) {
            fakeResponse.setHeader('Content-Type', 'application/json');
            fakeResponse.setBody('{"shipmentCount":1,"shipments":[{"id":989898,"orderId":2431394,"merchantOrderId":"01064778","status":"SHIPPED","shipDate":"2020-04-24 11:08:49","carrier":"fedex","service":"fedex_international_economy","tracking":"392210113498","totalWeight":"44.31","trackingUrl":"http://www.fedex.com/Tracking?action=track&tracknumbers=392210113498","latestTrackingEvent":{"statusDescription":"Test"},"isVoided": false,"containers":[{"id":490317,"shipmentId":989898,"sscc":null,"weight":"44.31","length":"24.00","height":"17.00","width":"16.00","packageCode":"package","items":[{"id":696975,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269471,"sku":"AWNA-41267-001-MCF","upc":"41267","clientSku":"41267"},{"id":696976,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269053,"sku":"AWNA-15587-001-MCF","upc":"15587","clientSku":"15587"},{"id":696977,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269499,"sku":"AWNA-34265-001-MCF","upc":"34265","clientSku":"34265"},{"id":696978,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269035,"sku":"AWNA-32150-001-MCF","upc":"32150","clientSku":"32150"},{"id":696979,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269218,"sku":"AWNA-16096-001-MCF","upc":"16096","clientSku":"16096"},{"id":696980,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269105,"sku":"AWNA-21143-001-MCF","upc":"21143","clientSku":"21143"},{"id":696981,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268925,"sku":"AWNA-14537-001-MCF","upc":"14537","clientSku":"14537"},{"id":696982,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269109,"sku":"AWNA-36982-001-MCF","upc":"36982","clientSku":"36982"},{"id":696983,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268928,"sku":"AWNA-14561-001-MCF","upc":"14561","clientSku":"14561"},{"id":696984,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269502,"sku":"AWNA-41814-001-MCF","upc":"41814","clientSku":"41814"},{"id":696985,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269158,"sku":"AWNA-34522-001-MCF","upc":"34522","clientSku":"34522"},{"id":696986,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269103,"sku":"AWNA-20423-001-MCF","upc":"20423","clientSku":"20423"},{"id":696987,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269603,"sku":"AWNA-16053-001-MCF","upc":"16053","clientSku":"16053"}]}]}]}');
            fakeResponse.setStatusCode(200);
        }
        else {
            fakeResponse.setStatusCode(400);
            fakeResponse.setStatus('Bad request');
        }
        return fakeResponse;
    }
}