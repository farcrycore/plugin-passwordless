<cfcomponent extends="farcry.core.packages.forms.forms" displayname="Passwordless" hint="Configuration for Passwordless logins" output="true" key="passwordless">

	<cfproperty name="bEnabled" type="boolean" default="true" 
				ftSeq="1" ftFieldset="General Settings" ftLabel="Enabled" ftType="boolean"
				ftHint="Enable passwordless logins to the Webtop.">

	<!--- sms --->
	<cfproperty name="bAllowSMS" type="boolean" default="true" 
				ftSeq="10" ftFieldset="SMS Settings" ftLabel="Allow logins via SMS" ftType="boolean"
				ftHint="Enable logins to the Webtop via SMS.">

	<cfproperty name="smsSender" type="string" default="" 
				ftSeq="11" ftFieldset="SMS Settings" ftLabel="SMS Sender" ftType="string"
				ftHint="This is the name of the Sender displayed in the SMS message. <strong>Note: Letters and numbers only</strong>, no whitespace or special characters allowed.">

	<cfproperty name="smsTemplate" type="longchar" default="" 
				ftSeq="12" ftFieldset="SMS Settings" ftLabel="SMS Template"
				ftType="longchar"
				ftHint="Use the template variables <code>[token]</code>,<code>[magicLink]</code> and <code>[expires]</code> to place the token, magic link URL and expiry time (number of minutes) into the SMS message.">

	<!--- email --->
	<cfproperty name="bAllowEmail" type="boolean" default="true" 
				ftSeq="20" ftFieldset="Email Settings" ftLabel="Allow logins via Email" ftType="boolean"
				ftHint="Enable logins to the Webtop via Email.">

	<cfproperty name="emailFrom" type="string" default="" 
				ftSeq="21" ftFieldset="Email Settings" ftLabel="Email From" ftType="string"
				ftHint="This is the email address that will appear in the from: field of the email.">

	<cfproperty name="emailSubject" type="string" default="" 
				ftSeq="22" ftFieldset="Email Settings" ftLabel="Email Subject" ftType="string"
				ftHint="This is the subject: line of the email.">

	<cfproperty name="emailTemplate" type="longchar" default="" 
				ftSeq="25" ftFieldset="Email Settings" ftLabel="Email Template"
				ftType="longchar"
				ftHint="Use the template variables <code>[token]</code>,<code>[magicLink]</code> and <code>[expires]</code> to place the token, magic link URL and expiry time (number of minutes) into the SMS message.">

	<!--- security --->
	<cfproperty name="tokenLength" type="integer" default="6" 
				ftSeq="30" ftFieldset="Security" ftLabel="Token Length" ftType="integer"
				ftHint="This is the length of the token that is used in the magic URL. A length of 6 provides around 387,420,489 possible tokens.">

	<cfproperty name="tokenTimeout" type="integer" default="900" 
				ftSeq="31" ftFieldset="Security" ftLabel="Token Timeout" ftType="integer"
				ftHint="This is number of seconds that the token / magic link remains valid for, e.g. 900 seconds is 15 minutes.">

	<cfproperty name="salt" type="string" default="" 
				ftSeq="32" ftFieldset="Security" ftLabel="Salt for Hashing" ftType="string"
				ftHint="This is a salt used for hashing the cache key that is used to store the token and user data. Recommended to use a random string of 16 characters or more.">


</cfcomponent>