public class HotelsProjectCmpController {
    
    @AuraEnabled
    public static List<String> getCity()
    {
        List <AggregateResult> listForCity = [Select City__c From Hotel__c Group By City__c];
        List <String> gotCity = new List<String>();
        
        for (AggregateResult ls: listForCity) {
            gotCity.add((String)ls.get('City__c'));   
        }
        return gotCity;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getRooms (Date checkIn, Date checkOut, String city, Integer capacity) {
        if (String.isBlank(city) || checkIn == null || checkOut == null || capacity == null || capacity == 0){
            System.debug('Form cannot be empty');
            return null;
        } else {
            
            List<Room__c> suitableRooms = findRoomsByCityAndCapacity(city, capacity);
            List<String> reservedRooms = findReservatedRooms(checkIn, checkOut);
            
            List<Room__c> availableRooms = new List<Room__c>();
            List<String> availableRoomsIDs = new List<String>();
            for (Room__c sr : suitableRooms) {
                if (!reservedRooms.contains(sr.ID)) {
                    availableRooms.add(sr);
                    availableRoomsIDs.add(sr.ID);
                }
            }
            Map<String, List<String>> roomServices  = findRoomServices(availableRoomsIDs);
            Map<String, List<String>> resultRoomServices = new Map<String, List<String>>();
            for (Room__c ar : availableRooms) {
                if(roomServices.containsKey(ar.ID)) {
                    resultRoomServices.put(JSON.serialize(ar), roomServices.get(ar.ID));
                } else {
                    resultRoomServices.put(JSON.serialize(ar), new List<String>());
                }
            }
            
            return resultRoomServices;
        }
        
    }
    
    
    @AuraEnabled 
    public static List<String> findReservatedRooms (Date checkIn, Date checkOut) {
        System.debug('Searching reserved rooms from ' + checkIn + ' to ' + checkOut);
        List<Reservation__c> listReservations = [SELECT Room__r.ID FROM Reservation__c WHERE 
                                                 (Check_inDate__c >= :checkIn AND Check_outDate__c <= :checkOut) 
                                                 OR 
                                                 (Check_inDate__c <= :checkIn AND Check_outDate__c >= :checkOut)
                                                 OR
                                                 (Check_inDate__c <= :checkIn AND Check_outDate__c >= :checkIn)
                                                 OR
                                                 (Check_inDate__c <= :checkOut AND Check_outDate__c >= :checkOut)];
        
        System.debug('Returned ' + listReservations.size() + ' reservations');
        
        List<String> reservationIDs = new List<String>();
        for (Reservation__c reservation : listReservations) {
            reservationIDs.add(reservation.Room__r.ID);
        } 
        return reservationIDs;
    }
    
    @AuraEnabled 
    public static List<Room__c> findRoomsByCityAndCapacity (String city, Integer capacity) {
        System.debug('Searching by City: ' + city + ' and capacity: ' + capacity);
        List<Room__c> roomByCityAndCapacity = [SELECT ID, Capacity__c, Hotel__r.city__c, Hotel__r.name FROM Room__c 
                                               WHERE Hotel__r.city__c = :city AND Capacity__c = :capacity];
        System.debug('Returned ' + roomByCityAndCapacity.size() + ' records');
        
        return roomByCityAndCapacity;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> findRoomServices (List <String> roomIds) {
        System.debug('Load services for: ' + roomIds.size() );
        Map<String, List<String>> resultRoomServices = new Map<String, List<String>>();
        
        if (!roomIds.isEmpty()) {                 
            List<ServiceRoom__c> roomServices = [Select Room__r.ID, Service__r.Name from ServiceRoom__c WHERE Room__r.ID in :roomIds];
            
            for (ServiceRoom__c roomService : roomServices) {
                
                if(!resultRoomServices.containsKey(roomService.Room__r.ID)){
                    List<String> services = new List<String>();
                    services.add(roomService.Service__r.Name);
                    
                    resultRoomServices.put(roomService.Room__r.ID, services);
                } else {
                    List<String> services = resultRoomServices.get(roomService.Room__r.ID);
                    services.add(roomService.Service__r.Name);
                    
                    resultRoomServices.put(roomService.Room__r.ID, services);                     
                }
                
            } 
            System.debug('Returned: ' + resultRoomServices.size() );  
        }
        return resultRoomServices;
    }
    
    @AuraEnabled 
    public static Boolean reservationRoom  (Date checkIn, Date checkOut, String roomId) {
        System.debug('Trying to create reservation from ' + checkIn + ' to ' + checkOut + ' for room ' + roomId);
        List<String> checkReservation = findReservatedRooms (checkIn, checkOut);
        if (checkReservation.contains(roomID)) {
            return false;
        } else {
            Reservation__c roomReservation = new Reservation__c();
            
            roomReservation.Room__c = roomId;
            roomReservation.Check_inDate__c = checkIn;
            roomReservation.Check_outDate__c = checkOut;
            roomReservation.Status__c = 'Pre-reservation';
            
            Insert roomReservation;
            
            return true;
        }
        
        
    }
    
}