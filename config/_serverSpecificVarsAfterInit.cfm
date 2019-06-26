<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<skin:registerJS id="intltelinputJS" bCombine="false" baseHREF="/passwordless/intltelinput/js" lFiles="intlTelInput.min.js"  />
<skin:registerJS id="intltelinputUtilJS" bCombine="false" baseHREF="/passwordless/intltelinput/js" lFiles="utils.js"  />
<skin:registerCSS id="intltelinputCSS" bCombine="false" baseHREF="/passwordless/intltelinput/css" lFiles="intlTelInput.min.css" />

<!--- configure passwordless login caching in object broker --->
<cfset application.fc.lib.objectbroker.configureType(typename="farPasswordlessLogin", maxobjects=100000, timeout=application.fapi.getConfig("passwordless", "tokenTimeout", 900))>

<cfsetting enablecfoutputonly="false">