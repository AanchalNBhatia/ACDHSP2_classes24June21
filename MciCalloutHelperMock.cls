@isTest
global with sharing class MciCalloutHelperMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        response.setBody('{"mciId": 1000503445,"firstName": "JOHN","middleName": "","lastName": "ABRAHAM","suffix": "","ssn": "","birthDate": "1985-05-15T00:00:00","genderText": "Male","raceCodes": "","deathDate": "0001-01-01T00:00:00","score": null}');
        response.setStatusCode(200);
        return response; 
    }
}