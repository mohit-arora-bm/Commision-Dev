({
	doInit:  function( component, event, helper ) {
		if(! $A.util.isEmpty( component.get('v.templateId') ) ) {
			helper.doInitHelper( component, event );
		}
	},
	handleObjectChange : function(component, event, helper) {
		helper.getFieldsHelper( component, event );
	},
	onChangeField:  function( component, event, helper) {
		var fieldAPIName = event.getSource().get('v.value');
		var fieldsList = component.get('v.fieldsList');
		var selectedFieldsList = component.get('v.selectedFieldsList');
		
		for( var fld in fieldsList )  {
			if( fieldsList[fld].fieldAPIName == fieldAPIName ) {
				for( var selfld in selectedFieldsList )  {
					if( selectedFieldsList[selfld].fieldAPIName == fieldAPIName ) {
						selectedFieldsList[selfld].fieldLabel = fieldsList[fld].fieldLabel;
						selectedFieldsList[selfld].fieldType = fieldsList[fld].fieldType;
					}
				}
			}
		}

		component.set('v.selectedFieldsList', selectedFieldsList);

	},	
	handleRecordChange : function( component, event, helper) {

	},
	onChangeObject: function( component, event, helper) {
		if( $A.util.isEmpty( component.get('v.selectedTemplateObject') ) ) {
			component.set('v.fieldsList', []); 
		}
	},
	saveDataLoaderTemplate: function( component, event, helper ) {
		var allValid = component.find('input').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
		}, true);
		if( allValid ) {
			helper.saveDataLoaderTemplateHelper( component, event );
		}
	},
	addFieldRow: function( component, event, helper ) {
		helper.addRowHelper( component, event );
	},
	removeFieldRow: function( component, event, helper ) {
		console.log( event.getSource().get('v.name') );
		var fieldAPIName = event.getSource().get('v.name');
		var fieldsList = component.get('v.selectedFieldsList');
		var fieldsListUpdated = [];

		for( var fld in fieldsList ) {
			if( fieldsList[fld].fieldAPIName != fieldAPIName ) {
				fieldsListUpdated.push( fieldsList[fld] );
			}
		}
		component.set('v.selectedFieldsList', fieldsListUpdated);
	} 
})