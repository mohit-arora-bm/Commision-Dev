({
    initHelper : function(component) { 
        let adjList = [];
        adjList.push({});
        let types = [];
        types.push({"label": "Gross Profit","value": "Gross Profit"});
        types.push({"label": "Commission Adjustment", "value": "Commission Adjustment"});
        let adjTypes = [];
        adjTypes.push({"label": "(GP) Gift Certificate.", "value": "(GP) Gift Certificate."});
        adjTypes.push({"label": "(GP) Misc GP Adjustment", "value": "(GP) Misc GP Adjustment"});
        adjTypes.push({"label": "(CA) Previous Month Carryover", "value": "(CA) Previous Month Carryover"});
        adjTypes.push({"label": "(CA) Draws", "value": "(CA) Draws"});
        adjTypes.push({"label": "(CA) Overrides", "value": "(CA) Overrides"});
        adjTypes.push({"label": "(CA) Misc Adjustment", "value": "(CA) Misc Adjustment"});
        adjTypes.push({"label": "(CA) Rescind", "value": "(CA) Rescind"});
        adjTypes.push({"label": "(CA) Sales Mgmt Comm ADj", "value": "(CA) Sales Mgmt Comm ADj"});
        console.log(adjList.length);
        component.set('v.adjTypes',adjTypes);
        component.set('v.types',types);
        component.set('v.adjList',adjList);
    },
    getAdjRow : function() {
        return {
            agileComp__Commission_Employee_Attained_Value_Recor__c : null,
            agileComp__Type__c : null,
            agileComp__Adjustment_Type__c : null,
            agileComp__Adjustment_Amount__c : null,
            agileComp__Adjustment_Description__c : null
        };
    },
    showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
    },
    logError : function(component, methodName, errorName, errorMessage) {
		console.error(methodName,errorName,errorMessage);
        component.find('dataService').logException('AC_MultiAdjustment -> ' + methodName + errorName, errorMessage);
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    hideSpinner : function( component ) {
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
    },
})