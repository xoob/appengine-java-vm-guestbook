<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  
  <!--
  ~ Copyright (c) 2013 Google Inc. All Rights Reserved.
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License"); you
  ~ may not use this file except in compliance with the License. You may
  ~ obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
  ~ implied. See the License for the specific language governing
  ~ permissions and limitations under the License.
  -->
  
  <%@ page contentType="text/html;charset=UTF-8" language="java" %>
  
  <%@ page import="java.util.List" %>
  <%@ page import="com.google.appengine.api.users.User" %>
  <%@ page import="com.google.appengine.api.users.UserService" %>
  <%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
  <%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
  <%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
  <%@ page import="com.google.appengine.api.datastore.Query" %>
  <%@ page import="com.google.appengine.api.datastore.Entity" %>
  <%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
  <%@ page import="com.google.appengine.api.datastore.Key" %>
  <%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
  
  <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
  
  <%
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    pageContext.setAttribute("guestbookName", guestbookName);
    
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    pageContext.setAttribute("user", user);
    
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected Guestbook.
    Query query = new Query("Greeting", guestbookKey).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(5));
  %>
  
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  
  <!-- Material Design fonts -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700" type="text/css">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  
  <!-- Bootstrap -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">

  <!-- Bootstrap Material Design -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-material-design/0.5.4/css/bootstrap-material-design.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-material-design/0.5.4/css/ripples.css" rel="stylesheet">
  
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
  
  <title>App Engine: Java Managed VM: Guestbook Demo</title>
</head>
<body>
  <div class="navbar navbar-warning">
    <div class="container-fluid">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-warning-collapse">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="javascript:void(0)">
          <strong>guest</strong>book
        </a>
      </div>
      <div class="navbar-collapse collapse navbar-warning-collapse">
        <ul class="nav navbar-nav">
          <li class="active"><a href="https://c9.io">
            powered by Cloud9 IDE</a></li>
        </ul>

        <ul class="nav navbar-nav navbar-right">
          <% if (user != null) { %>
            <li class="dropdown">
              <a href="#" data-target="#" class="dropdown-toggle" data-toggle="dropdown">
                ${fn:escapeXml(user.nickname)}
                <b class="caret"></b></a>
              <ul class="dropdown-menu">
                <li><a href="<%= userService.createLogoutURL("/guestbook.jsp") %>">
                  Sign out</a></li>
              </ul>
            </li>
          <% } else { %>
            <li><a href="<%= userService.createLoginURL("/guestbook.jsp") %>">
              Sign in</a></li>
          <% } %>
        </ul>
      </div>
    </div>
  </div>
  
  <div class="container">
    <h1 class="header">
      Guestbook Demo
    </h1>
    
    <p>
      <a href="/SystemViewer">Click to see more information regarding the running JVM...</a></p>
    
    <!-- List guestbook entries -->
    
    <div class="list-group">
      <% if (greetings.isEmpty()) { %>
        <div class="alert alert-info">
          Guestbook <strong>${fn:escapeXml(guestbookName)}</strong> is still
          empty. Why not leave a message?
        </div>
      <% } %>
      
      <%
        for (Entity greeting : greetings) {
          pageContext.setAttribute("greeting_content", greeting.getProperty("content"));
          pageContext.setAttribute("greeting_user", greeting.getProperty("user"));
      %>
        <div class="list-group-item">
          <div class="row-picture">
            <img class="circle" src="https://robohash.org/robot${fn:escapeXml(greeting_user.nickname)}.png" alt="icon">
          </div>
          <div class="row-content">
            <h4 class="list-group-item-heading">
              <% if (greeting.getProperty("user") == null) { %>
                Somebody anonymous wrote:
              <% } else { %>
                <strong>${fn:escapeXml(greeting_user.nickname)}</strong> wrote:
              <% } %>
            </h4>
            <p class="list-group-item-text">${fn:escapeXml(greeting_content)}</p>
          </div>
        </div>
        <div class="list-group-separator"></div>
      <% } %>
    </div>
  
    <!-- Guestbook form -->
    
    <div class="well bs-component">
      <form action="/sign" method="post" class="form-horizontal">
        <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
    
        <fieldset>
          <legend>Leave a message in the guestbook</legend>
          
          <div class="form-group">
            <label for="content" class="col-md-2 control-label">Message</label>
            <div class="col-md-10">
              <textarea name="content" class="form-control"></textarea>
            </div>
          </div>
          
          <div class="form-group">
              <label for="ccode" class="col-md-2 control-label">Captcha</label>
              <div class="col-md-3">
                <img src="/captcha"><br>
                <input type="text" name="ccode" class="form-control" autocomplete="off">
              </div>
          </div>
          
          <div class="form-group">
            <div class="col-md-10 col-md-offset-2">
              <button type="submit" class="btn btn-primary">Post message</button>
            </div>
          </div>
        </fieldset>
      </form>
    </div>
    
    <!-- Switch guestbook form -->
    
    <form action="/guestbook.jsp" method="get">
      <div><input type="text" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/></div>
      <div><input type="submit" value="Switch Guestbook" /></div>
    </form>
      
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.6/js/bootstrap.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-material-design/0.5.4/js/material.js"></script>
  
    <script>
      $.material.init()
    </script>
  </div>
</body>
</html>
