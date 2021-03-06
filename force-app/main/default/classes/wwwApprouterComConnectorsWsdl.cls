//Generated by wsdl2apex

public class wwwApprouterComConnectorsWsdl {
    public class Provide_ServicePort {
        public String endpoint_x = 'https://ci1.awana.org/pSSRates';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.approuter.com/connectors/response/11/', 'wwwApprouterComConnectorsResponse11', 'http://www.approuter.com/connectors/request/11/', 'wwwApprouterComConnectorsRequest11', 'http://www.approuter.com/connectors/wsdl', 'wwwApprouterComConnectorsWsdl'};
        public wwwApprouterComConnectorsResponse11.SSResponse_element Provide_Service(Decimal totalWeight,String destinationStreet,String destinationCity,String destinationRegion,String destinationZip,String destinationCountry,String CommercialResidential,String customerNumber,String callingSystem,Boolean getCheapestMethod) {
            wwwApprouterComConnectorsRequest11.SSRequest_element request_x = new wwwApprouterComConnectorsRequest11.SSRequest_element();
            request_x.totalWeight = totalWeight;
            request_x.destinationStreet = destinationStreet;
            request_x.destinationCity = destinationCity;
            request_x.destinationRegion = destinationRegion;
            request_x.destinationZip = destinationZip;
            request_x.destinationCountry = destinationCountry;
            request_x.CommercialResidential = CommercialResidential;
            request_x.customerNumber = customerNumber;
            request_x.callingSystem = callingSystem;
            request_x.getCheapestMethod = getCheapestMethod;
            wwwApprouterComConnectorsResponse11.SSResponse_element response_x;
            Map<String, wwwApprouterComConnectorsResponse11.SSResponse_element> response_map_x = new Map<String, wwwApprouterComConnectorsResponse11.SSResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://www.approuter.com/connectors/request/11/',
              'SSRequest',
              'http://www.approuter.com/connectors/response/11/',
              'SSResponse',
              'wwwApprouterComConnectorsResponse11.SSResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}