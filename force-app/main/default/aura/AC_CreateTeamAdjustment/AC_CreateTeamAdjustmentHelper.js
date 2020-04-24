({
    showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
	}
})