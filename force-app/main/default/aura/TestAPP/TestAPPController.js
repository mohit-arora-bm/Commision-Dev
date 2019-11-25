({
	loadJquery : function(component, event, helper) {
		// Initialize DOM with cron builder
    $('#cron').cronBuilder();

    // Add event handler to button
    $('button#generate').click(function(){

        // Get current cron expression
        var expression=$('#cron').data('cronBuilder').getExpression();

        // Dispaly cron expression
        $('#result').text(expression);
    })
	}
})