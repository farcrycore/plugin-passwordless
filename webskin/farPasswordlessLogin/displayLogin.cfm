<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: FarCry UD login form --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<skin:loadJS id="intltelinputJS" />
<skin:loadJS id="intltelinputUtilJS" />
<skin:loadCSS id="intltelinputCSS" />


<cfset bShowForm = true>

<!--- if a token was provided process the login --->
<cfparam name="url.token" default="">
<cfif application.fapi.getConfig("passwordless", "bEnabled") AND len(url.token)>
	<cfset stResult = application.security.processLogin() />
</cfif>

<!--- process token/magic link request form --->
<cfset processPasswordlessForm(action="Log In", bWebtop=true)>


<skin:view typename="farLogin" template="displayHeaderLogin" />

<ft:form bAddFormCSS="false" class="clearfix">
	<skin:pop tags="error"><cfoutput>
		<div class="alert alert-error">
			<cfif len(trim(message.title))><strong>#message.title#</strong></cfif>
			<cfif len(trim(message.message))>#message.message#</cfif>
		</div>
	</cfoutput></skin:pop>
	<skin:pop tags="success"><cfoutput>
		<div class="alert alert-success">
			<cfif len(trim(message.title))><strong>#message.title#</strong></cfif>
			<cfif len(trim(message.message))>
				#message.message#
				<cfset bShowForm = false>
			</cfif>
		</div>
	</cfoutput></skin:pop>
	
	<cfif isdefined("arguments.stParam.message") and len(arguments.stParam.message)>
		<cfoutput><div class="alert alert-warning"><admin:resource key="security.message.#rereplace(arguments.stParam.message,'[^\w]','','ALL')#">#arguments.stParam.message#</admin:resource></div></cfoutput>
	</cfif>

	<cfif bShowForm>
		<cfoutput>
			<style>
				.intl-tel-input * {
					box-sizing: content-box;
				}
				.intl-tel-input {
					width: 100%;
				}
				.content-main form input[type="tel"] {
					font-size: 19px;
					height: 26px;
					line-height: 26px;
					margin-bottom: 20px;
					width: 87%;
					border-radius: 0;
				}
				.content-main form input[type="email"] {
					font-size: 19px;
					height: 26px;
					line-height: 26px;
					margin-bottom: 20px;
					width: 97%;
					border-radius: 0;
				}
			</style>


			<cfif application.fapi.getConfig("passwordless", "bEnabled", false) AND (application.fapi.getConfig("passwordless", "bAllowSMS", false) OR application.fapi.getConfig("passwordless", "bAllowEmail", false))>
				<p class="">
					Log in via...<br>
					<br>

					<ft:object typename="farPasswordlessLogin" lFields="mobile,email" prefix="passwordless" legend="" focusField="mobile" r_stFields="stFields" />

					<cfif application.fapi.getConfig("passwordless", "bAllowSMS", false)>
						<fieldset>
							<label for="#stFields.mobile.formfieldname#">#stFields.mobile.ftLabel#</label>
							#stFields.mobile.html#
						</fieldset>
						<br>
					</cfif>
					<cfif application.fapi.getConfig("passwordless", "bAllowSMS", false) AND application.fapi.getConfig("passwordless", "bAllowEmail", false)>
						<strong><p style="margin-top: -0.5em"><strong>or<br></strong></p>
					</cfif>
					<cfif application.fapi.getConfig("passwordless", "bAllowSMS", false)>
						<fieldset>
							<label for="#stFields.email.formfieldname#">#stFields.email.ftLabel#</label>
							#stFields.email.html#
						</fieldset>
					</cfif>
					<br>

					<div class="btn-group dropdown pull-right">
						<ft:button rendertype="button" class="btn btn-primary btn-large" rbkey="security.buttons.login" value="Log In" />
					</div><!-- /.btn-group -->

				</p>

			<cfelse>
				<p>Passwordless logins have not been enabled for the Webtop.</p>
			</cfif>


		</cfoutput>
	</cfif>

</ft:form>

<skin:view typename="farLogin" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">
