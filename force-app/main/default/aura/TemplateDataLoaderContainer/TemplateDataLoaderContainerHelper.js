({
	createTemplateConfigHelper : function(component, event, templateId, templateName) {
        try {
			var self = this;
            $A.createComponent(
                'c:TemplateDataLoader',
                {
                    "aura:id": 'TemplateDataLoader',
                    "templateId" : templateId,
                    "templateName" : templateName
                },
                function(newComponent, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = [];
                        body.push(newComponent);
                        component.set("v.body", body);
                    } else if (status === "ERROR") {
                        self.showToast('Info Message',errorMessage,'','5000','info_alt','error','dismissible');
                    }
                }
            );
        } catch(e) {
           component.find('dataService').logException('TemplateDataLoader -> createComponent ' + e.name, e.message);
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
          component.find('dataService').logException('AQ_AgileQuoteGroupConfig -> showToast ' + e.name, e.message);
        }
    },
})