({
	fetch: function fetch(component, event, helper) {
		var params = event.getParam('arguments');
		var defaultErrorMessage = 'Something Went Wrong.';
		if (params && params.action) {
			return new Promise($A.getCallback(function (resolve, reject) {
				params.action.setCallback(this, function (response) {
					var response;
					var state = response.getState();
					if (state === 'SUCCESS' && typeof resolve === 'function') {
						response = response.getReturnValue();
                        resolve(response);
						/*if (response) {
                            resolve(response);
						}*/
					} else if (state === 'ERROR' && typeof reject === 'function') {
						var errors = response.getError();console.log(JSON.stringify(errors));
						if (Array.isArray(errors) && errors.length && errors[0] && errors[0].message) {
							var errorMessage = errors[0].message.split($A.get("$Label.c.AC_Error_Separator"));
							$A.get('e.force:showToast').setParams({
								title: 'Error',
								message: errorMessage[0],
								type: 'error'
							}).fire();
							helper.logError(component, errorMessage[0], errorMessage[1]);
							reject(Error(errors[0].message));
						} else {
							helper.logError(component, defaultErrorMessage, '');
							reject(Error(defaultErrorMessage));
						}
					}
				});
				$A.enqueueAction(params.action);
			}));
		} else {
			return new Promise($A.getCallback(function(resolve, reject) {
				helper.logError(component, defaultErrorMessage, '');
				reject(Error(defaultErrorMessage));
			}));
		}
	},
	logError: function(component, event, helper) {
		var params = event.getParam('arguments');
		var errorMessage = params.errorMessage;
		var stackTrace = params.stackTrace;
		helper.logError(component, errorMessage, JSON.stringify(stackTrace));
	}
})