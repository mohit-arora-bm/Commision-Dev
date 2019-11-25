({
    selectRecord : function(component, event, helper){      
     // get the selected record from list  
       var getSelectRecord = component.get("v.record");
     // call the event   
       var compEvent = component.getEvent("AC_SelectRecordEvent");
     // set the Selected sObject Record to the event attribute.  
          compEvent.setParams({"recordByEvent" : getSelectRecord });  
     // fire the event  
          compEvent.fire();
     },
 })