({
	getFields : function(component,event,objectName) {
		var utilComp = component.find('dataService');
        try{
            var self = this;
            console.log(objectName);
            if(!$A.util.isEmpty(objectName)) {
               var action = component.get("c.returnObjectFields");
                action.setParams({
                    objName  : objectName,
                    selectedIndex : parseInt(component.get('v.selectedFields').length)
                });
                component.set('v.displaySpinner',true);
                utilComp.fetch( action ).then(
                    $A.getCallback(function( result ) {
                        if(result != null && !$A.util.isEmpty(result)){
                            component.set("v.option",JSON.parse(result));
                        }
                        component.set('v.displaySpinner',false);
                    }),
                    $A.getCallback(function( error ) {
                       /* if (error && Array.isArray(error) && error.length > 0) {
                            var message = error[0].message;
                            utilComp.methodOnError(error[0].message,self.showToast('Info Message',message,'','5000','info_alt','error','dismissible'));
                        }
                        component.set("v.displaySpinner",false);  */
                    })
                );
            }
        }catch(e){
            component.set('v.displaySpinner',false);
            
        }
	},

	hideComponent : function(component,event){
        try{
            var cmpEvent = component.getEvent("AC_SetRelatedField");
            cmpEvent.setParams({
                eventParamsObj : {}
            });
            cmpEvent.fire();
        	component.destroy();
        }catch(e){ 
        	console.log(e);
        }
	},

    changeField : function(component,event){
        try {
            var self = this;
            var checkValue = event.getSource().get("v.value");
            var isRelatedIndex,related = false;

            var fieldOption = component.get("v.option");
            console.log('fieldOption',fieldOption);
            if(!$A.util.isEmpty(fieldOption)){
                for( var index in fieldOption ) {
                    if(fieldOption[index].fieldAPIName === checkValue && fieldOption[index].isRelated === true){
                        related = true;
                        isRelatedIndex = index;
                        break;
                    }
                }
            }
            if(!related){
                if(!$A.util.isEmpty(fieldOption)){   
                    for( var index in fieldOption ) {
                        if(fieldOption[index].fieldAPIName === checkValue && fieldOption[index].isRelated === false){
                            var selectedFields = component.get('v.selectedFields');
                            var fieldMeta = JSON.parse(JSON.stringify(fieldOption[index]));
                            fieldMeta.relationshipName = fieldOption[index].fieldAPIName;
                            fieldMeta.isRelated = false;
                            component.set('v.selectedField',fieldMeta);
                            component.set("v.option",null);
                            selectedFields.push(fieldMeta);
                            component.set('v.selectedFields',selectedFields);
                            break;
                        }
                    };
                }
            }else{
               if(!$A.util.isEmpty(fieldOption[isRelatedIndex])){
                    if(!$A.util.isEmpty(fieldOption[isRelatedIndex].relatedObjectName)){
                        var selectedFields = component.get('v.selectedFields');
                        var fieldMeta = JSON.parse(JSON.stringify(fieldOption[isRelatedIndex]));
                        selectedFields.push(fieldMeta);
                        component.set('v.selectedField',null);
                        component.set('v.selectedFields',selectedFields);
                        self.getFields(component,event,fieldOption[isRelatedIndex].relatedObjectName);
                    }
               } 
            }
        } catch(e) {
            console.log(e);
        }
    },

    removeLastField : function(component,event){
        try {
            var indexVar = event.getSource().get('v.name');
            var self = this;
            var selectedFields = component.get('v.selectedFields');
            if(!$A.util.isEmpty(selectedFields[indexVar])){
                selectedFields.splice(indexVar, selectedFields.length);
                self.getFields(component,event,selectedFields[indexVar-1].relatedObjectName);
                component.set('v.selectedFields',selectedFields);
            }
        } catch(e) {
            console.log(e);
            //component.find('utilityComponent').logError(e);
        }
    },

    saveField : function(component,event){
        try {
            var self = this;
            if(self.validationSave(component,event) === true){
                var selectedFields = component.get('v.selectedFields');
                var selectedField =  component.get('v.selectedField');
                var field = '';
                if(!$A.util.isEmpty(selectedFields) && !$A.util.isEmpty(selectedField)){
                    for(var index in selectedFields){ 
                       field += selectedFields[index].relationshipName.trim()+'.';
                    }
                    var eventAdditionalParam = component.get('v.eventAdditionalParam')
                    var eventParamsObj ={
                        relatedField         : field.substring(0, field.length-1),
                        fieldMeta            : selectedField,
                        fieldApiName         : selectedFields[0].fieldAPIName,
                        eventAdditionalParam : eventAdditionalParam
                    }
                    var cmpEvent = component.getEvent("AC_SetRelatedField");

                    cmpEvent.setParams({
                        eventParamsObj : eventParamsObj
                    });
                    cmpEvent.fire();
                    component.destroy();
                }
            }
        } catch(e) {
           console.log(e);
        }
    },

    validationSave : function(component,event){
        var self = this;
        var selectedFields = component.get('v.selectedFields');
        if(!$A.util.isEmpty(selectedFields)){
            if(selectedFields[selectedFields.length-1].isRelated === true || component.get('v.selectedField') == null || $A.util.isEmpty(component.get('v.selectedField'))){
                self.showToast('Info Message','Please Select reference related field.','','5000','info_alt','error','dismissible');
                return false;
            }
        }
        return true;
    },

    showToast : function(title,message,messageTemplate,duration,key,type,mode) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : title,
                message: message,
                messageTemplate: messageTemplate,
                duration: duration,
                key: key,
                type: type,
                mode: mode
            });
            toastEvent.fire();
        } catch(e) {
            console.log(e);
        }
    },
    
})