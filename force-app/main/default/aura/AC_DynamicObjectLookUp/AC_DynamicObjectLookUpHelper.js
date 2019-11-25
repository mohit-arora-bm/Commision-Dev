({

    getObjects : function(component, event) {
        try {
            var self = this;
            component.set('v.issearching', true);
            var action = component.get("c.getDynamicOjectList");
            var utilComp = component.find('dataService');
            action.setParams({
                    'searchText' : component.get('v.searchText'),
                    'selectedObject' : component.get('v.selectedObject')
            });
            utilComp.fetch( action ).then(
                $A.getCallback(function( result ) {
                    if(!$A.util.isEmpty( component.get( 'v.selectedObject' ) ) ) {
                        var objectApiName = component.get( 'v.selectedObject' );
                        if(!$A.util.isEmpty(result)){
                            var lookupData = JSON.parse(result);
                            if(!$A.util.isEmpty(lookupData)){
                                for( var index in lookupData ) {
                                    if( lookupData[index].value.toLowerCase() === objectApiName.toLowerCase() ) {
                                        component.set('v.selectedObjectAPIName',lookupData[index].value);
                                        component.set('v.selectedObjectName',lookupData[index].label);
                                        component.set('v.selectedObject',lookupData[index].value);
                                        break;
                                    }
                                }
                            }
                        }
                    } else {
                        if(!$A.util.isEmpty(result)) {
                            component.set('v.listofsobject', JSON.parse(result));
                            component.set('v.sldsclass', 'slds-is-open');
                        } else {
                            component.set('v.listofsobject', [{label: 'No result Found', value: 'No Records'}]);
                        }
                    }
                    component.set('v.issearching', false);
                }),
                $A.getCallback(function( error ) {
                    component.set('v.issearching', false);
                    if (error && Array.isArray(error) && error.length > 0) {
                        var message = error[0].message;
                        self.showToast('Info Message',message,'','5000','info_alt','error','dismissible');
                    }
                })
            );
        } catch(e) {
            component.set('v.issearching', false);
            console.log(e);
        }
    },

    removeSelected : function(component,event){
        try{
            var self = this;
            component.set( 'v.selectedObjectAPIName', null );
            component.set('v.searchText',null);
            component.set('v.selectedObjectName',null);
            component.set('v.selectedObject',null);
            self.getObjects(component,event);
        }catch( e ) {
            console.log(e);
        }
    },


    onSelectHelper: function( component, event, value ) {
        try{
            var self = this;
            var lookupData = component.get( 'v.listofsobject' );
            if(!$A.util.isEmpty( lookupData) ){
                for( var index in lookupData ) {
                    if( lookupData[index].value === value ) {
                        component.set('v.selectedObjectAPIName',lookupData[index].value);
                        component.set('v.selectedObjectName',lookupData[index].label);
                        component.set('v.selectedObject',lookupData[index].value);
                        component.set('v.sldsclass','');
                        $A.get( 'e.c:AC_ObjectChangeEvent' ).fire();
                        break;
                    }
                }
            }
        }catch( e ) {
           console.log(e);
        }
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