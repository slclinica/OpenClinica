<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<fmt:setBundle basename="org.akaza.openclinica.i18n.notes" var="restext"/>
<fmt:setBundle basename="org.akaza.openclinica.i18n.words" var="resword"/>

<html>
<head>
<link rel="stylesheet" href="includes/styles.css" type="text/css">
<script language="JavaScript" src="includes/global_functions_javascript.js"></script>
<style type="text/css">

.popup_BG { background-image: url(images/main_BG.gif);
  background-repeat: repeat-x;
  background-position: top;
  background-color: #FFFFFF;
  }

  td.body {
    padding: 10px 20px;
  }

  td.background {
    padding: 10px;
    background-color: #00344c;
  }

  td.background img {
    width: 150px;
  }

</style>

</head>
<body class="popup_BG">
<script language="JavaScript">
       <!--
         function leftnavExpand(strLeftNavRowElementName){

         var objLeftNavRowElement;

           objLeftNavRowElement = MM_findObj(strLeftNavRowElementName);
           if (objLeftNavRowElement != null) {
             if (objLeftNavRowElement.style) { objLeftNavRowElement = objLeftNavRowElement.style; } 
             objLeftNavRowElement.display = (objLeftNavRowElement.display == "none" ) ? "" : "none";    
           }
           }

       //-->
 </script>    
 <jsp:include page="../include/alertbox.jsp"/>
 <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
 <tr valign="top">
  <td class="background"><img src="images/logo-color-on-dark.svg"></td>  
  </tr>
 <tr valign="top"> 
 <td class="body">
     <h1><span class="title_manage"><fmt:message key="item_meta_global_att" bundle="${resword}"/></span><h1>
<div style="width: 600px">
<div class="box_T"><div class="box_L"><div class="box_R"><div class="box_B"><div class="box_TL"><div class="box_TR"><div class="box_BL"><div class="box_BR">

<div class="textbox_center" align="center">
<table border="0" cellpadding="0" cellspacing="0" width="100%">  
  <tr valign="top" ><td class="table_header_column"><fmt:message key="CRF_name" bundle="${resword}"/>:</td><td class="table_cell">  
  <c:out value="${crf.name}"/>
   </td></tr>
  <tr valign="top" ><td class="table_header_column"><fmt:message key="item_name" bundle="${resword}"/>:</td><td class="table_cell">
  <c:out value="${item.name}"/>
   </td></tr>
  <tr valign="top" ><td class="table_header_column"><fmt:message key="OID" bundle="${resword}"/>:</td><td class="table_cell">
  <c:out value="${item.oid}"/>
   </td></tr>
  <tr valign="top"><td class="table_header_column"><fmt:message key="description" bundle="${resword}"/>:</td><td class="table_cell">
  <c:out value="${item.description}"/>&nbsp;
  </td></tr> 
  <tr valign="top"><td class="table_header_column"><fmt:message key="data_type" bundle="${resword}"/>:</td><td class="table_cell">
  <c:out value="${item.dataType.name}"/>&nbsp;
  </td></tr>
</table>
</div>

</div></div></div></div></div></div></div></div>
</div>
<br>

<span class="table_title_manage"><fmt:message key="item_meta_crf_att" bundle="${resword}"/></span>
<h5>&nbsp;&nbsp;&nbsp;<fmt:message key="click_on_each_CRF_version_link" bundle="${restext}"/></h5>
<c:set var="versionCount" value="0"/>

 <c:forEach var="versionItem" items="${versionItems}">
  
  <table border="0" cellpadding="0" cellspacing="0">
   <tr>
   <td valign="top" class="leftmenu"><a href="javascript:leftnavExpand('leftnavSubRow_SubSection<c:out value="${versionCount}"/>'); 
     javascript:setImage('ExpandGroup<c:out value="${versionCount}"/>','images/bt_Collapse.gif');"><img 
       name="ExpandGroup<c:out value="${versionCount}"/>" src="images/bt_Collapse.gif" border="0"></a></td>
   <td valign="top" class="leftmenu"><a href="javascript:leftnavExpand('leftnavSubRow_SubSection<c:out value="${versionCount}"/>'); 
       javascript:setImage('ExpandGroup<c:out value="${versionCount}"/>','images/bt_Expand.gif');"><b><c:out value="${versionItem.crfName}"/>&nbsp;<c:out value="${versionItem.crfVersionName}"/></b></a>
   </td>
   </tr>  
   <tr id="leftnavSubRow_SubSection<c:out value="${versionCount}"/>" style="display: all" valign="top">
   <td colspan="2">
     <div>
         <div class="box_T"><div class="box_L"><div class="box_R"><div class="box_B"><div class="box_TL"><div class="box_TR"><div class="box_BL"><div class="box_BR">

         <div class="textbox_center">
       <table border="0" cellpadding="0" cellspacing="0">
        <tr>

         <td class="table_header_column_top"><fmt:message key="label" bundle="${resword}"/></td>
         <td class="table_header_column_top"><fmt:message key="response_type" bundle="${resword}"/></td>
           <td class="table_header_column_top"><fmt:message key="response_options" bundle="${resword}"/>/   
           <fmt:message key="response_values" bundle="${resword}"/></td>

           <td class="table_header_column_top"><fmt:message key="group_name" bundle="${resword}"/></td>

           <td class="table_header_column_top"><fmt:message key="required" bundle="${resword}"/></td>
          </tr>
          <tr valign="top">            
           <td class="table_cell"><c:out value="${versionItem.leftItemText}"/>&nbsp;</td>
           <td class="table_cell"><c:out value="${versionItem.responseSet.responseType.name}"/>&nbsp;</td>
           <td class="table_cell">
            <c:forEach var="option" items="${versionItem.responseSet.options}" varStatus="status">
                <c:out value="${option.text}"/>
            |
                <c:out value="${option.value}"/>
                <c:if test="${!status.last}">
                <br>
                </c:if>

            </c:forEach>&nbsp;
              <c:choose>
               <c:when test="${versionItem.groupLabel != 'Ungrouped'}">
                   <td class="table_cell"><c:out value="${versionItem.groupLabel}"/></td>
               </c:when>
               <c:otherwise>
                   <td class="table_cell"><c:out value=""/>&nbsp;</td>
               </c:otherwise>
               </c:choose>
           <td class="table_cell">
            <c:choose>
             <c:when test="${versionItem.required==true}">
               <fmt:message key="yes" bundle="${resword}"/> 
             </c:when> 
             <c:otherwise>
               No
             </c:otherwise> 
            </c:choose>&nbsp;
            </td> 
           </tr>          
       </table>
       </div>

         </div></div></div></div></div></div></div></div>
         </div>
    </td>
  </tr>
  
  </table>
  
  <br>
  <c:set var="versionCount" value="${versionCount+1}"/>
 </c:forEach>
 </td>
 </tr>
</table>
</body>
</html>

