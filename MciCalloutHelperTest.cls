@isTest
public with sharing class MciCalloutHelperTest {

   
    static testMethod void mciCallouts()
    {
        String expectedResult='200####{"mciId": 1000503445,"firstName": "JOHN","middleName": "","lastName": "ABRAHAM","suffix": "","ssn": "","birthDate": "1985-05-15T00:00:00","genderText": "Male","raceCodes": "","deathDate": "0001-01-01T00:00:00","score": null}';
        string searchClient='{"firstName" : JOHN,"lastName" : ABRAHAM,"genderCode" : 1,"birthDate" : 1985-05-15T00:00:00,"ssn" : }';
        String insertClient='{"sourceSystemId" : "53","sourceSystemClientId" :"","firstName" : "Ankit","lastName" : "Gupta","genderCode" : 1,"birthDate" : 1985-05-15T00:00:00}';

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MciCalloutHelperMock());
        String actualValue = MciCalloutHelper.searchClient(searchClient);
        System.assertEquals(actualValue, expectedResult);
        String result=MciCalloutHelper.insertNewClient(insertClient);
        String resCode=result.subString(0,3);
        System.assertEquals('200',resCode);
        String clientResult=MciCalloutHelper.updateClient(insertClient);
        System.assertEquals(clientResult, expectedResult);
        MciCalloutHelper.updateClientAuto(insertClient);
    }
    static testMethod void testGetDetails()
    {
            MciCalloutHelper.getDetails('searchClient','Internal');   
    }
}