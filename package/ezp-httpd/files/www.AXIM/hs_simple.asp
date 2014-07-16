
            <div class="setting">
              <div class="label"><% lang("Terms of Use"); %></div>
              <div class='radiobutton'>
                  <input type="radio" value="1" name="hs_tos_enable" onchange="onofftos()"
                   <%nvg_attr_match("hs_tos_enable","hs_tos_rule","$0","tos_enable","1","checked");%>/>
                   <%lang("Enable");%>
               
                   <input type="radio" value="0" name="hs_tos_enable" onchange="onofftos()"
                   <%nvg_attr_match("hs_tos_enable","hs_tos_rule","$0","tos_enable","0","checked");%>/>
                   <%lang("Disable");%>
               </div>
             </div>

             <div class="setting">
               <div class="label"><%lang("Terms of Use Text");%></div>
                         <textarea style="margin-left:0px;" cols="50" rows="6" id="hs_tos_text" name="hs_tos_text" ></textarea>
                    <br/>(<%lang("0-22500 characters.");%>)
             </div>
             <div class="setting">
                 <div class="label"><%lang("White List URLs");%></div>
                         <textarea style="margin-left:0px;" cols="50" rows="6" name="hs_uam_allow" onchange="valid_hotspot_contents(this,'White List URLs')"><%show_file("hs_uam_allow.txt");%></textarea>
                     <br/>(<%lang("0-512 characters.");%>)
            </div>
            <script type="text/javascript">
            	onofftos();
		document.getElementById("hs_tos_text").innerHTML = switch_to_web_form(encode64('<%show_file("hs_tos_text.txt");%>'));
                //if(document.getElementsByName("hs_enable")[1].checked == true)
                //{                                                            
                    document.getElementById("hs_tos_text").disabled = true;
                    document.getElementsByName("hs_uam_allow")[0].disabled = true;
                    document.getElementsByName("hs_tos_enable")[1].disabled = true;
                    document.getElementsByName("hs_tos_enable")[0].disabled = true;
                //}              

            </script>
            

