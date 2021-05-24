/******************************************************************************************************************
Programmer:         Ayesha
Contact:            ayesha@infoglen.com
Project:            DRM 
Original:           7/19/2018  - To test TestCSVReader
****************************************************************************************************************************/

@isTest
public class TestCSVReader
{
    public static testMethod void testReadCSVFile()
    {
        List<List<String>> lst = CSVReader.readCSVFile('name,id\r\n"a,bc",123');
        System.assert(null != lst);
    }
    
    public static testMethod void testReadIETFRFC4180CSVFile()
    {
        List<List<String>> lst = CSVReader.readIETFRFC4180CSVFile(Blob.valueOf(('name,id\r\nabc,123')));
        System.assert(null != lst);
    }
    
    public static testMethod void testEquals()
    {
        CSVReader.CSVValue csvValue = new CSVReader.CSVValue('test', false, null);
        csvValue.equals(csvValue);
        System.assert(null != csvValue);
    }
    
    public static testMethod void testAssertEquals()
    {
        CSVReader.CSVValue csvValue = new CSVReader.CSVValue('test', false, null);
        csvValue.assertEquals(csvValue);
        System.assert(null != csvValue);
    }
    
}