<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%
    response.setHeader("Cache-Control", "no-store");
    jakarta.servlet.http.HttpSession oldSession = request.getSession(false);
    if (oldSession != null) oldSession.invalidate();
    response.sendRedirect("index.jsp");
%>
