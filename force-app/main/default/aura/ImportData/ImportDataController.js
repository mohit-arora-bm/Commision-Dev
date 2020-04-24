({
	onChangeTemplate: function( component, event, helper) {
		
		var selectedId = event.getParam('selectedRecordId');
		if(! $A.util.isEmpty( selectedId ) ) {
			component.set( 'v.templateName', event.getParam('selectedRecordName') );
			helper.onChangeTemplateHelper( component, event, selectedId );

		}
	},
	onChangeImportFile: function( component, event, helper) {
		console.log( ' Files Value :: '+event.getSource().get("v.files"));
		var files = event.getSource().get("v.files");
		component.set('v.file', files[0]);
		component.set('v.toPreview', true);
		/*var headers = [];
		var headMap = {};
		var selectedFieldsList = component.get('v.selectedFieldsList');
		var headersfieldNames = [];
		var headersfieldNamesWithType = {};
		for( var selFld in selectedFieldsList ) {
			headMap[selectedFieldsList[selFld].mappedHeader] = selectedFieldsList[selFld].fieldLabel;
			headersfieldNamesWithType[selectedFieldsList[selFld].fieldAPIName] = selectedFieldsList[selFld].fieldType;
			headersfieldNames.push(selectedFieldsList[selFld].fieldAPIName);
		}
		component.set('v.headersMap', headMap);
		component.set('v.headersfieldNamesWithType', headersfieldNamesWithType);
		component.set('v.headersfieldNames', headersfieldNames);
		component.set('v.headers', headers);*/
		helper.readFile( component, event, files[0] );
	},

	
	onUpload: function( component, event, helper ) {
		var allValid = component.find('fieldMap').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
		}, true);
		if( allValid ) {
			component.set('v.onUpload', true);
			var headers = [];
			var headMap = {};
			var headMapWithRequired = {};
			var selectedFieldsList = component.get('v.selectedFieldsList');
			var headersfieldNames = [];
			var headersfieldNamesWithType = {};
			for( var selFld in selectedFieldsList ) {
				headMap[selectedFieldsList[selFld].mappedHeader] = selectedFieldsList[selFld].fieldLabel;
				headMapWithRequired[selectedFieldsList[selFld].mappedHeader] = selectedFieldsList[selFld].isRequired;
				headersfieldNamesWithType[selectedFieldsList[selFld].fieldAPIName] = selectedFieldsList[selFld].fieldType;
				headersfieldNames.push(selectedFieldsList[selFld].fieldAPIName);
			}
			component.set('v.headersMap', headMap);
			component.set('v.headMapWithRequired', headMapWithRequired);
			component.set('v.headersfieldNamesWithType', headersfieldNamesWithType);
			component.set('v.headersfieldNames', headersfieldNames);
			component.set('v.headers', headers);
			helper.readFile( component, event, component.get('v.file') );
		}
		
		
	},
	onChangeAllOrNone:  function( component, event, helper ){
		component.set('v.allOrNone', event.getSource().get('v.checked'));
	}
})