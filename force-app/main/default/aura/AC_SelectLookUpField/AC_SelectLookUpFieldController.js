({
	doInit : function(component, event, helper) {
		
        try{
            var fieldMeta = component.get('v.fieldMeta');
            
            var selectedFields = component.get('v.selectedFields');
            selectedFields.push(fieldMeta);
            component.set('v.selectedFields',selectedFields);
            if(!$A.util.isEmpty(fieldMeta)){
                helper.getFields(component,event,fieldMeta.relatedObjectName);
            }
        }catch(e){
            console.log(e);
        }
	},

	handleHide : function(component, event, helper) {
        try{
            helper.hideComponent(component,event);
        }catch(e){
            console.log(e);
        }
	},

    handleChangeField : function(component, event, helper) {
        try{
            helper.changeField(component, event);
        }catch(e){
             console.log(e);
        }
    },


    removeRow : function(component,event,helper){
        try{
            helper.removeLastField(component, event);
        }catch(e){
            console.log(e);
        }
    },

    handleSave :  function(component,event,helper){
        try{
            helper.saveField(component, event);
        }catch(e){
            console.log(e);
        }
    },
})