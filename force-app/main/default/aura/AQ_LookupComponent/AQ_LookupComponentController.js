({
	filterList: function( component, event, helper ) {
		var searchFromWithin = component.get( 'v.searchFromWithin' );
		var searchValue = component.find( 'searchInput' ).getElement().value;
		component.set( 'v.searchText', searchValue );
		if( searchValue.length > 0 ) {
			helper.showLookup( component );
			if( searchFromWithin ) {
				helper.filterListHelperWithin( component, event, searchValue );
			} else {
				helper.filterListHelper( component, event, searchValue );
			}
		} else {
			helper.hideLookup( component );
		}		
	},
	onSelect: function( component, event, helper ) {
		if( !$A.util.isEmpty( event.currentTarget.id ) ) {
			helper.onSelectHelper( component, event, event.currentTarget.id );
		}
	},
	onClear: function( component, event, helper ) {
		component.set( 'v.selectedItem', null );
		helper.fireEvent( component, '' );
		helper.hideLookup( component );
	},
	hideLookup: function( component, event, helper ) {
		if( !component.get( 'v.preventLookupHide' ) ) {
			//helper.hideLookup( component );
		}
	},
	searchForExistingLookup: function( component, event, helper ) {
		if( !$A.util.isEmpty( component.get( 'v.searchText' ) ) ) {
			helper.showLookup( component );		
		}
	},
	mouseDown: function( component, event, helper ) {
		component.set( 'v.preventLookupHide', true );
	},
	mouseUp: function( component ) {
		component.find( 'searchInput' ).getElement().focus();
		component.set( 'v.preventLookupHide', false );
	}
})