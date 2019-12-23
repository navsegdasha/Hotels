@isTest
public class HotelsProjectCmpControllerTest {
    public static final Integer DEFAILT_FIELD_LENGTH = 5;
    
    @isTest static void getCityTest () {
        Hotel__c testHotel1 = new Hotel__c();
        testHotel1.City__c = generateRandomString (DEFAILT_FIELD_LENGTH);
        Hotel__c testHotel2 = new Hotel__c();
        testHotel2.City__c = generateRandomString (DEFAILT_FIELD_LENGTH);
        Hotel__c testHotel3 = new Hotel__c();
        testHotel3.City__c = testHotel2.City__c;
        insert  testHotel1;
        insert  testHotel2;
        insert  testHotel3;
        List<String> cities = HotelsProjectCmpController.getCity();
        
        System.assert(cities.size() == 2);
        System.assert(cities.contains(testHotel1.City__c));
        System.assert(cities.contains(testHotel2.City__c));
    }
    
    @isTest static void getRoomsTest () {
        
        Hotel__c testHotel1 = new Hotel__c();
        testHotel1.City__c = generateRandomString (DEFAILT_FIELD_LENGTH);
        Hotel__c testHotel2 = new Hotel__c();
        testHotel2.City__c = generateRandomString (DEFAILT_FIELD_LENGTH);
        insert  testHotel1;
        insert  testHotel2;
        
        Room__c testRoom1 = new Room__c();
        testRoom1.Name = generateRandomString (DEFAILT_FIELD_LENGTH);
        testRoom1.Capacity__c = 2;
        testRoom1.Hotel__c = testHotel1.Id;
        
        Room__c testRoom2 = new Room__c();
        testRoom2.Name = generateRandomString (DEFAILT_FIELD_LENGTH);
        testRoom2.Capacity__c = 2;
        testRoom2.Hotel__c = testHotel1.Id;
        
        Room__c testRoom3 = new Room__c();
        testRoom3.Name = generateRandomString (DEFAILT_FIELD_LENGTH);
        testRoom3.Capacity__c = 2;
        testRoom3.Hotel__c = testHotel2.Id;
        
        Room__c testRoom4 = new Room__c();
        testRoom4.Name = generateRandomString (DEFAILT_FIELD_LENGTH);
        testRoom4.Capacity__c = 3;
        testRoom4.Hotel__c = testHotel1.Id;
        insert  testRoom1;
        insert  testRoom2;
        insert  testRoom3;
        insert  testRoom4;
        
        Reservation__c testReservation1 = new Reservation__c();
        testReservation1.Check_inDate__c = Date.newInstance(2019, 12, 10);
        testReservation1.Check_outDate__c = Date.newInstance(2019, 12, 20);
        testReservation1.Room__c = testRoom2.Id;
  
        insert  testReservation1;
        
        Map<String, List<String>> roomsTest = HotelsProjectCmpController.getRooms (testReservation1.Check_inDate__c, testReservation1.Check_outDate__c, testHotel1.City__c, (Integer)testRoom1.Capacity__c);
        System.assert(roomsTest.size() == 1);
    }

    @isTest static void reservationRoomTest () {
        
        Hotel__c testHotel1 = new Hotel__c();
        testHotel1.City__c = generateRandomString (DEFAILT_FIELD_LENGTH);
        insert  testHotel1;
        
        Room__c testRoom1 = new Room__c();
        testRoom1.Name = generateRandomString (DEFAILT_FIELD_LENGTH);
        testRoom1.Capacity__c = 2;
        testRoom1.Hotel__c = testHotel1.Id;
        insert  testRoom1;
        
        Reservation__c testReservation1 = new Reservation__c();
        testReservation1.Check_inDate__c = Date.newInstance(2019, 12, 10);
        testReservation1.Check_outDate__c = Date.newInstance(2019, 12, 20);
        testReservation1.Room__c = testRoom1.Id;
  
        insert  testReservation1;
        
       
       HotelsProjectCmpController.reservationRoom(testReservation1.Check_inDate__c, testReservation1.Check_outDate__c, testReservation1.Room__c);
       List<Reservation__c> r = [SELECT Check_inDate__c, Check_outDate__c, Room__r.ID FROM Reservation__c WHERE Room__r.ID = :testReservation1.Room__c];
       
        
       System.assert(r.size() == 1);
       Reservation__c correctReservation = null; 
        for(Reservation__c res: r){
            if (res.Room__r.ID.equals(testReservation1.Room__c)){
                correctReservation = res;
            }
        }
        System.assert(correctReservation != null);
        
       
    }






    private static String generateRandomString (Integer len) {
        String alphaNumericString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            + '0123456789'
            + 'abcdefghijklmnopqrstuvxyz';
        
        String randomString =''; 
        
        for (Integer i = 0; i < len; i++) { 
            
            Integer charIndex = (Integer)(AlphaNumericString.length()* Math.random()); 
            
            randomString = randomString + 
                String.fromCharArray(new List<integer> {alphaNumericString.charAt(charIndex)}); 
        } 
        
        return randomString;
    }
}