<% do_pagehead1(); %>      
<html>
<head>
<title><% nv_get("model"); %> - Music</title>
<% do_pagehead2(); %>
<script type="text/javascript" src="./table.js"></script>
<script type="text/javascript">

var F; 

function to_submit(F) {
    F.submit_button.value = "aximddns";
	F.action.value = "Apply";
    ajax_preaction(F, "apply.cgi", 6000);
    display_mask(F);
}


function init() {
    F = document.getElementsByName('form')[0];
    <%widget_start();%>
}
</script>
</head>
  <body class="gui" onload="init();">
    <div id="wrapper">
        <div id="header">
	    <script type="text/javascript">do_header_pre()</script>
          <% do_menu("AirCloud", "Music"); %>
        <script type="text/javascript">do_header_post()</script>
        </div>
  
	  <script type="text/javascript">do_body_pre()</script>	
	  <script type="text/javascript">do_page_path('<%lang("AirCloud");%>', '<%lang("AXIM DDNS");%>')</script>
	  <script type="text/javascript">do_table_pre()</script>	
	  <script type="text/javascript">do_mainframe_pre()</script>	
          <div id="contentsInfo">
            <form name="form" action="apply.cgi" method="post">
	          <script type="text/javascript">do_hidden_elements('aximddns_rule')</script>	

              <fieldset>
                <legend><%lang("AXIM DDNS");%></legend>
                <div class="setting">
                  <div class="label"><% lang("DDNS"); %></div>
                  <input type="radio" value="1" name="axim_ddns_enable" onclick="init()"
                        <%nvg_attr_match("DDNS_enable","aximddns_rule","0","user_enable","1","checked");%>><%lang("Enable");%>
                  </input>

                  <input type="radio" value="0" name="axim_ddns_enable" onclick="init()"
                        <%nvg_attr_match("DDNS_enable","aximddns_rule","0","user_enable","0","checked");%>><%lang("Disable");%>
                  </input>
                </div>

                <div class="setting">
                  <div class="label"><%lang("User Name");%></div>
                  <input name="aximddns_user_name" size="16" maxLength="15" id="aximddns_user_name"
                      onblur="valid_name(this,'User Name')"
                      value='<%nvg_attr_get("DDNS_name", "aximddns_rule","0", "user_name");%>' />
                      .mycloudwifi.com
                </div>

              </fieldset><br />


              <div class="submitFooter">
                <input type="button" name="save_button" value='<%lang("Save Settings");%>' onClick="to_submit(this.form)" />
                <input type="reset" value="<%lang("Cancel Changes");%> "onClick="window.location.reload()" />
              </div>

              </form>
          </div>
	  <script type="text/javascript">do_mainframe_post()</script>	
      <%widget_show();%>
	  <script type="text/javascript">do_table_post()</script>	
	  <script type="text/javascript">do_body_post()</script>	
	  <script type="text/javascript">do_others()</script>	
      <div id="floatKiller"></div>
    </div>
    <script type="text/javascript">create_background_cover()</script>
    <script type="text/javascript">create_waiting_window()</script>
    <script type="text/javascript">create_return_window()</script>
  </body>
</html>
