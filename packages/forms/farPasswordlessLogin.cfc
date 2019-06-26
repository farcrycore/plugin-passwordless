<cfcomponent displayname="Passwordless Login" hint="The Passwordless login form" extends="farcry.core.packages.forms.forms" output="false"
	fualias="passwordless">

	<cfproperty name="mobile" type="string" default="" 
				ftSeq="1" ftFieldset="" ftLabel="Mobile Number" ftType="intltel" />

	<cfproperty name="email" type="string" default="" 
				ftSeq="2" ftFieldset="" ftLabel="Email Address" ftType="email" ftPlaceholder="your@email.com" />


	<cffunction name="processPasswordlessForm" output="false" returntype="string">
		<cfargument name="action" type="string" default="">
		<cfargument name="bWebtop" type="boolean" default="false">

		<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

		<ft:processform action="#arguments.action#">
			<ft:processformobjects typename="farPasswordlessLogin" r_stProperties="stProperties">

				<!--- validate mobile --->
				<cfset hasMobile = len(trim(stProperties.mobile))>
				<cfset r = rematch("^\+[1-9]\d{1,14}$", stProperties.mobile)>
				<cfset validMobile = arrayLen(r) eq 1 AND r[1] eq stProperties.mobile>
				<cfif NOT validMobile>
					<cfset hasMobile = false>
				</cfif>

				<!--- validate email --->
				<cfset hasEmail = len(trim(stProperties.email))>
				<cfif NOT isValid("email", stProperties.email)>
					<cfset hasEmail = false>
				</cfif>

				<cfif NOT hasMobile AND NOT hasEmail>
					<!--- TODO: change string to ask for fields based on the allowed services --->
					<skin:bubble message="Please provide your mobile number or email address" tags="error" />	

				<cfelse>

					<!--- create a new session token --->
					<cfset token = createSessionToken(mobile=stProperties.mobile, email=stProperties.email)>
					<!--- set up the magic link return URL --->
					<cfset magicLink = getMagicLink(token=token, bWebtop=arguments.bWebtop)>

					<cfif hasMobile>
						<!--- send SMS --->
						<cfset result = sendSMS(mobile=stProperties.mobile, token=token, magicLink=magicLink)>
						<cfif structKeyExists(result, "statusCode") AND result.statusCode eq "200">
							<skin:bubble message="A magic link to log in has been sent to you via SMS" tags="success" />
						<cfelse>
							<skin:bubble message="There was a problem sending your magic link via SMS" tags="error" />
							<cflog file="passwordless" text="processPasswordlessForm error: #serializeJSON(result)#">
						</cfif>

						<skin:location url="#application.fapi.fixURL(removevalues="token")#" />

					<cfelseif hasEmail>
						<!--- send email --->
						<cfset sendEmail(email=stProperties.email, token=token, magicLink=magicLink)>

						<skin:bubble message="A magic link to log in has been sent to you via Email" tags="success" />	
						<skin:location url="#application.fapi.fixURL(removevalues="token")#" />

					</cfif>

				</cfif>

			</ft:processformobjects>
		</ft:processform>

	</cffunction>


	<cffunction name="createSessionToken" output="false" returntype="string">
		<cfargument name="mobile" type="string" default="">
		<cfargument name="email" type="string" default="">

		<cfset var token = application.security.userdirectories.passwordlessUD.createSessionToken(argumentCollection=arguments)>

		<cfreturn token>
	</cffunction>

	<cffunction name="lookupSessionToken" output="false" returntype="struct">
		<cfargument name="token" type="string" required="true">

		<cfset var stResult = application.security.userdirectories.passwordlessUD.lookupSessionToken(argumentCollection=arguments)>

		<cfreturn stResult>
	</cffunction>


	<cffunction name="getMagicLink" output="false" returntype="string">
		<cfargument name="token" type="string" required="true">
		<cfargument name="bWebtop" type="boolean" required="false" default="false">

		<cfset var magicLink = "">

		<cfif arguments.bWebtop>
			<cfset magicLink = "#application.fc.lib.seo.getCanonicalProtocol()#://#cgi.http_host##application.url.webtop#/login.cfm?ud=passwordlessUD&token=#arguments.token#">
		<cfelse>
			<cfset magicLink = "#application.fc.lib.seo.getCanonicalProtocol()#://#cgi.http_host#/passwordless/login?token=#arguments.token#">
		</cfif>

		<cfreturn magicLink>
	</cffunction>


	<cffunction name="getSMSMessageText" output="false" returntype="string">
		<cfargument name="token" type="string" required="true">
		<cfargument name="magicLink" type="string" required="true">

		<cfset var text = application.fapi.getConfig("passwordless", "smsTemplate", "")>
		<cfif NOT len(trim(text))>
			<cfset text = "Your login token is [token]

Alternatively, click the magic link to log in:
[magicLink]

(This login will expire in [expires] minutes)
">	
		</cfif>

		<cfset text = replaceNoCase(text, "[token]", arguments.token, "all")>
		<cfset text = replaceNoCase(text, "[magicLink]", arguments.magicLink, "all")>
		<cfset text = replaceNoCase(text, "[expires]", int(application.fapi.getConfig("passwordless", "tokenTimeout", 900) / 60), "all")>

		<cfreturn text>
	</cffunction>

	<cffunction name="sendSMS" output="false" returntype="struct">
		<cfargument name="mobile" type="string" required="true">
		<cfargument name="token" type="string" required="true">
		<cfargument name="magicLink" type="string" required="true">

		<cfset var message = getSMSMessageText(token=arguments.token, magicLink=arguments.magicLink)>

		<cfset var result = application.fc.lib.aws.client.sns.publish(
			Message=message,
			MessageAttributes={
				"AWS.SNS.SMS.SenderID": application.fapi.getConfig("passwordless", "smsSender", ""),
				"AWS.SNS.SMS.SMSType": "Transactional"
			},
			PhoneNumber=arguments.mobile
		)>

		<cfreturn result>
	</cffunction>


	<cffunction name="sendEmail" output="false">
		<cfargument name="email" type="string" required="true">
		<cfargument name="token" type="string" required="true">

		<cfset var message = getEmailMessageText(token=arguments.token, magicLink=arguments.magicLink)>

		<cfset application.fc.lib.email.send(
			to=arguments.email,
			from=application.fapi.getConfig("passwordless", "emailFrom", ""),
			subject=application.fapi.getConfig("passwordless", "emailSubject", ""),
			bodyHTML=message
		)>

	</cffunction>

	<cffunction name="getEmailMessageText" output="false" returntype="string">
		<cfargument name="token" type="string" required="true">
		<cfargument name="magicLink" type="string" required="true">

		<cfset var text = application.fapi.getConfig("passwordless", "emailTemplate", "")>
		<cfif NOT len(trim(text))>
			<cfset text = "Your login token is [token]<br>
<br>
Alternatively, click the magic link to log in:<br>
<a href=""[magicLink]"">[magicLink]</a><br>
<br>
(This login will expire in [expires] minutes)<br>
">	
		</cfif>

		<cfset text = replaceNoCase(text, "[token]", arguments.token, "all")>
		<cfset text = replaceNoCase(text, "[magicLink]", arguments.magicLink, "all")>
		<cfset text = replaceNoCase(text, "[expires]", int(application.fapi.getConfig("passwordless", "tokenTimeout", 900) / 60), "all")>

		<cfreturn text>
	</cffunction>

</cfcomponent>