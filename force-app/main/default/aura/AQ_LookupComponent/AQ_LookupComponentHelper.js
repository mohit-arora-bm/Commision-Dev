({
	filterListHelper: function( component, event, searchValue ) {
		var action = component.get( 'c.returnRecords' );
		action.setParams({
			objectName: component.get( 'v.objectApiName' ),
			fieldApiName: component.get( 'v.fieldApiName' ),
			otherFields: component.get( 'v.fieldsSearchList' ),
			searchText: searchValue
		});
		action.setCallback( this, function( response ) {
			if( response.getState() === 'SUCCESS' ) {
				var returnVal = response.getReturnValue();
				component.set( 'v.lookupData', JSON.parse( returnVal ) );
			}
		});
		$A.enqueueAction( action );
	},
	filterListHelperWithin: function( component, event, searchValue ) {
		var withinSearchData = component.get( 'v.withinSearchData' );
		var lookupData = [];
		for( var element in withinSearchData ) {
			if( withinSearchData[element].Name.toLowerCase().indexOf( searchValue.toLowerCase() ) > -1 ) {
				var lookupObject = new Object();
				let innerKey = '';
				lookupObject.val = withinSearchData[element].Id;
				lookupObject.showText = withinSearchData[element].Name;
				lookupObject.otherFieldsWrapper = [];
				var fieldsSearchList = component.get( 'v.fieldsSearchList' ).split( ',' );
				for( var innerElement in fieldsSearchList ) {
					var innerLookupObj = {
						val: fieldsSearchList[innerElement],
						showText: withinSearchData[element][fieldsSearchList[innerElement]]
					}
					lookupObject.otherFieldsWrapper.push( innerLookupObj );
				}
				lookupData.push( lookupObject );
			}
		}
		component.set( 'v.lookupData', lookupData );
	},
	onSelectHelper: function( component, event, recordId ) {
		var self = this;
		var lookupData = component.get( 'v.lookupData' );
		for( var element in lookupData ) {
			if( lookupData[element].val === recordId ) {
				var selectedItem = {
					showText: lookupData[element].showText,
					val: recordId
				}
				component.find( 'searchInput' ).getElement().value = '';
				component.set( 'v.selectedItem', selectedItem );
				self.fireEvent( component, recordId, lookupData[element].showText );
			}
		}
		component.set( 'v.preventLookupHide', false );
	},
	fireEvent: function( component, recordId, recordName ) {
		component.getEvent( 'lookupEvent' ).setParams({
			'selectedRecordId': recordId,
			'selectedRecordName': recordName
		}).fire();
	},
	showLookup: function( component ) {
		$A.util.addClass( component.find( 'lookupDiv' ), 'slds-is-open' );
	},
	hideLookup: function( component ) {
		$A.util.removeClass( component.find( 'lookupDiv' ), 'slds-is-open' );
		component.set( 'v.preventLookupHide', false );
	},
})