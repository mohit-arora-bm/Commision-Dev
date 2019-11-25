({
	doInit : function(component, event, helper) {
		try {
			helper.getObjects(component,event);
		} catch(e) {
            console.log(e);
        }
	},

	findObject : function(component, event, helper) {
		try {
			helper.getObjects(component,event);
		} catch(e) {
            console.log(e);
        }
	},

	onClear: function( component, event, helper ) {
		try{
			helper.removeSelected(component,event);
		}catch( e ) {
             component.find('utilityComponent').logError(e);
        }
	},

	onSelect: function( component, event, helper ) {
		try{
			if( !$A.util.isEmpty( event.currentTarget.id ) && event.currentTarget.id != 'No Records' ) {
				helper.onSelectHelper( component, event, event.currentTarget.id );
			}
		}catch( e ) {
            console.log(e);
        }
	},

	onBlur: function( component, event, helper ) {
		try{
			if( $A.util.isEmpty( component.get('v.searchText') ) ) {
				component.set('v.sldsclass', '');
			}
		}catch( e ) {
            console.log(e);
        }
	},

	hideLookup: function( component, event, helper ) {
		try{
        	component.set('v.sldsclass','');
        }catch( e ) {
             console.log(e);
        }
	},

})