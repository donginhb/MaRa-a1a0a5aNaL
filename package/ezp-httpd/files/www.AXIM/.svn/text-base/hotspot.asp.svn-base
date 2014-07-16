<% do_pagehead1(); %>      
<html>
  <head>
    <title><% nv_get("model"); %> - Hotspot Serivce</title>
    <% do_pagehead2(); %>
    <script type="text/javascript" src="./table.js"></script>
    <script type="text/javascript">

    var F;

    function local_rule_check(T) {
        if ((!E('username').value)) {
            alert('User name is required.');
            return false;
        }

        if (!E('passwd').value) {
            alert('Password is required.');
            return false;
        }
        return true;
    }
    function local_table_check(T, R) {
        return rlist_check_dup_field(T, R, enum_hs._NAME);
    }

var enum_hs = {                                                               
    _ENABLE:0,                                                                  
    _NAME:1,                                                                    
    _PASSWD:2,                                                                  
}

var default_rule = ['1','',''];

var rule;
function local_create_input_field(T, nth, r) {
    rule = (r != undefined) ? r : default_rule;

    _local_create_input_field(T, nth);
}

function _local_create_input_field(T, nth) {
    var s = '';

    s += "<div class='isetting'>"
        + "<div class='ilabel'>"+'<%lang("Sequence Number");%>' + "</div>"
        + "<div class='iInputField'><input type='hidden' id='hs_table_old_seq' value='"+nth+"' />"
        + "<input id='hs_table_seq' size='4' maxlength='4' value='"+nth+"' /></div>"
        +"</div><br/>";

    s += "<div class='isetting'>"
        + "<div class='ilabel'>"+'<%lang("Rule Enable");%>' + "</div>"
        + "<div class='iInputField'><input id='enable' name='enable' type='checkbox'/></div>"
        +"</div><br/>";

    s += "<div class='isetting'>"
        + "<div class='ilabel'>"+'<%lang("User Name");%>' + "</div>"
        + "<div class='iInputField'><input id='username' name='username' size='20' maxlength='20' onblur='valid_name(this, \"User Name\", 1)'/></div>"
        +"</div><br/>";

    s += "<div class='isetting'>"
        + "<div class='ilabel'>"+'<%lang("Password");%>' + "</div>"
        + "<div class='iInputField'><input id='passwd' name='passwd' size='20' maxlength='20' onblur='valid_name(this, \"Password\", 1)'/></div>"
        +"</div>";


    E(T+'_input_field').innerHTML = s;

    local_fill_input_field();
}
function local_fill_input_field() {
    tbl_assign_enable('enable', rule[enum_hs._ENABLE]);
    E('username').value = rule[enum_hs._NAME];
    E('passwd').value = rule[enum_hs._PASSWD];
}

function local_create_table(T, R) {
    var c;
    c = "<tr>"
        + '<th><%lang("Rule Enable");%></th>'
        + '<th><%lang("User Name");%></th>'
        + '<th><%lang("Password");%></th>'
      + "</tr>";

    var cur_num = parseInt(E(T+"_cur_rule_num").value);
    for (var i = 0; i < cur_num; i++) {
        c += "<tr onclick='tbl_focus_tr(\""+T+"\", this);'>"
             + "<td>" + tbl_wrap_enable(R[i][enum_hs._ENABLE]) + "</td>"
             + "<td>" + R[i][enum_hs._NAME] + "</td>"
             + "<td>" + R[i][enum_hs._PASSWD] + "</td>"
           + "</tr>";
    }

    return c;
}
function local_pack_key_value_pair(F, T, prefix) {
    /* Important */
    tbl_append_element(F, 'hs_rule', '');
    var row_num = parseInt(E(T+'_cur_rule_num').value);

    tbl_append_element(F, prefix + "_num", row_num);

    for (var i = 0; i < row_num; i++) {
        tbl_append_element(F, prefix + i + '_enable', hs_user_rule[i][enum_hs._ENABLE]);
        tbl_append_element(F, prefix + i + '_username', hs_user_rule[i][enum_hs._NAME]);
        tbl_append_element(F, prefix + i + '_passwd', hs_user_rule[i][enum_hs._PASSWD]);
    }
}

