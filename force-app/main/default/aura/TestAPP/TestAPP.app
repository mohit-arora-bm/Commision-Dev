<aura:application extends="force:slds">
    <ltng:require styles="{!$Resource.Cron + '/jquery-cron-quartz-master/src/jquery-cron-quartz.css'}"
 scripts="{!join(',',
          $Resource.jquery,
          $Resource.Cron+ '/jquery-cron-quartz-master/src/jquery-cron-quartz.js')}"
                  afterScriptsLoaded="{!c.loadJquery}"/>
   <div id='cron'></div>
    <button id="generate" type="button" class="btn btn-success">Generate Cron Expression</button>
    <div class="alert alert-warning">
                    <p><strong>Cron Expression:</strong> <span id="result"></span></p>
                </div>
    <c:AC_TemplateConfig/>
</aura:application>