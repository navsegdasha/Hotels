({
    loadparam : function(component, event, controller) {
              
        var actionGetCity = component.get("c.getCity");
        actionGetCity.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.searchCity", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionGetCity);
        
        var checkInDate = new Date();
        var checkOutDate = new Date();
            checkOutDate.setDate(checkInDate.getDate() + 1);
        
        component.set("v.checkInDate", checkInDate.toISOString().split('T')[0]);
        component.set("v.checkOutDate", checkOutDate.toISOString().split('T')[0]);
        
    },
    
    loadRoomsByParam : function(component, event, controller) {
        
        var searchParamHotelCity = document.getElementById("hotelSearchCity").value;
        var searchParamCheckIn = document.getElementById("reservationCheckInDate").valueAsDate;
        var searchParamCheckOut = document.getElementById("reservationCheckOutDate").valueAsDate;
        if (searchParamCheckIn >= searchParamCheckOut) {
            alert('Check out Date cannot be less then Check in Date')
            return;
        };
        var searchParamCapacity = document.getElementById("count").value;
        Number.parseInt(searchParamCapacity);
        
        
        var searchAction = component.get("c.getRooms");
        searchAction.setParams({checkIn : searchParamCheckIn, checkOut : searchParamCheckOut, city : searchParamHotelCity, capacity : searchParamCapacity});
        searchAction.setCallback(this, function(response)  {
            var state = response.getState();
            if (state === "SUCCESS") {
                var roomsMap = [];
                var rooms = response.getReturnValue();
                if (rooms == null) {
                    alert('Missed required fields');
                }
                else {
                    for(var key in rooms){
                        roomsMap.push({hotel:JSON.parse(key).Hotel__r.Name, 
                                       capacity:JSON.parse(key).Capacity__c,
                                       services:rooms[key],
                                       roomId:JSON.parse(key).Id});
                    }
                    
                    component.set("v.rooms", roomsMap);
                }
            }
        });
        $A.enqueueAction(searchAction);
    },
    
    bookRoom : function(component, event, controller) {
        var element = event.target;
        var roomId = element.value
        
        var reservationCheckInDate = document.getElementById("reservationCheckInDate").valueAsDate;
        var reservationCheckOutDate = document.getElementById("reservationCheckOutDate").valueAsDate;
        
        var actionReservation = component.get("c.reservationRoom");
        actionReservation.setParams({roomId : roomId,  checkIn : reservationCheckInDate, checkOut : reservationCheckOutDate });
        actionReservation.setCallback(this, function(response)  {
            var state = response.getState();
            var successResult = response.getReturnValue();
            if (successResult == false) {
                alert ('Cannot update product');
            } else {
                alert ('Success');
            }
        });
        
        $A.enqueueAction(actionReservation); 
        
        var someAction = component.get("c.loadRoomsByParam");
        $A.enqueueAction(someAction);
    }
})