function local_generate_rule(T) {
    var rule_tmp = Array();
    rule_tmp[enum_hs._ENABLE]   = tbl_dewrap_enable('enable');
    rule_tmp[enum_hs._NAME]     = E('username').value;
    rule_tmp[enum_hs._PASSWD]   = E('passwd').value;

    return rule_tmp;
}

function SelHSMODE(F) {
	if(F.value == "simple")
		$("#hs_show_setting").load("hs_simple.asp");
	else if(F.value == "local")
		$("#hs_show_setting").load("hs_local.asp");
	
    //F.submit_button.value = "hotspot";
    //F.action.value = "Gozila";
    //F.submit();
}

var tos_objects =
[
    { name: 'hs_tos_text'  },
];

var pages_objects =
[
    { name: 'hs_pages_title'  },
    { name: 'hs_page_header_elements_contents'  },
    { name: 'hs_page_header_contents'  },
    { name: 'hs_page_welcome_message'  },
    { name: 'hs_page_tos_agreement'  },
    { name: 'hs_page_ad_contents'  },
    { name: 'hs_page_footer_contents'  },
];


var hs_objects =
[
    { name: 'hs_mode'  },
    { name: 'hs_ua_enable'  },
    { name: 'hs_static_ipaddr'  },
    { name: 'hs_static_mask'  },
    { name: 'hs_tos_enable'  },
    { name: 'hs_tos_text'  },
    { name: 'hs_uam_allow'  },
    { name: 'hs_pages_mode'  },
    { name: 'hs_pages_title'  },
    { name: 'hs_page_header_elements_contents'  },
    { name: 'hs_page_header_contents'  },
    { name: 'hs_page_tos_agreement'  },
    { name: 'hs_page_welcome_message'  },
    { name: 'hs_page_ad_contents'  },
    { name: 'hs_page_footer_contents'  },
];

