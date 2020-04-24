({
	doInitHelper: function( component, event ) {
		var self = this;
		try {
			self.showSpinner(component);
			var dataService = component.find('dataService');
			var action = component.get('c.getDataTemplate');
			action.setParams({
				templateId: component.get('v.templateId')
			});
			dataService.fetch(action).then($A.getCallback(function (response) {
				console.log(response);
				if(! $A.util.isEmpty( response ) ) {
					component.set('v.selectedTemplateObject',  response.objectName  );
					component.set('v.fieldsList', JSON.parse( response.fields ) );
					var selectedFieldsList = [];
					if( $A.util.isEmpty( response.selectedFields ) ) {
						selectedFieldsList.push( self.fieldPayLoad( component, event ) );
					}else {
						selectedFieldsList = JSON.parse( response.selectedFields );
					}
					
					component.set('v.selectedFieldsList', selectedFieldsList);
				}
				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
				component.find('dataService').logException('TemplateDataLoader -> getFieldsHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			component.find('dataService').logException('TemplateDataLoader -> getFieldsHelper ' + e.name, e.message);
		}
	},

	getFieldsHelper: function( component, event ) {
		var self = this;
		try {
			self.showSpinner(component);
			var dataService = component.find('dataService');
			var action = component.get('c.getFields');
			action.setParams({
				objectAPIName: component.get('v.selectedTemplateObject')
			});
			dataService.fetch(action).then($A.getCallback(function (response) {
				console.log(response);
				if(! $A.util.isEmpty( response ) ) {
					component.set('v.fieldsList', response);
					var selectedFieldsList = [];
					for(var fld in response ) {
						if( response[fld].isRequired ){
							selectedFieldsList.push( response[fld]);
						}
					}
					selectedFieldsList.push( self.fieldPayLoad( component, event ) );
					component.set('v.selectedFieldsList', selectedFieldsList);
				}
				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
				component.find('dataService').logException('TemplateDataLoader -> getFieldsHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			component.find('dataService').logException('TemplateDataLoader -> getFieldsHelper ' + e.name, e.message);
		}
	},

	saveDataLoaderTemplateHelper: function( component, event ) {
		var self = this;
		var templateName = component.get('v.templateName');
		try {
			self.showSpinner(component);
			var dataService = component.find('dataService');
			var action = component.get('c.saveTemplateData');
			action.setParams({
				templateName: templateName,
				objectAPIName: component.get('v.selectedTemplateObject'),
				fieldListJSON: JSON.stringify(component.get('v.selectedFieldsList')),
				templateId: component.get('v.templateId')
			});
			dataService.fetch(action).then($A.getCallback(function (response) {
				console.log(response);
				$A.get('e.force:refreshView').fire();
				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
				component.find('dataService').logException('TemplateDataLoader -> getFieldsHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			component.find('dataService').logException('TemplateDataLoader -> getFieldsHelper ' + e.name, e.message);
		}
	},

	showSpinner: function(component) {
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
	},
	hideSpinner: function(component) {
		$A.util.addClass(component.find('spinner'), 'slds-hide');
	},

	readFile: function(component, helper, file) {
        if (!file) return;
        console.log('file'+file.name);
        if(!file.name.match(/\.(csv||CSV)$/)){
            return alert('only support csv files');
        }else{
            
            reader = new FileReader();
            reader.onerror =function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');
                };
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function(e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function(e) { 
                
                var output = '<ui type=\"disc\"><li><strong>'+file.name +'</strong> ('+file.type+')- '+file.size+'bytes, last modified: '+file.lastModifiedDate.toLocaleDateString()+'</li></ui>';
                component.set("v.filename",file.name);
                component.set("v.TargetFileName",output);
               
            };
            reader.onload = function(e) {
                var data=e.target.result;
                component.set("v.fileContentData",data);
                console.log("file data"+JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                var dataRows=allTextLines.length-1;
                var headers = allTextLines[0].split(',');
                component.set('v.headers', headers);
                console.log("Rows length::"+dataRows);
               
              
                	var numOfRows=component.get("v.NumOfRecords");
                    if(dataRows > numOfRows+1 || dataRows == 1 || dataRows== 0){
                   
                     alert("File Rows between 1 to "+numOfRows+" .");
                    component.set("v.showMain",true);
                    
                } 
                else{
                    var lines = [];
                    var filecontentdata;
                    var content = "<div class=\"slds-p-horizontal_small slds-scrollable quoteTempConfigDiv \"><table class=\"table slds-table slds-table--bordered \">";
                    content += "<thead><tr class=\"slds-text-title--caps\">";
                    for(i=0;i<headers.length; i++){
                        content += '<th scope=\"col"\>'+headers[i]+'</th>';
                    }
                    content += "</tr></thead>";
                    for (var i=1; i<allTextLines.length; i++) {
                        filecontentdata = allTextLines[i].split(',');
                        if(filecontentdata[0]!=''){
                            content +="<tr>";
                            
                            for(var j=0;j<filecontentdata.length;j++){
                                content +='<td>'+filecontentdata[j]+'</td>';
                            }
                            content +="</tr>";
                        }
                    }
					content += "</table></div>";
					
                    console.log('Table headers :: '+component.get('v.headers'));
                    component.set("v.TableContent",content);
					component.set("v.showMain",false);                   
                }
            }
            reader.readAsText(file);
            
        }
        var reader = new FileReader();
        reader.onloadend = function() {
         
        };
        reader.readAsDataURL(file);
	},
	addRowHelper: function( component, event ) {
		var self = this;
		var selectedFieldLength = component.get('v.selectedFieldsList').length;
		var selectedFieldsList = component.get( 'v.selectedFieldsList' );
		selectedFieldsList.push( self.fieldPayLoad( component, event ) ); 
		component.set('v.selectedFieldsList', selectedFieldsList);
	},
	fieldPayLoad: function( component, event ) {

		var selectFieldObj = {
			fieldAPIName : '',
			fieldLabel : '',
			fieldType : '',
			isRequired : false,
			mappedHeader : ''
		}

		return selectFieldObj;
	}
})