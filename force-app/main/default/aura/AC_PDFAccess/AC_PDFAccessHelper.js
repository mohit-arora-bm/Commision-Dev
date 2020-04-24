({
    createPDF : function(component,pageName,eavId,includeDetails) { 
        let pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/apex/'+pageName+'?id='+eavId  + '&includeDetails='+includeDetails
            },

        };
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                console.log(url);
                window.open(url,'_blank');
                // navService.navigate(pageReference);


            }), $A.getCallback(function(error) {
                console.log(error); 
            }));
    },
    checkEmployee : function(component, periodId, includeDetails) {
        let self = this;
        var dataService = component.find('dataService');
		var action = component.get('c.getEmployeeAttainId');
		action.setParams({'periodId': periodId});
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            self.createPDF(component,'AC_EmployeePDF',response,includeDetails);
        })).catch(function (error) {
            self.showToast(component, 'Error', 'error', error.message);
			self.logError(component, 'checkEmployee', error.name, error.message);
		});
    },
    showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
    },
    logError : function(component, methodName, errorName, errorMessage) {
		component.find('dataService').logException('AC_PDFAccess -> ' + methodName + errorName, errorMessage);
	},
})