function onoffhotspot() {
    F=EN('form')[0];
    var enable_hotspot;
    enable_hotspot=(EN("hs_enable")[0].checked == true) ? 1 : 0;
    sel_change(enable_hotspot, 1,  F, hs_objects);
}
    function changepagesmode() {
        F=EN('form')[0];
        var select_pages_mode;
        select_pages_mode=(EN("hs_pages_mode")[1].checked == true) ? 1 : 0;
        sel_change(select_pages_mode, 1,  F, pages_objects);
    }
    function onofftos() {
        F=EN('form')[0];
        var enable_tos;
        var tos_opt = document.getElementsByName("hs_tos_enable");
        enable_tos=(tos_opt[0].checked == true) ? 1 : 0;
        sel_change(enable_tos, 1,  F, tos_objects);
    }

    function onoffua() {
        F=EN('form')[0];
        var enable_ua;
        enable_ua=(EN("hs_ua_enable")[0].checked == true) ? 1 : 0;
        sel_change(enable_ua, 1,  F, ua_objects);
    }


    function to_submit(F) {
       if ($("#hs_mode").val() == "local")                                                                          
        {                                                                                                            
            var special_table = $("#hs_table_element tr");                                                           
            var tr_count,td_count,count;                                                                             
            for(tr_count = 1;tr_count < special_table.length;tr_count++)                                             
            {   
		count=tr_count;                                                                                                     
                var special_data = special_table.eq(tr_count).children("td");                                        
                var enable = 1;                                                                                      
                if(special_data.eq(0).children("img").attr("src") == "x_011.gif")                                    
                    enable = 0;                                                                                      
                      
		count--;                                                                                               
                var obj_enable=document.createElement("input");                                                      
                F.appendChild(obj_enable);                                                                           
                obj_enable.setAttribute ("name","hs_user_rule"+count+"_enable");                                  
                obj_enable.setAttribute ("value",enable);                                                            
                obj_enable.setAttribute ("type","hidden");                                                           
                                                                                                                     
                var obj_name=document.createElement("input");                                                        
                F.appendChild(obj_name);                                                                             
                obj_name.setAttribute ("name","hs_user_rule"+count+"_name");                                      
                obj_name.setAttribute ("value",special_data.eq(1).text());                                           
                obj_name.setAttribute ("type","hidden");                                                             
                                                                                                                     
                var obj_password=document.createElement("input");                                                    
                F.appendChild(obj_password);                                                                         
                obj_password.setAttribute ("name","hs_user_rule"+count+"_password");                              
                obj_password.setAttribute ("value",special_data.eq(2).text());                                       
                obj_password.setAttribute ("type","hidden");                                                         
            }                                                                                                        
        }                             
	tr_count--;
        var obj_count=document.createElement("input");                         
        F.appendChild(obj_count);                                              
        obj_count.setAttribute ("name","hs_user_rule_num");                    
        obj_count.setAttribute ("value",tr_count);                                
        obj_count.setAttribute ("type","hidden");  

        var backup_footer=F.hs_page_footer_contents.value;
        F.hs_page_footer_contents.value=encode64(F.hs_page_footer_contents.value);
        var backup_ad=F.hs_page_ad_contents.value;
        F.hs_page_ad_contents.value=encode64(F.hs_page_ad_contents.value);
        
        var backup_header=F.hs_page_header_contents.value;
        F.hs_page_header_contents.value=encode64(F.hs_page_header_contents.value);
        var backup_tos=F.hs_tos_text.value;
        F.hs_tos_text.value=encode64(F.hs_tos_text.value);

        var backup_header_elements=F.hs_page_header_elements_contents.value;
        F.hs_page_header_elements_contents.value=encode64(F.hs_page_header_elements_contents.value);

        var backup_welcome=F.hs_page_welcome_message.value;
        F.hs_page_welcome_message.value=encode64(F.hs_page_welcome_message.value);
        
        var backup_tos_agreement=F.hs_page_tos_agreement.value;
        F.hs_page_tos_agreement.value=encode64(F.hs_page_tos_agreement.value);


        F.submit_button.value = "hotspot";
	F.action.value = "Apply";
        <% hs_local_db_submit(); %>

        ajax_preaction(F, "apply.cgi", 6000);
        F.hs_page_footer_contents.value=backup_footer;
        F.hs_page_ad_contents.value=backup_ad;
        F.hs_page_header_contents.value=backup_header;
        F.hs_tos_text.value=backup_tos;
        F.hs_page_header_elements_contents.value=backup_header_elements;
        F.hs_page_welcome_message.value=backup_welcome;
        F.hs_page_tos_agreement.value=backup_tos_agreement;
        display_mask(F);
    }
    function switch_to_web_form (input)
    {
        var output;
        output = decode64(input);
        return output;
    }

    function init() {
        F = document.getElementsByName("form")[0];
        var enable = (document.getElementsByName("hs_enable")[0].checked == true) ? 1 : 0;
        var local_mode = (document.getElementsByName("hs_mode")[0].value == "local") ? 1 : 0;

        sel_change(enable, 1, F, hs_objects);
        
        document.getElementById("hs_mode").onchange();
        document.getElementById("hs_page_footer_contents").innerHTML = switch_to_web_form(encode64('<%show_file("hs_page_footer_contents.txt");%>'));
	document.getElementById("hs_page_ad_contents").innerHTML = switch_to_web_form(encode64('<%show_file("hs_page_ad_contents.txt");%>'));
	document.getElementById("hs_page_header_contents").innerHTML = switch_to_web_form(encode64('<%show_file("hs_page_header_contents.txt");%>'));
        document.getElementById("hs_page_header_elements_contents").innerHTML = switch_to_web_form(encode64('<%show_file("hs_page_header_elements_contents.txt");%>'));
        document.getElementById("hs_page_welcome_message").innerHTML = switch_to_web_form(encode64('<%show_file("hs_page_welcome_message.txt");%>'));
        document.getElementById("hs_page_tos_agreement").innerHTML = switch_to_web_form(encode64('<%show_file("hs_page_tos_agreement.txt");%>'));

	
        changepagesmode();
        if (enable == 1) {
            if (  <% nv_attr_get("wl_basic_rule",0,"enable"); %>  ) {
                if( !<% nv_attr_get("wl0_basic_rule",1,"enable"); %> ) {
                    alert('<%lang("Wireless SSID1/SSID2 have to be enable when you enable Hotspot service.");%>');
                }
            }else{
                alert('<%lang("Wireless SSID1/SSID2 have to be enable when you enable Hotspot service.");%>');
            }
            if (  local_mode == 1  ) {
                tbl_disable_row_edit('hs_table');
            }

        }else{
		sel_change(0, 1,  F, pages_objects);
	}
        <%widget_start();%>
	}
    </script>
  </head>
  <body class="gui" onload="init()"> 
    <div id="wrapper">
      <div id="header"> 
	    <script type="text/javascript">do_header_pre()</script>
        <% do_menu("Wireless", "Guest Hotspot"); %>
        <script type="text/javascript">do_header_post()</script>
      </div>
             
	  <script type="text/javascript">do_body_pre()</script>	
	  <script type="text/javascript">do_table_pre()</script>	
	  <script type="text/javascript">do_mainframe_pre()</script>	
	  <script type="text/javascript">
            do_page_path('<%lang("Wireless (Wi-Fi)");%>', '<%lang("Hotspot");%>')
      </script>
      <div id="contents">
        <form name="form" action="apply.cgi" method="post">
	  <script type="text/javascript">do_hidden_elements('hotspot_rule')</script>
          <fieldset>
            <legend>Hotspot Setting</legend>
            <div class="setting">
              <div class="label">Hotspot</div>
              <input type="radio" value="1" name="hs_enable" onclick="init()"
                    <% nvg_attr_match("hs_enable", "hs_server_rule", "0", "enable", "1", "checked"); %>>
                    <% lang("Enable"); %>
              </input>
              <input type="radio" value="0" name="hs_enable" onclick="init()"
                    <% nvg_attr_match("hs_enable", "hs_server_rule", "0", "enable", "0", "checked"); %>>
                    <% lang("Disable"); %>
              </input>
            </div>
 
 	    <div class="setting">
              <div class="label"><% lang("Wireless SSID"); %></div>
              <div class="label"><%nv_attr_get("wl0_ssid_rule","1","ssid");%></div>
            </div>

            <div class="setting">
              <div class="label"><%lang("IP Address");%></div>
              <input type="text" maxLength="15" size="18" name="hs_static_ipaddr"
                value='<%nv_attr_get("hs_server_rule", "0", "ipaddr");%>'
                onblur='valid_ipaddr(this, "IP Address")' />
            </div>

            <div class="setting">
              <div class="label"><%lang("Netmask");%></div>
              <select name="hs_static_mask">
              <option value="8" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","8","selected");%>>
                255.0.0.0</option>
              <option value="16" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","16","selected");%>>
                255.255.0.0</option>
              <option value="17" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","17","selected");%>>
                255.255.128.0</option>
              <option value="18" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","18","selected");%>>
                255.255.192.0</option>
              <option value="19" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","19","selected");%>>
                255.255.224.0</option>
              <option value="20" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","20","selected");%>>
                255.255.240.0</option>
              <option value="21" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","21","selected");%>>
                255.255.248.0</option>
              <option value="22" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","22","selected");%>>
                255.255.252.0</option>
              <option value="23" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","23","selected");%>>
                255.255.254.0</option>
              <option value="24" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","24","selected");%>>
                255.255.255.0</option>
              <option value="25" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","25","selected");%>>
                255.255.255.128</option>
              <option value="26" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","26","selected");%>>
                255.255.255.192</option>
              <option value="27" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","27","selected");%>>
                255.255.255.224</option>
              <option value="28" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","28","selected");%>>
                255.255.255.240</option>
              <option value="29" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","29","selected");%>>
                255.255.255.248</option>
              <option value="30" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","30","selected");%>>
                255.255.255.252</option>
              <option value="31" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","31","selected");%>>
                255.255.255.254</option>
              <option value="32" <%nvg_attr_match("hs_static_mask","hs_server_rule","0","mask","32","selected");%>>
                255.255.255.255</option>
              </select>
            </div>
 

            <div class="setting">
              <div class="label"><% lang("Authentication Mode"); %></div>
              <select name="hs_mode" id="hs_mode" onchange="SelHSMODE(this)" >
 		  <option value="simple" <%nvg_attr_match("hs_mode","hs_server_rule","0","mode","simple","selected"); %>><%lang("Splash Page");%>
                  </option>
                  <option value="local"  <%nvg_attr_match("hs_mode","hs_server_rule","0","mode","local","selected"); %>><%lang("Local User Database");%>
                  </option>
              </select>
            </div>
 	    <!--<% hs_show_setting(); %>--!>
 	    <div id="hs_show_setting"></div>
            
          </fieldset>
              <fieldset>
              <legend><%lang("Hotspot Pages Setting");%></legend>
                <br /> 
                <div class="setting">
                    <div class="label"><% lang("Hotspot Pages"); %></div>
                    <div style='display:inline-block;'>
                    <div style='display:inline-block;'><input type="radio" value="default" name="hs_pages_mode" onchange="changepagesmode()"
                        <%nvg_attr_match("hs_pages_mode","hs_pages_rule","0","pages_mode","default","checked");%>>
                        <%lang("Default");%>
                    </input></div><br />
                                                                                 
                    <div style='display:inline-block;'><input type="radio" value="customization" name="hs_pages_mode" onchange="changepagesmode()"
                        <%nvg_attr_match("hs_pages_mode","hs_pages_rule","0","pages_mode","customization","checked");%>>
                        <%lang("Customized");%>
                    </input></div>
                    </div>
                </div>


                <br /> 
                <div class="setting">
                    <div class="label"><%lang("Web Page Title");%></div>
                    <input name="hs_pages_title" size="18" maxLength="20" onBlur="valid_name(this,'Web Page Title')"
                        value='<%nvg_attr_get("hs_pages_title", "hs_pages_rule", "0", "title");%>'
                        onblur='valid_name(this, "Title")' />
                </div>

                <br /> 
                <div class="setting">                                         
                     <div class="label"><%lang("Hotspot Page HEAD Elements");%></div>     
                      <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_page_header_elements_contents" name="hs_page_header_elements_contents" ></textarea>
                     <br/>(<%lang("0-1024 characters.");%>)
               </div>     

                <div class="setting">                                 
                    <div class="label"><%lang("Header Content");%></div> 
                        <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_page_header_contents" name="hs_page_header_contents"></textarea>
                    <br/>(<%lang("0-512 characters.");%>)
                </div>                                                                                     
                <div class="setting">                                         
                     <div class="label"><%lang("Welcome Message");%></div>     
                      <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_page_welcome_message" name="hs_page_welcome_message" ></textarea>
                     <br/>(<%lang("0-1024 characters.");%>)
               </div>     
               <div class="setting">                                         
                     <div class="label"><%lang("Terms of Use Message");%></div>     
                      <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_page_tos_agreement" name="hs_page_tos_agreement" ></textarea>
                     <br/>(<%lang("0-512 characters.");%>)
               </div>     

                <div class="setting">
                     <div class="label"><%lang("Advertisement Content");%></div>
                         <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_page_ad_contents" name="hs_page_ad_contents"></textarea>
                     <br/>(<%lang("0-1024 characters.");%>)
                </div>
                <div class="setting">                                                     
                     <div class="label"><%lang("Footer Content");%></div>       
                      <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_page_footer_contents" name="hs_page_footer_contents" ></textarea>
                     <br/>(<%lang("0-512 characters.");%>)
               </div>                                                                                                                                        


              </fieldset> <br /> 
          <div class="submitFooter">
            <input type="button" name="save_button" value="<%lang("Save Settings");%>" 
                    onClick=to_submit(this.form) />
            <input type="reset" value="<%lang("Cancel Changes");%>" onClick="window.location.reload()" />
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
    <script type="text/javascript">create_input_window("hs_table", "hs_user_rule", 1)</script>
    <script type="text/javascript">create_return_window("hotspot.asp")</script>
  </body>
</html>
